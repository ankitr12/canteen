import 'package:canteen_fbdb/HomePage.dart';
import 'package:canteen_fbdb/loginPage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Wrapper extends StatefulWidget {
  const Wrapper({super.key});

  @override
  State<Wrapper> createState() => _WrapperState();
}

class _WrapperState extends State<Wrapper> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data != null) {
            // User is logged in, check Firestore
            return FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance
                  .collection('users')
                  .doc(snapshot.data!.uid)
                  .get(),
              builder: (context, userSnapshot) {
                if (userSnapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                
                if (userSnapshot.hasData && userSnapshot.data!.exists) {
                  bool isBlocked = userSnapshot.data!.get('isBlocked') ?? false;
                  
                  if (isBlocked) {
                    // User is blocked, sign out and redirect to LoginPage
                    FirebaseAuth.instance.signOut();
                    return LoginPage();
                  } else {
                    // User is not blocked, proceed to HomePage
                    return HomePage();
                  }
                } else {
                  // If no user data is found, log out for safety
                  FirebaseAuth.instance.signOut();
                  return LoginPage();
                }
              },
            );
          } else {
            // User is not logged in, show LoginPage
            return LoginPage();
          }
        },
      ),
    );
  }
}
