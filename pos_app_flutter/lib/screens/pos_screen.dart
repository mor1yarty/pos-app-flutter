import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/pos_provider.dart';
import '../widgets/product_search_widget.dart';
import '../widgets/purchase_list_widget.dart';
import '../widgets/tax_modal_widget.dart';
import '../utils/constants.dart';
import '../services/barcode_service.dart';
import 'settings_screen.dart';
import 'barcode_scanner_screen.dart';

class PosScreen extends StatelessWidget {
  const PosScreen({super.key});

  // バーコードスキャナーを開く
  Future<void> _openBarcodeScanner(BuildContext context) async {
    try {
      final result = await Navigator.of(context).push<BarcodeResult>(
        MaterialPageRoute(
          builder: (context) => const BarcodeScannerScreen(),
        ),
      );
      
      if (result != null && result.isValid) {
        // バーコードが読み取れた場合は自動的に商品検索を実行
        if (context.mounted) {
          await _searchProductByBarcode(context, result.code);
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('バーコードスキャンエラー: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // バーコードから商品を検索
  Future<void> _searchProductByBarcode(BuildContext context, String code) async {
    try {
      final provider = context.read<PosProvider>();
      await provider.searchProduct(code);
      
      if (!context.mounted) return;
      
      if (provider.currentProduct != null) {
        // 商品が見つかった場合はSnackBarで通知
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'バーコードスキャン成功: ${provider.currentProduct!.name}',
            ),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        // 商品が見つからなかった場合
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('商品が見つかりませんでした: $code'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('商品検索エラー: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PosProvider>(
      builder: (context, provider, child) {
        return Stack(
          children: [
            _buildMainContent(context),
            
            // 税金表示モーダル
            if (provider.showTaxModal)
              TaxModalWidget(
                totalAmount: provider.totalAmount,
                onContinue: () {
                  provider.purchase();
                },
                onClose: () {
                  provider.hideTaxModal();
                },
              ),
          ],
        );
      },
    );
  }

  Widget _buildMainContent(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('POS システム'),
        centerTitle: true,
        actions: [
          // バーコードスキャンボタン
          IconButton(
            icon: const Icon(Icons.qr_code_scanner),
            onPressed: () => _openBarcodeScanner(context),
            tooltip: 'バーコードスキャン',
          ),
          Consumer<PosProvider>(
            builder: (context, provider, child) {
              return IconButton(
                icon: Icon(
                  provider.useApi ? Icons.cloud : Icons.storage,
                  color: provider.useApi ? Colors.white : Colors.orange,
                ),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const SettingsScreen(),
                    ),
                  );
                },
                tooltip: provider.useApi ? 'API接続中' : 'モック使用中',
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<PosProvider>().clearAll();
            },
            tooltip: 'リセット',
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // 商品検索セクション
            Container(
              padding: const EdgeInsets.all(AppConstants.defaultPadding),
              child: const ProductSearchWidget(),
            ),
            
            // 購入リストセクション
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.defaultPadding,
                ),
                child: const PurchaseListWidget(),
              ),
            ),
            
            // 購入ボタンセクション
            Container(
              padding: const EdgeInsets.all(AppConstants.defaultPadding),
              child: Consumer<PosProvider>(
                builder: (context, provider, child) {
                  return Column(
                    children: [
                      // 合計金額表示
                      if (provider.purchaseList.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.all(AppConstants.defaultPadding),
                          decoration: BoxDecoration(
                            color: AppConstants.surfaceColor,
                            borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '合計:',
                                style: AppConstants.titleStyle,
                              ),
                              Text(
                                '¥${provider.totalAmount.toString().replaceAllMapped(
                                  RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                                  (match) => '${match[1]},',
                                )}',
                                style: AppConstants.titleStyle.copyWith(
                                  color: AppConstants.primaryColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      
                      const SizedBox(height: AppConstants.defaultMargin),
                      
                      // 購入ボタン
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: provider.purchaseList.isEmpty || provider.isPurchasing
                              ? null
                              : () => provider.showTaxModalDialog(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppConstants.primaryColor,
                            foregroundColor: Colors.white,
                          ),
                          child: provider.isPurchasing
                              ? const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                      ),
                                    ),
                                    SizedBox(width: AppConstants.defaultMargin),
                                    Text('処理中...'),
                                  ],
                                )
                              : Text(
                                  '購入確認 (${provider.purchaseItemCount}件)',
                                  style: AppConstants.bodyStyle.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}