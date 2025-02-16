import 'package:flutter/material.dart';

class Cart extends StatefulWidget {
  const Cart({super.key});

  @override
  State<Cart> createState() => _CartState();
}

class _CartState extends State<Cart> {
  List<Map<String, dynamic>> cartItems = [
    {"name": "Oil", "price": 40.56, "quantity": 3, "image": "asset/nut.jpg"},
    {"name": "Copra", "price": 20.56, "quantity": 1, "image": "asset/nut.jpg"},
    {"name": "Coconut", "price": 10.22, "quantity": 2, "image": "asset/nut.jpg"},
  ];

  double get subtotal => cartItems.fold(0, (sum, item) => sum + (item['price'] * item['quantity']));
  double deliveryFee = 10.0;
  double get total => subtotal + deliveryFee;

  void addToCart(String name, double price, String image) {
    setState(() {
      cartItems.add({"name": name, "price": price, "quantity": 1, "image": image});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Cart"),
        backgroundColor: Color(0xFF033015),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ...cartItems.map((item) => Card(
              margin: EdgeInsets.symmetric(vertical: 8.0),
              child: ListTile(
                leading: Image.asset(item['image'], width: 60, height: 60),
                title: Text(item['name'], style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                subtitle: Text("₹${item['price']}", style: TextStyle(fontSize: 16)),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: () {
                        setState(() {
                          if (item['quantity'] > 1) item['quantity']--;
                        });
                      },
                      icon: Icon(Icons.remove),
                    ),
                    Text(item['quantity'].toString(), style: TextStyle(fontSize: 16)),
                    IconButton(
                      onPressed: () {
                        setState(() {
                          item['quantity']++;
                        });
                      },
                      icon: Icon(Icons.add),
                    ),
                  ],
                ),
              ),
            )),
            Divider(thickness: 2),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Subtotal: ₹${subtotal.toStringAsFixed(2)}", style: TextStyle(fontSize: 16)),
                  Text("Delivery: ₹${deliveryFee.toStringAsFixed(2)}", style: TextStyle(fontSize: 16)),
                  Text("Total: ₹${total.toStringAsFixed(2)}", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF033015),
                padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 50.0),
              ),
              child: Text("Proceed To Check-Out", style: TextStyle(fontSize: 18, color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
