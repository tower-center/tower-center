import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/battery.dart';
import '../models/system_dictionary.dart';
import '../repositories/fleet_repository.dart';

class RegisterBatteryDialog extends StatefulWidget {
  final FleetRepository repository;

  const RegisterBatteryDialog({
    super.key,
    required this.repository,
  });

  @override
  State<RegisterBatteryDialog> createState() => _RegisterBatteryDialogState();
}

class _RegisterBatteryDialogState extends State<RegisterBatteryDialog> {
  final _formKey = GlobalKey<FormState>();
  final _tagController = TextEditingController();
  final _snController = TextEditingController();
  
  List<SystemDictionary> _activeBatteryModels = [];
  bool _isFetchingModels = true;
  String? _selectedModel;
  
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadBatteryModels();
  }

  Future<void> _loadBatteryModels() async {
    try {
      final snap = await FirebaseFirestore.instance
          .collection('system_dictionaries')
          .where('category', isEqualTo: 'battery_model')
          .where('isActive', isEqualTo: true)
          .get();
      
      final models = snap.docs.map((doc) => SystemDictionary.fromJson(doc.data())).toList();
      models.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      
      setState(() {
        _activeBatteryModels = models;
        if (models.isNotEmpty) _selectedModel = models.first.label;
        _isFetchingModels = false;
      });
    } catch (e) {
      setState(() => _isFetchingModels = false);
    }
  }

  void _scanBatterySn() async {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('相機啟動中...')));
    await Future.delayed(const Duration(seconds: 1));
    _snController.text = 'BTY-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}';
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);
    
    try {
      final newBattery = Battery(
        documentId: 'BTY-${DateTime.now().millisecondsSinceEpoch}',
        serialNumber: _snController.text.trim(),
        tagName: _tagController.text.trim(),
        batteryModel: _selectedModel ?? '未知電池型號',
        cycleCount: 0,
        healthStatus: '全新健康 (無膨脹)',
        currentPackageId: null, // 未分配給任何套裝
        purchaseDate: DateTime.now(),
      );
      
      await widget.repository.addBattery(newBattery);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('成功登錄電池: ${newBattery.tagName}')));
        Navigator.pop(context, newBattery);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('登錄失敗: $e')));
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.battery_charging_full, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 8),
          const Text('登錄全新電池'),
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
                TextFormField(
                  controller: _tagController,
                  decoration: const InputDecoration(labelText: '外場標籤 (如 M301)', border: OutlineInputBorder()),
                  validator: (v) => v == null || v.trim().isEmpty ? '必填' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _snController,
                  decoration: InputDecoration(
                    labelText: '出廠序號 (S/N)',
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(icon: const Icon(Icons.qr_code_scanner), onPressed: _scanBatterySn),
                  ),
                  validator: (v) => v == null || v.trim().isEmpty ? '必填' : null,
                ),
                const SizedBox(height: 16),
                _isFetchingModels 
                  ? const CircularProgressIndicator()
                  : _activeBatteryModels.isEmpty
                    ? const Text('❌ 無啟用的電池型號字典', style: TextStyle(color: Colors.red))
                    : DropdownButtonFormField<String>(
                        value: _selectedModel,
                        decoration: const InputDecoration(labelText: '電池型號', border: OutlineInputBorder()),
                        items: _activeBatteryModels.map((m) {
                          return DropdownMenuItem(
                            value: m.label,
                            child: Text(m.label),
                          );
                        }).toList(),
                        onChanged: (val) => setState(() => _selectedModel = val),
                        validator: (val) => val == null ? '請選擇電池型號' : null,
                      ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: _isLoading ? null : () => Navigator.pop(context), child: const Text('取消')),
        ElevatedButton(
          onPressed: _isLoading ? null : _submit,
          child: _isLoading ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('確認登錄'),
        ),
      ],
    );
  }
}
