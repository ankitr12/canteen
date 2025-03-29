import 'package:canteen_fbdb/wrapper.dart';
import 'package:flutter/material.dart';

class SplashPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Future.delayed(Duration(seconds: 2),() {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Wrapper()), 
      );
    });

    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('D:/flutter workspace/canteen_fbdb/lib/assets/khaogalli.png',
            height: 120), 
            const SizedBox(height: 20),
            Text(
              'FRESH FOOD ZONE',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 30),
            
          ],
        ),
      ),
    );
  }
}
