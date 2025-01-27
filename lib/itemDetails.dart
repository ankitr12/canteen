import 'package:canteen_fbdb/models/cart_items.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:canteen_fbdb/provider/cartProvider.dart';
class pop_up_card extends StatelessWidget {
  
  final Map<String, dynamic> foodItem;
  pop_up_card({required this.foodItem});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        showFoodDetailsBottomSheet(context, foodItem);
      },
    );
  }
}

void showFoodDetailsBottomSheet(
    BuildContext context, Map<String, dynamic> foodItem) {
  final cartProvider = Provider.of<CartProvider>(context, listen: false);

  showModalBottomSheet(
    context: context,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (BuildContext context) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Food Name
            Text(
              foodItem['name'],
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            // Food Description
            Text(
              foodItem['description'],
              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
            ),
            const SizedBox(height: 10),
            // Food Price
            Text(
              '₹${foodItem['price'].toStringAsFixed(2)}',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.green),
            ),
            const SizedBox(height: 20),
            // Add/Remove to Cart
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(Icons.remove_circle_outline),
                  onPressed: () {
                    final cartItem = CartItem.fromMap(foodItem);
                    cartProvider.decreaseQuantity(cartItem);
                  },
                ),
                Consumer<CartProvider>(
                  builder: (context, cart, child) {
                    final cartItem = CartItem.fromMap(foodItem);
                    final quantity = cart.getQuantity(cartItem) ?? 0;
                    return Text(
                      '$quantity',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    );
                  },
                ),
                IconButton(
                  icon: Icon(Icons.add_circle_outline),
                  onPressed: () {
                    final cartItem = CartItem.fromMap(foodItem);

                    // Add to cart
                    cartProvider.addItem(cartItem);
                    
                  },
                ),
              ],
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Close the bottom sheet
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${foodItem['name']} added to cart!')),
                );
              },
              child: Text('Add to Cart'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: EdgeInsets.symmetric(horizontal: 50, vertical: 12),
                textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      );
    },
  );
}
