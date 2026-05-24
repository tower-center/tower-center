import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/aircraft_model.dart';
import '../models/drone_operator.dart';
import '../models/system_dictionary.dart';

/// 後台基礎資料管理 (機型、空拍手、字典選項) - Firestore 資料庫存取層
class AdminRepository {
  final FirebaseFirestore _firestore;

  AdminRepository({FirebaseFirestore? firestore}) 
      : _firestore = firestore ?? FirebaseFirestore.instance;

  // ==========================================
  // 1. 機型 (AircraftModel) CRUD
  // ==========================================

  /// 監聽所有機型變更 (Stream) - 最新建立的在最前面
  Stream<List<AircraftModel>> getAircraftModelsStream() {
    return _firestore
        .collection('aircraft_models')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => AircraftModel.fromJson(doc.data())).toList();
    });
  }

  /// 監聽已啟用的機型變更 (Stream) - 最新建立的在最前面 (用於前台下拉選單)
  Stream<List<AircraftModel>> getActiveAircraftModelsStream() {
    return _firestore
        .collection('aircraft_models')
        .where('isActive', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      // 由於 Firestore 無法在使用 where 過濾後在無複合索引下直接排序，
      // 但我們可以用單一欄位 orderBy(createdAt)，以防萬一，先在本地再做一次確保
      final list = snapshot.docs.map((doc) => AircraftModel.fromJson(doc.data())).toList();
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    });
  }

  /// 新增機型
  Future<void> addAircraftModel(AircraftModel model) async {
    await _firestore
        .collection('aircraft_models')
        .doc(model.documentId)
        .set(model.toJson());
  }

  /// 更新機型 (含修改內容或變更啟用狀態)
  Future<void> updateAircraftModel(AircraftModel model) async {
    await _firestore
        .collection('aircraft_models')
        .doc(model.documentId)
        .update(model.toJson());
  }

  // ==========================================
  // 2. 空拍手/保管人 (DroneOperator) CRUD
  // ==========================================

  /// 監聽所有空拍手變更 (Stream) - 最新建立的在最前面
  Stream<List<DroneOperator>> getDroneOperatorsStream() {
    return _firestore
        .collection('drone_operators')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => DroneOperator.fromJson(doc.data())).toList();
    });
  }

  /// 監聽已啟用的空拍手變更 (Stream) - 最新建立的在最前面 (用於前台下拉選單)
  Stream<List<DroneOperator>> getActiveDroneOperatorsStream() {
    return _firestore
        .collection('drone_operators')
        .where('isActive', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      final list = snapshot.docs.map((doc) => DroneOperator.fromJson(doc.data())).toList();
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    });
  }

  /// 新增空拍手
  Future<void> addDroneOperator(DroneOperator operator) async {
    await _firestore
        .collection('drone_operators')
        .doc(operator.documentId)
        .set(operator.toJson());
  }

  /// 更新空拍手
  Future<void> updateDroneOperator(DroneOperator operator) async {
    await _firestore
        .collection('drone_operators')
        .doc(operator.documentId)
        .update(operator.toJson());
  }

  // ==========================================
  // 3. 系統字典表 (SystemDictionary) CRUD
  // ==========================================

  /// 監聽特定類別之所有字典變更 (Stream) - 最新建立的在最前面
  Stream<List<SystemDictionary>> getSystemDictionariesStream(String category) {
    return _firestore
        .collection('system_dictionaries')
        .where('category', isEqualTo: category)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => SystemDictionary.fromJson(doc.data())).toList();
    });
  }

  /// 監聽特定類別之已啟用字典變更 (Stream) - 最新建立的在最前面 (用於前台下拉選單)
  Stream<List<SystemDictionary>> getActiveSystemDictionariesStream(String category) {
    return _firestore
        .collection('system_dictionaries')
        .where('category', isEqualTo: category)
        .where('isActive', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      final list = snapshot.docs.map((doc) => SystemDictionary.fromJson(doc.data())).toList();
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    });
  }

  /// 新增字典選項
  Future<void> addSystemDictionary(SystemDictionary dictionary) async {
    await _firestore
        .collection('system_dictionaries')
        .doc(dictionary.documentId)
        .set(dictionary.toJson());
  }

  /// 更新字典選項
  Future<void> updateSystemDictionary(SystemDictionary dictionary) async {
    await _firestore
        .collection('system_dictionaries')
        .doc(dictionary.documentId)
        .update(dictionary.toJson());
  }

  // ==========================================
  // 4. 物理刪除方法 (Delete)
  // ==========================================

  /// 永久刪除機型
  Future<void> deleteAircraftModel(String documentId) async {
    await _firestore.collection('aircraft_models').doc(documentId).delete();
  }

  /// 永久刪除空拍手
  Future<void> deleteDroneOperator(String documentId) async {
    await _firestore.collection('drone_operators').doc(documentId).delete();
  }

  /// 永久刪除字典選項
  Future<void> deleteSystemDictionary(String documentId) async {
    await _firestore.collection('system_dictionaries').doc(documentId).delete();
  }
}
