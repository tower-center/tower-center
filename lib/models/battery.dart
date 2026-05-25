import 'package:freezed_annotation/freezed_annotation.dart';

part 'battery.freezed.dart';
part 'battery.g.dart';

String _readTagName(Map json, String key) {
  return json['tagName'] as String? ?? json['documentId'] as String? ?? '未命名標籤';
}

/// 電池實體 (Battery)
@freezed
abstract class Battery with _$Battery {
  const factory Battery({
    /// 系統內部 UUID (作為 Document ID)
    required String documentId,
    
    /// 電池出廠序號 (唯一不可變的硬體 SN)
    String? serialNumber,
    
    /// 外場標籤名稱 (可變動，如 M301, P01)
    @JsonKey(readValue: _readTagName)
    required String tagName,
    
    /// 電池型號
    required String batteryModel,
    
    /// 採購日期
    DateTime? purchaseDate,
    
    /// 循環次數
    required int cycleCount,
    
    /// 膨脹狀態 / 健康狀態
    required String healthStatus,
    
    /// 目前配置套裝 ID (可為 null，代表在庫存中)
    String? currentPackageId,
  }) = _Battery;

  factory Battery.fromJson(Map<String, dynamic> json) => _$BatteryFromJson(json);
}
