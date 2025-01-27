import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class OrderTrackingPage extends StatelessWidget {
  final String orderId;
  const OrderTrackingPage({required this.orderId, Key? key}) : super(key: key);

  Future<Map<String, dynamic>?> fetchLatestOrder() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      throw Exception("No user logged in");
    }

    final querySnapshot = await FirebaseFirestore.instance
        .collection('orders')
        .where('userId', isEqualTo: userId)
        .where('id', isEqualTo: orderId)
        // .orderBy('orderDate', descending: true)
        // .limit(1)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      return querySnapshot.docs.first.data();
    }
    return null;
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
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: Colors.yellow,
              ),
            );
          }
          if (snapshot.hasError || snapshot.data == null) {
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

          final order = snapshot.data!;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                          const Divider(color: Colors.white24),
                          _buildRow(
                            label: 'Total Amount:',
                            value: '₹${order['totalAmount']}',
                            valueColor: Colors.yellow,
                          ),
                          const Divider(color: Colors.white24),
                          const SizedBox(height: 10),
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
                  const SizedBox(height: 20),
                  Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    color: Colors.grey[900],
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Stepper(
                        currentStep: _getCurrentStep(order['status']),
                        steps: _buildSteps(order['status']),
                        controlsBuilder: (context, _) =>
                            const SizedBox.shrink(),
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

  int _getCurrentStep(String status) {
    switch (status) {
      case 'QUEUED':
        return 0;
      case 'PREPARING':
        return 1;
      case 'READY TO TAKEAWAY':
        return 2;
      case 'COMPLETED':
        return 3;
      default:
        return 0;
    }
  }

  List<Step> _buildSteps(String status) {
  // Map each status to a step index for easier comparison
  final statusIndex = {
    'QUEUED': 0,
    'PREPARING': 1,
    'READY TO TAKEAWAY': 2,
    'COMPLETED': 3,
  };

  int currentStepIndex = statusIndex[status] ?? 0;

  return [
    Step(
      title: const Text(
        'Queued',
        style: TextStyle(color: Colors.white),
      ),
      subtitle: const Text(
        'Your order has been placed.',
        style: TextStyle(color: Colors.white70),
      ),
      content: const SizedBox.shrink(),
      isActive: true,
      state: currentStepIndex >= 0 ? StepState.complete : StepState.indexed,
    ),
    Step(
      title: const Text(
        'Preparing',
        style: TextStyle(color: Colors.white),
      ),
      subtitle: const Text(
        'Your food is being prepared.',
        style: TextStyle(color: Colors.white70),
      ),
      content: const SizedBox.shrink(),
      isActive: currentStepIndex >= 1,
      state: currentStepIndex >= 1 ? StepState.complete : StepState.indexed,
    ),
    Step(
      title: const Text(
        'Ready to Takeaway',
        style: TextStyle(color: Colors.white),
      ),
      subtitle: const Text(
        'Your food is ready to be picked up.',
        style: TextStyle(color: Colors.white70),
      ),
      content: const SizedBox.shrink(),
      isActive: currentStepIndex >= 2,
      state: currentStepIndex >= 2 ? StepState.complete : StepState.indexed,
    ),
    Step(
      title: const Text(
        'Completed',
        style: TextStyle(color: Colors.white),
      ),
      subtitle: const Text(
        'Order completed successfully.',
        style: TextStyle(color: Colors.white70),
      ),
      content: const SizedBox.shrink(),
      isActive: currentStepIndex >= 3,
      state: currentStepIndex == 3 ? StepState.complete : StepState.indexed,
    ),
  ];
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
}
