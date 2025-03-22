import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class OrderHistoryScreen extends StatelessWidget {
  final String userId;

  const OrderHistoryScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('exportingOrders')
          .where('userId', isEqualTo: userId) // Fetch orders of current user
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text("No orders found"));
        }

        var orders = snapshot.data!.docs;

        return ListView.builder(
          itemCount: orders.length,
          itemBuilder: (context, index) {
            var order = orders[index].data() as Map<String, dynamic>;

            return Card(
              margin: const EdgeInsets.all(8),
              child: ListTile(
                title: Text("Product: ${order['productName']}"),
                subtitle: Text("Amount: ${order['amount']}"),
                trailing: Text("Status: ${order['status'] ?? 'Pending'}"),
              ),
            );
          },
        );
      },
    );
  }
}