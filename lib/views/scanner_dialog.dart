import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

// 僅在 Web 平台使用原生瀏覽器媒體設備請求
import 'dart:html' as html;
import 'dart:js_interop';
import 'dart:js_interop_unsafe';

class ScannerDialog extends StatefulWidget {
  const ScannerDialog({super.key});

  @override
  State<ScannerDialog> createState() => _ScannerDialogState();
}

class _ScannerDialogState extends State<ScannerDialog> with SingleTickerProviderStateMixin {
  MobileScannerController? _scannerController;
  
  bool _isInitialized = false;
  bool _isError = false;
  String _errorMessage = "";
  bool _isCopied = false;
  
  final List<String> _logs = [];
  
  late AnimationController _animationController;

  void _log(String message) {
    debugPrint("[Scanner SDK] $message");
    if (mounted) {
      setState(() {
        _logs.add("[${DateTime.now().toString().substring(11, 19)}] $message");
      });
    }
  }

  @override
  void initState() {
    super.initState();
    
    _log("初始化 ScannerDialog...");
    
    if (kIsWeb) {
      _log("設定本地 zxing.min.js 條碼解析庫路徑...");
      MobileScannerPlatform.instance.setBarcodeLibraryScriptUrl('zxing.min.js');
      _injectJSImageDecoder();
    }

    // 建立控制器，設定 autoStart 為 false，由我們手動在正確時機調用啟動
    _scannerController = MobileScannerController(
      detectionSpeed: DetectionSpeed.normal,
      facing: CameraFacing.back,
      autoStart: false,
      autoZoom: true,
      formats: const [BarcodeFormat.qrCode, BarcodeFormat.dataMatrix],
    );

    // 掃描線上下滑動動畫
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    // 確保 Widget 完全掛載在 DOM 後，才開啟相機
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startCameraProcess();
    });
  }

  @override
  void dispose() {
    _log("銷毀 ScannerDialog 元件...");
    _animationController.dispose();
    _scannerController?.dispose();
    super.dispose();
  }

  Future<void> _startCameraProcess() async {
    if (!mounted) return;
    
    setState(() {
      _isInitialized = false;
      _isError = false;
      _errorMessage = "";
    });

    _log("開始相機啟動流程...");

    if (kIsWeb) {
      try {
        _log("正在檢查全域 window.ZXing 物件...");
        final hasZXing = globalContext.has('ZXing');
        _log("window.ZXing 是否已加載: $hasZXing");
        
        _log("正在檢查瀏覽器媒體設備支援度...");
        final hasMediaDevices = html.window.navigator.mediaDevices != null;
        _log("navigator.mediaDevices 是否可用: $hasMediaDevices");
        
        if (hasMediaDevices) {
          final devices = await html.window.navigator.mediaDevices!.enumerateDevices();
          _log("檢測到瀏覽器視訊/音訊設備數量: ${devices.length}");
          for (var device in devices) {
            _log(" - 設備種類: ${device.kind}, 名稱: ${device.label.isNotEmpty ? device.label : '未命名(無權限)'}");
          }
        }
      } catch (e) {
        _log("Web 環境探測異常: $e");
      }
    }

    try {
      _log("正在調用 controller.start()...");
      // 我們設定一個安全超時，若 6 秒內 start 毫無反應，主動判定為 pending 異常以告知使用者
      await _scannerController!.start().timeout(
        const Duration(seconds: 6),
        onTimeout: () {
          _log("【超時警告】controller.start() 呼叫超過 6 秒未回應！可能被系統硬體佔用或權限掛起。");
          throw TimeoutException("相機啟動程序超時(6秒)，這通常是相機設備被其他程式佔用，或瀏覽器權限異常。");
        },
      );
      
      _log("controller.start() 成功返回！");
      
      if (mounted) {
        setState(() {
          _isInitialized = true;
          _isError = false;
        });
      }
    } catch (e) {
      _log("啟動相機異常失敗: $e");
      if (mounted) {
        setState(() {
          _isError = true;
          _errorMessage = e.toString();
        });
      }
    }
  }

  /// 一鍵乾淨重試：完整銷毀當前控制器，並重新建立控制器以防止 Web 端髒狀態殘留
  Future<void> _resetAndRetry() async {
    _log("使用者要求重新請求與啟動相機...");
    try {
      _log("正在銷毀舊相機控制器...");
      await _scannerController?.dispose();
    } catch (e) {
      _log("銷毀舊控制器失敗: $e");
    }
    
    if (kIsWeb) {
      MobileScannerPlatform.instance.setBarcodeLibraryScriptUrl('zxing.min.js');
    }
    
    setState(() {
      _isInitialized = false;
      _isError = false;
      _scannerController = MobileScannerController(
        detectionSpeed: DetectionSpeed.normal,
        facing: CameraFacing.back,
        autoStart: false,
        autoZoom: true,
        formats: const [BarcodeFormat.qrCode, BarcodeFormat.dataMatrix],
      );
    });

    _log("重新建立控制器完成，準備啟動...");
    _startCameraProcess();
  }

  void _onDetect(BarcodeCapture capture) {
    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isNotEmpty && barcodes.first.rawValue != null) {
      final code = barcodes.first.rawValue!;
      _log("成功掃描條碼: $code");
      Navigator.of(context).pop(code);
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
                  // 輔育函數：將 HTMLImageElement 繪製到指定最大邊的 Canvas 中並導出 Data URL
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

                  // 使用 BrowserMultiFormatReader 並指定可能格式，使其支援 QR_CODE 與 DATA_MATRIX
                  var hints = new Map();
                  var formats = [
                    ZXing.BarcodeFormat.QR_CODE,
                    ZXing.BarcodeFormat.DATA_MATRIX
                  ];
                  hints.set(ZXing.DecodeHintType.POSSIBLE_FORMATS, formats);
                  var codeReader = new ZXing.BrowserMultiFormatReader(hints);
                  
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
      _log("已成功注入升級版 JS 圖片解碼器！");
    } catch (e) {
      _log("注入 JS 圖片解碼器異常: $e");
    }
  }

  Future<void> _pickAndDecodeImage() async {
    _log("啟動相簿選取相片程序...");
    if (!kIsWeb) {
      _log("非 Web 環境暫不支援相簿選取");
      return;
    }

    try {
      final uploadInput = html.FileUploadInputElement()..accept = 'image/*';
      uploadInput.click();
      
      uploadInput.onChange.listen((e) {
        final files = uploadInput.files;
        if (files == null || files.isEmpty) {
          _log("使用者取消選取圖片");
          return;
        }
        
        final file = files[0];
        _log("已選取圖片: ${file.name} (大小: ${file.size} bytes)");
        
        final reader = html.FileReader();
        reader.readAsDataUrl(file);
        reader.onLoadEnd.listen((e) {
          final dataUrl = reader.result as String;
          _log("正在解析選取相片中的 QR Code...");
          _decodeQRCodeFromDataUrl(dataUrl);
        });
      });
    } catch (e) {
      _log("選取相片程序異常: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('啟動相簿失敗: $e')),
        );
      }
    }
  }

  Future<void> _decodeQRCodeFromDataUrl(String dataUrl) async {
    try {
      final hasDecoder = globalContext.has('decodeQRCodeFromDataUrl');
      if (!hasDecoder) {
        throw "JS 圖片解碼器尚未準備就緒";
      }
      
      final promise = globalContext.callMethod(
        'decodeQRCodeFromDataUrl'.toJS,
        dataUrl.toJS,
      ) as JSPromise;
      final result = await promise.toDart;
      
      _log("相片 QR Code 解析成功: $result");
      if (mounted) {
        Navigator.of(context).pop(result.toString());
      }
    } catch (e) {
      final errorMsg = e.toString().replaceFirst("Error: ", "");
      _log("❌ 圖片解析失敗: $errorMsg");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.redAccent.shade700,
            content: const Text(
              '解析失敗：請確保圖片中有清晰的 QR Code！',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(16),
      child: Container(
        width: 420,
        height: 600, // 稍微拉高以完美容納極客 Debug Console
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.5 : 0.15),
              blurRadius: 24,
              spreadRadius: 4,
            ),
          ],
        ),
        child: Column(
          children: [
            // 頂部導覽列
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.qr_code_scanner, 
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '掃描母艦 QR Code',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.photo_library_rounded),
                    tooltip: '從相簿選取照片解析',
                    onPressed: _pickAndDecodeImage,
                  ),
                  if (_isInitialized)
                    IconButton(
                      icon: const Icon(Icons.flip_camera_ios_rounded),
                      tooltip: '切換鏡頭',
                      onPressed: () async {
                        _log("使用者點選切換相機鏡頭...");
                        try {
                          await _scannerController?.switchCamera();
                          _log("相機鏡頭切換成功");
                        } catch (e) {
                          _log("切換相機鏡頭失敗: $e");
                        }
                      },
                    ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            
            // 相機與引導內容區
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  // 設為完全透明，100% 避免 Flutter Web 中 Canvas 將灰色背景繪製在底層原生相機視訊(Platform View)上方
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.5),
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(19),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // 1. MobileScanner 必須在初始化前就渲染在 Widget 樹中，控制器才能成功 attached
                      if (_scannerController != null)
                        Positioned.fill(
                          child: MobileScanner(
                            controller: _scannerController!,
                            onDetect: _onDetect,
                          ),
                        ),

                      // 2. 當相機已就緒，疊加一個極簡的綠色對焦框（100% 不含任何大面積半透明遮罩與 Canvas 動畫，避開 Web 渲染 Bug）
                      if (_isInitialized) ...[
                        Center(
                          child: Container(
                            width: 240,
                            height: 240,
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                              border: Border.all(
                                color: Colors.tealAccent.shade400,
                                width: 3.5,
                              ),
                              borderRadius: BorderRadius.circular(24),
                            ),
                          ),
                        ),
                        // 提示文字疊加
                        Positioned(
                          bottom: 20,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.75),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              '請將 QR Code 對準綠色框線',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ),
                      ],

                      // 3. 正在初始化相機時的不透明載入遮罩
                      if (!_isInitialized && !_isError)
                        Positioned.fill(
                          child: Container(
                            color: Theme.of(context).colorScheme.surface,
                            child: _buildStatusWidget(
                              child: const CircularProgressIndicator(strokeWidth: 3),
                              title: "正在開啟相機裝置",
                              subtitle: "正在加載視訊畫面...\n請在提示時允許相機權限",
                            ),
                          ),
                        ),

                      // 4. 發生錯誤時的不透明錯誤遮罩
                      if (_isError)
                        Positioned.fill(
                          child: Container(
                            color: Theme.of(context).colorScheme.surface,
                            child: _buildPermissionDeniedWidget(),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),

            // 5. 終極極客 Debug Console - 玻璃質感滾動終端日誌面板
            Container(
              height: 120,
              margin: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.greenAccent.shade700.withValues(alpha: 0.4),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.greenAccent.shade700.withValues(alpha: 0.1),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Terminal Header
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      color: Colors.grey.shade900,
                      child: Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(color: Colors.redAccent, shape: BoxShape.circle),
                          ),
                          const SizedBox(width: 5),
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(color: Colors.amberAccent, shape: BoxShape.circle),
                          ),
                          const SizedBox(width: 5),
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(color: Colors.greenAccent, shape: BoxShape.circle),
                          ),
                          const SizedBox(width: 10),
                          const Icon(Icons.terminal_rounded, color: Colors.greenAccent, size: 12),
                          const SizedBox(width: 6),
                          Text(
                            "SCANNER HARDWARE TRACE CONSOLE",
                            style: TextStyle(
                              color: Colors.greenAccent.shade400,
                              fontSize: 9,
                              fontFamily: 'monospace',
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.8,
                            ),
                          ),
                          const Spacer(),
                          InkWell(
                            onTap: () {
                              // 因為 _logs 是 reverse: true 列印，但在剪貼簿中我們用正序輸出
                              final textToCopy = _logs.join('\n');
                              Clipboard.setData(ClipboardData(text: textToCopy));
                              setState(() {
                                _isCopied = true;
                              });
                              _log("已將日誌複製至剪貼簿！");
                              Future.delayed(const Duration(seconds: 2), () {
                                if (mounted) {
                                  setState(() {
                                    _isCopied = false;
                                  });
                                }
                              });
                            },
                            borderRadius: BorderRadius.circular(4),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    _isCopied ? Icons.check_circle_rounded : Icons.copy_all_rounded,
                                    color: _isCopied ? Colors.greenAccent.shade200 : Colors.greenAccent.shade400,
                                    size: 11,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    _isCopied ? "已複製!" : "複製日誌",
                                    style: TextStyle(
                                      color: _isCopied ? Colors.greenAccent.shade200 : Colors.greenAccent.shade400,
                                      fontSize: 9,
                                      fontFamily: 'monospace',
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Terminal Content
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: ListView.builder(
                          itemCount: _logs.length,
                          reverse: true, // 最新日誌顯示在最下方
                          itemBuilder: (context, index) {
                            // 因為是 reverse，我們把最新的擺在最後
                            final logItem = _logs[_logs.length - 1 - index];
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 2),
                              child: Text(
                                logItem,
                                style: TextStyle(
                                  color: logItem.contains("異常") || logItem.contains("超時") || logItem.contains("失敗")
                                      ? Colors.redAccent.shade200
                                      : logItem.contains("成功") || logItem.contains("返回")
                                          ? Colors.greenAccent.shade200
                                          : Colors.greenAccent.shade400,
                                  fontFamily: 'monospace',
                                  fontSize: 10,
                                  height: 1.3,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusWidget({
    required Widget child,
    required String title,
    required String subtitle,
  }) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          child,
          const SizedBox(height: 20),
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  height: 1.5,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionDeniedWidget() {
    final hasProtocolIssue = kIsWeb && html.window.location.protocol != 'https:' && html.window.location.hostname != 'localhost';
    
    return Padding(
      padding: const EdgeInsets.all(20),
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.errorContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.videocam_off_rounded,
                size: 36,
                color: Theme.of(context).colorScheme.onErrorContainer,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              "需要相機使用權限",
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              hasProtocolIssue
                  ? "【安全警告】您的網址不安全\n瀏覽器僅允許在 HTTPS 或 localhost 下開啟相機。目前網址協定為 HTTP，瀏覽器會強制封鎖相機存取。"
                  : "未能開啟相機。這通常是因為瀏覽器權限被封鎖，或沒有偵測到相機設備。",
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.error,
                    fontWeight: hasProtocolIssue ? FontWeight.bold : FontWeight.normal,
                    height: 1.4,
                  ),
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "如何解決：",
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 6),
            _buildStepRow("1", "請點選瀏覽器上方網址列左側的 🔒 (鎖頭圖示) 或設定按鈕。"),
            _buildStepRow("2", "找到「相機」選項，將其設定為「允許」。"),
            _buildStepRow("3", "點選下方按鈕重新嘗試啟動相機。"),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _pickAndDecodeImage,
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor: Colors.teal.shade700,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.photo_library_rounded, size: 18),
                label: const Text(
                  "備用方案：從相簿選取照片解析",
                  style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton.icon(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close, size: 16),
                  label: const Text("關閉對話框"),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: _resetAndRetry,
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                    foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                  icon: const Icon(Icons.refresh_rounded, size: 16),
                  label: const Text("重新嘗試啟動"),
                ),
              ],
            ),
            if (_errorMessage.isNotEmpty) ...[
              const SizedBox(height: 16),
              ExpansionTile(
                title: const Text("詳細偵錯錯誤訊息", style: TextStyle(fontSize: 12)),
                dense: true,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SelectableText(
                      _errorMessage,
                      style: const TextStyle(fontFamily: 'monospace', fontSize: 11, color: Colors.grey),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStepRow(String number, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 18,
            height: 18,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              shape: BoxShape.circle,
            ),
            child: Text(
              number,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}

/// 繪製科技感十足的遮罩與對焦框
class ScannerOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const scanAreaSize = 240.0;
    final left = (size.width - scanAreaSize) / 2;
    final top = (size.height - scanAreaSize) / 2;
    final right = left + scanAreaSize;
    final bottom = top + scanAreaSize;

    // 科技感半透明深色塗料 (0.65 透明度)
    final bgPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.65)
      ..style = PaintingStyle.fill;

    // 使用 4 區塊拼接法繪製遮罩，100% 避開 saveLayer/BlendMode 導致 Flutter Web HTML 合成層的灰白濾鏡 Bug
    // 1. 上方區塊
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, top), bgPaint);
    // 2. 下方區塊
    canvas.drawRect(Rect.fromLTWH(0, bottom, size.width, size.height - bottom), bgPaint);
    // 3. 左方區塊
    canvas.drawRect(Rect.fromLTWH(0, top, left, scanAreaSize), bgPaint);
    // 4. 右方區塊
    canvas.drawRect(Rect.fromLTWH(right, top, size.width - right, scanAreaSize), bgPaint);

    // 5. 繪製四個角落對焦框線 (直接畫在 Canvas 上，無任何透明混合干擾)
    final borderPaint = Paint()
      ..color = Colors.tealAccent.shade400
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.5
      ..strokeCap = StrokeCap.round;

    const borderLength = 28.0;

    // 左上
    canvas.drawPath(
      Path()
        ..moveTo(left, top + borderLength)
        ..lineTo(left, top)
        ..lineTo(left + borderLength, top),
      borderPaint,
    );
    // 右上
    canvas.drawPath(
      Path()
        ..moveTo(right - borderLength, top)
        ..lineTo(right, top)
        ..lineTo(right, top + borderLength),
      borderPaint,
    );
    // 左下
    canvas.drawPath(
      Path()
        ..moveTo(left, bottom - borderLength)
        ..lineTo(left, bottom)
        ..lineTo(left + borderLength, bottom),
      borderPaint,
    );
    // 右下
    canvas.drawPath(
      Path()
        ..moveTo(right - borderLength, bottom)
        ..lineTo(right, bottom)
        ..lineTo(right, bottom - borderLength),
      borderPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
