// import 'package:canteen_fbdb/CartPage.dart';
// import 'package:provider/provider.dart';
// import 'package:canteen_fbdb/provider/cartProvider.dart';
// import 'package:canteen_fbdb/models/cart_items.dart';
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:shimmer/shimmer.dart';

// class CategoryPage extends StatefulWidget {
//   final String categoryName;

//   const CategoryPage({required this.categoryName, Key? key}) : super(key: key);

//   @override
//   _CategoryPageState createState() => _CategoryPageState();
// }

// class _CategoryPageState extends State<CategoryPage> {
//   List<Map<String, dynamic>> dishes = [];
//   bool isLoading = true;

//   @override
//   void initState() {
//     super.initState();
//     fetchDishes();
//   }

//   Future<void> fetchDishes() async {
//     try {
//       QuerySnapshot snapshot = await FirebaseFirestore.instance
//           .collection('food_items')
//           .where('category', isEqualTo: widget.categoryName.toLowerCase())
//           .get();

//       setState(() {
//         dishes = snapshot.docs
//             .map((doc) => doc.data() as Map<String, dynamic>)
//             .toList();
//         isLoading = false;
//       });
//     } catch (e) {
//       print('Error fetching dishes: $e');
//       setState(() {
//         isLoading = false;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(
//           widget.categoryName,
//           style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
//         ),
//         flexibleSpace: Container(
//           decoration: const BoxDecoration(
//             gradient: LinearGradient(
//               colors: [Colors.orange, Colors.amberAccent],
//               begin: Alignment.topLeft,
//               end: Alignment.bottomRight,
//             ),
//           ),
//         ),
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back),
//           onPressed: () {
//             Navigator.pop(context);
//           },
//         ),
//       ),
//       body: Container(
//         color: const Color.fromARGB(255, 255, 249, 228),
//         child: isLoading
//             ? _buildShimmerLoading()
//             : dishes.isEmpty
//                 ? _buildEmptyState()
//                 : _buildDishList(),
//       ),
//       floatingActionButton: FloatingActionButton(
//         backgroundColor: Colors.black,
//         child: const Icon(Icons.shopping_cart, color: Colors.amber,),
//         onPressed: () {
//           Navigator.push(context, 
//           MaterialPageRoute(builder: (context)=> CartPage())
//           );
//         },
//       ),
//     );
//   }

//   Widget _buildDishList() {
//     return ListView.builder(
//       itemCount: dishes.length,
//       itemBuilder: (context, index) {
//         final dish = dishes[index];
//         final bool isAvailable = dish['available'] ?? true;
//         return GestureDetector(
//           onTap: () => _showFoodDetailsBottomSheet(context, dish, isAvailable),
//           child: Card(
//             margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//             elevation: 4,
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(15),
//             ),
//             child: Row(
//               children: [
//                 ClipRRect(
//                   borderRadius: BorderRadius.circular(15),
//                   child: Image.network(
//                     dish['url'],
//                     width: 100,
//                     height: 100,
//                     fit: BoxFit.cover,
//                     color: isAvailable ? null : Colors.grey,
//                     colorBlendMode: isAvailable ? null : BlendMode.saturation,
//                   ),
//                 ),
//                 const SizedBox(width: 16),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         dish['name'].toString().toUpperCase(),
//                         style: TextStyle(
//                           fontSize: 18,
//                           fontWeight: FontWeight.bold,
//                           color: isAvailable ? Colors.black : Colors.grey,
//                         ),
//                       ),
//                       const SizedBox(height: 8),
//                       Text(
//                         '₹${dish['price']}',
//                         style: TextStyle(
//                           fontSize: 16,
//                           fontWeight: FontWeight.w500,
//                           color: isAvailable ? Colors.black : Colors.grey,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 const Icon(Icons.arrow_forward_ios, color: Colors.grey),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }

//   void _showFoodDetailsBottomSheet(
//       BuildContext context, Map<String, dynamic> foodItem, bool isAvailable) {
//     final cartProvider = Provider.of<CartProvider>(context, listen: false);

//     showModalBottomSheet(
//       context: context,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
//       ),
//       builder: (BuildContext context) {
//         int quantity = 1;
//         return StatefulBuilder(
//           builder: (BuildContext context, StateSetter setState) {
//             return Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Text(
//                     '₹${foodItem['price'].toStringAsFixed(2)}',
//                     style: const TextStyle(
//                         fontSize: 20,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.black),
//                   ),
//                   const SizedBox(height: 20),
//                   ElevatedButton(
//                     onPressed: isAvailable
//                         ? () {
//                             final cartItem = CartItem.fromMap(foodItem);
//                             cartItem.quantity = quantity;
//                             cartProvider.addItem(cartItem);
//                             Navigator.pop(context);
//                             ScaffoldMessenger.of(context).showSnackBar(
//                               SnackBar(
//                                 content: Text(
//                                     '${foodItem['name']} added to cart! ($quantity)'),
//                               ),
//                             );
//                           }
//                         : null,
//                     child: Text(
//                       isAvailable ? 'Add to Cart' : 'Unavailable',
//                       style: const TextStyle(color: Colors.black),
//                     ),
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor:
//                           isAvailable ? Colors.amber : Colors.grey,
//                       padding: const EdgeInsets.symmetric(
//                           horizontal: 50, vertical: 12),
//                       textStyle: const TextStyle(
//                           fontSize: 16, fontWeight: FontWeight.bold),
//                     ),
//                   ),
//                 ],
//               ),
//             );
//           },
//         );
//       },
//     );
//   }
// }
import 'package:canteen_fbdb/HomePage.dart';
import 'package:flutter/material.dart';

class MyWidget extends StatefulWidget {
  const MyWidget({super.key});

  @override
  State<MyWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: (){
            Navigator.push(context,
            PageRouteBuilder(pageBuilder: ( _, __, ___)=>HomePage()
            )
            );
          }, 
          child: Text('data')),
      ),
    );
  }
}