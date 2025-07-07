import 'package:flutter/material.dart';

class AppConstants {
  // カラーパレット
  static const Color primaryColor = Color(0xFF2196F3);
  static const Color primaryVariant = Color(0xFF1976D2);
  static const Color secondaryColor = Color(0xFF03DAC6);
  static const Color surfaceColor = Color(0xFFF5F5F5);
  static const Color errorColor = Color(0xFFB00020);
  static const Color successColor = Color(0xFF4CAF50);
  static const Color warningColor = Color(0xFFFF9800);
  
  // テキストスタイル
  static const TextStyle headlineStyle = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: Colors.black87,
  );
  
  static const TextStyle titleStyle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: Colors.black87,
  );
  
  static const TextStyle bodyStyle = TextStyle(
    fontSize: 16,
    color: Colors.black87,
  );
  
  static const TextStyle captionStyle = TextStyle(
    fontSize: 14,
    color: Colors.black54,
  );
  
  // サイズ設定
  static const double defaultPadding = 16.0;
  static const double defaultMargin = 8.0;
  static const double defaultBorderRadius = 8.0;
  static const double defaultButtonHeight = 48.0;
  static const double defaultElevation = 2.0;
  
  // アニメーション
  static const Duration defaultAnimationDuration = Duration(milliseconds: 300);
  static const Duration fastAnimationDuration = Duration(milliseconds: 150);
  static const Duration slowAnimationDuration = Duration(milliseconds: 500);
  
  // メッセージ
  static const String errorNetworkMessage = 'ネットワークエラーが発生しました';
  static const String errorUnknownMessage = '予期しないエラーが発生しました';
  static const String loadingMessage = '読み込み中...';
  static const String noDataMessage = 'データがありません';
  static const String productNotFoundMessage = '商品がマスタ未登録です';
  static const String purchaseSuccessMessage = '購入が完了しました';
  
  // 入力バリデーション
  static const int maxProductCodeLength = 13;
  static const int minProductCodeLength = 1;
}