import 'package:flutter/material.dart';
import '../../models/accessory_def.dart';
import '../../models/aircraft_model.dart';
import '../../models/drone_operator.dart';
import '../../models/system_dictionary.dart';
import '../../repositories/admin_repository.dart';

/// 極光後台管理面板 - 整合機型、空拍手與編號字典的動態 CRUD & 啟用狀態切換
class AdminManagementScreen extends StatefulWidget {
  final AdminRepository repository;

  const AdminManagementScreen({
    super.key,
    required this.repository,
  });

  @override
  State<AdminManagementScreen> createState() => _AdminManagementScreenState();
}

class _AdminManagementScreenState extends State<AdminManagementScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedDictCategory = 'tactical_name'; // 預設為飛機編號類別

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.admin_panel_settings_outlined),
            SizedBox(width: 8),
            Text('極光系統後台管理'),
          ],
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorSize: TabBarIndicatorSize.tab,
          tabs: const [
            Tab(
              icon: Icon(Icons.flight_outlined),
              text: '機型管理',
            ),
            Tab(
              icon: Icon(Icons.people_outline),
              text: '空拍手管理',
            ),
            Tab(
              icon: Icon(Icons.menu_book_outlined),
              text: '名稱設定',
            ),
            Tab(
              icon: Icon(Icons.category_outlined),
              text: '配件定義',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildAircraftModelTab(),
          _buildDroneOperatorTab(),
          _buildSystemDictionaryTab(),
          _buildAccessoryDefTab(),
        ],
      ),
    );
  }

  // ==========================================
  // 1. 【機型管理】分頁與對話框
  // ==========================================

  Widget _buildAircraftModelTab() {
    return StreamBuilder<List<AircraftModel>>(
      stream: widget.repository.getAircraftModelsStream(),
      builder: (context, snapshot) {
        final models = snapshot.data ?? [];
        
        // 本地排序：已啟用的排在前面，停用的排在後面；同狀態下最新建立的排在前面
        models.sort((a, b) {
          if (a.isActive && !b.isActive) return -1;
          if (!a.isActive && b.isActive) return 1;
          return b.createdAt.compareTo(a.createdAt);
        });

        // 搜集目前所有機型的自訂欄位 Key 清單
        final Set<String> globalExistingKeys = {};
        for (final m in models) {
          globalExistingKeys.addAll(m.customFields.keys);
        }

        return Scaffold(
          floatingActionButton: FloatingActionButton.extended(
            heroTag: 'add_model_fab',
            onPressed: () => _showAircraftModelDialog(globalExistingKeys: globalExistingKeys),
            icon: const Icon(Icons.add),
            label: const Text('新增出廠機型'),
          ),
          body: () {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('載入失敗: ${snapshot.error}'));
            }
            if (models.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.flight_outlined, size: 64, color: Colors.grey.shade400),
                    const SizedBox(height: 12),
                    const Text('尚無機型資料，請點擊下方按鈕新增', style: TextStyle(color: Colors.grey)),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () => _showAircraftModelDialog(globalExistingKeys: globalExistingKeys),
                      icon: const Icon(Icons.add),
                      label: const Text('新增出廠機型'),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: models.length,
              itemBuilder: (context, index) {
                final model = models[index];
                return Card.outlined(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    leading: CircleAvatar(
                      backgroundColor: model.isActive 
                          ? Theme.of(context).colorScheme.primaryContainer 
                          : Colors.grey.shade200,
                      child: Icon(
                        Icons.flight, 
                        color: model.isActive 
                            ? Theme.of(context).colorScheme.onPrimaryContainer 
                            : Colors.grey,
                      ),
                    ),
                    title: Text(
                      model.name,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('製造商: ${model.manufacturer}'),
                          if (model.customFields.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 4,
                              children: model.customFields.entries.map((entry) {
                                return Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
                                  ),
                                  child: Text(
                                    '${entry.key}: ${entry.value}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ],
                      ),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // 啟用 / 停用 切換開關
                        Switch(
                          value: model.isActive,
                          activeThumbColor: Theme.of(context).colorScheme.primary,
                          onChanged: (value) async {
                            final updatedModel = model.copyWith(isActive: value);
                            await widget.repository.updateAircraftModel(updatedModel);
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('機型「${model.name}」已${value ? '啟用' : '停用'}'),
                                duration: const Duration(seconds: 1),
                              ),
                            );
                          },
                        ),
                        const SizedBox(width: 8),
                        // 刪除按鈕 (物理刪除)
                        IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                          tooltip: '刪除機型',
                          onPressed: () async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Row(
                                  children: [
                                    Icon(Icons.warning_amber_rounded, color: Colors.redAccent),
                                    SizedBox(width: 8),
                                    Text('確認永久刪除'),
                                  ],
                                ),
                                content: Text('確定要永久刪除機型「${model.name}」嗎？\n此動作將從系統資料庫中完全抹除，且無法復原。'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context, false),
                                    child: const Text('取消'),
                                  ),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.redAccent,
                                      foregroundColor: Colors.white,
                                    ),
                                    onPressed: () => Navigator.pop(context, true),
                                    child: const Text('確定刪除'),
                                  ),
                                ],
                              ),
                            );

                            if (confirm == true) {
                              await widget.repository.deleteAircraftModel(model.documentId);
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('機型「${model.name}」已永久刪除')),
                              );
                            }
                          },
                        ),
                        const SizedBox(width: 4),
                        // 編輯按鈕
                        IconButton(
                          icon: const Icon(Icons.edit_outlined),
                          onPressed: () => _showAircraftModelDialog(model: model),
                          tooltip: '編輯機型',
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }(),
        );
      },
    );
  }

  void _showAircraftModelDialog({AircraftModel? model, Set<String>? globalExistingKeys}) {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(text: model?.name);
    final manufacturerController = TextEditingController(text: model?.manufacturer ?? 'DJI');

    // 暫存自訂欄位的 controllers
    final List<MapEntry<TextEditingController, TextEditingController>> customFieldsControllers = [];
    if (model != null) {
      // 編輯模式：只加載這筆資料自己的自訂欄位
      if (model.customFields.isNotEmpty) {
        model.customFields.forEach((key, value) {
          customFieldsControllers.add(MapEntry(
            TextEditingController(text: key),
            TextEditingController(text: value),
          ));
        });
      }
    } else if (globalExistingKeys != null && globalExistingKeys.isNotEmpty) {
      // 新增模式：預載全域記憶的所有 Keys，值留空
      for (final key in globalExistingKeys) {
        customFieldsControllers.add(MapEntry(
          TextEditingController(text: key),
          TextEditingController(),
        ));
      }
    }

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Text(model == null ? '新增出廠機型' : '編輯出廠機型'),
              content: Form(
                key: formKey,
                child: SizedBox(
                  width: 500,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextFormField(
                          controller: nameController,
                          decoration: const InputDecoration(
                            labelText: '機型名稱',
                            border: OutlineInputBorder(),
                            hintText: '如 DJI Mavic 3 Pro',
                          ),
                          validator: (val) => val == null || val.trim().isEmpty ? '請輸入機型名稱' : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: manufacturerController,
                          decoration: const InputDecoration(
                            labelText: '製造商名稱',
                            border: OutlineInputBorder(),
                            hintText: '如 DJI',
                          ),
                          validator: (val) => val == null || val.trim().isEmpty ? '請輸入製造商' : null,
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '⚙️ 自訂擴充欄位',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.primary,
                                fontSize: 16,
                              ),
                            ),
                            TextButton.icon(
                              onPressed: () {
                                setDialogState(() {
                                  customFieldsControllers.add(MapEntry(
                                    TextEditingController(),
                                    TextEditingController(),
                                  ));
                                });
                              },
                              icon: const Icon(Icons.add, size: 18),
                              label: const Text('新增欄位'),
                            ),
                          ],
                        ),
                        const Divider(),
                        if (customFieldsControllers.isEmpty)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 12),
                            child: Text(
                              '尚無自訂欄位，您可以點擊「新增欄位」自訂規格（如：重量、電池型號等）',
                              style: TextStyle(color: Colors.grey, fontSize: 13),
                            ),
                          ),
                        ...List.generate(customFieldsControllers.length, (index) {
                          final entry = customFieldsControllers[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 4,
                                  child: TextFormField(
                                    controller: entry.key,
                                    decoration: const InputDecoration(
                                      labelText: '欄位名稱',
                                      hintText: '如 重量',
                                      border: OutlineInputBorder(),
                                      contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                                    ),
                                    validator: (val) => val == null || val.trim().isEmpty ? '名稱空白' : null,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  flex: 5,
                                  child: TextFormField(
                                    controller: entry.value,
                                    decoration: const InputDecoration(
                                      labelText: '內容值',
                                      hintText: '如 249g',
                                      border: OutlineInputBorder(),
                                      contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                                    ),
                                    // 預載的欄位如果被使用者留空，表示不想在這次儲存它，因此 validator 不要報錯！
                                    // 只有當「名稱不為空」且「是使用者主動打的新自訂欄位」才需要驗證，但為了彈性，
                                    // 我們過濾儲存即可，所以這裏不對預載/空白進行嚴格 validator 攔截。
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                                  onPressed: () {
                                    setDialogState(() {
                                      customFieldsControllers.removeAt(index);
                                    });
                                  },
                                ),
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
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

                    final name = nameController.text.trim();
                    final manufacturer = manufacturerController.text.trim();

                    // 將自訂欄位組合成 Map，排除欄位名稱或內容值為空的項目
                    final Map<String, String> customFields = {};
                    for (final entry in customFieldsControllers) {
                      final k = entry.key.text.trim();
                      final v = entry.value.text.trim();
                      if (k.isNotEmpty && v.isNotEmpty) {
                        customFields[k] = v;
                      }
                    }

                    if (model == null) {
                      // 新增
                      final newModel = AircraftModel(
                        documentId: 'MODEL-${DateTime.now().millisecondsSinceEpoch}',
                        name: name,
                        manufacturer: manufacturer,
                        createdAt: DateTime.now(),
                        isActive: true,
                        customFields: customFields,
                      );
                      await widget.repository.addAircraftModel(newModel);
                    } else {
                      // 編輯
                      final updatedModel = model.copyWith(
                        name: name,
                        manufacturer: manufacturer,
                        customFields: customFields,
                      );
                      await widget.repository.updateAircraftModel(updatedModel);
                    }

                    if (!context.mounted) return;
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('機型「$name」儲存成功')),
                    );
                  },
                  child: const Text('儲存'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ==========================================
  // 2. 【空拍手管理】分頁與對話框
  // ==========================================

  Widget _buildDroneOperatorTab() {
    return StreamBuilder<List<DroneOperator>>(
      stream: widget.repository.getDroneOperatorsStream(),
      builder: (context, snapshot) {
        final operators = snapshot.data ?? [];
        
        // 本地排序：已啟用的排在前面，停用的排在後面；同狀態下最新建立的排在前面
        operators.sort((a, b) {
          if (a.isActive && !b.isActive) return -1;
          if (!a.isActive && b.isActive) return 1;
          return b.createdAt.compareTo(a.createdAt);
        });

        // 搜集目前所有空拍手的自訂欄位 Key 清單
        final Set<String> globalExistingKeys = {};
        for (final op in operators) {
          globalExistingKeys.addAll(op.customFields.keys);
        }

        return Scaffold(
          floatingActionButton: FloatingActionButton.extended(
            heroTag: 'add_operator_fab',
            onPressed: () => _showDroneOperatorDialog(globalExistingKeys: globalExistingKeys),
            icon: const Icon(Icons.add),
            label: const Text('新增空拍手'),
          ),
          body: () {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('載入失敗: ${snapshot.error}'));
            }
            if (operators.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.people_outline, size: 64, color: Colors.grey.shade400),
                    const SizedBox(height: 12),
                    const Text('尚無空拍手資料，請點擊下方按鈕新增', style: TextStyle(color: Colors.grey)),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () => _showDroneOperatorDialog(globalExistingKeys: globalExistingKeys),
                      icon: const Icon(Icons.add),
                      label: const Text('新增空拍手'),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: operators.length,
              itemBuilder: (context, index) {
                final operator = operators[index];
                return Card.outlined(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    leading: CircleAvatar(
                      backgroundColor: operator.isActive 
                          ? Theme.of(context).colorScheme.primaryContainer 
                          : Colors.grey.shade200,
                      child: Icon(
                        Icons.person, 
                        color: operator.isActive 
                            ? Theme.of(context).colorScheme.onPrimaryContainer 
                            : Colors.grey,
                      ),
                    ),
                    title: Text(
                      operator.name,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('電話: ${operator.phone}'),
                          const SizedBox(height: 2),
                          Text('證照號碼: ${operator.licenseNumber}'),
                          if (operator.customFields.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 4,
                              children: operator.customFields.entries.map((entry) {
                                return Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
                                  ),
                                  child: Text(
                                    '${entry.key}: ${entry.value}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ],
                      ),
                    ),
                    isThreeLine: true,
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // 啟用 / 停用 切換開關
                        Switch(
                          value: operator.isActive,
                          activeThumbColor: Theme.of(context).colorScheme.primary,
                          onChanged: (value) async {
                            final updatedOperator = operator.copyWith(isActive: value);
                            await widget.repository.updateDroneOperator(updatedOperator);
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('空拍手「${operator.name}」已${value ? '啟用' : '停用'}'),
                                duration: const Duration(seconds: 1),
                              ),
                            );
                          },
                        ),
                        const SizedBox(width: 8),
                        // 刪除按鈕 (物理刪除)
                        IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                          tooltip: '刪除空拍手',
                          onPressed: () async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Row(
                                  children: [
                                    Icon(Icons.warning_amber_rounded, color: Colors.redAccent),
                                    SizedBox(width: 8),
                                    Text('確認永久刪除'),
                                  ],
                                ),
                                content: Text('確定要永久刪除空拍手「${operator.name}」嗎？\n此動作將從系統資料庫中完全抹除，且無法復原。'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context, false),
                                    child: const Text('取消'),
                                  ),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.redAccent,
                                      foregroundColor: Colors.white,
                                    ),
                                    onPressed: () => Navigator.pop(context, true),
                                    child: const Text('確定刪除'),
                                  ),
                                ],
                              ),
                            );

                            if (confirm == true) {
                              await widget.repository.deleteDroneOperator(operator.documentId);
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('空拍手「${operator.name}」已永久刪除')),
                              );
                            }
                          },
                        ),
                        const SizedBox(width: 4),
                        // 編輯按鈕
                        IconButton(
                          icon: const Icon(Icons.edit_outlined),
                          onPressed: () => _showDroneOperatorDialog(operator: operator),
                          tooltip: '編輯空拍手',
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }(),
        );
      },
    );
  }

  void _showDroneOperatorDialog({DroneOperator? operator, Set<String>? globalExistingKeys}) {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(text: operator?.name);
    final phoneController = TextEditingController(text: operator?.phone);
    final licenseController = TextEditingController(text: operator?.licenseNumber);

    // 暫存自訂欄位的 controllers
    final List<MapEntry<TextEditingController, TextEditingController>> customFieldsControllers = [];
    if (operator != null) {
      // 編輯模式：只加載這筆資料自己的自訂欄位
      if (operator.customFields.isNotEmpty) {
        operator.customFields.forEach((key, value) {
          customFieldsControllers.add(MapEntry(
            TextEditingController(text: key),
            TextEditingController(text: value),
          ));
        });
      }
    } else if (globalExistingKeys != null && globalExistingKeys.isNotEmpty) {
      // 新增模式：預載全域記憶的所有 Keys，值留空
      for (final key in globalExistingKeys) {
        customFieldsControllers.add(MapEntry(
          TextEditingController(text: key),
          TextEditingController(),
        ));
      }
    }

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Text(operator == null ? '新增空拍手' : '編輯空拍手資料'),
              content: Form(
                key: formKey,
                child: SizedBox(
                  width: 500,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextFormField(
                          controller: nameController,
                          decoration: const InputDecoration(
                            labelText: '空拍手姓名',
                            border: OutlineInputBorder(),
                          ),
                          validator: (val) => val == null || val.trim().isEmpty ? '請輸入姓名' : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: phoneController,
                          keyboardType: TextInputType.phone,
                          decoration: const InputDecoration(
                            labelText: '聯絡電話',
                            border: OutlineInputBorder(),
                            hintText: '如 0912-345-678',
                          ),
                          validator: (val) => val == null || val.trim().isEmpty ? '請輸入電話' : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: licenseController,
                          decoration: const InputDecoration(
                            labelText: '操作人合格證照號碼',
                            border: OutlineInputBorder(),
                            hintText: '如 UUA123456789',
                          ),
                          validator: (val) => val == null || val.trim().isEmpty ? '請輸入證照號碼' : null,
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '⚙️ 自訂擴充欄位',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.primary,
                                fontSize: 16,
                              ),
                            ),
                            TextButton.icon(
                              onPressed: () {
                                setDialogState(() {
                                  customFieldsControllers.add(MapEntry(
                                    TextEditingController(),
                                    TextEditingController(),
                                  ));
                                });
                              },
                              icon: const Icon(Icons.add, size: 18),
                              label: const Text('新增欄位'),
                            ),
                          ],
                        ),
                        const Divider(),
                        if (customFieldsControllers.isEmpty)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 12),
                            child: Text(
                              '尚無自訂欄位，您可以點擊「新增欄位」自訂規格（如：居住地、血型等）',
                              style: TextStyle(color: Colors.grey, fontSize: 13),
                            ),
                          ),
                        ...List.generate(customFieldsControllers.length, (index) {
                          final entry = customFieldsControllers[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 4,
                                  child: TextFormField(
                                    controller: entry.key,
                                    decoration: const InputDecoration(
                                      labelText: '欄位名稱',
                                      hintText: '如 居住地',
                                      border: OutlineInputBorder(),
                                      contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                                    ),
                                    validator: (val) => val == null || val.trim().isEmpty ? '名稱空白' : null,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  flex: 5,
                                  child: TextFormField(
                                    controller: entry.value,
                                    decoration: const InputDecoration(
                                      labelText: '內容值',
                                      hintText: '如 台北市',
                                      border: OutlineInputBorder(),
                                      contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                                  onPressed: () {
                                    setDialogState(() {
                                      customFieldsControllers.removeAt(index);
                                    });
                                  },
                                ),
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
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

                    final name = nameController.text.trim();
                    final phone = phoneController.text.trim();
                    final license = licenseController.text.trim();

                    // 將自訂欄位組合成 Map
                    final Map<String, String> customFields = {};
                    for (final entry in customFieldsControllers) {
                      final k = entry.key.text.trim();
                      final v = entry.value.text.trim();
                      if (k.isNotEmpty && v.isNotEmpty) {
                        customFields[k] = v;
                      }
                    }

                    if (operator == null) {
                      // 新增
                      final newOp = DroneOperator(
                        documentId: 'OP-${DateTime.now().millisecondsSinceEpoch}',
                        name: name,
                        phone: phone,
                        licenseNumber: license,
                        createdAt: DateTime.now(),
                        isActive: true,
                        customFields: customFields,
                      );
                      await widget.repository.addDroneOperator(newOp);
                    } else {
                      // 編輯
                      final updatedOp = operator.copyWith(
                        name: name,
                        phone: phone,
                        licenseNumber: license,
                        customFields: customFields,
                      );
                      await widget.repository.updateDroneOperator(updatedOp);
                    }

                    if (!context.mounted) return;
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('空拍手「$name」儲存成功')),
                    );
                  },
                  child: const Text('儲存'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ==========================================
  // 3. 【名稱設定】分頁與對話框
  // ==========================================

  Widget _buildSystemDictionaryTab() {
    final isTacticalName = _selectedDictCategory == 'tactical_name';
    final categoryLabel = isTacticalName ? '飛機編號' : '電池型號';

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'add_dict_fab',
        onPressed: () => _showSystemDictionaryDialog(),
        icon: const Icon(Icons.add),
        label: Text('新增$categoryLabel'),
      ),
      body: Column(
        children: [
          // 頂部小提醒與分類切換
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
            child: Column(
              children: [
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(value: 'tactical_name', label: Text('飛機編號設定')),
                    ButtonSegment(value: 'battery_model', label: Text('電池型號設定')),
                  ],
                  selected: {_selectedDictCategory},
                  onSelectionChanged: (Set<String> newSelection) {
                    setState(() {
                      _selectedDictCategory = newSelection.first;
                    });
                  },
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.info_outline, color: Theme.of(context).colorScheme.primary, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        isTacticalName 
                          ? '此處管理的編號為前台登錄新母艦時使用的「飛機編號」下拉選項，最新建立之編號會優先顯示在選單最前方。'
                          : '此處管理的型號為前台登錄新電池時使用的「電池型號」下拉選項，最新建立之型號會優先顯示在選單最前方。',
                        style: const TextStyle(fontSize: 12, color: Colors.black87),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<List<SystemDictionary>>(
              stream: widget.repository.getSystemDictionariesStream(_selectedDictCategory),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('載入失敗: ${snapshot.error}'));
                }
                final list = snapshot.data ?? [];
                
                // 本地排序：已啟用的排在前面，停用的排在後面；同狀態下最新建立的排在前面
                list.sort((a, b) {
                  if (a.isActive && !b.isActive) return -1;
                  if (!a.isActive && b.isActive) return 1;
                  return b.createdAt.compareTo(a.createdAt);
                });

                if (list.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.menu_book_outlined, size: 64, color: Colors.grey.shade400),
                        const SizedBox(height: 12),
                        Text('尚無任何$categoryLabel，請點擊下方按鈕新增', style: const TextStyle(color: Colors.grey)),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () => _showSystemDictionaryDialog(),
                          icon: const Icon(Icons.add),
                          label: Text('新增$categoryLabel'),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: list.length,
                  itemBuilder: (context, index) {
                    final dict = list[index];
                    return Card.outlined(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        leading: CircleAvatar(
                          backgroundColor: dict.isActive 
                              ? Theme.of(context).colorScheme.primaryContainer 
                              : Colors.grey.shade200,
                          child: Icon(
                            Icons.label_important, 
                            color: dict.isActive 
                                ? Theme.of(context).colorScheme.onPrimaryContainer 
                                : Colors.grey,
                          ),
                        ),
                        title: Text(
                          dict.label,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text('系統識別碼: ${dict.value}'),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // 啟用 / 停用 切換開關
                            Switch(
                              value: dict.isActive,
                              activeThumbColor: Theme.of(context).colorScheme.primary,
                              onChanged: (value) async {
                                final updatedDict = dict.copyWith(isActive: value);
                                await widget.repository.updateSystemDictionary(updatedDict);
                                if (!context.mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('戰術編號「${dict.label}」已${value ? '啟用' : '停用'}'),
                                    duration: const Duration(seconds: 1),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(width: 8),
                            // 刪除按鈕 (物理刪除)
                            IconButton(
                              icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                              tooltip: '刪除編號',
                              onPressed: () async {
                                final confirm = await showDialog<bool>(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Row(
                                      children: [
                                        Icon(Icons.warning_amber_rounded, color: Colors.redAccent),
                                        SizedBox(width: 8),
                                        Text('確認永久刪除'),
                                      ],
                                    ),
                                    content: Text('確定要永久刪除$categoryLabel「${dict.label}」嗎？\n此動作將從系統資料庫中完全抹除，且無法復原。'),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context, false),
                                        child: const Text('取消'),
                                      ),
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.redAccent,
                                          foregroundColor: Colors.white,
                                        ),
                                        onPressed: () => Navigator.pop(context, true),
                                        child: const Text('確定刪除'),
                                      ),
                                    ],
                                  ),
                                );

                                if (confirm == true) {
                                  await widget.repository.deleteSystemDictionary(dict.documentId);
                                  if (!context.mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('$categoryLabel「${dict.label}」已永久刪除')),
                                  );
                                }
                              },
                            ),
                            const SizedBox(width: 4),
                            // 編輯按鈕
                            IconButton(
                              icon: const Icon(Icons.edit_outlined),
                              onPressed: () => _showSystemDictionaryDialog(dict: dict),
                              tooltip: '編輯編號',
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showSystemDictionaryDialog({SystemDictionary? dict}) {
    final categoryLabel = _selectedDictCategory == 'tactical_name' ? '飛機編號' : '電池型號';
    final formKey = GlobalKey<FormState>();
    final labelController = TextEditingController(text: dict?.label);
    final valueController = TextEditingController(text: dict?.value);

    // 當 label 修改時，如果 value 沒有被手動編輯過，可以自動同名拼音/英文對應
    bool isValueEditedManually = dict != null;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(dict == null ? '新增$categoryLabel' : '編輯$categoryLabel'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: labelController,
                  decoration: const InputDecoration(
                    labelText: '戰術編號顯示名稱',
                    border: OutlineInputBorder(),
                    hintText: '如 雷霆-05',
                  ),
                  onChanged: (val) {
                    if (!isValueEditedManually) {
                      // 自動生成對應的系統代碼
                      valueController.text = val.trim().replaceAll(' ', '-').toLowerCase();
                    }
                  },
                  validator: (val) => val == null || val.trim().isEmpty ? '請輸入顯示名稱' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: valueController,
                  decoration: const InputDecoration(
                    labelText: '系統識別代碼 (不可重複)',
                    border: OutlineInputBorder(),
                    hintText: '如 thunder-05',
                  ),
                  onChanged: (val) {
                    isValueEditedManually = true;
                  },
                  validator: (val) => val == null || val.trim().isEmpty ? '請輸入系統代碼' : null,
                ),
              ],
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

                final label = labelController.text.trim();
                final value = valueController.text.trim();

                if (dict == null) {
                  // 新增
                  final newDict = SystemDictionary(
                    documentId: 'DICT-${DateTime.now().millisecondsSinceEpoch}',
                    category: _selectedDictCategory,
                    label: label,
                    value: value,
                    createdAt: DateTime.now(),
                    isActive: true,
                  );
                  await widget.repository.addSystemDictionary(newDict);
                } else {
                  // 編輯
                  final updatedDict = dict.copyWith(
                    label: label,
                    value: value,
                  );
                  await widget.repository.updateSystemDictionary(updatedDict);
                }

                if (!context.mounted) return;
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('戰術編號「$label」儲存成功')),
                );
              },
              child: const Text('儲存'),
            ),
          ],
        );
      },
    );
  }

  // ==========================================
  // 4. 【配件定義管理】分頁與對話框
  // ==========================================

  Widget _buildAccessoryDefTab() {
    return StreamBuilder<List<AccessoryDef>>(
      stream: widget.repository.getAccessoryDefsStream(),
      builder: (context, snapshot) {
        final defs = snapshot.data ?? [];
        
        defs.sort((a, b) {
          if (a.isActive && !b.isActive) return -1;
          if (!a.isActive && b.isActive) return 1;
          return b.createdAt.compareTo(a.createdAt);
        });

        return Scaffold(
          floatingActionButton: FloatingActionButton.extended(
            heroTag: 'add_accessory_def_fab',
            onPressed: () => _showAccessoryDefDialog(),
            icon: const Icon(Icons.add),
            label: const Text('新增配件'),
          ),
          body: () {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('載入失敗: ${snapshot.error}'));
            }
            if (defs.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.category_outlined, size: 64, color: Colors.grey.shade400),
                    const SizedBox(height: 12),
                    const Text('尚無配件定義資料，請點擊下方按鈕新增', style: TextStyle(color: Colors.grey)),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () => _showAccessoryDefDialog(),
                      icon: const Icon(Icons.add),
                      label: const Text('新增配件'),
                    ),
                  ],
                ),
              );
            }

            // 將配件依據機型進行分組
            final groupedDefs = <String, List<AccessoryDef>>{};
            for (final def in defs) {
              groupedDefs.putIfAbsent(def.aircraftModelName, () => []).add(def);
            }

            final sortedKeys = groupedDefs.keys.toList()..sort();

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: sortedKeys.length,
              itemBuilder: (context, index) {
                final modelName = sortedKeys[index];
                final modelDefs = groupedDefs[modelName]!;
                
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 8, top: 16, bottom: 12),
                      child: Row(
                        children: [
                          Icon(Icons.flight, color: Theme.of(context).colorScheme.primary),
                          const SizedBox(width: 8),
                          Text(
                            modelName,
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    ...modelDefs.map((def) => Card.outlined(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        leading: CircleAvatar(
                          backgroundColor: def.isActive 
                              ? Theme.of(context).colorScheme.primaryContainer 
                              : Colors.grey.shade200,
                          child: Icon(
                            Icons.category, 
                            color: def.isActive 
                                ? Theme.of(context).colorScheme.onPrimaryContainer 
                                : Colors.grey,
                          ),
                        ),
                        title: Text(
                          def.name,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Switch(
                              value: def.isActive,
                              activeThumbColor: Theme.of(context).colorScheme.primary,
                              onChanged: (value) async {
                                final updatedDef = def.copyWith(isActive: value);
                                await widget.repository.updateAccessoryDef(updatedDef);
                                if (!context.mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('配件「${def.name}」已${value ? '啟用' : '停用'}'),
                                    duration: const Duration(seconds: 1),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                              tooltip: '刪除配件',
                              onPressed: () async {
                                final confirm = await showDialog<bool>(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Row(
                                      children: [
                                        Icon(Icons.warning_amber_rounded, color: Colors.redAccent),
                                        SizedBox(width: 8),
                                        Text('確認永久刪除'),
                                      ],
                                    ),
                                    content: Text('確定要永久刪除配件「${def.name}」嗎？'),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context, false),
                                        child: const Text('取消'),
                                      ),
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.redAccent,
                                          foregroundColor: Colors.white,
                                        ),
                                        onPressed: () => Navigator.pop(context, true),
                                        child: const Text('確定刪除'),
                                      ),
                                    ],
                                  ),
                                );

                                if (confirm == true) {
                                  await widget.repository.deleteAccessoryDef(def.documentId);
                                  if (!context.mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('配件「${def.name}」已永久刪除')),
                                  );
                                }
                              },
                            ),
                            const SizedBox(width: 4),
                            IconButton(
                              icon: const Icon(Icons.edit_outlined),
                              onPressed: () => _showAccessoryDefDialog(def: def),
                              tooltip: '編輯配件',
                            ),
                          ],
                        ),
                      ),
                    )).toList(),
                  ],
                );
              },
            );
          }(),
        );
      },
    );
  }

  void _showAccessoryDefDialog({AccessoryDef? def}) {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(text: def?.name);
    String? selectedModel = def?.aircraftModelName;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Text(def == null ? '新增配件定義' : '編輯配件定義'),
              content: StreamBuilder<List<AircraftModel>>(
                stream: widget.repository.getActiveAircraftModelsStream(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const SizedBox(height: 100, child: Center(child: CircularProgressIndicator()));
                  }
                  final models = snapshot.data ?? [];
                  if (models.isEmpty) {
                    return const SizedBox(
                      width: 400,
                      child: Text('目前沒有任何啟用的出廠機型，請先至「機型管理」新增。', style: TextStyle(color: Colors.red)),
                    );
                  }

                  if (selectedModel == null && models.isNotEmpty) {
                    selectedModel = models.first.name;
                  }

                  return Form(
                    key: formKey,
                    child: SizedBox(
                      width: 400,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          DropdownButtonFormField<String>(
                            value: selectedModel,
                            decoration: const InputDecoration(
                              labelText: '專屬出廠機型',
                              border: OutlineInputBorder(),
                            ),
                            items: models.map((m) {
                              return DropdownMenuItem<String>(
                                value: m.name,
                                child: Text(m.name),
                              );
                            }).toList(),
                            onChanged: (val) {
                              setDialogState(() {
                                selectedModel = val;
                              });
                            },
                            validator: (val) => val == null ? '請選擇機型' : null,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: nameController,
                            decoration: const InputDecoration(
                              labelText: '配件名稱',
                              hintText: '如 螺旋槳、充電管家',
                              border: OutlineInputBorder(),
                            ),
                            validator: (val) => val == null || val.trim().isEmpty ? '請輸入配件名稱' : null,
                          ),
                        ],
                      ),
                    ),
                  );
                }
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('取消'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (formKey.currentState?.validate() ?? false) {
                      final name = nameController.text.trim();
                      
                      if (def == null) {
                        final newDef = AccessoryDef(
                          documentId: 'ACC-${DateTime.now().millisecondsSinceEpoch}',
                          name: name,
                          aircraftModelName: selectedModel!,
                          createdAt: DateTime.now(),
                          isActive: true,
                        );
                        await widget.repository.addAccessoryDef(newDef);
                      } else {
                        final updatedDef = def.copyWith(
                          name: name,
                          aircraftModelName: selectedModel!,
                        );
                        await widget.repository.updateAccessoryDef(updatedDef);
                      }

                      if (!context.mounted) return;
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('配件「$name」儲存成功')),
                      );
                    }
                  },
                  child: const Text('儲存'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
