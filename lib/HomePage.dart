import 'dart:async';
import 'package:canteen_fbdb/feedbackPage.dart';
import 'package:canteen_fbdb/models/cart_items.dart';
import 'package:canteen_fbdb/offers.dart';
import 'package:canteen_fbdb/orderAfterTracking.dart';
import 'package:canteen_fbdb/orderHistoryPage.dart';
//import 'package:canteen_fbdb/orderAfterTrackingPage.dart';
import 'package:canteen_fbdb/provider/cartProvider.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'CategoryPage.dart';
import 'CartPage.dart';
import 'changePasswordPage.dart';
import 'loginPage.dart';
import 'searchBarPage.dart';
import 'updateDetailsPage.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> foodItems = [];

  final List<Map<String, String>> categories = [
    {
      'name': 'Sandwich',
      'image': 'D:/flutter workspace/canteen_fbdb/lib/assets/sandwich.png'
    },
    {
      'name': 'Frankie',
      'image': 'D:/flutter workspace/canteen_fbdb/lib/assets/frankie.png'
    },
    {
      'name': 'Main Course',
      'image': 'D:/flutter workspace/canteen_fbdb/lib/assets/main_course.png'
    },
    {
      'name': 'Chinese',
      'image': 'D:/flutter workspace/canteen_fbdb/lib/assets/chinese.png'
    },
    {
      'name': 'South Indian',
      'image': 'D:/flutter workspace/canteen_fbdb/lib/assets/south_indian.png'
    },
    {
      'name': 'Breakfast',
      'image': 'D:/flutter workspace/canteen_fbdb/lib/assets/breakfast.png'
    },
    {
      'name': 'Snacks',
      'image': 'D:/flutter workspace/canteen_fbdb/lib/assets/snacks.png'
    },
    {
      'name': 'Beverages',
      'image': 'D:/flutter workspace/canteen_fbdb/lib/assets/beverage.png'
    },
  ];

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _showTrackingOption = false;
  StreamSubscription<QuerySnapshot>? _ordersSubscription;
  @override
  void initState() {
    super.initState();
    //_checkLatestOrderStatus();
    _setupOrdersListener();
    fetchFoodItems();
  }

  @override
  void dispose() {
    _ordersSubscription
        ?.cancel(); // Cancel the listener when the widget is disposed
    super.dispose();
  }

  Future<Map<String, dynamic>?> _setupOrdersListener() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return null;

    // Listen for changes in the orders collection
    _ordersSubscription = FirebaseFirestore.instance
        .collection('orders')
        .where('userId', isEqualTo: userId)
        .orderBy('orderDate', descending: true)
        .limit(1)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        final order = snapshot.docs.first.data();
        final status = order['status'];
        setState(() {
          _showTrackingOption =
              status != 'COMPLETED'; // Update UI based on order status
        });
      } else {
        setState(() {
          _showTrackingOption = false; // No orders found
        });
      }
    });
  }

  Future<void> fetchFoodItems() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('food_items').get();
    final items = snapshot.docs.map((doc) => doc.data()).toList();

    setState(() {
      foodItems = items..shuffle(); // Shuffle for randomness
    });
  }

  Future<Map<String, dynamic>?> _checkLatestOrderStatus() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    final querySnapshot = await FirebaseFirestore.instance
        .collection('orders')
        .where('userId', isEqualTo: userId)
        .orderBy('orderDate', descending: true)
        .limit(1)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      final order = querySnapshot.docs.first.data();
      return {'id': querySnapshot.docs.first.id, ...order};
    }
    return null;
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

  Future<void> _reloadPage() async {
    // Fetch the latest order status
    final userId = FirebaseAuth.instance.currentUser?.uid;
    final querySnapshot = await FirebaseFirestore.instance
        .collection('orders')
        .where('userId', isEqualTo: userId)
        .orderBy('orderDate', descending: true)
        .limit(1)
        .get();
    // Update the UI state
    setState(() {
      if (querySnapshot.docs.isNotEmpty) {
        final order = querySnapshot.docs.first.data();
        final status = order['status'];
        _showTrackingOption = status != 'COMPLETED';
      } else {
        _showTrackingOption = false;
      }
      fetchFoodItems();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: Row(
          children: [
            SizedBox(width: 20),
            Icon(Icons.restaurant_menu, color: Colors.yellow),
            SizedBox(width: 8),
            Text('Khaogalli',
                style: GoogleFonts.roboto(
                  fontSize: 26,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: Colors.white),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                builder: (context) => SizedBox(
                  height: MediaQuery.of(context).size.height * 0.8,
                  child: SearchBarPage(),
                ),
              );
            },
          ),
          SizedBox(height: 20, width: 20),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _reloadPage,
        child: Container(
          color: const Color.fromARGB(255, 255, 249, 228),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Track Order Card
                if (_showTrackingOption)
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: GestureDetector(
                      onTap: () async {
                        // Retrieve the latest order
                        final latestOrder = await _checkLatestOrderStatus();

                        // Check if the order exists and navigate with the orderId
                        if (latestOrder != null && latestOrder['id'] != null) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  OrderAfterTrackingPage(orderId: latestOrder['id']),
                            ),
                          );
                        } else {
                          // Handle case where order is null or orderId is not found
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("No order found to track!"),
                              margin: EdgeInsets.only(
                                bottom: MediaQuery.of(context).size.height -
                                    100, // Adjust this value as needed
                                left: 10,
                                right: 10,
                              ),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      },
                      child: Card(
                        color: Colors.yellow,
                        elevation: 5,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Icon(Icons.track_changes,
                                  color: Colors.black, size: 28),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'Track Your Last Order',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                              const Icon(Icons.arrow_forward_ios,
                                  color: Colors.black),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                // Featured Deals Carousel
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: CarouselSlider(
                    carouselController: CarouselSliderController(),
                    items: [
                      'D:/flutter workspace/canteen_fbdb/lib/assets/featured.jpg',
                      'D:/flutter workspace/canteen_fbdb/lib/assets/featured.jpg',
                      'D:/flutter workspace/canteen_fbdb/lib/assets/featured.jpg',
                    ].map((image) {
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => Offers()));
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            image: DecorationImage(
                              image: AssetImage(image),
                              fit: BoxFit.cover,
                              colorFilter: ColorFilter.srgbToLinearGamma(),
                            ),
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              gradient: LinearGradient(
                                colors: [
                                  Colors.black.withOpacity(0.6),
                                  Colors.transparent
                                ],
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                              ),
                            ),
                            child: Align(
                              alignment: Alignment.bottomLeft,
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Text(
                                  'Featured Deals',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                    options: CarouselOptions(
                      autoPlay: true,
                      aspectRatio: 2.5,
                      enlargeCenterPage: true,
                    ),
                  ),
                ),
                // Welcome Text

                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 18.0, vertical: 8.0),
                  child: Text(
                    ' WHAT WOULD YOU LIKE TO EAT TODAY?',
                    style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        backgroundColor:
                            const Color.fromARGB(255, 255, 231, 145)),
                  ),
                ),
                //categories
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: Text(
                    ' Categories',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ),
                SizedBox(
                  height: 190,
                  child: ListView.builder(
                    padding: EdgeInsets.all(8.0),
                    scrollDirection: Axis.horizontal,
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => CategoryPage(
                                      categoryName: categories[index]
                                          ['name']!)));
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              Hero(
                                tag: categories[index]['name']!,
                                child: Material(
                                  elevation: 6,
                                  borderRadius: BorderRadius.circular(15),
                                  child: Container(
                                    height: 150,
                                    width: 150,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(15),
                                      image: DecorationImage(
                                        image: AssetImage(
                                            categories[index]['image']!),
                                        fit: BoxFit.cover,
                                        scale: 10,
                                      ),
                                    ),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(15),
                                        gradient: LinearGradient(
                                          colors: [
                                            Colors.black.withOpacity(0.5),
                                            Colors.transparent
                                          ],
                                          begin: Alignment.bottomCenter,
                                          end: Alignment.topCenter,
                                        ),
                                      ),
                                      child: Center(
                                        child: Text(
                                          categories[index]['name']!,
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Text('   Menu',
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                foodItems.isEmpty
                    ? Center(
                        child:
                            CircularProgressIndicator())
                    : GridView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        padding: EdgeInsets.all(16.0),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12.0,
                          mainAxisSpacing: 12.0,
                        ),
                        itemCount: foodItems.length,
                        itemBuilder: (context, index) {
                          final food = foodItems[index];
                          final bool isAvailable = food['available'] ?? true;
                          return GestureDetector(
                            onTap: () {
                              // Navigate to food details page (create if needed)
                              showFoodDetailsBottomSheet(
                                  context, food, isAvailable);
                            },
                            child: Material(
                              elevation: 6,
                              borderRadius: BorderRadius.circular(15),
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15),
                                  image: DecorationImage(
                                    image: NetworkImage(food[
                                        'url']), // Ensure Firestore has image URLs
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(15),
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.black.withOpacity(0.5),
                                        Colors.transparent
                                      ],
                                      begin: Alignment.bottomCenter,
                                      end: Alignment.topCenter,
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      softWrap: true,
                                      food['name']
                                          .toString()
                                          .toUpperCase(), // Food item name
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.black,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.shopping_cart), label: 'Cart'),
          BottomNavigationBarItem(
              icon: Icon(Icons.account_circle), label: 'Account'),
        ],
        selectedItemColor: Colors.amber,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          if (index == 1) {
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => CartPage()));
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
                future: fetchUserDetails(), builder: _drawerHeaderBuilder),
            Divider(),
            _drawerListTile(
              icon: Icons.edit,
              text: 'Update Details',
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (context) => UpdateDetailsPage())),
            ),
            Divider(),
            _drawerListTile(
              icon: Icons.history,
              text: 'Order History',
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (context) => OrderHistoryPage())),
            ),
            Divider(),
            _drawerListTile(
              icon: Icons.lock,
              text: 'Change Password',
              onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ChangePasswordPage())),
            ),
            Divider(),
            _drawerListTile(
              icon: Icons.feedback,
              text: 'Feedback',
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (context) => FeedbackPage())),
            ),
            Divider(),
            _drawerListTile(
              icon: Icons.logout,
              text: 'Logout',
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

  Widget _drawerHeaderBuilder(
      BuildContext context, AsyncSnapshot<Map<String, dynamic>?> snapshot) {
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
            style: TextStyle(color: Colors.amber, fontSize: 18),
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
    BuildContext context, Map<String, dynamic> foodItem, bool isAvailable) {
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
                            foodItem['name'].toString().toUpperCase(),
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
                  onPressed: isAvailable
                      ? () {
                          final cartItem = CartItem.fromMap(foodItem);
                          cartItem.quantity = quantity;
                          cartProvider.addItem(cartItem);
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              duration: Duration(seconds: 1),
                              content: Text(
                                  '${foodItem['name']} added to cart! ($quantity)'),
                              margin: EdgeInsets.only(
                                bottom: MediaQuery.of(context).size.height -
                                    820, // Adjust this value as needed
                                left: 10,
                                right: 10,
                              ),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      : null,
                  child: Text(
                    isAvailable ? 'Add to Cart' : 'Unavailable',
                    style: const TextStyle(color: Colors.black),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isAvailable ? Colors.amber : Colors.grey,
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


