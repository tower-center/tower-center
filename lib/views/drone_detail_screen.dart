import 'package:flutter/material.dart';
import '../models/drone.dart';
import '../models/battery.dart';
import '../models/action_log.dart';
import '../repositories/fleet_repository.dart';

/// 武裝掛載面板 / 機身詳細配置頁面 (整合動態時間軸日誌)
class DroneDetailScreen extends StatefulWidget {
  final Drone drone;
  final FleetRepository repository;

  const DroneDetailScreen({
    super.key,
    required this.drone,
    required this.repository,
  });

  @override
  State<DroneDetailScreen> createState() => _DroneDetailScreenState();
}

class _DroneDetailScreenState extends State<DroneDetailScreen> {
  bool _isActionLoading = false;
  bool _isLoadingLogs = true;
  List<ActionLog> _logs = [];

  @override
  void initState() {
    super.initState();
    _loadLogs();
  }

  /// 載入該機身的事件軌跡日誌
  Future<void> _loadLogs() async {
    setState(() => _isLoadingLogs = true);
    try {
      final fetchedLogs = await widget.repository.getDroneActionLogs(widget.drone.documentId);
      setState(() {
        _logs = fetchedLogs;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('載入事件日誌失敗: $e'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoadingLogs = false);
      }
    }
  }

  /// 顯示「配對遙控器」對話框
  void _showPairRcDialog() {
    final formKey = GlobalKey<FormState>();
    final rcController = TextEditingController();

    /// 遙控器掃碼 Mock
    void scanRcSn() async {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('相機啟動中，請對準遙控器 QR 碼...')),
      );
      await Future.delayed(const Duration(seconds: 1));
      rcController.text = 'RC-SCAN-8899';
    }

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const Row(
              children: [
                Icon(Icons.settings_remote, color: Colors.indigo),
                SizedBox(width: 8),
                Text('配對遙控器'),
              ],
            ),
            content: Form(
              key: formKey,
              child: TextFormField(
                controller: rcController,
                decoration: InputDecoration(
                  labelText: '遙控器序號 (S/N)',
                  prefixIcon: const Icon(Icons.pin),
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.qr_code_scanner),
                    onPressed: scanRcSn,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return '請輸入或掃描遙控器序號';
                  }
                  return null;
                },
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('取消'),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (!formKey.currentState!.validate()) return;
                  final rcSn = rcController.text.trim();
                  
                  Navigator.pop(context); // 關閉對話框
                  setState(() => _isActionLoading = true);

                  try {
                    // 呼叫 Repository 完成綁定
                    await widget.repository.pairRemoteController(
                      rcSn: rcSn,
                      droneSn: widget.drone.documentId,
                    );
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('遙控器 $rcSn 成功配對至 ${widget.drone.currentName}！'),
                        backgroundColor: Colors.green,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                    
                    // 自動記錄一筆事件日誌
                    final pairLog = ActionLog(
                      documentId: 'LOG-${DateTime.now().millisecondsSinceEpoch}',
                      timestamp: DateTime.now(),
                      eventType: 'battery_transfer', // 遙控器配對調度事件
                      droneSn: widget.drone.documentId,
                      rcSn: rcSn,
                      description: '手動將遙控器 (S/N: $rcSn) 配對綁定至本機。',
                    );
                    await widget.repository.addDroneActionLog(pairLog);
                    _loadLogs(); // 重新載入日誌
                  } catch (e) {
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('配對失敗: $e'), backgroundColor: Colors.red),
                    );
                  } finally {
                    if (mounted) setState(() => _isActionLoading = false);
                  }
                },
                child: const Text('確認配對'),
              ),
            ],
          );
        },
      ),
    );
  }

  /// 顯示「單筆新增/掃描電池」對話框
  void _showAddBatteryDialog() {
    final formKey = GlobalKey<FormState>();
    final tagController = TextEditingController(); // M301
    final snController = TextEditingController();  // 出廠序號
    final modelController = TextEditingController(text: '智能飛行電池');

    /// 電池掃碼 Mock
    void scanBatterySn() async {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('相機啟動中，請對準電池條碼...')),
      );
      await Future.delayed(const Duration(seconds: 1));
      snController.text = 'BTY-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}';
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Row(
            children: [
              Icon(Icons.battery_charging_full, color: Colors.teal),
              SizedBox(width: 8),
              Text('登錄新電池'),
            ],
          ),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    '請掃描電池上的原廠出廠序號，並為其指定一個外場任務標籤。',
                    style: TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  // 外場標籤
                  TextFormField(
                    controller: tagController,
                    decoration: const InputDecoration(
                      labelText: '外場標籤 (Tag)',
                      border: OutlineInputBorder(),
                      hintText: '如 M301',
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return '請輸入標籤名稱';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  // 原廠序號
                  TextFormField(
                    controller: snController,
                    decoration: InputDecoration(
                      labelText: '原廠出廠序號 (S/N)',
                      border: const OutlineInputBorder(),
                      hintText: '使用掃碼或手動輸入',
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.qr_code_scanner),
                        onPressed: scanBatterySn,
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return '請輸入出廠序號';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  // 電池型號
                  TextFormField(
                    controller: modelController,
                    decoration: const InputDecoration(
                      labelText: '電池型號',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return '請輸入電池型號';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('取消'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (!formKey.currentState!.validate()) return;
                
                final tag = tagController.text.trim();
                final sn = snController.text.trim();
                final model = modelController.text.trim();

                Navigator.pop(context); // 關閉對話框
                setState(() => _isActionLoading = true);

                try {
                  final newBattery = Battery(
                    documentId: 'BTY-${DateTime.now().millisecondsSinceEpoch}',
                    serialNumber: sn,
                    tagName: tag,
                    batteryModel: model,
                    cycleCount: 0,
                    healthStatus: '全新健康 (無膨脹)',
                    currentDroneSn: widget.drone.documentId,
                    purchaseDate: DateTime.now(),
                  );

                  // 寫入 Firestore
                  await widget.repository.addBattery(newBattery);

                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('已成功錄入電池 [$tag] (S/N: $sn)！'),
                      backgroundColor: Colors.teal,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );

                  // 自動記錄一筆日誌事件
                  final batteryLog = ActionLog(
                    documentId: 'LOG-${DateTime.now().millisecondsSinceEpoch}',
                    timestamp: DateTime.now(),
                    eventType: 'battery_transfer',
                    droneSn: widget.drone.documentId,
                    description: '為本機掛載並登錄新電池 (標籤: $tag, S/N: $sn)。',
                  );
                  await widget.repository.addDroneActionLog(batteryLog);
                  _loadLogs(); // 重新載入日誌
                } catch (e) {
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('電池建檔失敗: $e'), backgroundColor: Colors.red),
                  );
                } finally {
                  if (mounted) setState(() => _isActionLoading = false);
                }
              },
              child: const Text('確認登錄'),
            ),
          ],
        );
      },
    );
  }

  /// 顯示「新增日誌紀錄」Dialog
  void _showAddActionLogDialog() {
    final formKey = GlobalKey<FormState>();
    String selectedType = 'health_check'; // 預設為健康檢查
    final descriptionController = TextEditingController();
    final costController = TextEditingController(text: '0');
    final tagsController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: const Row(
                children: [
                  Icon(Icons.edit_note, color: Colors.blueAccent),
                  SizedBox(width: 8),
                  Text('新增事件日誌'),
                ],
              ),
              content: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // 1. 事件類型選擇 (Dropdown)
                      DropdownButtonFormField<String>(
                        value: selectedType,
                        decoration: const InputDecoration(
                          labelText: '事件類型',
                          border: OutlineInputBorder(),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'health_check', child: Text('✅ 健康檢查 (Health Check)')),
                          DropdownMenuItem(value: 'battery_transfer', child: Text('🔋 電池調度 (Battery Transfer)')),
                          DropdownMenuItem(value: 'repair', child: Text('🔧 設備維修 (Repair)')),
                          DropdownMenuItem(value: 'crash', child: Text('💥 異常墜毀 (Crash)')),
                        ],
                        onChanged: (val) {
                          if (val != null) {
                            setDialogState(() {
                              selectedType = val;
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 16),
                      // 2. 詳細描述
                      TextFormField(
                        controller: descriptionController,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          labelText: '詳細事件描述',
                          border: OutlineInputBorder(),
                          hintText: '請詳述發生的事件與當前狀態...',
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return '請輸入描述內容';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      // 3. 花費金額
                      TextFormField(
                        controller: costController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: const InputDecoration(
                          labelText: '花費金額 (USD)',
                          prefixText: '\$ ',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || double.tryParse(value) == null) {
                            return '請輸入有效的金額數字';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      // 4. AI 標籤 (逗號分隔)
                      TextFormField(
                        controller: tagsController,
                        decoration: const InputDecoration(
                          labelText: '分析標籤 (以逗號分隔)',
                          prefixIcon: Icon(Icons.tag),
                          border: OutlineInputBorder(),
                          hintText: '例如: 例行, 馬達, 槳葉',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('取消'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (!formKey.currentState!.validate()) return;

                    final description = descriptionController.text.trim();
                    final cost = double.parse(costController.text.trim());
                    // 剖析標籤，去除空白並轉為 List
                    final tags = tagsController.text
                        .split(',')
                        .map((t) => t.trim())
                        .where((t) => t.isNotEmpty)
                        .toList();

                    Navigator.pop(context);
                    setState(() => _isActionLoading = true);

                    try {
                      final newLog = ActionLog(
                        documentId: 'LOG-${DateTime.now().millisecondsSinceEpoch}',
                        timestamp: DateTime.now(),
                        eventType: selectedType,
                        droneSn: widget.drone.documentId, // 自動帶入當前機身 SN
                        description: description,
                        cost: cost,
                        aiTags: tags,
                      );

                      // 寫入 Firestore
                      await widget.repository.addDroneActionLog(newLog);

                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('成功記錄: ${_getEventName(selectedType)}'),
                          backgroundColor: Colors.blueAccent,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );

                      // 重新載入日誌清單
                      _loadLogs();
                    } catch (e) {
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('紀錄失敗: $e'), backgroundColor: Colors.red),
                      );
                    } finally {
                      if (mounted) setState(() => _isActionLoading = false);
                    }
                  },
                  child: const Text('完成記錄'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  /// 確認並刪除機身
  void _confirmDeleteDrone() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.red),
            SizedBox(width: 8),
            Text('確認報廢/刪除'),
          ],
        ),
        content: Text('確定要報廢/刪除母艦「${widget.drone.currentName}」嗎？此操作將從資料庫中永久移除該設備且無法復原。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), // 關閉對話框
            child: const Text('取消'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              Navigator.pop(context); // 關閉對話框
              setState(() => _isActionLoading = true);
              try {
                // 呼叫 Repository 執行 Firestore 刪除操作
                await widget.repository.deleteDrone(widget.drone.documentId);
                if (!context.mounted) return;
                // 返回上一頁，並傳遞 true 表示已刪除
                Navigator.pop(context, true);
              } catch (e) {
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('刪除失敗: $e'), backgroundColor: Colors.red),
                );
              } finally {
                if (mounted) setState(() => _isActionLoading = false);
              }
            },
            child: const Text('確認報廢'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.drone.currentName} 配置面板'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            color: Colors.red.shade400,
            tooltip: '報廢/刪除母艦',
            onPressed: _isActionLoading ? null : _confirmDeleteDrone,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. 機身狀態卡片 (Material 3 Card)
                Card.filled(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.flight,
                              size: 32,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                widget.drone.currentName,
                                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 24),
                        _buildDetailRow(Icons.pin, '機身序號 (S/N)', widget.drone.documentId),
                        const SizedBox(height: 8),
                        _buildDetailRow(Icons.dns, '出廠機型', widget.drone.modelType),
                        const SizedBox(height: 8),
                        _buildDetailRow(Icons.person, '保管人', widget.drone.currentKeeper),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // 2. 武裝配置面板
                Text(
                  '武裝與配件配置',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 12),

                // 配對遙控器按鈕
                Card.outlined(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: _isActionLoading ? null : _showPairRcDialog,
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                      child: Row(
                        children: [
                          Icon(Icons.settings_remote, size: 28, color: Colors.indigo),
                          SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('配對專屬遙控器', style: TextStyle(fontWeight: FontWeight.bold)),
                                SizedBox(height: 2),
                                Text('綁定遙控器 S/N 至此母艦', style: TextStyle(fontSize: 12, color: Colors.grey)),
                              ],
                            ),
                          ),
                          Icon(Icons.chevron_right),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // 登錄智能電池按鈕
                Card.outlined(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: _isActionLoading ? null : _showAddBatteryDialog,
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                      child: Row(
                        children: [
                          Icon(Icons.battery_charging_full, size: 28, color: Colors.teal),
                          SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('登錄新智能電池', style: TextStyle(fontWeight: FontWeight.bold)),
                                SizedBox(height: 2),
                                Text('掃描出廠序號並建立追蹤標籤', style: TextStyle(fontSize: 12, color: Colors.grey)),
                              ],
                            ),
                          ),
                          Icon(Icons.chevron_right),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // 已掛載電池清單區塊
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '目前配置電池 (Batteries)',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                
                StreamBuilder<List<Battery>>(
                  stream: widget.repository.getDroneBatteriesStream(widget.drone.documentId),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: CircularProgressIndicator(),
                      ));
                    }
                    if (snapshot.hasError) {
                      return Text('載入電池失敗: ${snapshot.error}', style: const TextStyle(color: Colors.red));
                    }
                    final batteries = snapshot.data ?? [];
                    
                    if (batteries.isEmpty) {
                      return Card.outlined(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        color: Colors.grey.shade50,
                        child: const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Center(
                            child: Text('目前沒有綁定任何電池', style: TextStyle(color: Colors.grey)),
                          ),
                        ),
                      );
                    }

                    // 電池清單 Grid
                    return GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 2.5,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                      ),
                      itemCount: batteries.length,
                      itemBuilder: (context, index) {
                        final b = batteries[index];
                        return Card.outlined(
                          margin: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            child: Row(
                              children: [
                                const Icon(Icons.battery_std, color: Colors.teal, size: 24),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        b.tagName,
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        'S/N: ${b.serialNumber ?? '無紀錄'}',
                                        style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
                const SizedBox(height: 28),

                // 3. 事件日誌 (Action Logs) 時間軸區塊
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '事件日誌 (Action Logs)',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.refresh, size: 20),
                      onPressed: _loadLogs,
                      tooltip: '重新整理事件',
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // 時間軸清單渲染
                _isLoadingLogs
                    ? const Padding(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    : _logs.isEmpty
                        ? Padding(
                            padding: const EdgeInsets.symmetric(vertical: 36),
                            child: Column(
                              children: [
                                Icon(Icons.history, size: 48, color: Colors.grey.shade400),
                                const SizedBox(height: 8),
                                Text(
                                  '暫無事件紀錄',
                                  style: TextStyle(color: Colors.grey.shade500),
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  '點擊右下角按鈕，記錄此母艦的第一筆事件！',
                                  style: TextStyle(fontSize: 12, color: Colors.grey),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _logs.length,
                            itemBuilder: (context, index) {
                              return _buildTimelineTile(
                                _logs[index],
                                isLast: index == _logs.length - 1,
                              );
                            },
                          ),
                const SizedBox(height: 80), // 預留空間給 FAB
              ],
            ),
          ),
          
          // 通用 Action 讀取遮罩 (防重複觸控)
          if (_isActionLoading)
            Container(
              color: Colors.black12,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
      // M3 規範的新增日誌 FAB
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isActionLoading ? null : _showAddActionLogDialog,
        icon: const Icon(Icons.add_task),
        label: const Text('記錄新事件'),
      ),
    );
  }

  /// 視覺化 TimelineTile 元件 (藉由 Column + Icon 與 IntrinsicHeight 彈性拉伸線條)
  Widget _buildTimelineTile(ActionLog log, {bool isLast = false}) {
    final eventColor = _getEventColor(log.eventType);
    final eventIcon = _getEventIcon(log.eventType);
    final eventName = _getEventName(log.eventType);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 左側時間軸線條與圓點區
          Column(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: eventColor.withAlpha((0.15 * 255).round()),
                  shape: BoxShape.circle,
                  border: Border.all(color: eventColor, width: 2),
                ),
                child: Icon(eventIcon, size: 14, color: eventColor),
              ),
              Expanded(
                child: Container(
                  width: 2,
                  color: isLast ? Colors.transparent : Colors.grey.shade300,
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          // 右側卡片內容區
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Card.outlined(
                margin: EdgeInsets.zero,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // 使用 M3 規格的精緻微型 Chip 顯示事件類型，帶有專屬配色標記
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: eventColor.withAlpha((0.1 * 255).round()),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: eventColor.withAlpha((0.3 * 255).round()), width: 1),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(eventIcon, size: 12, color: eventColor),
                                const SizedBox(width: 4),
                                Text(
                                  eventName.replaceFirst(RegExp(r'[^\w\s]*\s*'), ''), // 去除 emoji 的純文字
                                  style: TextStyle(
                                    color: eventColor,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            '${log.timestamp.year}/${log.timestamp.month.toString().padLeft(2, '0')}/${log.timestamp.day.toString().padLeft(2, '0')} ${log.timestamp.hour.toString().padLeft(2, '0')}:${log.timestamp.minute.toString().padLeft(2, '0')}',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Colors.grey.shade600,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        log.description,
                        style: const TextStyle(fontSize: 14, height: 1.3),
                      ),
                      if (log.cost > 0) ...[
                        const SizedBox(height: 8),
                        Text(
                          '事件花費成本: \$${log.cost.toStringAsFixed(1)} USD',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Colors.blueGrey,
                          ),
                        ),
                      ],
                      if (log.aiTags.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 4,
                          children: log.aiTags.map(
                            (tag) => Chip(
                              label: Text(tag, style: const TextStyle(fontSize: 10)),
                              padding: EdgeInsets.zero,
                              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              backgroundColor: Theme.of(context).colorScheme.secondaryContainer.withAlpha((0.5 * 255).round()),
                            ),
                          ).toList(),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 輔助方法：渲染詳情行
  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey),
        const SizedBox(width: 8),
        Text('$label: ', style: const TextStyle(color: Colors.grey)),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w500),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  /// 輔助方法：獲取事件圖示
  IconData _getEventIcon(String eventType) {
    switch (eventType) {
      case 'crash':
        return Icons.report_problem;
      case 'repair':
        return Icons.build;
      case 'battery_transfer':
        return Icons.battery_charging_full;
      case 'health_check':
        return Icons.verified;
      default:
        return Icons.event_note;
    }
  }

  /// 輔助方法：獲取事件代表顏色
  Color _getEventColor(String eventType) {
    switch (eventType) {
      case 'crash':
        return Colors.red.shade700; // 紅色代表 Crash
      case 'repair':
        return Colors.blue.shade700; // 藍色代表 Repair (符合任務要求：藍色代表 Repair)
      case 'battery_transfer':
        return Colors.teal.shade700; // 藍綠色代表電池調度
      case 'health_check':
        return Colors.green.shade700; // 綠色代表健康檢查
      default:
        return Colors.grey.shade700;
    }
  }

  /// 輔助方法：獲取事件繁體中文名稱
  String _getEventName(String eventType) {
    switch (eventType) {
      case 'crash':
        return '💥 異常墜毀';
      case 'repair':
        return '🔧 設備維修';
      case 'battery_transfer':
        return '🔋 電池調配';
      case 'health_check':
        return '✅ 健康檢查';
      default:
        return '📝 一般日誌';
    }
  }
}
