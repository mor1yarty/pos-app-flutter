import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../utils/tax_calculator.dart';

class TaxModalWidget extends StatelessWidget {
  final int totalAmount;
  final VoidCallback? onContinue;
  final VoidCallback? onClose;

  const TaxModalWidget({
    super.key,
    required this.totalAmount,
    this.onContinue,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final taxBreakdown = TaxCalculator.calculateTaxBreakdown(totalAmount);
    
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius * 2),
      ),
      child: Container(
        padding: const EdgeInsets.all(AppConstants.defaultPadding * 1.5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius * 2),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppConstants.primaryColor.withOpacity(0.1),
              AppConstants.secondaryColor.withOpacity(0.1),
            ],
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // タイトル
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.defaultPadding,
                vertical: AppConstants.defaultMargin,
              ),
              decoration: BoxDecoration(
                color: AppConstants.primaryColor,
                borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.receipt_long,
                    color: Colors.white,
                    size: 24,
                  ),
                  const SizedBox(width: AppConstants.defaultMargin),
                  Text(
                    '購入明細',
                    style: AppConstants.titleStyle.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: AppConstants.defaultPadding),
            
            // 税金内訳表示
            Container(
              padding: const EdgeInsets.all(AppConstants.defaultPadding),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Column(
                children: [
                  // 税抜金額
                  _buildAmountRow(
                    '税抜金額',
                    taxBreakdown.priceExcludingTax,
                    Icons.shopping_cart_outlined,
                    Colors.grey[700]!,
                  ),
                  
                  const Divider(height: AppConstants.defaultPadding),
                  
                  // 消費税
                  _buildAmountRow(
                    '消費税 (${TaxCalculator.getTaxRatePercentage()})',
                    taxBreakdown.taxAmount,
                    Icons.percent,
                    AppConstants.warningColor,
                  ),
                  
                  const Divider(height: AppConstants.defaultPadding),
                  
                  // 税込合計
                  Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: AppConstants.defaultMargin,
                    ),
                    decoration: BoxDecoration(
                      color: AppConstants.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
                    ),
                    child: _buildAmountRow(
                      '税込合計',
                      taxBreakdown.priceIncludingTax,
                      Icons.payments,
                      AppConstants.primaryColor,
                      isTotal: true,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: AppConstants.defaultPadding),
            
            // 補足説明
            Container(
              padding: const EdgeInsets.all(AppConstants.defaultMargin),
              decoration: BoxDecoration(
                color: AppConstants.successColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
                border: Border.all(color: AppConstants.successColor.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: AppConstants.successColor,
                    size: 20,
                  ),
                  const SizedBox(width: AppConstants.defaultMargin / 2),
                  Expanded(
                    child: Text(
                      '上記金額で購入処理を実行します',
                      style: AppConstants.captionStyle.copyWith(
                        color: AppConstants.successColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: AppConstants.defaultPadding),
            
            // ボタン
            Row(
              children: [
                // キャンセルボタン
                Expanded(
                  child: OutlinedButton(
                    onPressed: onClose,
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.grey[400]!),
                      foregroundColor: Colors.grey[700],
                    ),
                    child: const Text('キャンセル'),
                  ),
                ),
                
                const SizedBox(width: AppConstants.defaultMargin),
                
                // 購入ボタン
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    onPressed: onContinue,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppConstants.successColor,
                      foregroundColor: Colors.white,
                    ),
                    icon: const Icon(Icons.shopping_cart_checkout),
                    label: const Text('購入実行'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAmountRow(
    String label,
    int amount,
    IconData icon,
    Color color, {
    bool isTotal = false,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          color: color,
          size: isTotal ? 24 : 20,
        ),
        const SizedBox(width: AppConstants.defaultMargin),
        Expanded(
          child: Text(
            label,
            style: (isTotal ? AppConstants.titleStyle : AppConstants.bodyStyle).copyWith(
              color: color,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
        Text(
          '¥${amount.toString().replaceAllMapped(
            RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
            (match) => '${match[1]},',
          )}',
          style: (isTotal ? AppConstants.titleStyle : AppConstants.bodyStyle).copyWith(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: isTotal ? 20 : 16,
          ),
        ),
      ],
    );
  }
}