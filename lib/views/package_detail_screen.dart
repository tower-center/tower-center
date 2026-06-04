import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/drone_package.dart';
import '../models/drone.dart';
import '../models/battery.dart';
import '../models/action_log.dart';
import '../models/remote_controller.dart';
import '../repositories/fleet_repository.dart';
import 'add_package_dialog.dart';
import 'add_battery_dialog.dart';
import 'scanner_dialog.dart';

/// 套裝 (Package) 管理面板 - 資源調度的核心視圖
class PackageDetailScreen extends StatefulWidget {
  final DronePackage package;
  final FleetRepository repository;

  const PackageDetailScreen({
    super.key,
    required this.package,
    required this.repository,
  });

  @override
  State<PackageDetailScreen> createState() => _PackageDetailScreenState();
}

class _PackageDetailScreenState extends State<PackageDetailScreen> {
  bool _isActionLoading = false;
  bool _isLoadingLogs = true;
  List<ActionLog> _logs = [];
  late DronePackage _currentPackage;

  @override
  void initState() {
    super.initState();
    _currentPackage = widget.package;
    _loadLogs();
  }

  Future<void> _loadLogs() async {
    setState(() => _isLoadingLogs = true);
    try {
      final fetchedLogs = await widget.repository.getPackageActionLogs(_currentPackage.documentId);
      setState(() {
        _logs = fetchedLogs;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('載入事件日誌失敗: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isLoadingLogs = false);
    }
  }

  Future<void> _refreshPackage() async {
    final updated = await widget.repository.getPackage(_currentPackage.documentId);
    if (updated != null && mounted) {
      setState(() {
        _currentPackage = updated;
      });
      _loadLogs();
    }
  }

  // ==========================================
  // 1. 機身 (Drone) 綁定與解綁
  // ==========================================

  void _showBindDroneDialog() {
    final formKey = GlobalKey<FormState>();
    final snController = TextEditingController();
    String activeMode = 'inventory'; // 'inventory' 或 'manual'
    String? selectedDroneId;

    void scanSn(StateSetter setDialogState) async {
      final scannedCode = await showDialog<String>(
        context: context,
        builder: (context) => const ScannerDialog(),
      );
      if (scannedCode != null && scannedCode.isNotEmpty) {
        setDialogState(() {
          snController.text = scannedCode;
        });
      }
    }

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text('放入飛機'),
            content: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('限定機型：${_currentPackage.modelType}', style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  // M3 SegmentedButton 模式切換
                  SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(value: 'inventory', label: Text('庫存挑選'), icon: Icon(Icons.warehouse_outlined)),
                      ButtonSegment(value: 'manual', label: Text('手動登錄'), icon: Icon(Icons.edit_note)),
                    ],
                    selected: {activeMode},
                    onSelectionChanged: (Set<String> newSelection) {
                      setDialogState(() {
                        activeMode = newSelection.first;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  if (activeMode == 'inventory') ...[
                    // 庫存挑選模式
                    StreamBuilder<List<Drone>>(
                      stream: widget.repository.getUnassignedDronesStream(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: Padding(padding: EdgeInsets.all(8.0), child: CircularProgressIndicator()));
                        }
                        final allDrones = snapshot.data ?? [];
                        // 篩選與當前便攜盒型號相同的空閒飛機
                        final filteredDrones = allDrones.where((d) => d.modelType == _currentPackage.modelType).toList();

                        if (filteredDrones.isEmpty) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            child: Text(
                              '⚠️ 目前無此型號的庫存飛機，請切換至「手動登錄」建立新飛機。',
                              style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
                            ),
                          );
                        }

                        // 確保選中的 ID 仍在清單中
                        if (selectedDroneId != null && !filteredDrones.any((d) => d.documentId == selectedDroneId)) {
                          selectedDroneId = null;
                        }

                        return DropdownButtonFormField<String>(
                          value: selectedDroneId,
                          decoration: const InputDecoration(
                            labelText: '選擇庫存飛機',
                            border: OutlineInputBorder(),
                          ),
                          items: filteredDrones.map((d) {
                            final snText = d.serialNumber != null ? ' (S/N: ${d.serialNumber})' : '';
                            return DropdownMenuItem(
                              value: d.documentId,
                              child: Text('${d.documentId}$snText'),
                            );
                          }).toList(),
                          onChanged: (val) {
                            setDialogState(() {
                              selectedDroneId = val;
                            });
                          },
                          validator: (val) => val == null ? '請選擇一台飛機' : null,
                        );
                      },
                    ),
                  ] else ...[
                    // 手動登錄模式
                    TextFormField(
                      controller: snController,
                      decoration: InputDecoration(
                        labelText: '輸入/掃描飛機序號 (S/N) [可選]',
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.qr_code_scanner),
                          onPressed: () => scanSn(setDialogState),
                        ),
                        border: const OutlineInputBorder(),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('取消')),
              ElevatedButton(
                onPressed: () async {
                  if (!formKey.currentState!.validate()) return;
                  Navigator.pop(context);
                  setState(() => _isActionLoading = true);

                  try {
                    if (activeMode == 'inventory') {
                      // 庫存挑選綁定
                      final droneId = selectedDroneId!;
                      final drone = (await widget.repository.getDrone(droneId))!;
                      
                      // 1. 更新飛機關聯
                      await widget.repository.updateDrone(drone.copyWith(
                        currentPackageId: _currentPackage.documentId,
                      ));

                      // 2. 更新便攜盒關聯
                      final updatedPkg = _currentPackage.copyWith(currentDroneSn: droneId);
                      await widget.repository.updatePackage(updatedPkg);

                      // 3. 記錄日誌
                      await widget.repository.addActionLog(ActionLog(
                        documentId: 'LOG-${DateTime.now().millisecondsSinceEpoch}',
                        timestamp: DateTime.now(),
                        eventType: 'repair',
                        packageId: _currentPackage.documentId,
                        droneSn: droneId,
                        description: '從庫存中挑選並放入飛機 (ID: $droneId)。',
                      ));
                    } else {
                      // 手動登錄新增
                      final inputSn = snController.text.trim();
                      final generatedId = 'DRN-${DateTime.now().millisecondsSinceEpoch}';
                      final documentId = inputSn.isNotEmpty ? inputSn : generatedId;

                      Drone? drone;
                      if (inputSn.isNotEmpty) {
                        drone = await widget.repository.getDrone(inputSn);
                      }

                      if (drone == null) {
                        drone = Drone(
                          documentId: documentId,
                          serialNumber: inputSn.isNotEmpty ? inputSn : null,
                          modelType: _currentPackage.modelType,
                          currentPackageId: _currentPackage.documentId,
                          status: '正常',
                        );
                        await widget.repository.addDrone(drone);
                      } else {
                        drone = drone.copyWith(currentPackageId: _currentPackage.documentId, status: '正常');
                        await widget.repository.updateDrone(drone);
                      }

                      final updatedPkg = _currentPackage.copyWith(currentDroneSn: documentId);
                      await widget.repository.updatePackage(updatedPkg);

                      await widget.repository.addActionLog(ActionLog(
                        documentId: 'LOG-${DateTime.now().millisecondsSinceEpoch}',
                        timestamp: DateTime.now(),
                        eventType: 'repair',
                        packageId: _currentPackage.documentId,
                        droneSn: documentId,
                        description: '手動登錄新飛機並放入便攜盒 (ID: $documentId)。',
                      ));
                    }

                    await _refreshPackage();
                  } catch (e) {
                    if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('綁定失敗: $e')));
                  } finally {
                    if (mounted) setState(() => _isActionLoading = false);
                  }
                },
                child: const Text('確認'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _unbindDrone() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('解除綁定實體飛機'),
        content: const Text('確定要將實體飛機從此套裝中移除嗎？\n(飛機將退回庫存狀態)'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('取消')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, foregroundColor: Colors.white),
            onPressed: () => Navigator.pop(c, true),
            child: const Text('解綁'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isActionLoading = true);
    try {
      final sn = _currentPackage.currentDroneSn!;
      final drone = await widget.repository.getDrone(sn);
      if (drone != null) {
        await widget.repository.updateDrone(drone.copyWith(currentPackageId: null));
      }

      final updatedPkg = _currentPackage.copyWith(currentDroneSn: null);
      await widget.repository.updatePackage(updatedPkg);

      await widget.repository.addActionLog(ActionLog(
        documentId: 'LOG-${DateTime.now().millisecondsSinceEpoch}',
        timestamp: DateTime.now(),
        eventType: 'repair',
        packageId: _currentPackage.documentId,
        description: '將實體飛機 (S/N: $sn) 從套裝中移除。',
      ));

      await _refreshPackage();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('解綁失敗: $e')));
    } finally {
      if (mounted) setState(() => _isActionLoading = false);
    }
  }

  // ==========================================
  // 2. 遙控器 (RC) 綁定與解綁
  // ==========================================

  void _showBindRcDialog() {
    final formKey = GlobalKey<FormState>();
    final rcController = TextEditingController();
    String activeMode = 'inventory'; // 'inventory' 或 'manual'
    String? selectedRcId;

    void scanRcSn(StateSetter setDialogState) async {
      final scannedCode = await showDialog<String>(
        context: context,
        builder: (context) => const ScannerDialog(),
      );
      if (scannedCode != null && scannedCode.isNotEmpty) {
        setDialogState(() {
          rcController.text = scannedCode;
        });
      }
    }

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text('放入遙控器'),
            content: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('限定型號：${_currentPackage.modelType}', style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  // M3 SegmentedButton 模式切換
                  SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(value: 'inventory', label: Text('庫存挑選'), icon: Icon(Icons.warehouse_outlined)),
                      ButtonSegment(value: 'manual', label: Text('手動登錄'), icon: Icon(Icons.edit_note)),
                    ],
                    selected: {activeMode},
                    onSelectionChanged: (Set<String> newSelection) {
                      setDialogState(() {
                        activeMode = newSelection.first;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  if (activeMode == 'inventory') ...[
                    // 庫存挑選模式
                    StreamBuilder<List<RemoteController>>(
                      stream: widget.repository.getUnassignedRemoteControllersStream(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: Padding(padding: EdgeInsets.all(8.0), child: CircularProgressIndicator()));
                        }
                        final allRcs = snapshot.data ?? [];
                        // 篩選與當前便攜盒型號相同的空閒遙控器
                        final filteredRcs = allRcs.where((rc) => rc.rcType == _currentPackage.modelType).toList();

                        if (filteredRcs.isEmpty) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            child: Text(
                              '⚠️ 目前無此型號的庫存遙控器，請切換至「手動登錄」建立新遙控器。',
                              style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
                            ),
                          );
                        }

                        // 確保選中的 ID 仍在清單中
                        if (selectedRcId != null && !filteredRcs.any((rc) => rc.documentId == selectedRcId)) {
                          selectedRcId = null;
                        }

                        return DropdownButtonFormField<String>(
                          value: selectedRcId,
                          decoration: const InputDecoration(
                            labelText: '選擇庫存遙控器',
                            border: OutlineInputBorder(),
                          ),
                          items: filteredRcs.map((rc) {
                            final snText = rc.serialNumber != null ? ' (S/N: ${rc.serialNumber})' : '';
                            return DropdownMenuItem(
                              value: rc.documentId,
                              child: Text('${rc.documentId}$snText'),
                            );
                          }).toList(),
                          onChanged: (val) {
                            setDialogState(() {
                              selectedRcId = val;
                            });
                          },
                          validator: (val) => val == null ? '請選擇一台遙控器' : null,
                        );
                      },
                    ),
                  ] else ...[
                    // 手動登錄模式
                    TextFormField(
                      controller: rcController,
                      decoration: InputDecoration(
                        labelText: '輸入/掃描遙控器序號 (S/N) [可選]',
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.qr_code_scanner),
                          onPressed: () => scanRcSn(setDialogState),
                        ),
                        border: const OutlineInputBorder(),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('取消')),
              ElevatedButton(
                onPressed: () async {
                  if (!formKey.currentState!.validate()) return;
                  Navigator.pop(context);
                  setState(() => _isActionLoading = true);

                  try {
                    if (activeMode == 'inventory') {
                      // 庫存挑選綁定
                      final rcId = selectedRcId!;
                      
                      await widget.repository.pairRemoteController(
                        rcSn: rcId,
                        rcType: _currentPackage.modelType,
                        packageId: _currentPackage.documentId,
                      );

                      final updatedPkg = _currentPackage.copyWith(currentRcSn: rcId);
                      await widget.repository.updatePackage(updatedPkg);

                      await widget.repository.addActionLog(ActionLog(
                        documentId: 'LOG-${DateTime.now().millisecondsSinceEpoch}',
                        timestamp: DateTime.now(),
                        eventType: 'battery_transfer',
                        packageId: _currentPackage.documentId,
                        rcSn: rcId,
                        description: '從庫存中挑選並放入遙控器 (ID: $rcId)。',
                      ));
                    } else {
                      // 手動登錄新增
                      final inputSn = rcController.text.trim();
                      final generatedId = 'RC-${DateTime.now().millisecondsSinceEpoch}';
                      final documentId = inputSn.isNotEmpty ? inputSn : generatedId;

                      await widget.repository.pairRemoteController(
                        rcSn: documentId,
                        serialNumber: inputSn.isNotEmpty ? inputSn : null,
                        rcType: _currentPackage.modelType,
                        packageId: _currentPackage.documentId,
                      );

                      final updatedPkg = _currentPackage.copyWith(currentRcSn: documentId);
                      await widget.repository.updatePackage(updatedPkg);

                      await widget.repository.addActionLog(ActionLog(
                        documentId: 'LOG-${DateTime.now().millisecondsSinceEpoch}',
                        timestamp: DateTime.now(),
                        eventType: 'battery_transfer',
                        packageId: _currentPackage.documentId,
                        rcSn: documentId,
                        description: '手動登錄新遙控器並放入便攜盒 (ID: $documentId)。',
                      ));
                    }

                    await _refreshPackage();
                  } catch (e) {
                    if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('配對失敗: $e')));
                  } finally {
                    if (mounted) setState(() => _isActionLoading = false);
                  }
                },
                child: const Text('確認'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _unbindRc() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('移除遙控器'),
        content: const Text('確定要將遙控器從此套裝中移除嗎？'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('取消')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, foregroundColor: Colors.white),
            onPressed: () => Navigator.pop(c, true),
            child: const Text('移除'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isActionLoading = true);
    try {
      final rcSn = _currentPackage.currentRcSn!;
      await widget.repository.unpairRemoteController(rcSn);
      
      final updatedPkg = _currentPackage.copyWith(currentRcSn: null);
      await widget.repository.updatePackage(updatedPkg);

      await widget.repository.addActionLog(ActionLog(
        documentId: 'LOG-${DateTime.now().millisecondsSinceEpoch}',
        timestamp: DateTime.now(),
        eventType: 'battery_transfer',
        packageId: _currentPackage.documentId,
        description: '將遙控器 (S/N: $rcSn) 從套裝中取出。',
      ));
      await _refreshPackage();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('解綁失敗: $e')));
    } finally {
      if (mounted) setState(() => _isActionLoading = false);
    }
  }

  // ==========================================
  // 3. 電池 (Batteries) 登錄
  // ==========================================

  void _showAddBatteryDialog() async {
    final newOrUpdatedBattery = await showDialog<Battery>(
      context: context,
      builder: (context) => AddBatteryToPackageDialog(
        repository: widget.repository,
        packageId: _currentPackage.documentId,
        packageModelType: _currentPackage.modelType,
      ),
    );

    if (newOrUpdatedBattery != null) {
      setState(() => _isActionLoading = true);
      try {
        await widget.repository.addActionLog(ActionLog(
          documentId: 'LOG-${DateTime.now().millisecondsSinceEpoch}',
          timestamp: DateTime.now(),
          eventType: 'battery_transfer',
          packageId: _currentPackage.documentId,
          description: '將電池 [${newOrUpdatedBattery.tagName}] (S/N: ${newOrUpdatedBattery.serialNumber}) 放進套裝。',
        ));
        await _refreshPackage();
      } catch (e) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('紀錄失敗: $e')));
      } finally {
        if (mounted) setState(() => _isActionLoading = false);
      }
    }
  }

  // ==========================================
  // UI 渲染 (Build)
  // ==========================================

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey),
          const SizedBox(width: 8),
          Text('$label: ', style: const TextStyle(color: Colors.grey, fontSize: 13)),
          Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${_currentPackage.tacticalName} 套裝管理面板'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            tooltip: '刪除便攜盒',
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (c) => AlertDialog(
                  title: const Text('⚠️ 確定要刪除此便攜盒嗎？'),
                  content: const Text('刪除後，此便攜盒內的所有設備（飛機、遙控器、電池）將會解除綁定並回歸庫存，供其他便攜盒使用。\n\n此動作無法復原！'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(c, false),
                      child: const Text('取消'),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () => Navigator.pop(c, true),
                      child: const Text('確認刪除'),
                    ),
                  ],
                ),
              );

              if (confirm == true && mounted) {
                setState(() => _isActionLoading = true);
                try {
                  await widget.repository.deletePackage(_currentPackage.documentId);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('便攜盒已成功刪除，所屬物資已回歸庫存！'),
                        backgroundColor: Colors.green,
                      ),
                    );
                    Navigator.of(context).pop(); // 返回首頁
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('刪除失敗: $e'), backgroundColor: Colors.red),
                    );
                  }
                } finally {
                  if (mounted) setState(() => _isActionLoading = false);
                }
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: '編輯套裝資料',
            onPressed: () async {
              final updatedPackage = await showDialog<DronePackage>(
                context: context,
                builder: (context) => AddPackageDialog(
                  repository: widget.repository,
                  package: _currentPackage,
                ),
              );
              
              if (updatedPackage != null && mounted) {
                setState(() {
                  _currentPackage = updatedPackage;
                });
                _loadLogs();
              }
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. 套裝基本資訊
                Card.filled(
                  color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.5),
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.inventory_2, size: 32, color: Theme.of(context).colorScheme.primary),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _currentPackage.tacticalName,
                                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 24),
                        _buildDetailRow(Icons.dns, '機型', _currentPackage.modelType),
                        _buildDetailRow(Icons.person, '保管人', _currentPackage.currentKeeper),
                        const SizedBox(height: 12),
                        const Text('套裝配件清單:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        const SizedBox(height: 4),
                        if (_currentPackage.accessories.isEmpty)
                          const Text('無配件', style: TextStyle(color: Colors.grey, fontSize: 13))
                        else
                          Wrap(
                            spacing: 8,
                            runSpacing: 4,
                            children: _currentPackage.accessories.entries.map((e) => Chip(
                              label: Text('${e.key} x${e.value}', style: const TextStyle(fontSize: 12)),
                              padding: EdgeInsets.zero,
                              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            )).toList(),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // 2. 實體設備掛載面板
                Text('套裝內容物 (實體設備)', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),

                // -- 飛機母艦 --
                Card.outlined(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        const Icon(Icons.flight, size: 32, color: Colors.blueAccent),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('機身母艦', style: TextStyle(fontWeight: FontWeight.bold)),
                              Text(_currentPackage.currentDroneSn ?? '未放入飛機', style: const TextStyle(color: Colors.grey)),
                            ],
                          ),
                        ),
                        if (_currentPackage.currentDroneSn == null)
                          ElevatedButton.icon(
                            onPressed: _isActionLoading ? null : _showBindDroneDialog,
                            icon: const Icon(Icons.add),
                            label: const Text('新增飛機'),
                          )
                        else
                          OutlinedButton.icon(
                            onPressed: _isActionLoading ? null : _unbindDrone,
                            icon: const Icon(Icons.logout, color: Colors.red),
                            label: const Text('取出機身', style: TextStyle(color: Colors.red)),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // -- 遙控器 --
                Card.outlined(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        const Icon(Icons.settings_remote, size: 32, color: Colors.indigo),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('遙控器', style: TextStyle(fontWeight: FontWeight.bold)),
                              Text(_currentPackage.currentRcSn ?? '未放入遙控器', style: const TextStyle(color: Colors.grey)),
                            ],
                          ),
                        ),
                        if (_currentPackage.currentRcSn == null)
                          ElevatedButton.icon(
                            onPressed: _isActionLoading ? null : _showBindRcDialog,
                            icon: const Icon(Icons.add),
                            label: const Text('新增遙控器'),
                          )
                        else
                          OutlinedButton.icon(
                            onPressed: _isActionLoading ? null : _unbindRc,
                            icon: const Icon(Icons.logout, color: Colors.red),
                            label: const Text('取出遙控器', style: TextStyle(color: Colors.red)),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // -- 智能電池清單 --
                Card.outlined(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.battery_charging_full, size: 28, color: Colors.teal),
                                SizedBox(width: 8),
                                Text('智能電池', style: TextStyle(fontWeight: FontWeight.bold)),
                              ],
                            ),
                            TextButton.icon(
                              onPressed: _isActionLoading ? null : _showAddBatteryDialog,
                              icon: const Icon(Icons.add),
                              label: const Text('放入電池'),
                            ),
                          ],
                        ),
                        const Divider(),
                        StreamBuilder<List<Battery>>(
                          stream: widget.repository.getPackageBatteriesStream(_currentPackage.documentId),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) return const CircularProgressIndicator();
                            final batteries = snapshot.data ?? [];
                            if (batteries.isEmpty) return const Text('套裝內目前沒有電池', style: TextStyle(color: Colors.grey));
                            
                            return Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: batteries.map((b) => Chip(
                                avatar: const Icon(Icons.battery_std, size: 16, color: Colors.teal),
                                label: Text(b.tagName),
                                onDeleted: () async {
                                  // 取出電池
                                  setState(() => _isActionLoading = true);
                                  try {
                                    await widget.repository.updateBattery(b.copyWith(currentPackageId: null));
                                    await widget.repository.addActionLog(ActionLog(
                                      documentId: 'LOG-${DateTime.now().millisecondsSinceEpoch}',
                                      timestamp: DateTime.now(),
                                      eventType: 'battery_transfer',
                                      packageId: _currentPackage.documentId,
                                      description: '將電池 [${b.tagName}] 取出套裝。',
                                    ));
                                  } finally {
                                    if (mounted) setState(() => _isActionLoading = false);
                                  }
                                },
                              )).toList(),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 28),

                // 3. 事件日誌時間軸
                Text('事件日誌 (Action Logs)', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),

                if (_isLoadingLogs)
                  const Center(child: CircularProgressIndicator())
                else if (_logs.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Center(child: Text('暫無事件紀錄', style: TextStyle(color: Colors.grey))),
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _logs.length,
                    itemBuilder: (context, index) {
                      final log = _logs[index];
                      return ListTile(
                        leading: const Icon(Icons.event_note, color: Colors.blueAccent),
                        title: Text(log.description),
                        subtitle: Text('${log.timestamp.toLocal()}'.split('.')[0]),
                      );
                    },
                  ),
              ],
            ),
          ),
          if (_isActionLoading)
            Container(
              color: Colors.black12,
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}
