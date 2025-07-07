import 'package:flutter/foundation.dart';
import '../models/product.dart';
import '../models/purchase_item.dart';
import '../models/transaction.dart';
import '../data/mock_products.dart';
import '../services/api_service.dart';

class PosProvider extends ChangeNotifier {
  // API サービス
  final ApiService _apiService = ApiService();
  
  // API使用フラグ（true: API使用, false: モックデータ使用）
  bool _useApi = false;
  
  // 商品検索関連
  String _productCode = '';
  Product? _currentProduct;
  bool _isSearching = false;
  String? _searchErrorMessage;

  // 購入リスト関連
  final List<PurchaseItem> _purchaseList = [];
  
  // 購入処理関連
  bool _isPurchasing = false;
  String? _purchaseErrorMessage;
  String? _purchaseSuccessMessage;
  bool _showTaxModal = false;

  // ローディング・エラー状態
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  String get productCode => _productCode;
  Product? get currentProduct => _currentProduct;
  bool get isSearching => _isSearching;
  String? get searchErrorMessage => _searchErrorMessage;
  
  List<PurchaseItem> get purchaseList => List.unmodifiable(_purchaseList);
  int get purchaseItemCount => _purchaseList.length;
  int get totalAmount => _purchaseList.fold(0, (sum, item) => sum + item.totalPrice);
  
  bool get isPurchasing => _isPurchasing;
  String? get purchaseErrorMessage => _purchaseErrorMessage;
  String? get purchaseSuccessMessage => _purchaseSuccessMessage;
  
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasError => _errorMessage != null;
  
  bool get useApi => _useApi;
  String get apiBaseUrl => _apiService.baseUrl;
  bool get showTaxModal => _showTaxModal;

  // 商品コード設定
  void setProductCode(String code) {
    _productCode = code;
    _clearSearchError();
    notifyListeners();
  }

  // 商品検索（API または モックデータを使用）
  Future<void> searchProduct(String code) async {
    if (code.isEmpty) {
      _setSearchError('商品コードを入力してください');
      return;
    }

    _setSearching(true);
    _clearSearchError();
    
    try {
      Product? product;
      
      if (_useApi) {
        // API経由で商品を検索
        product = await _apiService.searchProduct(code);
      } else {
        // モックデータから商品を検索
        await Future.delayed(const Duration(milliseconds: 500)); // 模擬的な遅延
        product = MockProducts.findByCode(code);
      }
      
      if (product != null) {
        _setCurrentProduct(product);
      } else {
        _setSearchError('商品がマスタ未登録です');
      }
    } on ApiException catch (e) {
      _setSearchError(e.message);
    } catch (e) {
      _setSearchError('商品検索でエラーが発生しました: ${e.toString()}');
    } finally {
      _setSearching(false);
    }
  }

  // 商品を購入リストに追加
  void addToPurchaseList() {
    if (_currentProduct == null) return;

    final existingItemIndex = _purchaseList.indexWhere(
      (item) => item.product.productId == _currentProduct!.productId,
    );

    if (existingItemIndex >= 0) {
      // 既存商品の数量を増加
      _purchaseList[existingItemIndex].quantity++;
    } else {
      // 新しい商品を追加
      _purchaseList.add(PurchaseItem(product: _currentProduct!));
    }

    _clearCurrentProduct();
    notifyListeners();
  }

  // 購入リストから商品を削除
  void removeFromPurchaseList(int index) {
    if (index >= 0 && index < _purchaseList.length) {
      _purchaseList.removeAt(index);
      notifyListeners();
    }
  }

  // 商品の数量を更新
  void updateQuantity(int index, int quantity) {
    if (index >= 0 && index < _purchaseList.length && quantity > 0) {
      _purchaseList[index].quantity = quantity;
      notifyListeners();
    }
  }

  // 税金表示モーダルを開く
  void showTaxModalDialog() {
    if (_purchaseList.isEmpty) {
      _setPurchaseError('購入する商品がありません');
      return;
    }
    _showTaxModal = true;
    notifyListeners();
  }
  
  // 税金表示モーダルを閉じる
  void hideTaxModal() {
    _showTaxModal = false;
    notifyListeners();
  }

  // 購入処理（API または モック処理を使用）
  Future<void> purchase() async {
    if (_purchaseList.isEmpty) {
      _setPurchaseError('購入する商品がありません');
      return;
    }

    _setPurchasing(true);
    _clearPurchaseMessages();
    hideTaxModal(); // 処理開始時にモーダルを閉じる

    try {
      final transaction = Transaction.fromPurchaseItems(items: _purchaseList);
      
      if (_useApi) {
        // API経由で購入処理
        final response = await _apiService.purchase(transaction);
        
        if (response.success) {
          _setPurchaseSuccess('購入が完了しました。合計金額: ¥${response.totalAmount}');
          _clearPurchaseList();
        } else {
          _setPurchaseError(response.message);
        }
      } else {
        // モック処理
        await Future.delayed(const Duration(milliseconds: 1000)); // 模擬的な遅延
        _setPurchaseSuccess('購入が完了しました。合計金額: ¥${transaction.totalAmount}');
        _clearPurchaseList();
      }
    } on ApiException catch (e) {
      _setPurchaseError(e.message);
    } catch (e) {
      _setPurchaseError('購入処理でエラーが発生しました: ${e.toString()}');
    } finally {
      _setPurchasing(false);
    }
  }

  // 購入リストをクリア
  void clearPurchaseList() {
    _purchaseList.clear();
    notifyListeners();
  }

  // 全ての状態をクリア
  void clearAll() {
    _productCode = '';
    _currentProduct = null;
    _purchaseList.clear();
    _clearAllMessages();
    notifyListeners();
  }
  
  // API使用の切り替え
  void toggleApiUsage() {
    _useApi = !_useApi;
    notifyListeners();
  }
  
  // API使用の設定
  void setApiUsage(bool useApi) {
    _useApi = useApi;
    notifyListeners();
  }
  
  // APIベースURLの設定
  Future<void> setApiBaseUrl(String url) async {
    await _apiService.setBaseUrl(url);
    notifyListeners();
  }
  
  // API接続確認
  Future<bool> checkApiConnection() async {
    try {
      return await _apiService.checkConnection();
    } catch (e) {
      return false;
    }
  }
  
  // リソースの解放
  @override
  void dispose() {
    _apiService.dispose();
    super.dispose();
  }

  // Private methods
  void _setSearching(bool searching) {
    _isSearching = searching;
    notifyListeners();
  }

  void _setCurrentProduct(Product? product) {
    _currentProduct = product;
    notifyListeners();
  }

  void _clearCurrentProduct() {
    _currentProduct = null;
    _productCode = '';
  }

  void _setSearchError(String error) {
    _searchErrorMessage = error;
    notifyListeners();
  }

  void _clearSearchError() {
    _searchErrorMessage = null;
  }

  void _setPurchasing(bool purchasing) {
    _isPurchasing = purchasing;
    notifyListeners();
  }

  void _setPurchaseError(String error) {
    _purchaseErrorMessage = error;
    notifyListeners();
  }

  void _setPurchaseSuccess(String message) {
    _purchaseSuccessMessage = message;
    notifyListeners();
  }

  void _clearPurchaseMessages() {
    _purchaseErrorMessage = null;
    _purchaseSuccessMessage = null;
  }

  void _clearPurchaseList() {
    _purchaseList.clear();
  }

  void _clearAllMessages() {
    _searchErrorMessage = null;
    _purchaseErrorMessage = null;
    _purchaseSuccessMessage = null;
    _errorMessage = null;
  }
}