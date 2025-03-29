import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math';

class ForgotPasswordPage extends StatefulWidget {
  @override
  _ForgotPasswordPageState createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage>
    with SingleTickerProviderStateMixin {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController otpController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool isOtpSent = false;
  bool isLoading = false;
  String? generatedOtp;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1000),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeIn,
      ),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> sendOtp(String email) async {
    setState(() {
      isLoading = true;
    });
    try {
      final userQuery = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: email)
          .get();

      if (userQuery.docs.isEmpty) {
        throw Exception('No account associated with this email.');
      }

      generatedOtp = (Random().nextInt(900000) + 100000).toString();

      await FirebaseFirestore.instance.collection('otp_logs').doc(email).set({
        'otp': generatedOtp,
        'expiresAt': DateTime.now().add(Duration(minutes: 5)).toIso8601String(),
      });

      bool emailSent = await _sendEmail(email, generatedOtp!);
      if (!emailSent) throw Exception("Failed to send OTP via email.");

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('OTP sent to $email')),
      );

      setState(() {
        isOtpSent = true;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  Future<void> verifyOtp(String email, String enteredOtp) async {
    setState(() {
      isLoading = true;
    });
    try {
      final otpDoc = await FirebaseFirestore.instance
          .collection('otp_logs')
          .doc(email)
          .get();

      if (!otpDoc.exists) throw Exception('No OTP found for this email.');

      final data = otpDoc.data()!;
      final expiresAt = DateTime.parse(data['expiresAt']);

      if (DateTime.now().isAfter(expiresAt)) throw Exception('OTP expired.');
      if (data['otp'] != enteredOtp) throw Exception('Invalid OTP.');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('OTP verified. An password reset link has been sent to your email !')),
      );

      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      Navigator.pop(context);
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  Future<bool> _sendEmail(String email, String otp) async {
    const String apiUrl = "https://api.sendgrid.com/v3/mail/send";
    const String apiKey = "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";

    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        "Authorization": "Bearer $apiKey",
        "Content-Type": "application/json"
      },
      body: jsonEncode({
        "personalizations": [
          {
            "to": [{"email": email}],
            "subject": "Your OTP Code for Password Reset"
          }
        ],
        "from": {"email": "ankitratnani2004@gmail.com"}, // Replace with verified sender email
        "content": [
          {
            "type": "text/plain",
            "value": "Your OTP is: $otp\n\nPlease enter this code in the app to reset your password."
          }
        ]
      }),
    );
    print("SendGrid Response: ${response.statusCode}");
    print("SendGrid Response Body: ${response.body}");

    return response.statusCode == 202;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Forgot Password',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.amberAccent,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Padding(
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
                      labelStyle: TextStyle(color: Colors.black),
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.amberAccent),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.amberAccent),
                      ),
                      filled: true,
                      fillColor: Colors.white,
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
                      labelStyle: TextStyle(color: Colors.black),
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.amberAccent),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.amberAccent),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the OTP';
                      }
                      return null;
                    },
                  ),
                SizedBox(height: 20),
                if (isLoading)
                  CircularProgressIndicator(color: Colors.amberAccent)
                else
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
                    child: Text(
                      isOtpSent ? 'Verify OTP' : 'Send OTP',
                      style: TextStyle(color: Colors.black),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amberAccent,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}