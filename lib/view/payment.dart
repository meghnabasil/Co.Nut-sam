import 'package:dup/view/History.dart';
import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';

import '../controller/session.dart';

class PaymentScreen extends StatefulWidget {
  final Map<String, String> shippingAddress;
  final double totalPrice;
  final String productName;
  final String productId;
  final String vendorId;
  final String selectedDestination;
  final String selectedPlan;
  final String selectedQuantity;
  final String costPerWeight;
  final String insuranceCost;
  final String portCost;
  const PaymentScreen({
    super.key,
    required this.totalPrice,
    required this.productName,
    required this.productId,
    required this.vendorId,
    required this.selectedDestination,
    required this.selectedPlan,
    required this.selectedQuantity,
    required this.costPerWeight,
    required this.insuranceCost,
    required this.portCost,
    required this.shippingAddress,
});
  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}
class _PaymentScreenState extends State<PaymentScreen> {
  final _razorpay = Razorpay();
  @override
  void initState() {
    super.initState();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }
  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }
  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Payment Success: ${response.paymentId}')),
    );


    final sessionData = await Session.getSession();
    final userId = sessionData['uid'];


    final orderData = {
      'userId': userId,
      'paymentId': response.paymentId,
      'amount': widget.totalPrice,
      'productName': widget.productName,
      'productId': widget.productId,
      'vendorId': widget.vendorId,
      'selectedDestination': widget.selectedDestination,
      'selectedPlan': widget.selectedPlan,
      'selectedQuantity': widget.selectedQuantity,
      'costPerWeight': widget.costPerWeight,
      'insuranceCost': widget.insuranceCost,
      'portCost': widget.portCost,
      'shippingAddress': widget.shippingAddress,
      'timestamp': FieldValue.serverTimestamp(),
    };
    try {
      await FirebaseFirestore.instance.collection('exportingOrders').add(orderData);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Order saved successfully!')),

      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => History()),
      );
    } catch (e) {
      debugPrint('Error saving order: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to save order: $e')));
    }
  }
  void _handlePaymentError(PaymentFailureResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Payment Failed: ${response.message}')),
    );
  }
  void _handleExternalWallet(ExternalWalletResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('External Wallet: ${response.walletName}')),
    );
  }

  void _openRazorpay() {
    final options = {
      'key': 'rzp_test_zrejXWOWxRf29k',
      'amount': (widget.totalPrice * 100).toInt(),
      'currency': 'INR',
      'name': 'dup',
      'description': 'Payment for Order',
      'prefill': {
        'contact': widget.shippingAddress['phone'],
        'email': widget.shippingAddress['email'],
      },
      'method': {
        'upi': true,
        'card': true,
        'netbanking': true,
        'wallet': true,
      },
      'theme': {'color': '#3399cc'},
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      debugPrint('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final shippingAddress = widget.shippingAddress;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment'),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Shipping Address',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text('Name: ${shippingAddress['fullName'] ?? "N/A"}'),
                    Text('Address: ${shippingAddress['addressLine1'] ?? "N/A"}'),
                    Text('City: ${shippingAddress['city'] ?? "N/A"}'),
                    Text('State: ${shippingAddress['state'] ?? "N/A"}'),
                    Text('Zip: ${shippingAddress['postalCode'] ?? "N/A"}'),
                    Text('Country: ${shippingAddress['country'] ?? "N/A"}'),

                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Payment Details',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ListTile(
                title: const Text('Amount'),
                subtitle: Text('₹${widget.totalPrice.toStringAsFixed(2)}'),
            ),
            ListTile(

              title: const Text('Email'),
              subtitle: Text(shippingAddress['Email']!),
            ),
            ListTile(
              title: const Text('Phone Number'),
              subtitle: Text(shippingAddress['phone']?? "N/A"),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => _openRazorpay(),
              child: Text("Pay"),
            ),
          ],
        ),
      ),
    );
  }
}