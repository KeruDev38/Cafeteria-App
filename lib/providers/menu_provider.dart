import 'package:flutter/foundation.dart';
import '../model/product.dart';

class MenuProvider with ChangeNotifier {
  final List<Product> _products = [
    Product(id: 1, name: 'Espresso', price: 2.50, category: 'Café', stock: 100),
    Product(id: 2, name: 'Cappuccino', price: 3.50, category: 'Café', stock: 80),
    Product(id: 3, name: 'Latte', price: 4.00, category: 'Café', stock: 75),
    Product(id: 4, name: 'Americano', price: 3.00, category: 'Café', stock: 90),
    Product(id: 5, name: 'Croissant', price: 2.00, category: 'Pastelería', stock: 50),
    Product(id: 6, name: 'Muffin', price: 2.50, category: 'Pastelería', stock: 40),
    Product(id: 7, name: 'Té Verde', price: 2.00, category: 'Té', stock: 60),
    Product(id: 8, name: 'Té Negro', price: 2.00, category: 'Té', stock: 55),
  ];

  List<Product> get products => _products;

  List<String> get categories {
    return _products.map((p) => p.category).toSet().toList();
  }

  List<Product> getProductsByCategory(String category) {
    return _products.where((p) => p.category == category).toList();
  }

  Product? getProductById(int id) {
    try {
      return _products.firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }

  void addProduct(Product product) {
    _products.add(product);
    notifyListeners();
  }

  void updateProduct(Product product) {
    final index = _products.indexWhere((p) => p.id == product.id);
    if (index != -1) {
      _products[index] = product;
      notifyListeners();
    }
  }

  void deleteProduct(int id) {
    _products.removeWhere((p) => p.id == id);
    notifyListeners();
  }

  void updateStock(int productId, int quantity) {
    final product = getProductById(productId);
    if (product != null) {
      product.stock = (product.stock + quantity).clamp(0, 9999);
      notifyListeners();
    }
  }

  bool hasStock(int productId, int quantity) {
    final product = getProductById(productId);
    return product != null && product.stock >= quantity;
  }

  void reduceStock(int productId, int quantity) {
    final product = getProductById(productId);
    if (product != null && product.stock >= quantity) {
      product.stock -= quantity;
      notifyListeners();
    }
  }

  void restoreStock(int productId, int quantity) {
    updateStock(productId, quantity);
  }

  int getNextId() {
    if (_products.isEmpty) return 1;
    return _products.map((p) => p.id).reduce((a, b) => a > b ? a : b) + 1;
  }
}
