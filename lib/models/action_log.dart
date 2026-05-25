import 'package:freezed_annotation/freezed_annotation.dart';

part 'action_log.freezed.dart';
part 'action_log.g.dart';

/// 動態時間軸/事件紀錄實體 (ActionLog)
@freezed
abstract class ActionLog with _$ActionLog {
  const factory ActionLog({
    /// 事件 UUID (作為 Document ID)
    required String documentId,
    
    /// 發生時間
    required DateTime timestamp,
    
    /// 事件類型 (例如：crash, repair, battery_transfer, health_check)
    required String eventType,
    
    /// 關聯套裝 ID
    String? packageId,
    
    /// 關聯機身序號
    String? droneSn,
    
    /// 關聯遙控器序號
    String? rcSn,
    
    /// 關聯電池序號
    String? batterySn,
    
    /// 事件詳述
    required String description,
    
    /// 維修花費或相關成本
    @Default(0.0) double cost,
    
    /// AI 分析標籤
    @Default([]) List<String> aiTags,
  }) = _ActionLog;

  factory ActionLog.fromJson(Map<String, dynamic> json) => _$ActionLogFromJson(json);
}
