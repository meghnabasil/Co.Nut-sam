import 'package:dup/view/productlist.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FavoriteListPage extends StatefulWidget {
  @override
  _FavoriteListPageState createState() => _FavoriteListPageState();
}

class _FavoriteListPageState extends State<FavoriteListPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? user;

  @override
  void initState() {
    super.initState();
    user = _auth.currentUser;
  }

  Future<String> getCompanyName(String productId) async {
    try {
      // Fetch product details using productId
      DocumentSnapshot productDoc = await FirebaseFirestore.instance
          .collection('products')
          .doc(productId)
          .get();

      if (productDoc.exists) {
        String vendorId = productDoc['vendorId'] ?? '';

        if (vendorId.isNotEmpty) {
          // Fetch vendor details using vendorId
          DocumentSnapshot vendorDoc = await FirebaseFirestore.instance
              .collection('vendors')
              .doc(vendorId)
              .get();

          if (vendorDoc.exists) {
            return vendorDoc['businessName'] ?? 'Unknown';
          }
        }
      }
    } catch (e) {
      print("Error fetching company name: $e");
    }
    return 'Unknown';
  }

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return Scaffold(
        body: Center(child: Text("User not logged in")),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "My WishList",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Color(0xFF033015),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('favorites')
            .doc(user!.uid)
            .collection('items')
            .orderBy('addedAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text("No favorites added yet"));
          }

          var favoriteDocs = snapshot.data!.docs;

          return ListView.builder(
            itemCount: favoriteDocs.length,
            itemBuilder: (context, index) {
              var favData = favoriteDocs[index].data() as Map<String, dynamic>;
              String productId = favData['productId'] ?? '';

              return FutureBuilder<String>(
                future: getCompanyName(productId),
                builder: (context, companySnapshot) {
                  String companyName = companySnapshot.data ?? 'Unknown';

                  return Card(
                    elevation: 8,
                    margin: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    shadowColor: Colors.green.shade300,
                    child: Padding(
                      padding: EdgeInsets.all(15),
                      child: ListTile(
                        leading: favData['imageUrl'] != null &&
                            favData['imageUrl'].isNotEmpty
                            ? ClipRRect(
                          borderRadius: BorderRadius.circular(01),
                          child: Image.network(
                            favData['imageUrl'],
                            width: 90,
                            height: 100,
                            fit: BoxFit.cover,
                          ),
                        )
                            : Icon(Icons.image, size: 60, color: Colors.grey),
                        title: Text(
                          favData['productName'] ?? "Unnamed Product",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 5),
                            Text(
                              "Company: $companyName",
                              style:
                              TextStyle(fontSize: 16, color: Colors.black54),
                            ),
                          ],
                        ),
                        onTap: () {
                          // Navigate to Product Detail Page
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProductDetail(
                                productId: favData['productId'],
                              ),
                            ),
                          );
                        },
                        trailing: IconButton(
                          icon: Icon(Icons.delete, color: Colors.red, size: 28),
                          onPressed: () async {
                            await FirebaseFirestore.instance
                                .collection('favorites')
                                .doc(user!.uid)
                                .collection('items')
                                .doc(favoriteDocs[index].id)
                                .delete();
                          },
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
