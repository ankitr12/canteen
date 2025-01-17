import 'package:flutter/material.dart';

class MenuPage extends StatelessWidget {
  const MenuPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Menu'),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () {
              Navigator.pushNamed(context, '/cart'); // Navigate to Cart Page
            },
          ),
        ],
      ),
      body: DefaultTabController(
        length: 3, // Adjust the length for the number of categories
        child: Column(
          children: [
            const TabBar(
              tabs: [
                Tab(text: 'Snacks'),
                Tab(text: 'Beverages'),
                Tab(text: 'Meals'),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  MenuCategory(category: 'Snacks'),
                  MenuCategory(category: 'Beverages'),
                  MenuCategory(category: 'Meals'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MenuCategory extends StatelessWidget {
  final String category;
  const MenuCategory({required this.category, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Replace with Firebase data fetching logic
    final List<Map<String, dynamic>> dummyData = [
      {'name': 'Burger', 'price': 5.0},
      {'name': 'Fries', 'price': 3.0},
    ];

    return ListView.builder(
      itemCount: dummyData.length,
      itemBuilder: (context, index) {
        final item = dummyData[index];
        return Card(
          margin: const EdgeInsets.all(8.0),
          child: ListTile(
            title: Text(item['name']),
            subtitle: Text('\$${item['price']}'),
            trailing: ElevatedButton(
              onPressed: () {
                // Add to cart logic
              },
              child: const Text('Add to Cart'),
            ),
          ),
        );
      },
    );
  }
}
