import 'package:canteen_fbdb/models/cart_items.dart';
import 'package:canteen_fbdb/paymentPage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:canteen_fbdb/provider/cartProvider.dart';

class CartPage extends StatelessWidget {
  Future<void> placeOrderWithCustomId(
      List<Map<String, dynamic>> items, double totalAmount) async {
    try {
      final FirebaseFirestore firestore = FirebaseFirestore.instance;
      DocumentReference counterDoc =
          firestore.collection('orders').doc('counter');
      final user = FirebaseAuth.instance.currentUser;
      await firestore.runTransaction((transaction) async {
        DocumentSnapshot snapshot = await transaction.get(counterDoc);

        if (snapshot.exists) {
          int currentCounter =
              (snapshot.data() as Map<String, dynamic>)['number'] as int;

          String newOrderId = currentCounter.toString();

          final order = {
            'id': newOrderId,
            'userId': user!.uid,
            'items': items,
            'totalAmount': totalAmount,
            'orderDate': FieldValue.serverTimestamp(),
            'status': 'pending',
          };

          DocumentReference newOrderDoc =
              firestore.collection('orders').doc(newOrderId);
          transaction.set(newOrderDoc, order);
          transaction.update(counterDoc, {'number': currentCounter + 1});
        } else {
          throw Exception("Counter document does not exist.");
        }
      });
    } catch (e) {
      print("Error placing order: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Cart'),
        backgroundColor: Colors.amberAccent,
        elevation: 0,
      ),
      body: Container(
        color: const Color.fromARGB(255, 255, 246, 219),
        child: cartProvider.items.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.shopping_cart_outlined,
                      size: 100,
                      color: Colors.grey,
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Your cart is empty!',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text('Go to Menu',
                          style: TextStyle(color: Colors.amber)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 30, vertical: 10),
                      ),
                    ),
                  ],
                ),
              )
            : Column(
                children: [
                  Text(
                    'Swipe left on an item to remove',
                    style: TextStyle(fontStyle: FontStyle.italic),
                  ),
                  Expanded(
                    child: ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      itemCount: cartProvider.items.length,
                      itemBuilder: (context, index) {
                        final item = cartProvider.items[index];
                        return Dismissible(
                            key: Key(item.name),
                            direction: DismissDirection.endToStart,
                            onDismissed: (direction) {
                              cartProvider.removeItem(item);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content:
                                      Text('${item.name} removed from cart!'),
                                ),
                              );
                            },
                            background: Container(
                              color: Colors.red,
                              alignment: Alignment.centerRight,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              child:
                                  const Icon(Icons.delete, color: Colors.white),
                            ),
                            child: Card(
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 5),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Column(
                                children: [
                                  ListTile(
                                    leading: CircleAvatar(
                                      backgroundImage: NetworkImage(item.url),
                                      child: Text(
                                        item.quantity.toString(),
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    title: Text(
                                      item.name.toUpperCase(),
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    subtitle: Text(
                                      '₹${item.price.toStringAsFixed(2)} x ${item.quantity}',
                                      style: TextStyle(color: Colors.grey[700]),
                                    ),
                                    trailing: IconButton(
                                      icon: const Icon(Icons.edit,
                                          color: Colors.black),
                                      onPressed: () {
                                        _showFoodDetailsBottomSheet(
                                            context, item.toMap());
                                      },
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10),
                                    child: TextField(
                                      onChanged: (value) {
                                        cartProvider.updateCustomization(
                                            item.name, value);
                                      },
                                      decoration: InputDecoration(
                                        labelText: 'Customize',
                                        hintText:
                                            'Add customization (e.g., no onions)',
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                ],
                              ),
                            ));
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Total: ₹${cartProvider.totalPrice.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        FloatingActionButton.extended(
                          onPressed: () {
                            final items = cartProvider.items.map((item) {
                              return {
                                'name': item.name,
                                'quantity': item.quantity,
                                'price': item.price,
                                'customization': item.customization ?? '',
                              };
                            }).toList();

                            final totalAmount = cartProvider.totalPrice;

                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(50)),
                              ),
                              builder: (context) => SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.25,
                                width: MediaQuery.of(context).size.width,
                                child: PaymentPage(
                                  totalAmount: totalAmount,
                                  items: items, // Pass items here
                                  clearCartCallback: cartProvider
                                      .clearCart, // Pass callback to clear cart
                                ),
                              ),
                            );
                          },
                          label: const Text(
                            'Checkout',
                            style: TextStyle(color: Colors.amber),
                          ),
                          icon: const Icon(Icons.payment, color: Colors.amber),
                          backgroundColor: Colors.black,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  void _showFoodDetailsBottomSheet(
      BuildContext context, Map<String, dynamic> foodItem) {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final existingItemIndex =
        cartProvider.items.indexWhere((item) => item.name == foodItem['name']);
    int initialQuantity = existingItemIndex >= 0
        ? cartProvider.items[existingItemIndex].quantity
        : 1;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext context) {
        int quantity = initialQuantity;

        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundImage: NetworkImage(foodItem['url']),
                        radius: 50,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              foodItem['name'],
                              style: const TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              foodItem['description'],
                              style: const TextStyle(fontSize: 16),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              '₹${foodItem['price']}',
                              style: const TextStyle(fontSize: 16),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline),
                        onPressed: () {
                          if (quantity > 1) {
                            setState(() {
                              quantity--;
                            });
                          }
                        },
                      ),
                      Text(
                        '$quantity',
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline),
                        onPressed: () {
                          setState(() {
                            quantity++;
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {
                      final cartItem = CartItem.fromMap(foodItem);
                      cartItem.quantity = quantity;
                      cartProvider.overWriteItem(cartItem);
                      Navigator.pop(context);

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                              '${foodItem['name']} updated in cart! ($quantity)'),
                        ),
                      );
                    },
                    child: const Text(
                      'Update Cart',
                      style: TextStyle(color: Colors.black),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 50, vertical: 12),
                      textStyle: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
