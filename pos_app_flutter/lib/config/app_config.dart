class AppConfig {
  static const String appName = 'POS Flutter';
  static const String version = '1.0.0';
  
  // API設定
  static const String defaultApiBaseUrl = 'http://localhost:8000';
  
  // デフォルト値
  static const String defaultEmployeeCode = '9999999999';
  static const String defaultStoreCode = '30';
  static const String defaultPosNo = '90';
  
  // 税率設定
  static const double taxRate = 0.10; // 10%
  
  // UI設定
  static const Duration defaultAnimationDuration = Duration(milliseconds: 300);
  static const Duration networkTimeout = Duration(seconds: 30);
  
  // カメラ設定（将来のバーコードスキャン用）
  static const Duration cameraTimeout = Duration(seconds: 30);
  
  // ローカルストレージキー
  static const String keyApiBaseUrl = 'api_base_url';
  static const String keyEmployeeCode = 'employee_code';
}