import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/drone.dart';
import '../models/action_log.dart';
import '../models/battery.dart';
import '../models/remote_controller.dart';
import '../models/drone_package.dart';

/// 機隊管理系統 - Firestore 資料庫存取層示範
class FleetRepository {
  final FirebaseFirestore _firestore;

  FleetRepository({FirebaseFirestore? firestore}) 
      : _firestore = firestore ?? FirebaseFirestore.instance;

  // ==========================================
  // Drone (機身) CRUD 基礎示範
  // ==========================================

  /// 新增機身 (Create)
  Future<void> addDrone(Drone drone) async {
    await _firestore
        .collection('drones')
        .doc(drone.documentId)
        .set(drone.toJson());
  }

  /// 讀取機身 (Read)
  Future<Drone?> getDrone(String documentId) async {
    final doc = await _firestore.collection('drones').doc(documentId).get();
    if (doc.exists && doc.data() != null) {
      return Drone.fromJson(doc.data()!);
    }
    return null;
  }

  /// 更新機身 (Update)
  Future<void> updateDrone(Drone drone) async {
    await _firestore
        .collection('drones')
        .doc(drone.documentId)
        .update(drone.toJson());
  }

  /// 刪除機身 (Delete)
  Future<void> deleteDrone(String documentId) async {
    await _firestore.collection('drones').doc(documentId).delete();
  }

  /// 監聽機身清單即時變更 (Stream)
  Stream<List<Drone>> getDronesStream() {
    return _firestore.collection('drones').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Drone.fromJson(doc.data())).toList();
    });
  }

  // ==========================================
  // DronePackage (套裝) CRUD
  // ==========================================

  Future<void> addPackage(DronePackage package) async {
    await _firestore
        .collection('drone_packages')
        .doc(package.documentId)
        .set(package.toJson());
  }

  Future<DronePackage?> getPackage(String documentId) async {
    final doc = await _firestore.collection('drone_packages').doc(documentId).get();
    if (doc.exists && doc.data() != null) {
      return DronePackage.fromJson(doc.data()!);
    }
    return null;
  }

  Future<void> updatePackage(DronePackage package) async {
    await _firestore
        .collection('drone_packages')
        .doc(package.documentId)
        .update(package.toJson());
  }

  Future<void> deletePackage(String documentId) async {
    await _firestore.collection('drone_packages').doc(documentId).delete();
  }

  Stream<List<DronePackage>> getPackagesStream() {
    return _firestore.collection('drone_packages').orderBy('createdAt', descending: true).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => DronePackage.fromJson(doc.data())).toList();
    });
  }

  // ==========================================
  // RemoteController (遙控器) 特殊操作
  // ==========================================

  /// 配對遙控器與套裝
  /// 若遙控器不存在則自動建立，並將 currentPackageId 指向當前套裝
  Future<void> pairRemoteController({
    required String rcSn,
    required String packageId,
  }) async {
    final docRef = _firestore.collection('remote_controllers').doc(rcSn);
    final doc = await docRef.get();

    if (doc.exists) {
      await docRef.update({
        'currentPackageId': packageId,
      });
    } else {
      final newRc = RemoteController(
        documentId: rcSn,
        rcType: '標準版遙控器',
        currentPackageId: packageId,
      );
      await docRef.set(newRc.toJson());
    }
  }

  /// 解除遙控器綁定
  Future<void> unpairRemoteController(String rcSn) async {
    await _firestore.collection('remote_controllers').doc(rcSn).update({
      'currentPackageId': FieldValue.delete(),
    });
  }

  // ==========================================
  // Battery (電池) 批量處理
  // ==========================================

  Future<void> addBattery(Battery battery) async {
    await _firestore
        .collection('batteries')
        .doc(battery.documentId)
        .set(battery.toJson());
  }

  Future<void> updateBattery(Battery battery) async {
    await _firestore
        .collection('batteries')
        .doc(battery.documentId)
        .update(battery.toJson());
  }

  Stream<List<Battery>> getBatteriesStream() {
    return _firestore.collection('batteries').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Battery.fromJson(doc.data())).toList();
    });
  }

  Future<List<Battery>> getUnassignedBatteries() async {
    final snapshot = await _firestore
        .collection('batteries')
        .where('currentPackageId', isNull: true)
        .get();
    return snapshot.docs.map((doc) => Battery.fromJson(doc.data())).toList();
  }

  Stream<List<Battery>> getPackageBatteriesStream(String packageId) {
    return _firestore
        .collection('batteries')
        .where('currentPackageId', isEqualTo: packageId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Battery.fromJson(doc.data())).toList();
    });
  }

  // ==========================================
  // ActionLog (動態時間軸) 特殊查詢示範
  // ==========================================

  Stream<List<ActionLog>> getAllActionLogsStream() {
    return _firestore
        .collection('action_logs')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => ActionLog.fromJson(doc.data())).toList();
    });
  }

  Future<void> addDroneActionLog(ActionLog log) async {
    await addActionLog(log);
  }

  Future<void> addActionLog(ActionLog log) async {
    await _firestore
        .collection('action_logs')
        .doc(log.documentId)
        .set(log.toJson());
  }

  /// 查詢特定套裝的軌跡紀錄 (依時間排序)
  Future<List<ActionLog>> getPackageActionLogs(String packageId) async {
    final snapshot = await _firestore
        .collection('action_logs')
        .where('packageId', isEqualTo: packageId)
        .orderBy('timestamp', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => ActionLog.fromJson(doc.data()))
        .toList();
  }
}
