import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/pos_provider.dart';
import '../models/purchase_item.dart';
import '../utils/constants.dart';

class PurchaseListWidget extends StatelessWidget {
  const PurchaseListWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<PosProvider>(
      builder: (context, provider, child) {
        return Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // セクションヘッダー
              Padding(
                padding: const EdgeInsets.all(AppConstants.defaultPadding),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '購入リスト',
                      style: AppConstants.titleStyle,
                    ),
                    if (provider.purchaseList.isNotEmpty)
                      Text(
                        '${provider.purchaseItemCount}件',
                        style: AppConstants.captionStyle.copyWith(
                          color: AppConstants.primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                  ],
                ),
              ),
              
              // 購入リストの内容
              Expanded(
                child: provider.purchaseList.isEmpty
                    ? _buildEmptyState()
                    : _buildPurchaseList(provider),
              ),
              
              // エラーメッセージ表示
              if (provider.purchaseErrorMessage != null)
                _buildErrorMessage(provider.purchaseErrorMessage!),
              
              // 成功メッセージ表示
              if (provider.purchaseSuccessMessage != null)
                _buildSuccessMessage(provider.purchaseSuccessMessage!),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: AppConstants.defaultPadding),
          Text(
            '購入する商品がありません',
            style: AppConstants.bodyStyle.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: AppConstants.defaultMargin),
          Text(
            '商品を検索して追加してください',
            style: AppConstants.captionStyle.copyWith(
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPurchaseList(PosProvider provider) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.defaultPadding,
        vertical: AppConstants.defaultMargin,
      ),
      itemCount: provider.purchaseList.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final item = provider.purchaseList[index];
        return _buildPurchaseItem(context, provider, item, index);
      },
    );
  }

  Widget _buildPurchaseItem(BuildContext context, PosProvider provider, PurchaseItem item, int index) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppConstants.defaultMargin),
      child: Row(
        children: [
          // 商品情報
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.product.name,
                  style: AppConstants.bodyStyle.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  'コード: ${item.product.code}',
                  style: AppConstants.captionStyle,
                ),
                const SizedBox(height: 4),
                Text(
                  '単価: ¥${item.product.price}',
                  style: AppConstants.captionStyle,
                ),
              ],
            ),
          ),
          
          const SizedBox(width: AppConstants.defaultMargin),
          
          // 数量操作
          Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 数量減少ボタン
                    InkWell(
                      onTap: item.quantity > 1
                          ? () => provider.updateQuantity(index, item.quantity - 1)
                          : null,
                      borderRadius: const BorderRadius.horizontal(
                        left: Radius.circular(AppConstants.defaultBorderRadius),
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        child: Icon(
                          Icons.remove,
                          size: 16,
                          color: item.quantity > 1 ? AppConstants.primaryColor : Colors.grey,
                        ),
                      ),
                    ),
                    
                    // 数量表示
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        border: Border.symmetric(
                          vertical: BorderSide(color: Colors.grey[300]!),
                        ),
                      ),
                      child: Text(
                        '${item.quantity}',
                        style: AppConstants.bodyStyle.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    
                    // 数量増加ボタン
                    InkWell(
                      onTap: () => provider.updateQuantity(index, item.quantity + 1),
                      borderRadius: const BorderRadius.horizontal(
                        right: Radius.circular(AppConstants.defaultBorderRadius),
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        child: const Icon(
                          Icons.add,
                          size: 16,
                          color: AppConstants.primaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 4),
              
              // 小計表示
              Text(
                '¥${item.totalPrice}',
                style: AppConstants.captionStyle.copyWith(
                  color: AppConstants.primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          
          const SizedBox(width: AppConstants.defaultMargin),
          
          // 削除ボタン
          IconButton(
            onPressed: () => provider.removeFromPurchaseList(index),
            icon: const Icon(Icons.delete_outline),
            color: AppConstants.errorColor,
            tooltip: '削除',
          ),
        ],
      ),
    );
  }

  Widget _buildErrorMessage(String message) {
    return Container(
      margin: const EdgeInsets.all(AppConstants.defaultPadding),
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
              message,
              style: AppConstants.captionStyle.copyWith(
                color: AppConstants.errorColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessMessage(String message) {
    return Container(
      margin: const EdgeInsets.all(AppConstants.defaultPadding),
      padding: const EdgeInsets.all(AppConstants.defaultMargin),
      decoration: BoxDecoration(
        color: AppConstants.successColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
        border: Border.all(color: AppConstants.successColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.check_circle_outline,
            color: AppConstants.successColor,
            size: 20,
          ),
          const SizedBox(width: AppConstants.defaultMargin / 2),
          Expanded(
            child: Text(
              message,
              style: AppConstants.captionStyle.copyWith(
                color: AppConstants.successColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}