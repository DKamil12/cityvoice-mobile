class Product {
  final int id;
  final String name;
  final String? description;
  final int price;
  final String? imageUrl;
  final String category;

  Product({
    required this.id,
    required this.name,
    this.description,
    required this.price,
    this.imageUrl,
    required this.category,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      price: json['price'],
      imageUrl: json['image'], 
      category: json['category'] ?? 'Без категории',
    );
  }
}
