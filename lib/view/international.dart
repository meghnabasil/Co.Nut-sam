import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:dup/view/productlist.dart';

class International extends StatefulWidget {
  const International({super.key});

  @override
  State<International> createState() => _InternationalState();
}

class _InternationalState extends State<International> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> exportingProducts = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchExportingProducts();
  }

  Future<void> fetchExportingProducts() async {
    try {
      QuerySnapshot querySnapshot = await _firestore.collection('products').get();
      List<Map<String, dynamic>> products = [];
      for (var doc in querySnapshot.docs) {
        var exportingDataSnapshot = await doc.reference.collection('exportingData').get();
        if (exportingDataSnapshot.docs.isNotEmpty) {
          Map<String, dynamic> productData = doc.data() as Map<String, dynamic>;
          String vendorId = productData['vendorId'];
          DocumentSnapshot vendorSnapshot = await _firestore.collection('vendors').doc(vendorId).get();
          if (vendorSnapshot.exists) {
            Map<String, dynamic> vendorData = vendorSnapshot.data() as Map<String, dynamic>;
            products.add({
              ...productData,
              'id': doc.id,
              'companyName': vendorData['businessName'],
            });
          }
        }
      }
      setState(() {
        exportingProducts = products;
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching exporting products: $e");
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        backgroundColor: const Color(0xFF033015),
        title: const Text(
          "International",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
        elevation: 4,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF033015)))
          : exportingProducts.isEmpty
          ? Center(
        child: Text(
          "No exporting products available",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey[600]),
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: exportingProducts.length,
        itemBuilder: (context, index) {
          final product = exportingProducts[index];
          return Card(
            elevation: 8,
            shadowColor: Colors.black54,
            color: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: _buildProductImage(product),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product["name"] ?? "No Name",
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          "Price: ₹${product["price"] ?? 'N/A'}",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.grey[700]),
                        ),
                        Text(
                          "Company: ${product["companyName"] ?? 'N/A'}",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.grey[700]),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.flight_takeoff, color: Color(0xFF033015), size: 40),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProductImage(Map<String, dynamic> product) {
    String imageUrl = (product["images"] != null &&
        product["images"] is List &&
        product["images"].isNotEmpty)
        ? product["images"][0]
        : "https://via.placeholder.com/200";

    return Image.network(
      imageUrl,
      width: 120,
      height: 120,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return const Center(
          child: CircularProgressIndicator(color: Color(0xFF033015)),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        return const Icon(Icons.broken_image, color: Colors.red, size: 100);
      },
    );
  }
}
