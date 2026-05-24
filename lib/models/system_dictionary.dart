import 'package:freezed_annotation/freezed_annotation.dart';

part 'system_dictionary.freezed.dart';
part 'system_dictionary.g.dart';

/// 系統字典表實體 (System Dictionary)
@freezed
abstract class SystemDictionary with _$SystemDictionary {
  const factory SystemDictionary({
    /// 文件 ID (如隨機產生的 UUID)
    required String documentId,
    
    /// 字典類別 (例如 'tactical_name' 戰術編號, 'project_status' 專案狀態)
    required String category,
    
    /// 前台顯示的文字標籤 (例如 '雷霆-01')
    required String label,
    
    /// 後台或系統內部儲存的值 (例如 'thunder-01')
    required String value,
    
    /// 建立時間 (用於排序，保證最新建立在選單最前面)
    required DateTime createdAt,
    
    /// 排序權重 (可選手動排序)
    @Default(0) int sortOrder,
    
    /// 是否啟用
    @Default(true) bool isActive,
  }) = _SystemDictionary;

  factory SystemDictionary.fromJson(Map<String, dynamic> json) => _$SystemDictionaryFromJson(json);
}
