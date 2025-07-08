class Product {
  final int productId;
  final String code;
  final String name;
  final int price;

  const Product({
    required this.productId,
    required this.code,
    required this.name,
    required this.price,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      productId: json['product_id'] as int,
      code: json['product_code'] as String,
      name: json['product_name'] as String,
      price: json['product_price'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product_id': productId,
      'code': code,
      'name': name,
      'price': price,
    };
  }

  @override
  String toString() {
    return 'Product{productId: $productId, code: $code, name: $name, price: $price}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Product &&
          runtimeType == other.runtimeType &&
          productId == other.productId;

  @override
  int get hashCode => productId.hashCode;
}