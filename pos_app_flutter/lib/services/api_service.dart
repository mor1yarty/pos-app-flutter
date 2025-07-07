import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/product.dart';
import '../models/transaction.dart';
import '../config/app_config.dart';

class ApiService {
  static const String _baseUrlKey = AppConfig.keyApiBaseUrl;
  
  late String _baseUrl;
  final http.Client _client = http.Client();
  
  ApiService() {
    _baseUrl = AppConfig.defaultApiBaseUrl;
    _loadBaseUrl();
  }

  // ベースURLをSharedPreferencesから読み込み
  Future<void> _loadBaseUrl() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedUrl = prefs.getString(_baseUrlKey);
      if (savedUrl != null && savedUrl.isNotEmpty) {
        _baseUrl = savedUrl;
      }
    } catch (e) {
      // SharedPreferencesでエラーが発生した場合はデフォルトURLを使用
      _baseUrl = AppConfig.defaultApiBaseUrl;
    }
  }

  // ベースURLを設定・保存
  Future<void> setBaseUrl(String url) async {
    _baseUrl = url;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_baseUrlKey, url);
    } catch (e) {
      // 保存に失敗してもメモリ上のURLは更新されているので続行
    }
  }

  // 現在のベースURLを取得
  String get baseUrl => _baseUrl;

  // 商品検索API
  Future<Product?> searchProduct(String code) async {
    try {
      final url = Uri.parse('$_baseUrl/products/$code');
      
      final response = await _client.get(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
      ).timeout(AppConfig.networkTimeout);

      if (response.statusCode == 200) {
        final Map<String, dynamic> json = jsonDecode(response.body);
        return Product.fromJson(json);
      } else if (response.statusCode == 404) {
        // 商品が見つからない場合
        return null;
      } else {
        throw ApiException(
          statusCode: response.statusCode,
          message: 'HTTP ${response.statusCode}: ${response.reasonPhrase}',
        );
      }
    } on http.ClientException catch (e) {
      throw ApiException(
        statusCode: 0,
        message: 'ネットワークエラー: ${e.message}',
      );
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      throw ApiException(
        statusCode: 0,
        message: '商品検索でエラーが発生しました: ${e.toString()}',
      );
    }
  }

  // 購入処理API
  Future<PurchaseResponse> purchase(Transaction transaction) async {
    try {
      final url = Uri.parse('$_baseUrl/purchase');
      
      final response = await _client.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(transaction.toJson()),
      ).timeout(AppConfig.networkTimeout);

      if (response.statusCode == 200) {
        final Map<String, dynamic> json = jsonDecode(response.body);
        return PurchaseResponse.fromJson(json);
      } else {
        final errorMessage = response.statusCode == 400
            ? '購入データに問題があります'
            : 'HTTP ${response.statusCode}: ${response.reasonPhrase}';
        
        throw ApiException(
          statusCode: response.statusCode,
          message: errorMessage,
        );
      }
    } on http.ClientException catch (e) {
      throw ApiException(
        statusCode: 0,
        message: 'ネットワークエラー: ${e.message}',
      );
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      throw ApiException(
        statusCode: 0,
        message: '購入処理でエラーが発生しました: ${e.toString()}',
      );
    }
  }

  // APIの接続確認
  Future<bool> checkConnection() async {
    try {
      final url = Uri.parse('$_baseUrl/health');
      
      final response = await _client.get(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // リソースの解放
  void dispose() {
    _client.close();
  }
}

// 購入レスポンスクラス
class PurchaseResponse {
  final bool success;
  final String message;
  final int? transactionId;
  final int totalAmount;

  const PurchaseResponse({
    required this.success,
    required this.message,
    this.transactionId,
    required this.totalAmount,
  });

  factory PurchaseResponse.fromJson(Map<String, dynamic> json) {
    return PurchaseResponse(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      transactionId: json['transaction_id'] as int?,
      totalAmount: json['total_amount'] as int? ?? 0,
    );
  }
}

// API例外クラス
class ApiException implements Exception {
  final int statusCode;
  final String message;

  const ApiException({
    required this.statusCode,
    required this.message,
  });

  @override
  String toString() {
    return 'ApiException(statusCode: $statusCode, message: $message)';
  }
}