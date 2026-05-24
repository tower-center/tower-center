import 'package:freezed_annotation/freezed_annotation.dart';

part 'drone.freezed.dart';
part 'drone.g.dart';

/// 機身實體 (Drone)
@freezed
abstract class Drone with _$Drone {
  const factory Drone({
    /// 機身序號 (作為 Document ID)
    required String documentId,
    
    /// 出廠機型
    required String modelType,
    
    /// 目前戰術編號
    required String currentName,
    
    /// 目前保管人
    required String currentKeeper,
    
    /// 保險/註冊到期日
    DateTime? insuranceExpiry,
  }) = _Drone;

  factory Drone.fromJson(Map<String, dynamic> json) => _$DroneFromJson(json);
}
