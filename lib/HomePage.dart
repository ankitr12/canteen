import 'package:canteen_fbdb/feedbackPage.dart';
import 'package:canteen_fbdb/orderHistoryPage.dart';
import 'package:canteen_fbdb/orderTrackingPage.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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

  @override
  void initState() {
    super.initState();
    _checkLatestOrderStatus();
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
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
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
                                  OrderTrackingPage(orderId: latestOrder['id']),
                            ),
                          );
                        } else {
                          // Handle case where order is null or orderId is not found
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("No order found to track!")),
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
                    items: [
                      'D:/flutter workspace/canteen_fbdb/lib/assets/featured.jpg',
                      'D:/flutter workspace/canteen_fbdb/lib/assets/featured.jpg',
                      'D:/flutter workspace/canteen_fbdb/lib/assets/featured.jpg',
                    ].map((image) {
                      return Container(
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
                    'WHAT WOULD YOU LIKE TO EAT TODAY?',
                    style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        backgroundColor:
                            const Color.fromARGB(255, 255, 231, 145)),
                  ),
                ),
                // Categories Grid
                GridView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  padding: EdgeInsets.all(16.0),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12.0,
                    mainAxisSpacing: 12.0,
                  ),
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CategoryPage(
                              categoryName: categories[index]['name']!,
                            ),
                          ),
                        );
                      },
                      child: Hero(
                        tag: categories[index]['name']!,
                        child: Material(
                          elevation: 6,
                          borderRadius: BorderRadius.circular(15),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              image: DecorationImage(
                                image: AssetImage(categories[index]['image']!),
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
