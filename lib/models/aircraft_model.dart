import 'package:freezed_annotation/freezed_annotation.dart';

part 'aircraft_model.freezed.dart';
part 'aircraft_model.g.dart';

/// 出廠機型 (Aircraft Model)
@freezed
abstract class AircraftModel with _$AircraftModel {
  const factory AircraftModel({
    /// 文件 ID (如隨機產生的 UUID)
    required String documentId,
    
    /// 機型名稱 (如 DJI Mavic 3 Pro)
    required String name,
    
    /// 製造商 (如 DJI)
    required String manufacturer,
    
    /// 建立時間 (用於最新優先排序)
    required DateTime createdAt,
    
    /// 是否啟用
    @Default(true) bool isActive,
    
    /// 自訂擴充欄位 (Key: 欄位名稱, Value: 欄位內容)
    @Default({}) Map<String, String> customFields,
  }) = _AircraftModel;

  factory AircraftModel.fromJson(Map<String, dynamic> json) => _$AircraftModelFromJson(json);
}
