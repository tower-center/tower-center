import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/drone.dart';
import '../models/drone_package.dart';
import '../models/remote_controller.dart';
import '../models/battery.dart';
import '../models/action_log.dart';
import '../repositories/fleet_repository.dart';

/// 全新的物資詳細履歷頁面，支援「自訂屬性隨意擴充」與「即時同步」
class AssetDetailScreen extends StatefulWidget {
  final String assetId;
  final String type; // 'drone', 'rc', 'battery'
  final FleetRepository repository;

  const AssetDetailScreen({
    super.key,
    required this.assetId,
    required this.type,
    required this.repository,
  });

  @override
  State<AssetDetailScreen> createState() => _AssetDetailScreenState();
}

class _AssetDetailScreenState extends State<AssetDetailScreen> {
  bool _isSaving = false;

  String _getDictCategory() {
    switch (widget.type) {
      case 'drone': return 'drone_custom_field';
      case 'rc': return 'rc_custom_field';
      default: return 'battery_custom_field';
    }
  }

  // 取得該設備專屬的時間軸紀錄
  Stream<List<ActionLog>> _getAssetLogsStream() {
    return widget.repository.getAllActionLogsStream().map((logs) {
      return logs.where((log) {
        if (widget.type == 'drone') {
          return log.droneSn == widget.assetId;
        } else if (widget.type == 'rc') {
          return log.rcSn == widget.assetId;
        } else {
          // 電池：匹配 tagName 或序號
          return log.description.contains(widget.assetId) || 
                 (log.description.contains('電池') && log.description.contains(widget.assetId));
        }
      }).toList();
    });
  }

  // 新增或更新自訂屬性對話框
  void _showAddOrEditFieldDialog({String? existingKey, String? existingValue}) {
    final keyController = TextEditingController(text: existingKey);
    final valController = TextEditingController(text: existingValue);
    final formKey = GlobalKey<FormState>();
    final isEdit = existingKey != null;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEdit ? '編輯自訂屬性' : '新增自訂屬性'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: keyController,
                decoration: const InputDecoration(
                  labelText: '屬性名稱 (例如: 採購廠商, 保固期限)',
                  border: OutlineInputBorder(),
                ),
                enabled: !isEdit, // 編輯模式下不允許改 key，否則會變新增
                validator: (v) => v == null || v.trim().isEmpty ? '欄位名稱不能為空' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: valController,
                decoration: const InputDecoration(
                  labelText: '屬性內容 (例如: 聯強國際, 2028-12-31)',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v == null || v.trim().isEmpty ? '屬性內容不能為空' : null,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('取消')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, {
              'key': keyController.text.trim(),
              'value': valController.text.trim(),
            }),
            child: const Text('儲存'),
          ),
        ],
      ),
    ).then((result) {
      if (result != null) {
        final Map<String, String> data = result as Map<String, String>;
        _saveCustomField(data['key']!, data['value']!);
      }
    });
  }

  // 儲存自訂欄位回 Firestore
  Future<void> _saveCustomField(String key, String value, {bool showGlobalLoading = true}) async {
    if (showGlobalLoading) {
      setState(() => _isSaving = true);
    }
    try {
      if (widget.type == 'drone') {
        final drone = await widget.repository.getDrone(widget.assetId);
        if (drone != null) {
          final updatedFields = Map<String, String>.from(drone.customFields)..[key] = value;
          await widget.repository.updateDrone(drone.copyWith(customFields: updatedFields));
        }
      } else if (widget.type == 'rc') {
        // 遙控器沒有獨立 get 方法，直接透過 doc 更新
        final docRef = FirebaseFirestore.instance.collection('remote_controllers').doc(widget.assetId);
        final snapshot = await docRef.get();
        if (snapshot.exists && snapshot.data() != null) {
          final rc = RemoteController.fromJson(snapshot.data()!);
          final updatedFields = Map<String, String>.from(rc.customFields)..[key] = value;
          await docRef.update(rc.copyWith(customFields: updatedFields).toJson());
        }
      } else {
        // 電池
        final docRef = FirebaseFirestore.instance.collection('batteries').doc(widget.assetId);
        final snapshot = await docRef.get();
        if (snapshot.exists && snapshot.data() != null) {
          final battery = Battery.fromJson(snapshot.data()!);
          final updatedFields = Map<String, String>.from(battery.customFields)..[key] = value;
          await docRef.update(battery.copyWith(customFields: updatedFields).toJson());
        }
      }
      if (mounted && showGlobalLoading) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('自訂屬性已成功同步儲存！'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('儲存失敗: $e'), backgroundColor: Colors.red),
        );
      }
      rethrow;
    } finally {
      if (mounted && showGlobalLoading) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _deleteAsset() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.red),
            SizedBox(width: 8),
            Text('確認刪除設備'),
          ],
        ),
        content: const Text('確定要刪除此設備嗎？這將解除所有綁定，並在列表中隱藏，但會保留其歷史任務履歷紀錄。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('確認刪除'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      setState(() => _isSaving = true);
      try {
        if (widget.type == 'drone') {
          await widget.repository.softDeleteDrone(widget.assetId);
        } else if (widget.type == 'rc') {
          await widget.repository.softDeleteRemoteController(widget.assetId);
        } else {
          await widget.repository.softDeleteBattery(widget.assetId);
        }
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('設備已成功刪除！'), backgroundColor: Colors.green),
          );
          Navigator.pop(context); // 返回上一頁列表
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('刪除失敗: $e'), backgroundColor: Colors.red),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isSaving = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width <= 600;

    return Scaffold(
      appBar: AppBar(
        title: Text('${_getAssetTypeName()} 詳細履歷'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: '新增自訂屬性',
            onPressed: () => _showAddOrEditFieldDialog(),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            tooltip: '刪除此設備',
            onPressed: _deleteAsset,
          ),
        ],
      ),
      body: Stack(
        children: [
          _buildAssetStreamContent(isMobile),
          if (_isSaving)
            Container(
              color: Colors.black12,
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }

  String _getAssetTypeName() {
    switch (widget.type) {
      case 'drone':
        return '✈️ 空拍機';
      case 'rc':
        return '🎮 遙控器';
      default:
        return '🔋 智能電池';
    }
  }

  Widget _buildAssetStreamContent(bool isMobile) {
    if (widget.type == 'drone') {
      return StreamBuilder<Drone?>(
        stream: widget.repository.getDroneStream(widget.assetId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final drone = snapshot.data;
          if (drone == null) {
            return const Center(child: Text('找不到該空拍機資料'));
          }
          return _buildMainLayout(
            title: drone.documentId,
            subtitle: '型號: ${drone.modelType}',
            status: drone.status,
            packageId: drone.currentPackageId,
            customFields: drone.customFields,
            extraWidgets: [
              _buildDetailRow(Icons.pin, '出廠序號 (S/N)', drone.serialNumber ?? '未設定'),
              if (drone.insuranceExpiry != null)
                _buildDetailRow(Icons.security, '保險到期日', '${drone.insuranceExpiry!.toLocal()}'.split(' ')[0]),
            ],
            isMobile: isMobile,
          );
        },
      );
    } else if (widget.type == 'rc') {
      return StreamBuilder<RemoteController?>(
        stream: widget.repository.getRemoteControllerStream(widget.assetId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final rc = snapshot.data;
          if (rc == null) {
            return const Center(child: Text('找不到該遙控器資料'));
          }
          return _buildMainLayout(
            title: rc.documentId,
            subtitle: '型號: ${rc.rcType}',
            status: rc.status,
            packageId: rc.currentPackageId,
            customFields: rc.customFields,
            extraWidgets: [
              _buildDetailRow(Icons.pin, '出廠序號 (S/N)', rc.serialNumber ?? '未設定'),
            ],
            isMobile: isMobile,
          );
        },
      );
    } else {
      return StreamBuilder<Battery?>(
        stream: widget.repository.getBatteryStream(widget.assetId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final battery = snapshot.data;
          if (battery == null) {
            return const Center(child: Text('找不到該電池資料'));
          }
          return _buildMainLayout(
            title: battery.tagName,
            subtitle: '型號: ${battery.batteryModel}',
            status: battery.healthStatus,
            packageId: battery.currentPackageId,
            customFields: battery.customFields,
            extraWidgets: [
              _buildDetailRow(Icons.pin, '出廠序號 (S/N)', battery.serialNumber ?? '未設定'),
              _buildDetailRow(Icons.loop, '循環次數', '${battery.cycleCount} 次'),
              if (battery.purchaseDate != null)
                _buildDetailRow(Icons.calendar_month, '採購日期', '${battery.purchaseDate!.toLocal()}'.split(' ')[0]),
            ],
            isMobile: isMobile,
          );
        },
      );
    }
  }

  Widget _buildMainLayout({
    required String title,
    required String subtitle,
    required String status,
    String? packageId,
    required Map<String, String> customFields,
    required List<Widget> extraWidgets,
    required bool isMobile,
  }) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. 核心大卡片展示
          Card.filled(
            color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        widget.type == 'drone' 
                            ? Icons.flight 
                            : widget.type == 'rc' 
                                ? Icons.settings_remote 
                                : Icons.battery_charging_full,
                        size: 40,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(title, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                            Text(subtitle, style: const TextStyle(color: Colors.grey)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  _buildDetailRow(Icons.info_outline, '當前狀態', status, 
                      valueColor: status.contains('膨脹') || status.contains('異常') ? Colors.red : Colors.green),
                  packageId != null
                      ? FutureBuilder<DronePackage?>(
                          future: widget.repository.getPackage(packageId),
                          builder: (context, snapshot) {
                            final pkgName = snapshot.data?.tacticalName ?? packageId;
                            return _buildDetailRow(Icons.inventory_2_outlined, '目前位置', '📦 便攜盒 ($pkgName)');
                          },
                        )
                      : _buildDetailRow(Icons.inventory_2_outlined, '目前位置', '✅ 在庫存'),
                  ...extraWidgets,
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // 2. 自訂屬性區塊
          Align(
            alignment: Alignment.centerLeft,
            child: Text('✨ 設備自訂屬性', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 12),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('system_dictionaries')
                .where('category', isEqualTo: _getDictCategory())
                .where('isActive', isEqualTo: true)
                .snapshots(),
            builder: (context, dictSnapshot) {
              final globalKeys = dictSnapshot.data?.docs.map((doc) => doc['label'] as String).toList() ?? [];
              
              // 合併已填寫屬性與全域屬性定義
              final Map<String, String> mergedFields = {};
              for (final key in globalKeys) {
                mergedFields[key] = customFields[key] ?? '';
              }
              customFields.forEach((key, val) {
                if (!mergedFields.containsKey(key)) {
                  mergedFields[key] = val;
                }
              });

              if (mergedFields.isEmpty) {
                return Card.outlined(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 32),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(Icons.widgets_outlined, color: Colors.grey, size: 36),
                          SizedBox(height: 8),
                          Text('尚無自訂屬性，點擊右上角新增第一筆！', style: TextStyle(color: Colors.grey, fontSize: 13)),
                        ],
                      ),
                    ),
                  ),
                );
              }

              return Card.outlined(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: mergedFields.length,
                  separatorBuilder: (context, index) => const Divider(height: 1, indent: 16, endIndent: 16),
                  itemBuilder: (context, index) {
                    final key = mergedFields.keys.elementAt(index);
                    final val = mergedFields[key]!;
                    final isFromGlobal = globalKeys.contains(key);

                    return CustomFieldRow(
                      label: key,
                      value: val,
                      isGlobal: isFromGlobal,
                      onSave: (newVal) => _saveCustomField(key, newVal, showGlobalLoading: false),
                    );
                  },
                ),
              );
            },
          ),
          const SizedBox(height: 24),

          // 3. 專屬歷史任務軌跡 (ActionLogs)
          Text('🕒 歷史任務履歷時間軸', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          StreamBuilder<List<ActionLog>>(
            stream: _getAssetLogsStream(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              final logs = snapshot.data ?? [];
              if (logs.isEmpty) {
                return const Card(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Center(child: Text('暫無此物資的相關軌跡紀錄', style: TextStyle(color: Colors.grey))),
                  ),
                );
              }

              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: logs.length,
                itemBuilder: (context, index) {
                  final log = logs[index];
                  return Card(
                    child: ListTile(
                      leading: const Icon(Icons.history_toggle_off, color: Colors.blueAccent),
                      title: Text(log.description),
                      subtitle: Text('${log.timestamp.toLocal()}'.split('.')[0]),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey.shade600),
          const SizedBox(width: 12),
          Text('$label: ', style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: valueColor ?? Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CustomFieldRow extends StatefulWidget {
  final String label;
  final String value;
  final bool isGlobal;
  final Future<void> Function(String value) onSave;

  const CustomFieldRow({
    super.key,
    required this.label,
    required this.value,
    required this.isGlobal,
    required this.onSave,
  });

  @override
  State<CustomFieldRow> createState() => _CustomFieldRowState();
}

class _CustomFieldRowState extends State<CustomFieldRow> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  bool _isSavingLocal = false;
  bool _showSavedCheck = false;
  late String _lastSavedValue;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value);
    _focusNode = FocusNode();
    _lastSavedValue = widget.value;

    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) {
        _triggerSave();
      }
    });
  }

  @override
  void didUpdateWidget(CustomFieldRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value) {
      if (!_focusNode.hasFocus && _controller.text != widget.value) {
        _controller.text = widget.value;
      }
      _lastSavedValue = widget.value;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _triggerSave() async {
    final newValue = _controller.text.trim();
    if (newValue == _lastSavedValue.trim()) return;

    setState(() {
      _isSavingLocal = true;
      _showSavedCheck = false;
    });

    try {
      await widget.onSave(newValue);
      _lastSavedValue = newValue;
      if (mounted) {
        setState(() {
          _isSavingLocal = false;
          _showSavedCheck = true;
        });
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            setState(() {
              _showSavedCheck = false;
            });
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSavingLocal = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isSmallScreen = constraints.maxWidth < 450;
          
          final labelWidget = Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.label,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              if (widget.isGlobal) ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '全域',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ],
          );

          final inputWidget = TextFormField(
            controller: _controller,
            focusNode: _focusNode,
            onFieldSubmitted: (_) => _triggerSave(),
            decoration: InputDecoration(
              hintText: '請輸入${widget.label}',
              hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              filled: true,
              fillColor: Colors.grey.shade50,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade200),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 1.5),
              ),
              suffixIcon: _isSavingLocal
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: Padding(
                        padding: EdgeInsets.all(12.0),
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  : _showSavedCheck
                      ? const Icon(Icons.check_circle, color: Colors.green, size: 20)
                      : Icon(Icons.edit_outlined, color: Colors.grey.shade400, size: 18),
            ),
          );

          if (isSmallScreen) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                labelWidget,
                const SizedBox(height: 6),
                inputWidget,
              ],
            );
          } else {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: 140,
                  child: labelWidget,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: inputWidget,
                ),
              ],
            );
          }
        },
      ),
    );
  }
}
