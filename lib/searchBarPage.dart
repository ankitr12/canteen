import 'package:canteen_fbdb/CartPage.dart';
import 'package:canteen_fbdb/changePasswordPage.dart';
import 'package:canteen_fbdb/feedbackPage.dart';
import 'package:canteen_fbdb/loginPage.dart';
import 'package:canteen_fbdb/models/cart_items.dart';
import 'package:canteen_fbdb/orderHistoryPage.dart';
import 'package:canteen_fbdb/provider/cartProvider.dart';
import 'package:canteen_fbdb/updateDetailsPage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';

class SearchBarPage extends StatefulWidget {
  SearchBarPage({super.key});

  @override
  State<SearchBarPage> createState() => _SearchBarPageState();
}

class _SearchBarPageState extends State<SearchBarPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
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

      List<Map<String, dynamic>> combinedResults = [
        ...nameQuery.docs.map((doc) => doc.data() as Map<String, dynamic>),
        ...categoryQuery.docs.map((doc) => doc.data() as Map<String, dynamic>),
      ];

      Map<String, Map<String, dynamic>> uniqueResults = {};
      for (var item in combinedResults) {
        uniqueResults[item['id']] = item;
      }

      setState(() {
        searchResults = uniqueResults.values.toList();
      });
    } catch (e) {
      print("Error fetching search results: $e");
    }
  }

  Future<Map<String, dynamic>?> fetchUserDetails() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final snapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (snapshot.exists) {
          return snapshot.data();
        }
      } catch (e) {
        print("Error fetching user data: $e");
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: Container(
        color: const Color.fromARGB(255, 255, 249, 228),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Material(
                elevation: 8,
                borderRadius: BorderRadius.circular(30),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search food items...',
                    prefixIcon: Icon(Icons.search, color: Colors.black),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(20),
                  ),
                  onChanged: (query) {
                    setState(() {
                      searchQuery = query;
                    });
                    searchFoodItems(query.toLowerCase());
                  },
                ),
              ),
            ),
            searchResults.isEmpty
                ? Expanded(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.fastfood,
                              size: 100, color: Colors.grey[400]),
                          const SizedBox(height: 10),
                          Text(
                            'No results found!',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : Expanded(
                    child: ListView.builder(
                      itemCount: searchResults.length,
                      itemBuilder: (context, index) {
                        final item = searchResults[index];
                        return FadeIn(
                          child: Card(
                            margin: const EdgeInsets.symmetric(
                                vertical: 8, horizontal: 16),
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: ListTile(
                              leading: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.network(
                                  item['url'] ??
                                      'https://via.placeholder.com/80',
                                  width: 60,
                                  height: 60,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              title: Text(
                                item['name'].toString().toUpperCase(),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              subtitle: Text('Category: ${item['category']}'),
                              trailing: Text(
                                '₹${item['price']}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              onTap: () {
                                // final cartProvider = Provider.of<CartProvider>(
                                //     context,
                                //     listen: false);
                                // cartProvider.addItem(
                                //   CartItem(
                                //     name: item['name'],
                                //     price: item['price'],
                                //   ),
                                // );
                                // ScaffoldMessenger.of(context).showSnackBar(
                                //   SnackBar(
                                //     content:
                                //         Text('${item['name']} added to cart'),
                                //     duration: Duration(seconds: 1),
                                //   ),
                                // );
                                showFoodDetailsBottomSheet(context, item);
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.black,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.shopping_cart), label: 'Cart'),
          BottomNavigationBarItem(
              icon: Icon(Icons.account_circle), label: 'Account'),
        ],
        selectedItemColor: Colors.amber,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          if (index == 0) {
            Navigator.pop(context);
          }
          if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => CartPage()),
            );
          } else if (index == 2) {
            _scaffoldKey.currentState?.openEndDrawer();
          }
        },
      ),
      endDrawer: Drawer(
        backgroundColor: Color.fromARGB(255, 255, 249, 228),
        child: ListView(
          children: [
            FutureBuilder<Map<String, dynamic>?>(
              future: fetchUserDetails(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return DrawerHeader(
                    decoration: BoxDecoration(color: Colors.black),
                    child: Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    ),
                  );
                }
                if (snapshot.hasError || snapshot.data == null) {
                  return DrawerHeader(
                    decoration: BoxDecoration(color: Colors.black),
                    child: Center(
                      child: Text(
                        'No User Data Available',
                        style:
                            TextStyle(color: Colors.amberAccent, fontSize: 18),
                      ),
                    ),
                  );
                }

                final userDetails = snapshot.data!;
                return DrawerHeader(
                  decoration: BoxDecoration(color: Colors.black),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundImage: AssetImage(
                            'D:/flutter workspace/canteen_fbdb/lib/assets/user.png'),
                      ),
                      SizedBox(height: 10),
                      Text(
                        userDetails['name'] ?? 'No Name',
                        style: TextStyle(color: Colors.amber, fontSize: 18),
                      ),
                      Text(
                        userDetails['email'] ?? 'No Email',
                        style: TextStyle(color: Colors.amber, fontSize: 14),
                      ),
                    ],
                  ),
                );
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.edit),
              title: Text('Update Details'),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => UpdateDetailsPage()));
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.history),
              title: Text('Order History'),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => OrderHistoryPage()));
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.lock),
              title: Text('Change Password'),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ChangePasswordPage()));
              },
            ),
            Divider(),
            _drawerListTile(
              icon: Icons.feedback,
              text: 'Feedback',
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (context) => FeedbackPage())),
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text('Logout'),
              onTap: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()),
                  (Route<dynamic> route) => false,
                );
              },
            ),
            Divider(),
          ],
        ),
      ),
    );
  }
  Widget _drawerListTile(
      {required IconData icon,
      required String text,
      required VoidCallback onTap}) {
    return ListTile(
      leading: Icon(icon),
      title: Text(text),
      onTap: onTap,
    );
  }
}

// Function to show the bottom sheet
void showFoodDetailsBottomSheet(
    BuildContext context, Map<String, dynamic> foodItem) {
  final cartProvider = Provider.of<CartProvider>(context, listen: false);

  showModalBottomSheet(
    context: context,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (BuildContext context) {
      int quantity = 1; // Local state for tracking quantity

      return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Image and Details Row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Food Image
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        foodItem['url'],
                        width: 90,
                        height: 90,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Icon(
                          Icons.image_not_supported,
                          size: 80,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Food Name and Description
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            foodItem['name'],
                            style: const TextStyle(
                                fontSize: 22, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            foodItem['description'],
                            style: TextStyle(
                                fontSize: 16, color: Colors.grey[700]),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // Food Price
                Text(
                  '₹${foodItem['price'].toStringAsFixed(2)}',
                  style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                ),
                const SizedBox(height: 20),
                // Add/Remove to Cart
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
                    // Add to cart
                    final cartItem = CartItem.fromMap(foodItem);
                    cartItem.quantity = quantity; // Set quantity
                    cartProvider.addItem(cartItem);
                    Navigator.pop(context); // Close the bottom sheet
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                            '${foodItem['name']} added to cart! ($quantity)'),
                      ),
                    );
                  },
                  child: const Text(
                    'Add to Cart',
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
