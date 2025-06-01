class Product {
  final String id;
  final String name;
  final String image;
  final String price;

  Product({required this.id, required this.name, required this.image, required this.price});

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] ?? '',
      name: json['nome'] ?? '',
      image: json['imagem'] ?? '',
      price: json['preco'] ?? '',
    );
  }
}
