import 'package:freezed_annotation/freezed_annotation.dart';

part 'drone.freezed.dart';
part 'drone.g.dart';

/// 機身實體 (Drone)
@freezed
abstract class Drone with _$Drone {
  const factory Drone({
    /// 機身序號 (作為 Document ID，若無序號則使用隨機 ID)
    required String documentId,
    
    /// 實際機身出廠序號 (可選)
    String? serialNumber,
    
    /// 出廠機型
    required String modelType,
    
    /// 目前綁定的套裝 ID (可為 null，代表在庫存中)
    String? currentPackageId,
    
    /// 機身狀態 (如 正常、維修中、已報廢/遺失)
    @Default('正常') String status,
    
    /// 保險/註冊到期日
    DateTime? insuranceExpiry,
  }) = _Drone;

  factory Drone.fromJson(Map<String, dynamic> json) => _$DroneFromJson(json);
}
