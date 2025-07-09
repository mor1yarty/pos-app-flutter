import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../services/barcode_service.dart';
import '../widgets/custom_button.dart';

class BarcodeScannerScreen extends StatefulWidget {
  const BarcodeScannerScreen({super.key});

  @override
  State<BarcodeScannerScreen> createState() => _BarcodeScannerScreenState();
}

class _BarcodeScannerScreenState extends State<BarcodeScannerScreen>
    with WidgetsBindingObserver {
  MobileScannerController? _controller;
  bool _isInitialized = false;
  bool _isScanning = false;
  bool _isTorchOn = false;
  bool _hasPermission = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeScanner();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _disposeScanner();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _initializeScanner();
    } else if (state == AppLifecycleState.paused) {
      _pauseScanner();
    }
  }

  Future<void> _initializeScanner() async {
    try {
      // カメラ権限を確認
      final hasPermission = await BarcodeService.requestCameraPermission();
      setState(() {
        _hasPermission = hasPermission;
      });

      if (!hasPermission) {
        return;
      }

      // コントローラーを取得
      _controller = BarcodeService.getController();
      
      // スキャン開始
      final started = await BarcodeService.startScanning();
      setState(() {
        _isInitialized = started;
        _isScanning = started;
      });
    } catch (e) {
      debugPrint('バーコードスキャナーの初期化中にエラーが発生しました: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('カメラの初期化に失敗しました: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _pauseScanner() async {
    if (_controller != null && _isScanning) {
      await BarcodeService.stopScanning();
      setState(() {
        _isScanning = false;
      });
    }
  }

  Future<void> _disposeScanner() async {
    await BarcodeService.dispose();
    setState(() {
      _isInitialized = false;
      _isScanning = false;
      _controller = null;
    });
  }

  void _onBarcodeDetected(BarcodeCapture capture) {
    if (capture.barcodes.isNotEmpty) {
      final barcode = capture.barcodes.first;
      final code = barcode.rawValue;
      
      if (BarcodeService.isValidBarcode(code)) {
        // 振動フィードバック
        _provideFeedback();
        
        // 結果を返す
        _returnResult(code!, barcode.format);
      }
    }
  }

  void _provideFeedback() {
    // 振動フィードバック（必要に応じて実装）
    // HapticFeedback.lightImpact();
  }

  void _returnResult(String code, BarcodeFormat format) {
    final result = BarcodeResult(
      code: code,
      format: format,
      timestamp: DateTime.now(),
    );
    
    Navigator.of(context).pop(result);
  }

  Future<void> _toggleTorch() async {
    try {
      await BarcodeService.toggleTorch();
      setState(() {
        _isTorchOn = !_isTorchOn;
      });
    } catch (e) {
      debugPrint('トーチの切り替え中にエラーが発生しました: $e');
    }
  }

  Future<void> _switchCamera() async {
    try {
      await BarcodeService.switchCamera();
    } catch (e) {
      debugPrint('カメラの切り替え中にエラーが発生しました: $e');
    }
  }

  void _showManualInput() {
    showDialog(
      context: context,
      builder: (context) => _ManualInputDialog(
        onSubmit: (code) {
          if (BarcodeService.isValidBarcode(code)) {
            final result = BarcodeResult(
              code: code,
              format: BarcodeFormat.unknown,
              timestamp: DateTime.now(),
            );
            Navigator.of(context).pop(result);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('無効なバーコードです'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('バーコードスキャン'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: Icon(_isTorchOn ? Icons.flash_on : Icons.flash_off),
            onPressed: _isInitialized ? _toggleTorch : null,
            tooltip: 'フラッシュライト',
          ),
          IconButton(
            icon: const Icon(Icons.flip_camera_ios),
            onPressed: _isInitialized ? _switchCamera : null,
            tooltip: 'カメラ切り替え',
          ),
          IconButton(
            icon: const Icon(Icons.keyboard),
            onPressed: _showManualInput,
            tooltip: '手動入力',
          ),
        ],
      ),
      body: Column(
        children: [
          // カメラプレビュー
          Expanded(
            flex: 3,
            child: _buildCameraPreview(),
          ),
          
          // 説明エリア
          Expanded(
            flex: 1,
            child: _buildInstructionArea(),
          ),
        ],
      ),
    );
  }

  Widget _buildCameraPreview() {
    if (!_hasPermission) {
      return _buildPermissionMessage();
    }
    
    if (!_isInitialized) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return Stack(
      children: [
        MobileScanner(
          controller: _controller,
          onDetect: _onBarcodeDetected,
          errorBuilder: (context, error, child) {
            return _buildErrorWidget(error);
          },
        ),
        
        // スキャンエリアのオーバーレイ
        _buildScanOverlay(),
      ],
    );
  }

  Widget _buildPermissionMessage() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.camera_alt_outlined,
            size: 64,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          const Text(
            'カメラの権限が必要です',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'バーコードをスキャンするために\nカメラへのアクセスを許可してください',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          CustomButton(
            onPressed: _initializeScanner,
            text: '権限を許可',
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget(MobileScannerException error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red,
          ),
          const SizedBox(height: 16),
          const Text(
            'カメラエラー',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error.errorDetails?.message ?? 'カメラの初期化に失敗しました',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          CustomButton(
            onPressed: _initializeScanner,
            text: '再試行',
          ),
        ],
      ),
    );
  }

  Widget _buildScanOverlay() {
    return Container(
      decoration: ShapeDecoration(
        shape: ScannerOverlayShape(
          borderColor: Theme.of(context).colorScheme.primary,
          borderWidth: 3.0,
          overlayColor: Colors.black.withValues(alpha: 0.5),
        ),
      ),
    );
  }

  Widget _buildInstructionArea() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.qr_code_scanner,
            size: 48,
            color: Colors.blue,
          ),
          const SizedBox(height: 16),
          const Text(
            'バーコードを枠内に合わせてください',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'JANコード（13桁）、その他のバーコード形式に対応',
            style: TextStyle(fontSize: 14),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          CustomButton(
            onPressed: _showManualInput,
            text: '手動入力',
            width: 200,
          ),
        ],
      ),
    );
  }
}

// 手動入力ダイアログ
class _ManualInputDialog extends StatefulWidget {
  final Function(String) onSubmit;

  const _ManualInputDialog({required this.onSubmit});

  @override
  State<_ManualInputDialog> createState() => _ManualInputDialogState();
}

class _ManualInputDialogState extends State<_ManualInputDialog> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    // ダイアログが開いたときにフォーカスを当てる
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('バーコード手動入力'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _controller,
            focusNode: _focusNode,
            decoration: const InputDecoration(
              labelText: 'バーコード',
              hintText: 'JANコード（13桁）を入力',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
            onSubmitted: (value) {
              if (value.isNotEmpty) {
                widget.onSubmit(value);
                Navigator.of(context).pop();
              }
            },
          ),
          const SizedBox(height: 8),
          const Text(
            'JANコード（13桁）または他のバーコード形式を入力してください',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('キャンセル'),
        ),
        FilledButton(
          onPressed: () {
            final code = _controller.text.trim();
            if (code.isNotEmpty) {
              widget.onSubmit(code);
              Navigator.of(context).pop();
            }
          },
          child: const Text('OK'),
        ),
      ],
    );
  }
}

// スキャナーオーバーレイ形状
class ScannerOverlayShape extends ShapeBorder {
  final Color borderColor;
  final double borderWidth;
  final Color overlayColor;

  const ScannerOverlayShape({
    this.borderColor = Colors.red,
    this.borderWidth = 3.0,
    this.overlayColor = const Color.fromRGBO(0, 0, 0, 80),
  });

  @override
  EdgeInsetsGeometry get dimensions => const EdgeInsets.all(10);

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
    return Path()
      ..fillType = PathFillType.evenOdd
      ..addPath(getOuterPath(rect), Offset.zero);
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    Path path = Path()..addRect(rect);
    Path oval = Path()
      ..addRRect(RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: rect.center,
          width: rect.width * 0.6,
          height: rect.height * 0.4,
        ),
        const Radius.circular(10),
      ));
    return Path.combine(PathOperation.difference, path, oval);
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    final width = rect.width * 0.6;
    final height = rect.height * 0.4;
    final borderRect = Rect.fromCenter(
      center: rect.center,
      width: width,
      height: height,
    );
    
    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth;
    
    canvas.drawRRect(
      RRect.fromRectAndRadius(borderRect, const Radius.circular(10)),
      borderPaint,
    );
  }

  @override
  ShapeBorder scale(double t) {
    return ScannerOverlayShape(
      borderColor: borderColor,
      borderWidth: borderWidth * t,
      overlayColor: overlayColor,
    );
  }
}