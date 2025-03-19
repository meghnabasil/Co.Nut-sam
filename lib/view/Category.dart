import 'package:dup/view/productlist.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../controller/session.dart';

class CategoryPage extends StatefulWidget {
  final String categoryName;


  const CategoryPage({Key? key, required this.categoryName}) : super(key: key);

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  List<Map<String, dynamic>> products = [];
  bool isLoading = true;
  String searchQuery = "";
  String? currentVendorId;

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  /// Fetch products based on selected category
  Future<void> fetchProducts() async {
    final productSnapshot = await FirebaseFirestore.instance
        .collection('products')
        .where('category', isEqualTo: widget.categoryName)
        .get();

    List<Map<String, dynamic>> fetchedProducts = productSnapshot.docs
        .map((doc) => {...doc.data(), 'id': doc.id})
        .toList();

    setState(() {
      products = fetchedProducts;
      isLoading = false;
    });
  }
  /// Function to load vendor ID and fetch products
  Future<void> loadData() async {
    String? vendorId = await getCurrentVendorId();
    if (vendorId != null) {
      List<Map<String, dynamic>> fetchedProducts = await getProducts(vendorId);
      if(fetchedProducts.isNotEmpty){
        setState(() {
          var currentVendorId = vendorId;
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
    List<Map<String, dynamic>> filteredProducts = products
        .where((product) =>
        product['name'].toLowerCase().contains(searchQuery.toLowerCase()))
        .toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF033015),
        iconTheme: const IconThemeData(color: Colors.white),
        title: Container(
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white54,
            borderRadius: BorderRadius.circular(30),
          ),
          child: TextField(
            onChanged: (value) {
              setState(() {
                searchQuery = value;
              });
            },
            decoration: const InputDecoration(
              hintText: 'Search products...',
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 10),
            ),
          ),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : filteredProducts.isEmpty
          ? const Center(child: Text('No products available in this category.'))
          : GridView.builder(
        padding: const EdgeInsets.all(10),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 0.8,
        ),
        itemCount: filteredProducts.length,
        itemBuilder: (context, index) {
          final product = filteredProducts[index];

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
                borderRadius: BorderRadius.circular(40),
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
                          style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold),
                        ),
                        // Text(
                        //   product['company'] ?? 'Unknown Vendor',
                        //   style: const TextStyle(color: Colors.black54),
                        // ),
                        const SizedBox(height: 2),
                        Text(
                          '\₹${product['price']}',
                          style: const TextStyle(
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
