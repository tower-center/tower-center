import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/battery.dart';
import '../models/system_dictionary.dart';
import '../repositories/fleet_repository.dart';
import 'scanner_dialog.dart';

class AddBatteryToPackageDialog extends StatefulWidget {
  final FleetRepository repository;
  final String packageId;
  final String packageModelType;

  const AddBatteryToPackageDialog({
    super.key,
    required this.repository,
    required this.packageId,
    required this.packageModelType,
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
  
  // _loadBatteryModels removed as model is fixed to packageModelType

  @override
  void initState() {
    super.initState();
    _fetchUnassignedBatteries();
  }

  Future<void> _fetchUnassignedBatteries() async {
    try {
      final batteries = await widget.repository.getUnassignedBatteries();
      // Filter batteries by the package's model type
      final compatibleBatteries = batteries.where((b) => b.batteryModel == widget.packageModelType).toList();
      
      if (mounted) {
        setState(() {
          _unassignedBatteries = compatibleBatteries;
          _isFetching = false;
          if (compatibleBatteries.isNotEmpty) {
            _selectedBattery = compatibleBatteries.first;
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
    final scannedCode = await showDialog<String>(
      context: context,
      builder: (context) => const ScannerDialog(),
    );
    if (scannedCode != null && scannedCode.isNotEmpty) {
      setState(() {
        _snController.text = scannedCode;
      });
    }
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
        final String generatedId = 'BTY-${DateTime.now().millisecondsSinceEpoch}';
        final String inputSn = _snController.text.trim();
        final newBattery = Battery(
          documentId: inputSn.isNotEmpty ? inputSn : generatedId,
          serialNumber: inputSn.isNotEmpty ? inputSn : null,
          tagName: _tagController.text.trim(),
          batteryModel: widget.packageModelType,
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
                          labelText: '出廠序號 (S/N) [可選]',
                          border: const OutlineInputBorder(),
                          suffixIcon: IconButton(icon: const Icon(Icons.qr_code_scanner), onPressed: _scanBatterySn),
                        ),
                        // validator: (v) => v == null || v.trim().isEmpty ? '必填' : null,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Icon(Icons.flight, color: Theme.of(context).colorScheme.primary),
                          const SizedBox(width: 8),
                          Text('綁定電池型號：${widget.packageModelType}', style: const TextStyle(fontWeight: FontWeight.bold)),
                        ],
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
