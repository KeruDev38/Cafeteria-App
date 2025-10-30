class Product {
  final int id;
  String name;
  double price;
  String category;
  int stock;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.category,
    required this.stock,
  });

  Product copyWith({
    int? id,
    String? name,
    double? price,
    String? category,
    int? stock,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      category: category ?? this.category,
      stock: stock ?? this.stock,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'category': category,
      'stock': stock,
    };
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'],
      price: json['price'].toDouble(),
      category: json['category'],
      stock: json['stock'],
    );
  }
}
