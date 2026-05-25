import 'package:freezed_annotation/freezed_annotation.dart';

part 'accessory_def.freezed.dart';
part 'accessory_def.g.dart';

/// 飛機配件定義 (Accessory Definition)
@freezed
abstract class AccessoryDef with _$AccessoryDef {
  const factory AccessoryDef({
    /// 配件 ID (UUID)
    required String documentId,
    
    /// 配件名稱 (如 Mavic 3 充電管家)
    required String name,
    
    /// 所屬出廠機型 (對應 AircraftModel.name)
    required String aircraftModelName,
    
    /// 是否啟用
    @Default(true) bool isActive,
    
    /// 建立時間
    required DateTime createdAt,
  }) = _AccessoryDef;

  factory AccessoryDef.fromJson(Map<String, dynamic> json) => _$AccessoryDefFromJson(json);
}
