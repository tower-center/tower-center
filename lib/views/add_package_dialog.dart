import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/drone_package.dart';
import '../models/aircraft_model.dart';
import '../models/drone_operator.dart';
import '../models/system_dictionary.dart';
import '../models/accessory_def.dart';
import '../repositories/fleet_repository.dart';

/// 建立全新套裝表單 Dialog
class AddPackageDialog extends StatefulWidget {
  final FleetRepository repository;

  final DronePackage? package;

  const AddPackageDialog({
    super.key,
    required this.repository,
    this.package,
  });

  @override
  State<AddPackageDialog> createState() => _AddPackageDialogState();
}

class _AddPackageDialogState extends State<AddPackageDialog> {
  final _formKey = GlobalKey<FormState>();

  List<AircraftModel> _activeModels = [];
  List<DroneOperator> _activeOperators = [];
  List<SystemDictionary> _activeTacticalNames = [];
  bool _isFetchingOptions = true;

  String? _selectedModel;
  String? _selectedKeeper;
  String? _selectedTacticalName;
  
  Map<String, int> _accessoriesCount = {};

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadDropdownOptions();
  }

  Future<void> _loadDropdownOptions() async {
    try {
      final modelsSnap = await FirebaseFirestore.instance
          .collection('aircraft_models')
          .where('isActive', isEqualTo: true)
          .get();
      final operatorsSnap = await FirebaseFirestore.instance
          .collection('drone_operators')
          .where('isActive', isEqualTo: true)
          .get();
      final dictSnap = await FirebaseFirestore.instance
          .collection('system_dictionaries')
          .where('category', isEqualTo: 'tactical_name')
          .where('isActive', isEqualTo: true)
          .get();

      final models = modelsSnap.docs.map((doc) => AircraftModel.fromJson(doc.data())).toList();
      final operators = operatorsSnap.docs.map((doc) => DroneOperator.fromJson(doc.data())).toList();
      final dict = dictSnap.docs.map((doc) => SystemDictionary.fromJson(doc.data())).toList();

      models.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      operators.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      dict.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      setState(() {
        _activeModels = models;
        _activeOperators = operators;
        _activeTacticalNames = dict;

        if (widget.package != null) {
          // Edit mode
          _selectedModel = widget.package!.modelType;
          // Ensure selected values exist in active options, otherwise null
          if (dict.any((d) => d.label == widget.package!.tacticalName)) {
            _selectedTacticalName = widget.package!.tacticalName;
          }
          if (operators.any((o) => o.name == widget.package!.currentKeeper)) {
            _selectedKeeper = widget.package!.currentKeeper;
          }
          _accessoriesCount = Map.from(widget.package!.accessories);
        } else {
          // Create mode
          if (models.isNotEmpty) _selectedModel = models.first.name;
          if (operators.isNotEmpty) _selectedKeeper = operators.first.name;
          if (dict.isNotEmpty) _selectedTacticalName = dict.first.label;
        }

        _isFetchingOptions = false;
      });
    } catch (e) {
      setState(() {
        _isFetchingOptions = false;
      });
      debugPrint('Error loading options: $e');
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final filteredAccessories = Map<String, int>.fromEntries(
        _accessoriesCount.entries.where((entry) => entry.value > 0),
      );

      if (widget.package == null) {
        // 新增
        final newPackage = DronePackage(
          documentId: 'PKG-${DateTime.now().millisecondsSinceEpoch}',
          modelType: _selectedModel ?? '',
          tacticalName: _selectedTacticalName ?? '',
          currentKeeper: _selectedKeeper ?? '',
          accessories: filteredAccessories,
          createdAt: DateTime.now(),
        );

        await widget.repository.addPackage(newPackage);

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('成功建立套裝: ${newPackage.tacticalName}'),
            backgroundColor: Theme.of(context).colorScheme.primary,
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.of(context).pop(newPackage);
      } else {
        // 編輯
        final updatedPackage = widget.package!.copyWith(
          tacticalName: _selectedTacticalName ?? '',
          currentKeeper: _selectedKeeper ?? '',
          accessories: filteredAccessories,
        );

        await widget.repository.updatePackage(updatedPackage);

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('成功更新套裝: ${updatedPackage.tacticalName}'),
            backgroundColor: Theme.of(context).colorScheme.primary,
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.of(context).pop(updatedPackage);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('建立失敗: $e'),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: Row(
        children: [
          Icon(Icons.inventory_2_outlined, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 8),
          Text(widget.package == null ? '登錄全新套裝' : '編輯套裝'),
        ],
      ),
      content: SizedBox(
        width: 320,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_isFetchingOptions)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Center(
                      child: Column(
                        children: [
                          CircularProgressIndicator(strokeWidth: 3),
                          SizedBox(height: 8),
                          Text('正在載入基礎資料庫選項...', style: TextStyle(fontSize: 12, color: Colors.grey)),
                        ],
                      ),
                    ),
                  )
                else ...[
                  // 1. 飛機編號
                  _activeTacticalNames.isEmpty
                      ? const Padding(
                          padding: EdgeInsets.only(bottom: 16),
                          child: Text('❌ 無啟用的飛機編號', style: TextStyle(color: Colors.red, fontSize: 13)),
                        )
                      : DropdownButtonFormField<String>(
                          value: _selectedTacticalName,
                          decoration: const InputDecoration(
                            labelText: '飛機編號',
                            prefixIcon: Icon(Icons.label_important_outline),
                            border: OutlineInputBorder(),
                          ),
                          items: _activeTacticalNames.map((d) {
                            return DropdownMenuItem<String>(
                              value: d.label,
                              child: Text(d.label),
                            );
                          }).toList(),
                          onChanged: (val) {
                            setState(() {
                              _selectedTacticalName = val;
                            });
                          },
                          validator: (val) => val == null ? '請選擇飛機編號' : null,
                        ),
                  const SizedBox(height: 16),
                  
                  // 2. 出廠機型
                  _activeModels.isEmpty
                      ? const Padding(
                          padding: EdgeInsets.only(bottom: 16),
                          child: Text('❌ 無啟用的機型', style: TextStyle(color: Colors.red, fontSize: 13)),
                        )
                      : DropdownButtonFormField<String>(
                          value: _selectedModel,
                          decoration: const InputDecoration(
                            labelText: '出廠機型',
                            prefixIcon: Icon(Icons.flight),
                            border: OutlineInputBorder(),
                          ),
                          items: _activeModels.map((m) {
                            return DropdownMenuItem<String>(
                              value: m.name,
                              child: Text(m.name),
                            );
                          }).toList(),
                          onChanged: widget.package != null ? null : (val) {
                            setState(() {
                              _selectedModel = val;
                              _accessoriesCount.clear(); // 清空舊有機型選配
                            });
                          },
                          validator: (val) => val == null ? '請選擇出廠機型' : null,
                        ),
                  const SizedBox(height: 16),
                  
                  // 3. 目前保管人
                  _activeOperators.isEmpty
                      ? const Padding(
                          padding: EdgeInsets.only(bottom: 16),
                          child: Text('❌ 無啟用的空拍手', style: TextStyle(color: Colors.red, fontSize: 13)),
                        )
                      : DropdownButtonFormField<String>(
                          value: _selectedKeeper,
                          decoration: const InputDecoration(
                            labelText: '目前保管人',
                            prefixIcon: Icon(Icons.person_outline),
                            border: OutlineInputBorder(),
                          ),
                          items: _activeOperators.map((op) {
                            return DropdownMenuItem<String>(
                              value: op.name,
                              child: Text(op.name),
                            );
                          }).toList(),
                          onChanged: (val) {
                            setState(() {
                              _selectedKeeper = val;
                            });
                          },
                          validator: (val) => val == null ? '請指定保管責任人' : null,
                        ),
                  const SizedBox(height: 16),
                  
                  // 4. 動態載入專屬配件
                  if (_selectedModel != null)
                    StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('accessory_defs')
                          .where('aircraftModelName', isEqualTo: _selectedModel)
                          .where('isActive', isEqualTo: true)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.hasError) return const Text('讀取配件失敗');
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const CircularProgressIndicator();
                        }
                        
                        final defs = snapshot.data?.docs.map((doc) => AccessoryDef.fromJson(doc.data() as Map<String, dynamic>)).toList() ?? [];
                        
                        if (defs.isEmpty) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 8.0),
                            child: Text('此機型無設定專屬配件', style: TextStyle(color: Colors.grey)),
                          );
                        }

                        return Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('套裝專屬配件數量', style: Theme.of(context).textTheme.titleSmall?.copyWith(color: Theme.of(context).colorScheme.primary)),
                              const SizedBox(height: 8),
                              ...defs.map((def) {
                                final currentCount = _accessoriesCount[def.name] ?? 0;
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 8.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(child: Text(def.name)),
                                      Row(
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.remove_circle_outline),
                                            onPressed: currentCount > 0
                                                ? () => setState(() => _accessoriesCount[def.name] = currentCount - 1)
                                                : null,
                                          ),
                                          SizedBox(
                                            width: 30,
                                            child: Text(
                                              '$currentCount',
                                              textAlign: TextAlign.center,
                                              style: const TextStyle(fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.add_circle_outline),
                                            onPressed: () => setState(() => _accessoriesCount[def.name] = currentCount + 1),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                );
                              }),
                            ],
                          ),
                        );
                      },
                    ),
                ],
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('取消'),
        ),
        ElevatedButton(
          onPressed: (_isLoading || _isFetchingOptions || _activeModels.isEmpty || _activeOperators.isEmpty || _activeTacticalNames.isEmpty)
              ? null
              : _submitForm,
          style: ElevatedButton.styleFrom(
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('完成儲存'),
        ),
      ],
    );
  }
}
