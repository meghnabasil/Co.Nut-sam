import 'package:dup/view/productlist.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../controller/session.dart';

class ProductScreen extends StatefulWidget {
  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  String? currentVendorId;
  List<Map<String, dynamic>> products = [];
  bool isLoading = true; // Loading state

  @override
  void initState() {
    super.initState();
    loadData();
  }

  /// Function to load vendor ID and fetch products
  Future<void> loadData() async {
    String? vendorId = await getCurrentVendorId();
    if (vendorId != null) {
      List<Map<String, dynamic>> fetchedProducts = await getProducts(vendorId);
     if(fetchedProducts.isNotEmpty){
       setState(() {
         currentVendorId = vendorId;
         products = fetchedProducts;
         isLoading = false;
       });
       print("✅ Products fetched successfully: ${fetchedProducts.length} items.");
     }
     else{
       print("❌ Vendor ID is null. Unable to fetch products.");
     }
    }
  }

  /// Fetch the current vendor ID from session
  Future<String?> getCurrentVendorId() async {
    Map<String, String?> vendorData = await Session.getVendor();
    return vendorData['vid'];
  }

  Future<List<Map<String, dynamic>>> getProducts(String currentVendorId) async {
    final productSnapshot =
        await FirebaseFirestore.instance.collection('products').get();
    List<Map<String, dynamic>> productsWithCompany = [];

    final vendorDocs =
        await FirebaseFirestore.instance.collection('vendors').get();
    Map<String, String> vendorNames = {
      for (var doc in vendorDocs.docs)
        doc.id: doc.data()['businessName'] ?? 'Unknown'
    };

    for (var doc in productSnapshot.docs) {
      final data = doc.data();
      String vendorId = data['vendorId'] ?? '';

      if (vendorId == currentVendorId) continue;

      var productData = {
        ...data,
        'id': doc.id,
        'company': vendorNames[vendorId] ?? 'Unknown',
      };

      productsWithCompany.add(productData);
    }

    return productsWithCompany;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF033015),
        iconTheme: IconThemeData(color: Colors.white),
        title: Container(
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white54,
            borderRadius: BorderRadius.circular(30),
          ),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Search products...',
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 10),
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list, color: Colors.white),
            onPressed: () {
              // Add filter functionality here
            },
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator()) // Show loading indicator
          : products.isEmpty
              ? Center(child: Text('No products available.'))
              : GridView.builder(
                  padding: EdgeInsets.all(10),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 0.8,
                  ),
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final product = products[index];

                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProductDetail(
                              productId: product['id'],
                            ),
                          ),
                        );
                      },
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        elevation: 10,
                        shadowColor: Colors.green,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(10)),
                                child: Image.network(
                                  product['images'].isNotEmpty
                                      ? product['images'][0]
                                      : 'https://via.placeholder.com/150',
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    product['name'],
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    product['company'],
                                    style: TextStyle(color: Colors.black54),
                                  ),
                                  SizedBox(height: 5),
                                  Text(
                                    '\₹${product['price']}',
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF380230)),
                                  ),
                                ],
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
}
