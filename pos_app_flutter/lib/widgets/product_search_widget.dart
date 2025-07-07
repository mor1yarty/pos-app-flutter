import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/pos_provider.dart';
import '../utils/constants.dart';

class ProductSearchWidget extends StatefulWidget {
  const ProductSearchWidget({super.key});

  @override
  State<ProductSearchWidget> createState() => _ProductSearchWidgetState();
}

class _ProductSearchWidgetState extends State<ProductSearchWidget> {
  final _codeController = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void dispose() {
    _codeController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _searchProduct() {
    final code = _codeController.text.trim();
    if (code.isNotEmpty) {
      context.read<PosProvider>().searchProduct(code);
    }
  }

  void _clearSearch() {
    _codeController.clear();
    context.read<PosProvider>().setProductCode('');
    _focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PosProvider>(
      builder: (context, provider, child) {
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // セクションタイトル
                Text(
                  '商品検索',
                  style: AppConstants.titleStyle,
                ),
                const SizedBox(height: AppConstants.defaultMargin),
                
                // 商品コード入力フィールド
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _codeController,
                        focusNode: _focusNode,
                        decoration: const InputDecoration(
                          labelText: '商品コード',
                          hintText: 'JANコードまたは商品コードを入力',
                          prefixIcon: Icon(Icons.qr_code),
                        ),
                        keyboardType: TextInputType.number,
                        maxLength: AppConstants.maxProductCodeLength,
                        onChanged: (value) {
                          provider.setProductCode(value);
                        },
                        onFieldSubmitted: (_) => _searchProduct(),
                      ),
                    ),
                    const SizedBox(width: AppConstants.defaultMargin),
                    
                    // 検索ボタン
                    ElevatedButton(
                      onPressed: provider.isSearching ? null : _searchProduct,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppConstants.primaryColor,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(80, AppConstants.defaultButtonHeight),
                      ),
                      child: provider.isSearching
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Icon(Icons.search),
                    ),
                    
                    const SizedBox(width: AppConstants.defaultMargin / 2),
                    
                    // クリアボタン
                    IconButton(
                      onPressed: _clearSearch,
                      icon: const Icon(Icons.clear),
                      tooltip: 'クリア',
                    ),
                  ],
                ),
                
                // バーコードスキャンボタン（将来実装）
                const SizedBox(height: AppConstants.defaultMargin),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: null, // 将来のバーコードスキャン機能用
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('バーコードスキャン（準備中）'),
                  ),
                ),
                
                // エラーメッセージ表示
                if (provider.searchErrorMessage != null) ...[
                  const SizedBox(height: AppConstants.defaultMargin),
                  Container(
                    padding: const EdgeInsets.all(AppConstants.defaultMargin),
                    decoration: BoxDecoration(
                      color: AppConstants.errorColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
                      border: Border.all(color: AppConstants.errorColor.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.error_outline,
                          color: AppConstants.errorColor,
                          size: 20,
                        ),
                        const SizedBox(width: AppConstants.defaultMargin / 2),
                        Expanded(
                          child: Text(
                            provider.searchErrorMessage!,
                            style: AppConstants.captionStyle.copyWith(
                              color: AppConstants.errorColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                
                // 商品情報表示
                if (provider.currentProduct != null) ...[
                  const SizedBox(height: AppConstants.defaultMargin),
                  Container(
                    padding: const EdgeInsets.all(AppConstants.defaultPadding),
                    decoration: BoxDecoration(
                      color: AppConstants.successColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
                      border: Border.all(color: AppConstants.successColor.withOpacity(0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.check_circle_outline,
                              color: AppConstants.successColor,
                              size: 20,
                            ),
                            const SizedBox(width: AppConstants.defaultMargin / 2),
                            Text(
                              '商品が見つかりました',
                              style: AppConstants.captionStyle.copyWith(
                                color: AppConstants.successColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppConstants.defaultMargin),
                        
                        // 商品詳細情報
                        _buildProductInfo('商品名', provider.currentProduct!.name),
                        _buildProductInfo('商品コード', provider.currentProduct!.code),
                        _buildProductInfo('価格', '¥${provider.currentProduct!.price}'),
                        
                        const SizedBox(height: AppConstants.defaultMargin),
                        
                        // 追加ボタン
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              provider.addToPurchaseList();
                              _clearSearch();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppConstants.successColor,
                              foregroundColor: Colors.white,
                            ),
                            icon: const Icon(Icons.add_shopping_cart),
                            label: const Text('購入リストに追加'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProductInfo(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: AppConstants.captionStyle.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppConstants.captionStyle,
            ),
          ),
        ],
      ),
    );
  }
}