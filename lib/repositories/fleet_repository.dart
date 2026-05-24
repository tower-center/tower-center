import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/drone.dart';
import '../models/action_log.dart';
import '../models/battery.dart';
import '../models/remote_controller.dart';

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
  // RemoteController (遙控器) 特殊操作
  // ==========================================

  /// 配對遙控器與機身
  /// 若遙控器不存在則自動建立，並將 currentPairedDroneSn 指向當前機身
  Future<void> pairRemoteController({
    required String rcSn,
    required String droneSn,
  }) async {
    final docRef = _firestore.collection('remote_controllers').doc(rcSn);
    final doc = await docRef.get();

    if (doc.exists) {
      // 遙控器已存在，更新配對機身欄位
      await docRef.update({
        'currentPairedDroneSn': droneSn,
      });
    } else {
      // 遙控器不存在，以防呆機制預設屬性建立新實體
      final newRc = RemoteController(
        documentId: rcSn,
        rcType: '標準版遙控器',
        currentKeeper: '待分配保管人',
        currentPairedDroneSn: droneSn,
      );
      await docRef.set(newRc.toJson());
    }
  }

  // ==========================================
  // Battery (電池) 批量處理
  // ==========================================

  /// 新增單筆電池實體
  Future<void> addBattery(Battery battery) async {
    await _firestore
        .collection('batteries')
        .doc(battery.documentId)
        .set(battery.toJson());
  }

  /// 更新電池實體 (修改 TagName 或 SN 等)
  Future<void> updateBattery(Battery battery) async {
    await _firestore
        .collection('batteries')
        .doc(battery.documentId)
        .update(battery.toJson());
  }

  /// 監聽所有電池清單即時變更 (Stream)
  Stream<List<Battery>> getBatteriesStream() {
    return _firestore.collection('batteries').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Battery.fromJson(doc.data())).toList();
    });
  }

  /// 監聽特定機身目前掛載的電池清單 (Stream)
  Stream<List<Battery>> getDroneBatteriesStream(String droneSn) {
    return _firestore
        .collection('batteries')
        .where('currentDroneSn', isEqualTo: droneSn)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Battery.fromJson(doc.data())).toList();
    });
  }

  // ==========================================
  // ActionLog (動態時間軸) 特殊查詢示範
  // ==========================================

  /// 監聽所有事件紀錄即時變更 (Stream)
  Stream<List<ActionLog>> getAllActionLogsStream() {
    return _firestore
        .collection('action_logs')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => ActionLog.fromJson(doc.data())).toList();
    });
  }

  /// 新增事件紀錄 (符合 addDroneActionLog 規範)
  Future<void> addDroneActionLog(ActionLog log) async {
    await addActionLog(log);
  }

  /// 新增事件紀錄
  Future<void> addActionLog(ActionLog log) async {
    await _firestore
        .collection('action_logs')
        .doc(log.documentId)
        .set(log.toJson());
  }

  /// 查詢特定機身的軌跡紀錄 (依時間排序)
  /// 示範：如何查詢 ActionLog 裡的特定機身軌跡
  Future<List<ActionLog>> getDroneActionLogs(String droneSn) async {
    final snapshot = await _firestore
        .collection('action_logs')
        .where('droneSn', isEqualTo: droneSn)
        .orderBy('timestamp', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => ActionLog.fromJson(doc.data()))
        .toList();
  }
}
