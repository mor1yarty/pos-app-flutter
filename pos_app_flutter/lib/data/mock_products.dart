import '../models/product.dart';

class MockProducts {
  static final List<Product> _products = [
    const Product(
      productId: 1,
      code: '4901085123456',
      name: 'ボールペン（黒）',
      price: 150,
    ),
    const Product(
      productId: 2,
      code: '4901085123457',
      name: 'ボールペン（青）',
      price: 150,
    ),
    const Product(
      productId: 3,
      code: '4901085123458',
      name: 'ボールペン（赤）',
      price: 150,
    ),
    const Product(
      productId: 4,
      code: '4901085111111',
      name: 'ノート（A4・横罫）',
      price: 200,
    ),
    const Product(
      productId: 5,
      code: '4901085222222',
      name: 'クリアファイル（A4・20枚）',
      price: 300,
    ),
    const Product(
      productId: 6,
      code: '4901085333333',
      name: 'ホッチキス（中型）',
      price: 800,
    ),
    const Product(
      productId: 7,
      code: '4901085444444',
      name: 'はさみ（事務用）',
      price: 500,
    ),
    const Product(
      productId: 8,
      code: '4901085555555',
      name: 'マーカーペン（蛍光・黄）',
      price: 120,
    ),
    const Product(
      productId: 9,
      code: '4901085666666',
      name: 'マーカーペン（蛍光・ピンク）',
      price: 120,
    ),
    const Product(
      productId: 10,
      code: '4901085777777',
      name: 'マーカーペン（蛍光・緑）',
      price: 120,
    ),
  ];

  // 商品コードで検索
  static Product? findByCode(String code) {
    try {
      return _products.firstWhere((product) => product.code == code);
    } catch (e) {
      return null;
    }
  }

  // 商品IDで検索
  static Product? findById(int id) {
    try {
      return _products.firstWhere((product) => product.productId == id);
    } catch (e) {
      return null;
    }
  }

  // 全商品取得
  static List<Product> getAllProducts() {
    return List.unmodifiable(_products);
  }

  // 商品名で部分一致検索
  static List<Product> searchByName(String name) {
    if (name.isEmpty) return [];
    
    return _products
        .where((product) => product.name.contains(name))
        .toList();
  }

  // 価格範囲で検索
  static List<Product> searchByPriceRange(int minPrice, int maxPrice) {
    return _products
        .where((product) => 
            product.price >= minPrice && product.price <= maxPrice)
        .toList();
  }
}