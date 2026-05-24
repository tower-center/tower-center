import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:html' as html;
import 'dart:js_interop';
import 'dart:js_interop_unsafe';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/drone.dart';
import '../models/aircraft_model.dart';
import '../models/drone_operator.dart';
import '../models/system_dictionary.dart';
import '../repositories/fleet_repository.dart';
import 'scanner_dialog.dart';

/// 母艦建立表單 Dialog
class AddDroneDialog extends StatefulWidget {
  final FleetRepository repository;

  const AddDroneDialog({
    super.key,
    required this.repository,
  });

  @override
  State<AddDroneDialog> createState() => _AddDroneDialogState();
}

class _AddDroneDialogState extends State<AddDroneDialog> {
  final _formKey = GlobalKey<FormState>();
  final _snController = TextEditingController();

  List<AircraftModel> _activeModels = [];
  List<DroneOperator> _activeOperators = [];
  List<SystemDictionary> _activeTacticalNames = [];
  bool _isFetchingOptions = true;

  String? _selectedModel;
  String? _selectedKeeper;
  String? _selectedTacticalName;

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

      // 依建立時間降序排序 (最新建立排在選單最前方)
      models.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      operators.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      dict.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      setState(() {
        _activeModels = models;
        _activeOperators = operators;
        _activeTacticalNames = dict;

        if (models.isNotEmpty) _selectedModel = models.first.name;
        if (operators.isNotEmpty) _selectedKeeper = operators.first.name;
        if (dict.isNotEmpty) _selectedTacticalName = dict.first.label;

        _isFetchingOptions = false;
      });
    } catch (e) {
      setState(() {
        _isFetchingOptions = false;
      });
      debugPrint('Error loading options: $e');
    }
  }

  @override
  void dispose() {
    _snController.dispose();
    super.dispose();
  }

  /// 啟動真實相機 QR Code 掃描
  Future<void> _scanSerialNumber() async {
    final String? scannedCode = await showDialog<String>(
      context: context,
      builder: (context) => const ScannerDialog(),
    );

    if (scannedCode != null && scannedCode.isNotEmpty && mounted) {
      setState(() {
        _snController.text = scannedCode;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('掃描成功: $scannedCode'),
          backgroundColor: Theme.of(context).colorScheme.primary,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _injectJSImageDecoder() {
    try {
      final script = html.ScriptElement()
        ..text = '''
          window.decodeQRCodeFromDataUrl = function(dataUrl) {
            return new Promise(function(resolve, reject) {
              var img = new Image();
              img.onload = function() {
                try {
                  // 輔助函數：將 HTMLImageElement 繪製到指定最大邊的 Canvas 中並導出 Data URL
                  function getScaledDataUrl(imgObj, maxDimension) {
                    var width = imgObj.width;
                    var height = imgObj.height;
                    
                    if (width <= maxDimension && height <= maxDimension) {
                      return dataUrl;
                    }
                    
                    if (width > height) {
                      height = Math.round((height * maxDimension) / width);
                      width = maxDimension;
                    } else {
                      width = Math.round((width * maxDimension) / height);
                      height = maxDimension;
                    }
                    
                    var canvas = document.createElement('canvas');
                    canvas.width = width;
                    canvas.height = height;
                    var ctx = canvas.getContext('2d');
                    
                    ctx.imageSmoothingEnabled = true;
                    ctx.imageSmoothingQuality = 'high';
                    ctx.drawImage(imgObj, 0, 0, width, height);
                    return canvas.toDataURL('image/jpeg', 0.85);
                  }

                  var codeReader = new ZXing.BrowserQRCodeReader();
                  
                  // 步驟一：嘗試 800 像素縮圖（降噪與速度最優，適合絕大多數手機相簿照片）
                  var scale800 = getScaledDataUrl(img, 800);
                  codeReader.decodeFromImage(undefined, scale800)
                    .then(function(res) {
                      resolve(res.text || res.getText());
                    })
                    .catch(function(err800) {
                      console.log("[Decoder] 800px 解析失敗，嘗試 1200px...", err800);
                      
                      // 步驟二：嘗試 1200 像素縮圖（適合較為精細的二維碼）
                      var scale1200 = getScaledDataUrl(img, 1200);
                      codeReader.decodeFromImage(undefined, scale1200)
                        .then(function(res) {
                          resolve(res.text || res.getText());
                        })
                        .catch(function(err1200) {
                          console.log("[Decoder] 1200px 解析失敗，嘗試原圖解析...", err1200);
                          
                          // 步驟三：嘗試原圖解析
                          codeReader.decodeFromImage(undefined, dataUrl)
                            .then(function(res) {
                              resolve(res.text || res.getText());
                            })
                            .catch(function(errOrig) {
                              console.error("[Decoder] 所有尺寸解析皆失敗: ", errOrig);
                              reject("無法解析圖片中的 QR Code。請確保條碼清晰、沒有陰影遮擋，並對準焦距拍一張近照。");
                            });
                        });
                    });
                } catch (e) {
                  reject("解析圖片時發生錯誤: " + e);
                }
              };
              img.onerror = function() {
                reject("無法讀取選取的圖片檔案");
              };
              img.src = dataUrl;
            });
          };
        ''';
      html.document.head!.append(script);
    } catch (e) {
      debugPrint("注入 JS 圖片解碼器異常: $e");
    }
  }

  Future<void> _pickAndDecodeImage() async {
    if (!kIsWeb) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('從相簿選取照片目前僅支援網頁端')),
      );
      return;
    }

    _injectJSImageDecoder();

    try {
      final uploadInput = html.FileUploadInputElement()..accept = 'image/*';
      uploadInput.click();
      
      uploadInput.onChange.listen((e) {
        final files = uploadInput.files;
        if (files == null || files.isEmpty) return;
        
        final file = files[0];
        
        final reader = html.FileReader();
        reader.readAsDataUrl(file);
        reader.onLoadEnd.listen((e) {
          final dataUrl = reader.result as String;
          _decodeQRCodeFromDataUrl(dataUrl);
        });
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('選取相片失敗: $e')),
      );
    }
  }

  Future<void> _decodeQRCodeFromDataUrl(String dataUrl) async {
    try {
      final hasDecoder = globalContext.has('decodeQRCodeFromDataUrl');
      if (!hasDecoder) {
        throw "JS 圖片解碼器未準備就緒，請重試";
      }
      
      final promise = globalContext.callMethod(
        'decodeQRCodeFromDataUrl'.toJS,
        dataUrl.toJS,
      ) as JSPromise;
      final result = await promise.toDart;
      
      if (mounted) {
        setState(() {
          _snController.text = result.toString();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Theme.of(context).colorScheme.primary,
            content: Text('照片 QR Code 解析成功：${result.toString()}'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Theme.of(context).colorScheme.error,
            content: const Text(
              '解析失敗：請確保圖片中有清晰的 QR Code！',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  /// 提交表單，將機身寫入 Firestore
  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // 依 M3 設計建立 Drone 實體
      final newDrone = Drone(
        documentId: _snController.text.trim(),
        modelType: _selectedModel ?? '',
        currentName: _selectedTacticalName ?? '',
        currentKeeper: _selectedKeeper ?? '',
        insuranceExpiry: DateTime.now().add(const Duration(days: 365)), // 預設保險期限為一年
      );

      // 呼叫 Repository 寫入 Firestore
      await widget.repository.addDrone(newDrone);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('成功登錄機身: ${newDrone.currentName}'),
          backgroundColor: Theme.of(context).colorScheme.primary,
          behavior: SnackBarBehavior.floating,
        ),
      );

      // 關閉 Dialog 並回傳成功建立的實體
      Navigator.of(context).pop(newDrone);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('登錄失敗: $e'),
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
          Icon(Icons.flight_takeoff, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 8),
          const Text('登錄全新母艦機身'),
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
                const SizedBox(height: 8),
                // 1. 機身序號 (支援掃碼)
                TextFormField(
                  controller: _snController,
                  decoration: InputDecoration(
                    labelText: '機身序號 (S/N)',
                    prefixIcon: const Icon(Icons.pin),
                    border: const OutlineInputBorder(),
                    // 在尾端加入相簿選照與相機掃碼功能鈕
                    suffixIcon: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.photo_library_rounded),
                          tooltip: '從相簿選取照片解析',
                          onPressed: _pickAndDecodeImage,
                        ),
                        IconButton(
                          icon: const Icon(Icons.qr_code_scanner),
                          tooltip: '開啟相機掃描',
                          onPressed: _scanSerialNumber,
                        ),
                      ],
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return '請輸入或掃描機身序號';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
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
                  // 2. 出廠機型下拉選單
                  _activeModels.isEmpty
                      ? const Padding(
                          padding: EdgeInsets.only(bottom: 16),
                          child: Text('❌ 無啟用的機型，請先至後台管理建立', style: TextStyle(color: Colors.red, fontSize: 13)),
                        )
                      : DropdownButtonFormField<String>(
                          value: _selectedModel,
                          decoration: const InputDecoration(
                            labelText: '出廠機型',
                            prefixIcon: Icon(Icons.info_outline),
                            border: OutlineInputBorder(),
                          ),
                          items: _activeModels.map((m) {
                            return DropdownMenuItem<String>(
                              value: m.name,
                              child: Text(m.name),
                            );
                          }).toList(),
                          onChanged: (val) {
                            setState(() {
                              _selectedModel = val;
                            });
                          },
                          validator: (val) => val == null ? '請選擇出廠機型' : null,
                        ),
                  const SizedBox(height: 16),
                  // 3. 戰術編號下拉選單
                  _activeTacticalNames.isEmpty
                      ? const Padding(
                          padding: EdgeInsets.only(bottom: 16),
                          child: Text('❌ 無啟用的戰術編號，請先至後台管理建立', style: TextStyle(color: Colors.red, fontSize: 13)),
                        )
                      : DropdownButtonFormField<String>(
                          value: _selectedTacticalName,
                          decoration: const InputDecoration(
                            labelText: '戰術編號',
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
                          validator: (val) => val == null ? '請選擇戰術編號' : null,
                        ),
                  const SizedBox(height: 16),
                  // 4. 目前保管人下拉選單
                  _activeOperators.isEmpty
                      ? const Padding(
                          padding: EdgeInsets.only(bottom: 16),
                          child: Text('❌ 無啟用的空拍手，請先至後台管理建立', style: TextStyle(color: Colors.red, fontSize: 13)),
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
              : const Text('完成登錄'),
        ),
      ],
    );
  }
}
