import '../config/app_config.dart';

class TaxCalculator {
  // 税率（10%）
  static const double taxRate = AppConfig.taxRate;
  
  // 税抜価格から税込価格を計算
  static int calculateTaxIncluded(int priceExcludingTax) {
    return (priceExcludingTax * (1 + taxRate)).round();
  }
  
  // 税込価格から税抜価格を計算
  static int calculateTaxExcluded(int priceIncludingTax) {
    return (priceIncludingTax / (1 + taxRate)).round();
  }
  
  // 税込価格から消費税額を計算
  static int calculateTaxAmount(int priceIncludingTax) {
    final priceExcludingTax = calculateTaxExcluded(priceIncludingTax);
    return priceIncludingTax - priceExcludingTax;
  }
  
  // 複数の商品の税金計算結果を取得
  static TaxBreakdown calculateTaxBreakdown(int totalAmount) {
    final taxExcluded = calculateTaxExcluded(totalAmount);
    final taxAmount = totalAmount - taxExcluded;
    
    return TaxBreakdown(
      priceExcludingTax: taxExcluded,
      taxAmount: taxAmount,
      priceIncludingTax: totalAmount,
      taxRate: taxRate,
    );
  }
  
  // パーセンテージ表示用の税率文字列を取得
  static String getTaxRatePercentage() {
    return '${(taxRate * 100).toInt()}%';
  }
}

// 税金内訳クラス
class TaxBreakdown {
  final int priceExcludingTax;  // 税抜価格
  final int taxAmount;          // 消費税額
  final int priceIncludingTax;  // 税込価格
  final double taxRate;         // 税率

  const TaxBreakdown({
    required this.priceExcludingTax,
    required this.taxAmount,
    required this.priceIncludingTax,
    required this.taxRate,
  });

  @override
  String toString() {
    return 'TaxBreakdown{priceExcludingTax: $priceExcludingTax, taxAmount: $taxAmount, priceIncludingTax: $priceIncludingTax, taxRate: $taxRate}';
  }
}