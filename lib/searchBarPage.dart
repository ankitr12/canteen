import 'dart:async';

import 'package:canteen_fbdb/CartPage.dart';
import 'package:canteen_fbdb/HomePage.dart';
import 'package:canteen_fbdb/models/cart_items.dart';
import 'package:canteen_fbdb/provider/cartProvider.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

class SearchBarPage extends StatefulWidget {
  const SearchBarPage({super.key});

  @override
  State<SearchBarPage> createState() => _SearchBarPageState();
}

class _SearchBarPageState extends State<SearchBarPage> {
  String searchQuery = "";
  List<Map<String, dynamic>> searchResults = [];

  Future<void> searchFoodItems(String query) async {
    if (query.isEmpty) {
      setState(() {
        searchResults = [];
      });
      return;
    }

    try {
      // Convert the query to lowercase for case-insensitive search
      //query = query.toLowerCase();

      // Perform Firestore queries for both name and category
      QuerySnapshot nameQuery = await FirebaseFirestore.instance
          .collection('food_items')
          .where('name', isGreaterThanOrEqualTo: query.toLowerCase())
          .where('name', isLessThanOrEqualTo: query + '\uf8ff'.toLowerCase())
          .get();

      QuerySnapshot categoryQuery = await FirebaseFirestore.instance
          .collection('food_items')
          .where('category', isGreaterThanOrEqualTo: query)
          .where('category', isLessThanOrEqualTo: query + '\uf8ff')
          .get();

      // Combine results from both queries and remove duplicates
      List<Map<String, dynamic>> combinedResults = [
        ...nameQuery.docs.map((doc) => doc.data() as Map<String, dynamic>),
        ...categoryQuery.docs.map((doc) => doc.data() as Map<String, dynamic>),
      ];

      // Remove duplicates by using a set of unique document IDs
      Map<String, Map<String, dynamic>> uniqueResults = {};
      for (var item in combinedResults) {
        uniqueResults[item['id']] = item; // Use 'id' as a unique identifier
      }

      setState(() {
        searchResults = uniqueResults.values.toList();
      });
    } catch (e) {
      print("Error fetching search results: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.restaurant_menu, color: Colors.black),
            const SizedBox(width: 8),
            Text('Khaogalli', style: TextStyle(color: Colors.black)),
          ],
        ),
        // TextField(
        //   decoration: const InputDecoration(
        //     hintText: 'Search food items...',
        //     border: InputBorder.none,
        //   ),
        //   style: const TextStyle(color: Colors.white),
        //   onChanged: (query) {
        //     setState(() {
        //       searchQuery = query;
        //     });
        //     searchFoodItems(query.toLowerCase());
        //   },
        // ),
        backgroundColor: Colors.green,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          TextField(
            decoration: const InputDecoration(
              hintText: 'Search food items here...',
              contentPadding: EdgeInsets.all(20)
              
            ),
            //style: const TextStyle(color: Colors.white),
            onChanged: (query) {
              setState(() {
                searchQuery = query;
              });
              searchFoodItems(query.toLowerCase());
            },
          ),
          searchResults.isEmpty
              ? const Center(child: Text('No results found.'))
              : Expanded(
                  child: ListView.builder(
                    itemCount: searchResults.length,
                    itemBuilder: (context, index) {
                      final item = searchResults[index];
                      return ListTile(
                        //leading: Image.network(item['image_url']),
                        title: Text(item['name']!.toString().toUpperCase()),
                        subtitle: Text('Category: ${item['category']}'),
                        trailing: Text('₹${item['price']}'),
                        onTap: () {
                          final cartProvider =
                              Provider.of<CartProvider>(context, listen: false);
                          cartProvider.addItem(
                            CartItem(
                              name: item[
                                  'name'], // Accessing directly from the item
                              price: item['price'],
                            ),
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('${item['name']} added to cart'),
                              duration: Duration(seconds: 1),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.shopping_cart), label: 'Cart'),
          BottomNavigationBarItem(
              icon: Icon(Icons.account_circle), label: 'Account'),
        ],
        selectedItemColor: Colors.green,
        onTap: (index) {
          if (index == 0) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => HomePage()),
            );
          }
          if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => CartPage()),
            );
          }
        },
      ),
    );
  }
}
