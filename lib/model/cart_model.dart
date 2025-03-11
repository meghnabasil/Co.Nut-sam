class CartItem {
  final String productId;
  final String productName;
  final String vendorId;
  final int quantity;
  final double price; // Added price field

  CartItem({
    required this.productId,
    required this.productName,
    required this.vendorId,
    required this.quantity,
    required this.price, // Include price in the constructor
  });

  // Convert Firebase document to CartItem object
  factory CartItem.fromMap(Map<String, dynamic> data, String docId) {
    return CartItem(
      productId: docId,
      productName: data['productName'] ?? '',
      vendorId: data['vendorId'] ?? '',
      quantity: data['quantity'] ?? 1,
      price: (data['price'] ?? 0.0).toDouble(), // Ensure price is double
    );
  }

  // Convert CartItem object to Firebase map
  Map<String, dynamic> toMap() {
    return {
      'productName': productName,
      'vendorId': vendorId,
      'quantity': quantity,
      'price': price, // Save price to Firebase
    };
  }
}
