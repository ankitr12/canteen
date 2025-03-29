import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class OrderTrackingPage extends StatefulWidget {
  final String orderId;
  const OrderTrackingPage({required this.orderId, Key? key}) : super(key: key);

  @override
  State<OrderTrackingPage> createState() => _OrderTrackingPageState();
}

class _OrderTrackingPageState extends State<OrderTrackingPage> {
  bool canCancel = true; // Track if the order can be cancelled
  late Timer _timer;
  int remainingTime = 30; // Timer duration (30 seconds)

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  // Start 30 seconds timer
  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (remainingTime > 0) {
        setState(() {
          remainingTime--;
        });
      } else {
        // Disable cancel option after 30 seconds
        _timer.cancel();
        setState(() {
          canCancel = false;
        });
        _confirmOrder();
      }
    });
  }

  // Function to cancel the order and delete it from Firestore
  Future<void> _cancelOrder() async {
    await FirebaseFirestore.instance.collection('orders').doc(widget.orderId).delete();
    await FirebaseFirestore.instance.collection('payments').doc(widget.orderId).delete();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Order Cancelled Successfully'),
        backgroundColor: Colors.red,
      ),
    );

    Navigator.pop(context); // Close the OrderTrackingPage
  }

  // Function to confirm the order after 30 seconds
  Future<void> _confirmOrder() async {
    await FirebaseFirestore.instance.collection('orders').doc(widget.orderId).update({
      'status': 'QUEUED', // Order is now confirmed after 30 seconds
    });
  }

  Future<Map<String, dynamic>?> fetchLatestOrder() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) throw Exception("No user logged in");

    final querySnapshot = await FirebaseFirestore.instance
        .collection('orders')
        .where('userId', isEqualTo: userId)
        .where('id', isEqualTo: widget.orderId)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      return querySnapshot.docs.first.data();
    }
    return null;
  }

  String formatTimestamp(Timestamp timestamp) {
    return DateFormat('MMMM d, yyyy hh:mm a').format(timestamp.toDate());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 249, 228),
      appBar: AppBar(
        title: Text(
          'Order Tracking',
          style: GoogleFonts.lato(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.amber,
        elevation: 0,
        centerTitle: true,
      ),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: fetchLatestOrder(),
        builder: (context, orderSnapshot) {
          if (orderSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.yellow),
            );
          }
          if (orderSnapshot.hasError || orderSnapshot.data == null) {
            return Center(
              child: Text(
                'No recent orders found',
                style: GoogleFonts.lato(
                  fontSize: 18,
                  color: Colors.redAccent,
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
          }

          final order = orderSnapshot.data!;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Order Details Card
                  Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    color: Colors.grey[900],
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: Text(
                              'Order ID: ${order['id']}',
                              style: GoogleFonts.lato(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.yellow,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildRow(
                            label: 'Status:',
                            value: order['status'] ?? 'Unknown',
                            valueColor: order['status'] == 'COMPLETED'
                                ? Colors.greenAccent
                                : Colors.orangeAccent,
                          ),
                          _buildRow(
                            label: 'Total Amount:',
                            value: '₹${order['totalAmount']}',
                            valueColor: Colors.yellow,
                          ),
                          const Divider(color: Colors.white24),
                          const SizedBox(height: 10),

                          // Order Items
                          Text(
                            'Items:',
                            style: GoogleFonts.lato(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ...order['items'].map<Widget>((item) {
                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 4.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '- ${item['name']}',
                                    style: GoogleFonts.lato(
                                      fontSize: 16,
                                      color: Colors.white70,
                                    ),
                                  ),
                                  Text(
                                    'x ${item['quantity']}',
                                    style: GoogleFonts.lato(
                                      fontSize: 16,
                                      color: Colors.white70,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),

                  // Cancel Order Prompt (Visible for 30 seconds)
                  if (canCancel)
                    Card(
                      elevation: 8,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      color: Colors.red[900],
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          children: [
                            Text(
                              'You can cancel this order within:',
                              style: GoogleFonts.lato(
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              '$remainingTime seconds',
                              style: GoogleFonts.lato(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.yellow,
                              ),
                            ),
                            const SizedBox(height: 10),
                            ElevatedButton(
                              onPressed: () {
                                _cancelOrder();
                                _timer.cancel();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.redAccent,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 50,
                                  vertical: 12,
                                ),
                              ),
                              child: const Text(
                                'Cancel Order',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRow({
    required String label,
    required String value,
    required Color valueColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.lato(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.lato(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: valueColor,
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }
}
