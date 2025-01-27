import 'package:flutter/material.dart';
import 'package:canteen_fbdb/orderTrackingPage.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PaymentPage extends StatefulWidget {
  final double totalAmount;
  final List<Map<String, dynamic>> items;
  final VoidCallback clearCartCallback;

  const PaymentPage({
    required this.totalAmount,
    required this.items,
    required this.clearCartCallback,
    Key? key,
  }) : super(key: key);

  @override
  _PaymentPageState createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage>
    with SingleTickerProviderStateMixin {
  late Razorpay _razorpay;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  
  // get newOrderId => null;

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);

    _animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 1),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _razorpay.clear();
    _animationController.dispose();
    super.dispose();
  }

  Future<String?> placeOrderWithCustomId(
    List<Map<String, dynamic>> items, double totalAmount) async {
  try {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    DocumentReference counterDoc =
        firestore.collection('orders').doc('counter');
    var user = FirebaseAuth.instance.currentUser;

    String? newOrderId;

    await firestore.runTransaction((transaction) async {
      DocumentSnapshot snapshot = await transaction.get(counterDoc);

      if (snapshot.exists) {
        int currentCounter =
            (snapshot.data() as Map<String, dynamic>)['number'] as int;

        newOrderId = currentCounter.toString();

        final order = {
          'id': newOrderId,
          'userId': user!.uid,
          'items': items,
          'totalAmount': totalAmount,
          'orderDate': FieldValue.serverTimestamp(),
          'status': 'QUEUED',
        };

        DocumentReference newOrderDoc =
            firestore.collection('orders').doc(newOrderId);
        transaction.set(newOrderDoc, order);
        transaction.update(counterDoc, {'number': currentCounter + 1});
      } else {
        throw Exception("Counter document does not exist.");
      }
    });

    return newOrderId;
  } catch (e) {
    print("Error placing order: $e");
    return null;
  }
}


  void openCheckout() {
    var options = {
      'key': 'rzp_test_LXZO1v4DgjDFKy',
      'amount': (widget.totalAmount * 100),
      'name': 'Khaogalli',
      'description': 'Payment for your order',
      'prefill': {
        'contact': '8451021209',
        'email': 'ankitratnani@gmail.com',
      },
      'external': {
        'wallets': ['paytm']
      }
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      print(e.toString());
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
  try {
    // Record payment details in Firestore
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = FirebaseFirestore.instance.collection('payments').doc();
      await doc.set({
        'id': doc.id,
        'userId': user.uid,
        'paymentId': response.paymentId,
        'amount': widget.totalAmount,
        'status': 'successful',
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Place the order after successful payment
      String? newOrderId = await placeOrderWithCustomId(
        widget.items,
        widget.totalAmount,
      );

      if (newOrderId != null) {
        // Clear the cart
        widget.clearCartCallback();
        print('order id : $newOrderId');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Payment Successful! Order placed.')),
        );

        // Navigate to the OrderTrackingPage with the newOrderId
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OrderTrackingPage(
              orderId: newOrderId,
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to place order.')),
        );
      }
    }
  } catch (e) {
    print("Error during payment success handling: $e");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error placing order after payment.')),
    );
  }
}


  void _handlePaymentError(PaymentFailureResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Payment Failed: ${response.message}')),
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text('External Wallet Selected: ${response.walletName}')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 255, 246, 219),
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Confirm Payment',
            style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black,
                backgroundColor: Colors.grey.shade200),
          ),
          const SizedBox(height: 10),
          Text(
            'Total Amount: ₹${widget.totalAmount.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 18,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 20),
          ScaleTransition(
            scale: _scaleAnimation,
            child: ElevatedButton(
              onPressed: openCheckout,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber,
                padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              child: Text(
                'Pay Now',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
