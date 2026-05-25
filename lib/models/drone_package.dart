import 'package:freezed_annotation/freezed_annotation.dart';

part 'drone_package.freezed.dart';
part 'drone_package.g.dart';

/// 套裝 (Drone Package) - 作為資源調度的核心邏輯單位
@freezed
abstract class DronePackage with _$DronePackage {
  const factory DronePackage({
    /// 套裝 ID (UUID)
    required String documentId,
    
    /// 戰術編號 (如 Mavic 3 - A)
    required String tacticalName,
    
    /// 出廠機型 (如 DJI Mavic 3)
    required String modelType,
    
    /// 目前保管人
    required String currentKeeper,
    
    /// 配件清單 (Key: 配件名稱, Value: 數量)
    @Default({}) Map<String, int> accessories,
    
    /// 目前綁定的母艦機身 SN (可為 null，代表目前無飛機或送修中)
    String? currentDroneSn,
    
    /// 目前綁定的遙控器 SN (可為 null)
    String? currentRcSn,
    
    /// 建立時間
    required DateTime createdAt,
  }) = _DronePackage;

  factory DronePackage.fromJson(Map<String, dynamic> json) => _$DronePackageFromJson(json);
}
