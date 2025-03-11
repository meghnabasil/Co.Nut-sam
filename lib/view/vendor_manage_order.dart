import 'package:flutter/material.dart';

class ManageOrdersPage extends StatefulWidget {
  @override
  _ManageOrdersPageState createState() => _ManageOrdersPageState();
}

class _ManageOrdersPageState extends State<ManageOrdersPage> {
  List<Map<String, dynamic>> orders = [
    {
      'id': '001',
      'customer': 'John Doe',
      'productId': 'P1001',
      'product': 'Coconut Oil',
      'status': 'Pending',
      'total': '\$25.00',
      'date': '2025-02-25',
      'address': '123 Main St, City A',
      'newStatus': 'Pending'
    },
    {
      'id': '002',
      'customer': 'Jane Smith',
      'productId': 'P1002',
      'product': 'Coconut Water',
      'status': 'Shipped',
      'total': '\$40.00',
      'date': '2025-02-24',
      'address': '456 Market Rd, City B',
      'newStatus': 'Shipped'
    },
    {
      'id': '003',
      'customer': 'Alice Brown',
      'productId': 'P1003',
      'product': 'Coconut Husk',
      'status': 'Delivered',
      'total': '\$15.00',
      'date': '2025-02-23',
      'address': '789 Ocean Ave, City C',
      'newStatus': 'Delivered'
    },
  ];

  final Color primaryColor = Color(0xFF033015);

  void _confirmStatusChange(int index, String newStatus) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Status Change'),
          content: Text(
              'Are you sure you want to update Order #${orders[index]['id']} status to $newStatus?'),
          actions: [
            TextButton(
              onPressed: () {
                // Cancel: revert dropdown selection to previous value.
                Navigator.of(context).pop();
              },
              child: Text('No'),
            ),
            TextButton(
              onPressed: () {
                // Update order status if confirmed.
                setState(() {
                  orders[index]['status'] = newStatus;
                  orders[index]['newStatus'] = newStatus;
                });
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                        'Order #${orders[index]['id']} status updated to ${orders[index]['status']}'),
                  ),
                );
              },
              child: Text('Yes'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Manage Orders',
          style: TextStyle(color: Colors.white),

        ),
        iconTheme: IconThemeData(color: Colors.white),

        backgroundColor: primaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: orders.length,
                itemBuilder: (context, index) {
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Order #${orders[index]['id']} - ${orders[index]['product']}',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text('Customer: ${orders[index]['customer']}'),
                          Text('Product ID: ${orders[index]['productId']}'),
                          Text('Order Date: ${orders[index]['date']}'),
                          Text('Delivery Address: ${orders[index]['address']}'),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              DropdownButton<String>(
                                value: orders[index]['newStatus'],
                                onChanged: (String? newStatus) {
                                  // Only perform action if newStatus is not null and is different.
                                  if (newStatus != null &&
                                      newStatus != orders[index]['status']) {
                                    _confirmStatusChange(index, newStatus);
                                  }
                                },
                                items: [
                                  'Pending',
                                  'Processing',
                                  'Shipped',
                                  'Delivered',
                                  'Cancelled'
                                ].map<DropdownMenuItem<String>>((String status) {
                                  return DropdownMenuItem<String>(
                                    value: status,
                                    child: Text(status),
                                  );
                                }).toList(),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  // You can provide an action for the separate confirm button here,
                                  // or remove it if the dropdown confirmation is sufficient.
                                 // _confirmStatusChange(index, orders[index]['newStatus']);
                                },
                                child: Text('Confirm this order'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
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
