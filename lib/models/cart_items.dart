class CartItem {
  final String name;
  final double price;
  final String url; // Added field
  final String description; // Added field
  int quantity;
  String? customization;

  CartItem({
    required this.name,
    required this.price,
    required this.url, // Initialize field
    required this.description, // Initialize field
    this.quantity = 1,
    this.customization,
  });

  factory CartItem.fromMap(Map<String, dynamic> data) {
    return CartItem(
      name: data['name'],
      price: data['price'].toDouble(),
      url: data['url'] ?? '', // Handle missing data
      description: data['description'] ?? '', // Handle missing data
      quantity: data['quantity'] ?? 1,
      customization: data['customization'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'price': price,
      'url': url, // Add field
      'description': description, // Add field
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
