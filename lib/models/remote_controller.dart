import 'package:freezed_annotation/freezed_annotation.dart';

part 'remote_controller.freezed.dart';
part 'remote_controller.g.dart';

/// 遙控器實體 (RemoteController)
@freezed
abstract class RemoteController with _$RemoteController {
  const factory RemoteController({
    /// 遙控器序號 (作為 Document ID)
    required String documentId,
    
    /// 遙控器類型
    required String rcType,
    
    /// 目前配對機身序號
    String? currentPairedDroneSn,
    
    /// 目前保管人
    required String currentKeeper,
  }) = _RemoteController;

  factory RemoteController.fromJson(Map<String, dynamic> json) => _$RemoteControllerFromJson(json);
}
