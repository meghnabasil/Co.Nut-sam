import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../controller/cart_contoller.dart';
import '../model/cart_model.dart';

class Cart extends StatefulWidget {
  @override
  _CartState createState() => _CartState();
}

class _CartState extends State<Cart> {
  List<CartItem> cartItems = [];
  double deliveryFee = 50.0; // Example delivery fee
  double discount = 0.0; // Add discount if needed
  double totalAmount = 0.0;

  @override
  void initState() {
    super.initState();
    fetchCartItems();
  }

  // Fetch cart items from Firestore
  Future<void> fetchCartItems() async {
    final cartController = CartController();
    List<CartItem> items = await cartController.getCartItems();
    setState(() {
      cartItems = items;
      calculateTotal(); // Recalculate total whenever cart items change
    });
  }

  // Update quantity in the cart
  Future<void> updateQuantity(CartItem cartItem, int newQuantity) async {
    final cartController = CartController();
    cartItem.quantity = newQuantity;
    await cartController.updateCartItem(cartItem);
    fetchCartItems(); // Refresh the cart items after update
  }

  // Delete item from the cart
  Future<void> deleteCartItem(String productId) async {
    final cartController = CartController();
    await cartController.removeFromCart(productId);
    fetchCartItems(); // Refresh the cart after deletion
  }

  // Calculate the total amount of the cart
  void calculateTotal() {
    double subtotal = 0.0;
    for (var cartItem in cartItems) {
      subtotal += cartItem.price * cartItem.quantity;
    }

    totalAmount = subtotal + deliveryFee - discount;
  }

  @override
  Widget build(BuildContext context) {
    double maxTotal = 1000.0; // Example maximum total for filling the bar

    double subtotal = cartItems.fold(0.0, (prev, item) => prev + item.price * item.quantity);

    return Scaffold(
      appBar: AppBar(
        title: Text('My Cart',style: TextStyle(color: Colors.white),),
        backgroundColor: Color(0xFF033015),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: cartItems.isEmpty
          ? Center(child: Text("Your cart is empty"))
          : Column(
        children: [
          // Subtotal Bar with Linear Progress Indicator
          Container(
            padding: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
            color: Color(0xFFE0E0E0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Linear Progress Bar
                Container(
                  margin: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                  height: 10.0,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: LinearProgressIndicator(
                    value: (subtotal + deliveryFee) / maxTotal,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                  ),
                ),
                // Subtotal Text
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Subtotal:',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '₹${subtotal.toInt()}',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 20),
          // Cart Items List
          Expanded(
            child: ListView.builder(
              itemCount: cartItems.length,
              itemBuilder: (context, index) {
                CartItem cartItem = cartItems[index];
                return Card(
                  margin: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                  child: ListTile(
                    contentPadding: EdgeInsets.all(10),
                    leading: cartItem.imageUrl.isNotEmpty
                        ? Image.network(
                      cartItem.imageUrl,
                      width: 90,
                      height: 90,
                      fit: BoxFit.cover,
                    )
                        : Icon(Icons.image_not_supported, size: 50),
                    title: Text(
                      cartItem.productName,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('₹${cartItem.price} x Quantity: ${cartItem.quantity}'),
                        Row(
                          children: [
                            IconButton(
                              icon: Icon(Icons.remove),
                              onPressed: () {
                                if (cartItem.quantity > 1) {
                                  updateQuantity(cartItem, cartItem.quantity - 1);
                                }
                              },
                            ),
                            Text(cartItem.quantity.toString()),
                            IconButton(
                              icon: Icon(Icons.add),
                              onPressed: () {
                                updateQuantity(cartItem, cartItem.quantity + 1);
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () => deleteCartItem(cartItem.productId),
                    ),
                  ),
                );
              },
            ),
          ),

          // Order Summary Section
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Delivery Fee
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Delivery Fee:'),
                    Text('₹$deliveryFee'),
                  ],
                ),
                // Discount (if any)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Discount:'),
                    Text('₹$discount'),
                  ],
                ),
                Divider(),
                // Total
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Order Total:',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '₹$totalAmount',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Proceed to Buy Button
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: ElevatedButton(
              onPressed: () {
                // Handle proceed to buy logic (Navigate to checkout page)
                print("Proceeding to buy with total: ₹$totalAmount");
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[900],
                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 30),
                textStyle: TextStyle(fontSize: 18),
              ),
              child: Text(
                'Proceed to Buy',
                style: TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
          ),
          SizedBox(height: 30),
        ],
      ),
    );
  }
}
