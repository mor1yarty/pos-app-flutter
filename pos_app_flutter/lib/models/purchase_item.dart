import 'product.dart';

class PurchaseItem {
  final Product product;
  int quantity;

  PurchaseItem({
    required this.product,
    this.quantity = 1,
  });

  int get totalPrice => product.price * quantity;

  Map<String, dynamic> toJson() {
    return {
      'product_id': product.productId,
      'product_code': product.code,
      'product_name': product.name,
      'product_price': product.price,
      'quantity': quantity,
    };
  }

  @override
  String toString() {
    return 'PurchaseItem{product: $product, quantity: $quantity, totalPrice: $totalPrice}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PurchaseItem &&
          runtimeType == other.runtimeType &&
          product == other.product;

  @override
  int get hashCode => product.hashCode;
}