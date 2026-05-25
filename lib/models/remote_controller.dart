import 'package:freezed_annotation/freezed_annotation.dart';

part 'remote_controller.freezed.dart';
part 'remote_controller.g.dart';

/// 遙控器實體 (RemoteController)
@freezed
abstract class RemoteController with _$RemoteController {
  const factory RemoteController({
    /// 遙控器系統 ID (作為 Document ID)
    required String documentId,
    
    /// 實際遙控器序號 (可選)
    String? serialNumber,
    
    /// 遙控器類型
    required String rcType,
    
    /// 目前綁定的套裝 ID (可為 null，代表在庫存中)
    String? currentPackageId,
    
    /// 遙控器狀態 (如 正常、維修中、已報廢/遺失)
    @Default('正常') String status,
  }) = _RemoteController;

  factory RemoteController.fromJson(Map<String, dynamic> json) => _$RemoteControllerFromJson(json);
}
