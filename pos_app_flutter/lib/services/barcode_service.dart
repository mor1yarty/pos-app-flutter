import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/foundation.dart';

class BarcodeService {
  static MobileScannerController? _controller;
  static bool _isInitialized = false;
  
  // バーコードスキャンコントローラーを取得
  static MobileScannerController getController() {
    if (_controller == null || !_isInitialized) {
      _controller = MobileScannerController(
        detectionSpeed: DetectionSpeed.normal,
        facing: CameraFacing.back,
        torchEnabled: false,
      );
      _isInitialized = true;
    }
    return _controller!;
  }

  // カメラ権限を要求
  static Future<bool> requestCameraPermission() async {
    try {
      final status = await Permission.camera.status;
      
      if (status.isGranted) {
        return true;
      }
      
      if (status.isDenied) {
        final result = await Permission.camera.request();
        return result.isGranted;
      }
      
      if (status.isPermanentlyDenied) {
        // 設定画面を開く
        await openAppSettings();
        return false;
      }
      
      return false;
    } catch (e) {
      debugPrint('カメラ権限の要求中にエラーが発生しました: $e');
      return false;
    }
  }

  // バーコードスキャン開始
  static Future<bool> startScanning() async {
    try {
      final hasPermission = await requestCameraPermission();
      if (!hasPermission) {
        return false;
      }

      final controller = getController();
      await controller.start();
      return true;
    } catch (e) {
      debugPrint('バーコードスキャンの開始中にエラーが発生しました: $e');
      return false;
    }
  }

  // バーコードスキャン停止
  static Future<void> stopScanning() async {
    try {
      if (_controller != null) {
        await _controller!.stop();
      }
    } catch (e) {
      debugPrint('バーコードスキャンの停止中にエラーが発生しました: $e');
    }
  }

  // トーチ（フラッシュライト）の切り替え
  static Future<void> toggleTorch() async {
    try {
      if (_controller != null) {
        await _controller!.toggleTorch();
      }
    } catch (e) {
      debugPrint('トーチの切り替え中にエラーが発生しました: $e');
    }
  }

  // カメラの切り替え（前面/背面）
  static Future<void> switchCamera() async {
    try {
      if (_controller != null) {
        await _controller!.switchCamera();
      }
    } catch (e) {
      debugPrint('カメラの切り替え中にエラーが発生しました: $e');
    }
  }

  // バーコードデータの検証
  static bool isValidBarcode(String? code) {
    if (code == null || code.isEmpty) {
      return false;
    }
    
    // JANコード（13桁）の基本的な検証
    if (code.length == 13 && RegExp(r'^\d{13}$').hasMatch(code)) {
      return true;
    }
    
    // その他のバーコード形式も許可
    if (code.length >= 8 && code.length <= 20) {
      return true;
    }
    
    return false;
  }

  // バーコードタイプの取得
  static String getBarcodeTypeDescription(BarcodeFormat format) {
    switch (format) {
      case BarcodeFormat.ean13:
        return 'EAN-13 (JANコード)';
      case BarcodeFormat.ean8:
        return 'EAN-8';
      case BarcodeFormat.code128:
        return 'Code 128';
      case BarcodeFormat.code39:
        return 'Code 39';
      case BarcodeFormat.qrCode:
        return 'QR Code';
      case BarcodeFormat.dataMatrix:
        return 'Data Matrix';
      case BarcodeFormat.pdf417:
        return 'PDF417';
      default:
        return '未対応形式';
    }
  }

  // リソースの解放
  static Future<void> dispose() async {
    try {
      if (_controller != null) {
        _controller!.dispose();
        _controller = null;
        _isInitialized = false;
      }
    } catch (e) {
      debugPrint('バーコードサービスの解放中にエラーが発生しました: $e');
    }
  }
}

// バーコードスキャン結果クラス
class BarcodeResult {
  final String code;
  final BarcodeFormat format;
  final DateTime timestamp;

  const BarcodeResult({
    required this.code,
    required this.format,
    required this.timestamp,
  });

  // 表示用の説明を取得
  String get formatDescription => BarcodeService.getBarcodeTypeDescription(format);

  // 有効性を確認
  bool get isValid => BarcodeService.isValidBarcode(code);

  @override
  String toString() {
    return 'BarcodeResult(code: $code, format: $formatDescription, timestamp: $timestamp)';
  }
}