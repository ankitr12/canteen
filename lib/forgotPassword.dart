import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:math';

class ForgotPasswordPage extends StatefulWidget {
  @override
  _ForgotPasswordPageState createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController otpController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool isOtpSent = false;
  String? generatedOtp;

  Future<void> sendOtp(String email) async {
    try {
      // Check if email exists in Firebase Authentication
      final userQuery = await FirebaseFirestore.instance
          .collection('users') // Replace with your users collection name
          .where('email', isEqualTo: email)
          .get();

      if (userQuery.docs.isEmpty) {
        throw Exception('No account associated with this email.');
      }

      // Generate a 6-digit OTP
      generatedOtp = (Random().nextInt(900000) + 100000).toString();

      // Send OTP via email (Here, replace this with your backend email sending logic)
      await FirebaseFirestore.instance.collection('otp_logs').doc(email).set({
        'otp': generatedOtp,
        'expiresAt': DateTime.now().add(Duration(minutes: 5)).toIso8601String(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('OTP sent to $email')),
      );

      setState(() {
        isOtpSent = true;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  Future<void> verifyOtp(String email, String enteredOtp) async {
    try {
      // Fetch OTP from Firestore
      final otpDoc = await FirebaseFirestore.instance
          .collection('otp_logs')
          .doc(email)
          .get();

      if (!otpDoc.exists) {
        throw Exception('No OTP found for this email.');
      }

      final data = otpDoc.data()!;
      final expiresAt = DateTime.parse(data['expiresAt']);

      if (DateTime.now().isAfter(expiresAt)) {
        throw Exception('OTP expired.');
      }

      if (data['otp'] != enteredOtp) {
        throw Exception('Invalid OTP.');
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('OTP verified. Proceed to reset password.')),
      );

      // Reset Password (Firebase built-in functionality)
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Forgot Password'),
        backgroundColor: Colors.amberAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (!isOtpSent)
                TextFormField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'Enter your email',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                      return 'Enter a valid email';
                    }
                    return null;
                  },
                ),
              if (isOtpSent)
                TextFormField(
                  controller: otpController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Enter OTP',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the OTP';
                    }
                    return null;
                  },
                ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (!isOtpSent) {
                    if (_formKey.currentState?.validate() ?? false) {
                      sendOtp(emailController.text.trim());
                    }
                  } else {
                    if (_formKey.currentState?.validate() ?? false) {
                      verifyOtp(emailController.text.trim(), otpController.text.trim());
                    }
                  }
                },
                child: Text(isOtpSent ? 'Verify OTP' : 'Send OTP'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
