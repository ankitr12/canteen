class CartItem {
  final String name;
  final double price;
  final String url; 
  final String description;
  int quantity;
  String? customization;

  CartItem({
    required this.name,
    required this.price,
    required this.url, 
    required this.description, 
    this.quantity = 1,
    this.customization,
  });

  factory CartItem.fromMap(Map<String, dynamic> data) {
    return CartItem(
      name: data['name'],
      price: data['price'].toDouble(),
      url: data['url'] ?? '', 
      description: data['description'] ?? '', 
      quantity: data['quantity'] ?? 1,
      customization: data['customization'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'price': price,
      'url': url, 
      'description': description, 
      'quantity': quantity,
      'customization': customization,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CartItem &&
          runtimeType == other.runtimeType &&
          name == other.name;

  @override
  int get hashCode => name.hashCode;
}
