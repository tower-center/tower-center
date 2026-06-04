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

  /// 刪除機身 (Delete) - 物理刪除改為呼叫軟刪除以防關聯遺失
  Future<void> deleteDrone(String documentId) async {
    await softDeleteDrone(documentId);
  }

  /// 軟刪除機身 (Soft Delete)
  Future<void> softDeleteDrone(String documentId) async {
    final batch = _firestore.batch();
    final droneRef = _firestore.collection('drones').doc(documentId);
    
    // 1. 取得飛機詳情
    final doc = await droneRef.get();
    if (doc.exists && doc.data() != null) {
      final drone = Drone.fromJson(doc.data()!);
      final packageId = drone.currentPackageId;
      
      // 2. 如果已綁定套裝，解綁套裝上的飛機 SN
      if (packageId != null && packageId.isNotEmpty) {
        final pkgRef = _firestore.collection('drone_packages').doc(packageId);
        batch.update(pkgRef, {'currentDroneSn': null});
      }
    }
    
    // 3. 標記軟刪除，並解綁套裝 ID
    batch.update(droneRef, {
      'isDeleted': true,
      'currentPackageId': null,
    });
    
    await batch.commit();
  }

  /// 軟刪除遙控器 (Soft Delete)
  Future<void> softDeleteRemoteController(String documentId) async {
    final batch = _firestore.batch();
    final rcRef = _firestore.collection('remote_controllers').doc(documentId);
    
    // 1. 取得遙控器詳情
    final doc = await rcRef.get();
    if (doc.exists && doc.data() != null) {
      final rc = RemoteController.fromJson(doc.data()!);
      final packageId = rc.currentPackageId;
      
      // 2. 如果已綁定套裝，解綁套裝上的遙控器 SN
      if (packageId != null && packageId.isNotEmpty) {
        final pkgRef = _firestore.collection('drone_packages').doc(packageId);
        batch.update(pkgRef, {'currentRcSn': null});
      }
    }
    
    // 3. 標記軟刪除，並解綁套裝 ID
    batch.update(rcRef, {
      'isDeleted': true,
      'currentPackageId': null,
    });
    
    await batch.commit();
  }

  /// 軟刪除電池 (Soft Delete)
  Future<void> softDeleteBattery(String documentId) async {
    final docRef = _firestore.collection('batteries').doc(documentId);
    await docRef.update({
      'isDeleted': true,
      'currentPackageId': null,
    });
  }

  /// 監聽機身清單即時變更 (Stream)
  Stream<List<Drone>> getDronesStream() {
    return _firestore.collection('drones').snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => Drone.fromJson(doc.data()))
          .where((drone) => drone.isDeleted != true)
          .toList();
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
    final batch = _firestore.batch();

    // 1. 取得套裝詳情以確認綁定的飛機和遙控器
    final pkgDoc = await _firestore.collection('drone_packages').doc(documentId).get();
    if (!pkgDoc.exists) return;
    
    final data = pkgDoc.data();
    if (data != null) {
      final droneSn = data['currentDroneSn'] as String?;
      final rcSn = data['currentRcSn'] as String?;
      final tacticalName = data['tacticalName'] as String? ?? documentId;

      // 2. 解綁飛機
      if (droneSn != null && droneSn.isNotEmpty) {
        final droneRef = _firestore.collection('drones').doc(droneSn);
        batch.update(droneRef, {'currentPackageId': null});
      }

      // 3. 解綁遙控器
      if (rcSn != null && rcSn.isNotEmpty) {
        final rcRef = _firestore.collection('remote_controllers').doc(rcSn);
        batch.update(rcRef, {'currentPackageId': null});
      }

      // 4. 解綁電池
      final batteriesSnapshot = await _firestore
          .collection('batteries')
          .where('currentPackageId', isEqualTo: documentId)
          .get();
      for (final doc in batteriesSnapshot.docs) {
        batch.update(doc.reference, {'currentPackageId': null});
      }

      // 5. 寫入刪除與歸還庫存的 ActionLog
      final logId = DateTime.now().millisecondsSinceEpoch.toString();
      final logRef = _firestore.collection('action_logs').doc(logId);
      final newLog = ActionLog(
        documentId: logId,
        packageId: documentId,
        eventType: 'package_delete',
        description: '❌ 刪除便攜盒 「$tacticalName」，其中綁定的設備與電池已全部解除綁定並回歸庫存。',
        timestamp: DateTime.now(),
        aiTags: ['刪除便攜盒', '回歸庫存'],
      );
      batch.set(logRef, newLog.toJson());
    }

    // 6. 刪除便攜盒本身
    batch.delete(_firestore.collection('drone_packages').doc(documentId));

    // 提交 Batch 交易
    await batch.commit();
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
    String? serialNumber,
    required String rcType,
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
        serialNumber: serialNumber,
        rcType: rcType,
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
      return snapshot.docs
          .map((doc) => Battery.fromJson(doc.data()))
          .where((battery) => battery.isDeleted != true)
          .toList();
    });
  }

  Future<List<Battery>> getUnassignedBatteries() async {
    final snapshot = await _firestore
        .collection('batteries')
        .where('currentPackageId', isNull: true)
        .get();
    return snapshot.docs
        .map((doc) => Battery.fromJson(doc.data()))
        .where((battery) => battery.isDeleted != true)
        .toList();
  }

  Stream<List<Battery>> getPackageBatteriesStream(String packageId) {
    return _firestore
        .collection('batteries')
        .where('currentPackageId', isEqualTo: packageId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Battery.fromJson(doc.data()))
          .where((battery) => battery.isDeleted != true)
          .toList();
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

  // ==========================================
  // 庫存 (未分配物資) Streams
  // ==========================================

  /// 監聽未分配（在庫存中）的飛機
  Stream<List<Drone>> getUnassignedDronesStream() {
    return _firestore
        .collection('drones')
        .where('currentPackageId', isNull: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Drone.fromJson(doc.data()))
          .where((drone) => drone.isDeleted != true)
          .toList();
    });
  }

  /// 監聽未分配（在庫存中）的遙控器
  Stream<List<RemoteController>> getUnassignedRemoteControllersStream() {
    return _firestore
        .collection('remote_controllers')
        .where('currentPackageId', isNull: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => RemoteController.fromJson(doc.data()))
          .where((rc) => rc.isDeleted != true)
          .toList();
    });
  }

  /// 監聽未分配（在庫存中）的電池
  Stream<List<Battery>> getUnassignedBatteriesStream() {
    return _firestore
        .collection('batteries')
        .where('currentPackageId', isNull: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Battery.fromJson(doc.data()))
          .where((battery) => battery.isDeleted != true)
          .toList();
    });
  }

  /// 監聽特定飛機的即時變更
  Stream<Drone?> getDroneStream(String documentId) {
    return _firestore
        .collection('drones')
        .doc(documentId)
        .snapshots()
        .map((snapshot) {
      if (snapshot.exists && snapshot.data() != null) {
        return Drone.fromJson(snapshot.data()!);
      }
      return null;
    });
  }

  /// 監聽特定遙控器的即時變更
  Stream<RemoteController?> getRemoteControllerStream(String documentId) {
    return _firestore
        .collection('remote_controllers')
        .doc(documentId)
        .snapshots()
        .map((snapshot) {
      if (snapshot.exists && snapshot.data() != null) {
        return RemoteController.fromJson(snapshot.data()!);
      }
      return null;
    });
  }

  /// 監聽特定電池的即時變更
  Stream<Battery?> getBatteryStream(String documentId) {
    return _firestore
        .collection('batteries')
        .doc(documentId)
        .snapshots()
        .map((snapshot) {
      if (snapshot.exists && snapshot.data() != null) {
        return Battery.fromJson(snapshot.data()!);
      }
      return null;
    });
  }
}
