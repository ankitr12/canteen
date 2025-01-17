import 'package:canteen_fbdb/CartPage.dart';
import 'package:canteen_fbdb/CategoryPage.dart';
import 'package:canteen_fbdb/changePasswordPage.dart';
import 'package:canteen_fbdb/loginPage.dart';
import 'package:canteen_fbdb/orderHistoryPage';
import 'package:canteen_fbdb/searchBarPage.dart';
import 'package:canteen_fbdb/updateDetailsPage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

// class MyApp1 extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Navigator.pushReplacementNamed Example',
//       initialRoute: '/',
//       routes: {
//         '/': (context) => HomePage(),
//         '/login': (context) => LoginPage(),
//       },
//     );
//   }
// }

class HomePage extends StatelessWidget {
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
    }
  ];
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  HomePage({super.key});

  Future<Map<String, dynamic>?> fetchUserDetails() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final snapshot = await FirebaseFirestore.instance
            .collection('users') // Replace with your collection name
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
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: Row(
          children: [
            Icon(Icons.restaurant_menu, color: Colors.green),
            const SizedBox(width: 8),
            Text('Khaogalli', style: TextStyle(color: Colors.black)),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: Colors.black),
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => SearchBarPage()));
            },
          ),
          SizedBox(
            width: 20,
            height: 30,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              width: double.infinity,
              height: 150,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                image: DecorationImage(
                  image: AssetImage(
                      'D:/flutter workspace/canteen_fbdb/lib/assets/featured.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  gradient: LinearGradient(
                    colors: [Colors.black.withOpacity(0.5), Colors.transparent],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ),
                ),
                child: Align(
                  alignment: Alignment.bottomLeft,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Featured Deals',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Text(
            'WHAT WOULD YOU LIKE TO EAT TODAY ?',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 17,
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: EdgeInsets.all(3),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10.0,
                mainAxisSpacing: 10.0,
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
                  child: Card(
                    elevation: 10,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          categories[index]['image']!,
                          height: 145,
                          width: 177,
                          fit: BoxFit.cover,
                        ),
                        SizedBox(height: 10),
                        Text(
                          categories[index]['name']!,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
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
        child: ListView(
          children: [
            FutureBuilder<Map<String, dynamic>?>(
              future: fetchUserDetails(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return DrawerHeader(
                    decoration: BoxDecoration(color: Colors.green),
                    child: Center(
                      child: CircularProgressIndicator(
                        color: Colors.white,
                      ),
                    ),
                  );
                }
                if (snapshot.hasError || snapshot.data == null) {
                  return DrawerHeader(
                    decoration: BoxDecoration(color: Colors.green),
                    child: Center(
                      child: Text(
                        'No User Data Available',
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                    ),
                  );
                }

                final userDetails = snapshot.data!;
                return DrawerHeader(
                  decoration: BoxDecoration(color: Colors.green),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundImage: AssetImage(
                            'D:/flutter workspace/canteen_fbdb/lib/assets/user.png'),
                      ),
                      //Icon(Icons.supervised_user_circle,
                      //size: 70, color: Colors.white),
                      SizedBox(height: 10),
                      Text(
                        userDetails['name'] ?? 'No Name',
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                      Text(
                        userDetails['email'] ?? 'No Email',
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                    ],
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.edit),
              title: Text('Update Details'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => UpdateDetailsPage()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.history),
              title: Text('Order History'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => OrderHistoryPage()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.lock),
              title: Text('Change Password'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ChangePasswordPage()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text('Logout'),
              onTap: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => LoginPage()));
              },
            ),
          ],
        ),
      ),
    );
  }
}
