import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/battery.dart';
import '../models/system_dictionary.dart';
import '../repositories/fleet_repository.dart';

class AddBatteryToPackageDialog extends StatefulWidget {
  final FleetRepository repository;
  final String packageId;

  const AddBatteryToPackageDialog({
    super.key,
    required this.repository,
    required this.packageId,
  });

  @override
  State<AddBatteryToPackageDialog> createState() => _AddBatteryToPackageDialogState();
}

class _AddBatteryToPackageDialogState extends State<AddBatteryToPackageDialog> {
  bool _isNewBattery = false;
  bool _isLoading = false;
  
  // Existing battery selection
  List<Battery> _unassignedBatteries = [];
  bool _isFetching = true;
  Battery? _selectedBattery;

  final _formKey = GlobalKey<FormState>();
  final _tagController = TextEditingController();
  final _snController = TextEditingController();
  
  List<SystemDictionary> _activeBatteryModels = [];
  bool _isFetchingModels = true;
  String? _selectedModel;

  @override
  void initState() {
    super.initState();
    _fetchUnassignedBatteries();
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

  Future<void> _fetchUnassignedBatteries() async {
    try {
      final batteries = await widget.repository.getUnassignedBatteries();
      if (mounted) {
        setState(() {
          _unassignedBatteries = batteries;
          _isFetching = false;
          if (batteries.isNotEmpty) {
            _selectedBattery = batteries.first;
          } else {
            _isNewBattery = true; // Force new battery mode if no unassigned batteries
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isFetching = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('載入電池失敗: $e')));
      }
    }
  }

  void _scanBatterySn() async {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('相機啟動中...')));
    await Future.delayed(const Duration(seconds: 1));
    _snController.text = 'BTY-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}';
  }

  Future<void> _submit() async {
    if (_isNewBattery) {
      if (!_formKey.currentState!.validate()) return;
    } else {
      if (_selectedBattery == null) return;
    }

    setState(() => _isLoading = true);

    try {
      if (_isNewBattery) {
        final newBattery = Battery(
          documentId: 'BTY-${DateTime.now().millisecondsSinceEpoch}',
          serialNumber: _snController.text.trim(),
          tagName: _tagController.text.trim(),
          batteryModel: _selectedModel ?? '未知電池型號',
          cycleCount: 0,
          healthStatus: '全新健康 (無膨脹)',
          currentPackageId: widget.packageId,
          purchaseDate: DateTime.now(),
        );
        await widget.repository.addBattery(newBattery);
        if (mounted) Navigator.pop(context, newBattery);
      } else {
        final updatedBattery = _selectedBattery!.copyWith(currentPackageId: widget.packageId);
        await widget.repository.updateBattery(updatedBattery);
        if (mounted) Navigator.pop(context, updatedBattery);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('操作失敗: $e')));
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isFetching) {
      return const AlertDialog(
        content: SizedBox(
          height: 100,
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    return AlertDialog(
      title: const Text('放入電池'),
      content: SizedBox(
        width: 320,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Segmented Control for mode selection
              SegmentedButton<bool>(
                segments: const [
                  ButtonSegment(value: false, label: Text('選擇現有電池'), icon: Icon(Icons.list)),
                  ButtonSegment(value: true, label: Text('登錄全新電池'), icon: Icon(Icons.add)),
                ],
                selected: {_isNewBattery},
                onSelectionChanged: (Set<bool> newSelection) {
                  setState(() => _isNewBattery = newSelection.first);
                },
              ),
              const SizedBox(height: 24),
              
              if (!_isNewBattery) ...[
                if (_unassignedBatteries.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text('目前沒有未分配的電池。', style: TextStyle(color: Colors.red)),
                  )
                else
                  DropdownButtonFormField<Battery>(
                    value: _selectedBattery,
                    decoration: const InputDecoration(
                      labelText: '選擇未分配的電池',
                      border: OutlineInputBorder(),
                    ),
                    items: _unassignedBatteries.map((b) {
                      return DropdownMenuItem(
                        value: b,
                        child: Text('${b.tagName} (S/N: ${b.serialNumber})'),
                      );
                    }).toList(),
                    onChanged: (val) => setState(() => _selectedBattery = val),
                  ),
              ] else ...[
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _tagController,
                        decoration: const InputDecoration(labelText: '外場標籤 (如 M301)', border: OutlineInputBorder()),
                        validator: (v) => v == null || v.trim().isEmpty ? '必填' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _snController,
                        decoration: InputDecoration(
                          labelText: '出廠序號 (S/N)',
                          border: const OutlineInputBorder(),
                          suffixIcon: IconButton(icon: const Icon(Icons.qr_code_scanner), onPressed: _scanBatterySn),
                        ),
                        validator: (v) => v == null || v.trim().isEmpty ? '必填' : null,
                      ),
                      const SizedBox(height: 12),
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
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: _isLoading ? null : () => Navigator.pop(context), child: const Text('取消')),
        ElevatedButton(
          onPressed: _isLoading || (!_isNewBattery && _unassignedBatteries.isEmpty) ? null : _submit,
          child: _isLoading ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('確認放入'),
        ),
      ],
    );
  }
}
