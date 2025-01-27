import 'package:flutter/material.dart';
import 'package:canteen_fbdb/itemDetails.dart';

class FoodItemCard extends StatelessWidget {
  final Map<String, dynamic> foodItem;

  FoodItemCard({required this.foodItem});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        showFoodDetailsBottomSheet(context, foodItem);
      },
      child: Card(
        elevation: 3,
        margin: EdgeInsets.all(8),
        child: ListTile(
          leading: CircleAvatar(
            backgroundImage: NetworkImage(foodItem['url']),
          ),
          title: Text(foodItem['name']),
          subtitle: Text('₹${foodItem['price']}'),
        ),
      ),
    );
  }
}
