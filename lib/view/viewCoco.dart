import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProductDisplayPage extends StatefulWidget {
  @override
  _ProductDisplayPageState createState() => _ProductDisplayPageState();
}

class _ProductDisplayPageState extends State<ProductDisplayPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String? currentVendorId;

  @override
  void initState() {
    super.initState();
    _getCurrentVendor();
  }

  void _getCurrentVendor() {
    final User? user = _auth.currentUser;
    if (user != null) {
      setState(() {
        currentVendorId = user.uid;
      });
    }
  }

  Future<List<Map<String, dynamic>>> _fetchVendorProducts() async {
    if (currentVendorId == null) return [];

    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('products')
        .where('vendorId', isEqualTo: currentVendorId)
        .get();

    return snapshot.docs.map((doc) {
      var data = doc.data() as Map<String, dynamic>;
      data['id'] = doc.id; // Add document ID to the data
      return data;
    }).toList();
  }

  void _showUpdateStockBottomSheet(Map<String, dynamic> product) {
    final TextEditingController _stockController = TextEditingController();
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Update Stock for ${product['name']}",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              TextField(
                controller: _stockController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: "Enter new stock quantity"),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF008000)),
                onPressed: () async {
                  final int? newStock = int.tryParse(_stockController.text);
                  if (newStock != null) {
                    await FirebaseFirestore.instance
                        .collection('products')
                        .doc(product['id'])
                        .update({'stock': newStock});
                    setState(() {
                      product['stock'] = newStock;
                    });
                    Navigator.of(context).pop();
                  }
                },
                child: Text("Update Stock", style: TextStyle(color: Colors.white)),
              )
            ],
          ),
        );
      },
    );
  }

  Future<void> _deleteProduct(String productId) async {
    bool? confirmDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Delete Product"),
          content: Text("Are you sure you want to delete this product?"),
          actions: [
            TextButton(
              child: Text("Cancel", style: TextStyle(color: Colors.grey)),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF008000)),
              onPressed: () => Navigator.of(context).pop(true),
              child: Text("Delete", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );

    if (confirmDelete == true) {
      await FirebaseFirestore.instance.collection('products').doc(productId).delete();
      setState(() {});
    }
  }

  Widget _buildProductCard(Map<String, dynamic> product, String productId) {
    // Ensure 'imageUrls' is a list and not empty
    List<dynamic>? imageUrls = product['imageUrls'];
    List<String> imageList = [];

    if (imageUrls != null && imageUrls.isNotEmpty) {
      // Convert dynamic list to List<String>
      imageList = List<String>.from(imageUrls);
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 200,
              width: double.infinity,
              child: imageList.isNotEmpty
                  ? ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: imageList.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        imageList[index],
                        width: 322,
                        height: 200,
                        fit: BoxFit.cover,
                      ),
                    ),
                  );
                },
              )
                  : Center(
                child: Text("No Images Available", style: TextStyle(color: Colors.grey)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product['name'] ?? 'Unnamed Product',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  SizedBox(height: 4),
                  Text(
                    "Category: ${product['category'] ?? 'N/A'}",
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  SizedBox(height: 4),
                  Text(
                    "Company: ${product['company'] ?? 'N/A'}",
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  SizedBox(height: 4),
                  Text(
                    "Price: \$${product['price']?.toStringAsFixed(2) ?? 'N/A'}",
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  SizedBox(height: 4),
                  Text(
                    "Description: ${product['description'] ?? 'No description'}",
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  SizedBox(height: 4),
                  Text(
                    "Stock: ${product['stock'] ?? 'N/A'}",
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF033015)),
                          onPressed: () => _showUpdateStockBottomSheet(product),
                          child: Text("Update Stock", style: TextStyle(color: Colors.white)),
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                          onPressed: () => _deleteProduct(product['id']),
                          child: Text("Delete", style: TextStyle(color: Colors.white)),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchVendorProducts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error loading products"));
          }
          List<Map<String, dynamic>>? products = snapshot.data;
          if (products == null || products.isEmpty) {
            return Center(child: Text("No products available."));
          }
          return ListView.builder(
            itemCount: products.length,
            itemBuilder: (context, index) {
              String productId = products[index]['id'] ?? '';
              return _buildProductCard(products[index], productId);
            },
          );
        },
      ),
    );
  }
}
