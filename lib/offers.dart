import 'package:flutter/material.dart';

class Offers extends StatelessWidget {
  const Offers({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color.fromARGB(255, 254, 248, 227),
        body: Center(
          
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.discount_outlined,
              size: 150,
              color: Colors.grey.shade500,),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Offers will be displayed here as per canteen',
                  style:
                      TextStyle(color: Colors.black, fontWeight: FontWeight.bold,fontSize: 20
                      ),
                ),
              ),
            ],
          ),
        ));
  }
}
