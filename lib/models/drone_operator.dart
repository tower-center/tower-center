import 'package:freezed_annotation/freezed_annotation.dart';

part 'drone_operator.freezed.dart';
part 'drone_operator.g.dart';

/// 空拍手/保管人實體 (Drone Operator)
@freezed
abstract class DroneOperator with _$DroneOperator {
  const factory DroneOperator({
    /// 文件 ID (如隨機產生的 UUID)
    required String documentId,
    
    /// 空拍手姓名
    required String name,
    
    /// 聯絡電話
    required String phone,
    
    /// 證照號碼
    required String licenseNumber,
    
    /// 建立時間 (用於最新優先排序)
    required DateTime createdAt,
    
    /// 是否啟用
    @Default(true) bool isActive,
    
    /// 自訂擴充欄位 (Key: 欄位名稱, Value: 欄位內容)
    @Default({}) Map<String, String> customFields,
  }) = _DroneOperator;

  factory DroneOperator.fromJson(Map<String, dynamic> json) => _$DroneOperatorFromJson(json);
}
