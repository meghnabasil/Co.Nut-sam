import 'package:dup/view/productlist.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/products_model.dart';

class ProductScreen extends StatelessWidget {
  Stream<List<Map<String, dynamic>>> getProducts() async* {
    final productSnapshot =
        await FirebaseFirestore.instance.collection('products').get();

    List<Map<String, dynamic>> productsWithCompany = [];

    for (var doc in productSnapshot.docs) {
      final data = doc.data();
      String vendorId = data['vendorId'] ?? '';

      String companyName = 'Unknown'; // Default value

      if (vendorId.isNotEmpty) {
        final vendorDoc = await FirebaseFirestore.instance
            .collection('vendors')
            .doc(vendorId)
            .get();

        if (vendorDoc.exists) {
          companyName = vendorDoc.data()?['businessName'] ?? 'Unknown';
        }
      }

      // Adding companyName to product data
      var productData = {
        ...data,
        'id': doc.id,
        'company': companyName,
      };

      productsWithCompany.add(productData);
    }

    yield productsWithCompany;
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
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: getProducts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No products available.'));
          }

          final products = snapshot.data!;

          return GridView.builder(
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

                        //
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
                          borderRadius:
                              BorderRadius.vertical(top: Radius.circular(10)),
                          child: Image.network(
                            product['imageUrls'].isNotEmpty
                                ? product['imageUrls'][0]
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
                                  fontSize: 16, fontWeight: FontWeight.bold),
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
          );
        },
      ),
    );
  }
/*
  Stream<List<Product>> getProducts() {
    return FirebaseFirestore.instance.collection('products').snapshots().map(
          (snapshot) =>
              snapshot.docs.map((doc) => Product.fromFirestore(doc)).toList(),
        );
  }*/
}
