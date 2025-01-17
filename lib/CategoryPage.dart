import 'package:canteen_fbdb/models/cart_items.dart';
import 'package:canteen_fbdb/provider/cartProvider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CategoryPage extends StatefulWidget {
  final String categoryName;

  const CategoryPage({required this.categoryName, Key? key}) : super(key: key);

  @override
  _CategoryPageState createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  List<Map<String, dynamic>> dishes = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchDishes();
  }
  Future<void> fetchDishes() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('food_items')
          .where('category', isEqualTo: widget.categoryName.toLowerCase())
          .get();

      setState(() {
        dishes = snapshot.docs
            .map((doc) => doc.data() as Map<String, dynamic>)
            .toList();
        isLoading = false;
        
      });
    } catch (e) {
      print('Error fetching dishes: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.categoryName),
        backgroundColor: Colors.amberAccent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : dishes.isEmpty
              ? const Center(
                  child: Text(
                    'No dishes available in this category',
                    style: TextStyle(fontSize: 16),
                  ),
                )
              : ListView.builder(
                  itemCount: dishes.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(
                        dishes[index]['name']!.toString().toUpperCase(),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text('₹${dishes[index]['price']}'),
                      trailing: const Icon(Icons.add_shopping_cart),
                      onTap: () {
                        final cartProvider = Provider.of<CartProvider>(context, listen: false);
  cartProvider.addItem(
    CartItem(name: dishes[index]['name'], price: dishes[index]['price']),
  );
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('${dishes[index]['name']} added to cart',),duration: Duration(seconds: 1),),
    
  );
                      },
                    );
                  },
                ),
    );
  }
}
