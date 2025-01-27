import 'package:canteen_fbdb/loginPage.dart';
import 'package:canteen_fbdb/provider/cartProvider.dart';
import 'package:canteen_fbdb/wrapper.dart';
// import 'package:canteen_fbdb/menuPage.dart';
// import 'package:canteen_fbdb/registerPage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CartProvider()),
      ],
      child: MainApp(),
    ),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return  MaterialApp(
      home: Wrapper()
    );
  }
}
