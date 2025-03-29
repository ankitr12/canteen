import 'package:canteen_fbdb/orderTrackingPage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DailyOrderHistoryPage extends StatefulWidget {
  const DailyOrderHistoryPage({Key? key}) : super(key: key);

  @override
  _DailyOrderHistoryPageState createState() => _DailyOrderHistoryPageState();
}

class _DailyOrderHistoryPageState extends State<DailyOrderHistoryPage> {
  DateTime? selectedDate;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Fetch orders for the selected date
  Stream<List<Map<String, dynamic>>> getOrdersForDate(DateTime date) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception("No user logged in");
    }

    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

    return _firestore
        .collection('orders')
        .where('userId', isEqualTo: user.uid)
        .where('orderDate', isGreaterThanOrEqualTo: startOfDay)
        .where('orderDate', isLessThanOrEqualTo: endOfDay)
        .orderBy('orderDate', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => doc.data() as Map<String, dynamic>)
            .toList());
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 249, 228),
      appBar: AppBar(
        backgroundColor: Colors.yellow,
        title: const Text(
          'Daily Order History',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Center(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: () => _selectDate(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.yellow[700],
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  selectedDate == null
                      ? "Select Date"
                      : "Selected Date: ${DateFormat('dd MMM yyyy').format(selectedDate!)}",
                  style: const TextStyle(color: Colors.black, fontSize: 16),
                ),
              ),
            ),
            if (selectedDate != null)
              Expanded(
                child: StreamBuilder<List<Map<String, dynamic>>>(
                  stream: getOrdersForDate(selectedDate!),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                          child: CircularProgressIndicator(color: Colors.yellow));
                    }
                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(
                        child: Text(
                          'No orders found for this date.',
                          style: TextStyle(fontSize: 18, color: Colors.black),
                        ),
                      );
                    }
        
                    final orders = snapshot.data!;
        
                    return ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      itemCount: orders.length,
                      itemBuilder: (context, index) {
                        final order = orders[index];
                        final orderDate = order['orderDate']?.toDate() ?? DateTime.now();
                        final items = order['items'] as List<dynamic>?;
                        final status = order['status'] ?? 'Pending';
                        final totalAmount = order['totalAmount'] ?? 0;
        
                        return AnimatedOpacity(
                          duration: Duration(milliseconds: 500 + (index * 100)),
                          opacity: 1.0,
                          child: Card(
                            margin:
                                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            elevation: 8,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            color: Colors.grey[900],
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Order ID: ${order['id'] ?? 'N/A'}',
                                        style: const TextStyle(
                                          color: Colors.yellow,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      Text(
                                        status,
                                        style: TextStyle(
                                          color: status == 'Completed'
                                              ? Colors.green
                                              : Colors.orange,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Date: ${DateFormat('dd MMM yyyy, hh:mm a').format(orderDate)}',
                                    style: const TextStyle(
                                        color: Colors.white70, fontSize: 14),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Total Amount: ₹$totalAmount',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  const Text(
                                    'Items:',
                                    style: TextStyle(
                                      color: Colors.yellow,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  ...?items?.map((item) {
                                    final name = item['name'] ?? 'Unknown Item';
                                    final quantity = item['quantity'] ?? 1;
                                    final price = item['price'] ?? 0;
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 2.0),
                                      child: Text(
                                        '- $name (x$quantity) - ₹$price',
                                        style: const TextStyle(
                                            color: Colors.white70, fontSize: 13),
                                      ),
                                    );
                                  }),
                                  Center(
                                    child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.amber,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(25),
                                          ),
                                        ),
                                        onPressed: () {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) => OrderTrackingPage(
                                                      orderId: order['id'])));
                                        },
                                        child: Text(
                                          'Track Order',
                                          style: TextStyle(color: Colors.black),
                                        )),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}