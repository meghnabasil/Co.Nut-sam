import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:dup/view/vendormessagescreen.dart';

class ProductDetail extends StatefulWidget {
  final String productId;

  ProductDetail({required this.productId});

  @override
  _ProductDetailState createState() => _ProductDetailState();
}

class _ProductDetailState extends State<ProductDetail> {
  Map<String, dynamic>? productData;
  bool isLoading = true;
  bool isFavorite = false;
  int quantity = 1;
  List<String> imageUrls = [];
  List<String> cart = [];
  List<Map<String, dynamic>> products = [];
  String? userId = FirebaseAuth.instance.currentUser?.uid; // Get logged-in user
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Flags to toggle visibility of containers
  bool showExportDetails = false;
  bool showSubscriptionCard = false;
  String selectedPlan = '1 Year';
  double price = 100.0; // Base price, can be adjusted
  String vendorName = "Unknown Vendor";
  String? vendorId;
  String? vendorEmail;
  String? vendorPhone;
  String? vendorAddress;
  String? vendorCity;

  @override
  void initState() {
    super.initState();
    fetchProductDetails();
  }

  Future<void> fetchProductDetails() async {
    print("Fetching Product Details for ID: ${widget.productId}");
    try {
      DocumentSnapshot productSnapshot = await FirebaseFirestore.instance
          .collection('products')
          .doc(widget.productId)
          .get();

      if (productSnapshot.exists) {
        setState(() {
          productData = productSnapshot.data() as Map<String, dynamic>?;
          imageUrls = List<String>.from(productData?['images'] ?? []);
          vendorId = productData?['vendorId'];
          isLoading = false;
        });

        print('Vendor ID: $vendorId');

        if (vendorId != null) {
          fetchVendorDetails(vendorId!);
        }

        bool isExporting = productData?['isExporting'] ?? false;
        bool isSubscription = productData?['isSubscription'] ?? false;

        if (isExporting) {
          fetchExportingDetails();
        }
        if (isSubscription) {
          fetchSubscriptionDetails();
        }
      } else {
        setState(() => isLoading = false);
        print("Product not found");
      }
    } catch (e) {
      setState(() => isLoading = false);
      print("Error fetching product: $e");
    }
  }

  Future<void> fetchExportingDetails() async {
    try {
      QuerySnapshot exportSnapshot = await FirebaseFirestore.instance
          .collection('products')
          .doc(widget.productId)
          .collection('exportingData')
          .get();

      if (exportSnapshot.docs.isNotEmpty) {
        List<Map<String, dynamic>> exportingDetails =
            exportSnapshot.docs.map((doc) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          data['country'] = doc.id; // Adding country name as a key
          return data;
        }).toList();

        setState(() {
          productData?['exportingDetails'] = exportingDetails;
        });

        print("Exporting Details: $exportingDetails");
      } else {
        print("No exporting details found");
      }
    } catch (e) {
      print("Error fetching exporting details: $e");
    }
  }

  Future<void> fetchSubscriptionDetails() async {
    try {
      QuerySnapshot subscriptionSnapshot = await FirebaseFirestore.instance
          .collection('products')
          .doc(widget.productId)
          .collection('subscriptionData')
          .get();

      if (subscriptionSnapshot.docs.isNotEmpty) {
        List<Map<String, dynamic>> subscriptionDetails =
            subscriptionSnapshot.docs.map((doc) {
          return doc.data() as Map<String, dynamic>;
        }).toList();

        setState(() {
          productData?['subscriptionDetails'] = subscriptionDetails;
        });

        print("Subscription Details: $subscriptionDetails");
      } else {
        print("No subscription details found");
      }
    } catch (e) {
      print("Error fetching subscription details: $e");
    }
  }

  Future<void> fetchVendorDetails(String vendorId) async {
    print(vendorId);
    try {
      DocumentSnapshot vendorSnapshot = await FirebaseFirestore.instance
          .collection('vendors')
          .doc(vendorId)
          .get();

      if (vendorSnapshot.exists) {
        setState(() {
          vendorName = vendorSnapshot["businessName"];
          vendorEmail = vendorSnapshot['email'];
          vendorPhone = vendorSnapshot['phone'];
          vendorAddress = vendorSnapshot['address'];
          vendorCity = vendorSnapshot['city'];
        });
      } else {
        print("Vendor not found");
      }
    } catch (e) {
      print("Error fetching vendor details: $e");
    }
  }

  void showVendorDetailsPopup() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(vendorName ?? "Vendor Details"),
          content:
              Text('$vendorEmail\n $vendorPhone\n $vendorAddress, $vendorCity'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Close"),
            ),
          ],
        );
      },
    );
  }

  Future<void> checkFavoriteStatus() async {
    try {
      User? user = _auth.currentUser;
      if (user == null) return;

      DocumentSnapshot favSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('favorites')
          .doc(widget.productId)
          .get();

      setState(() {
        isFavorite = favSnapshot.exists;
      });
    } catch (e) {
      print("Error checking favorite status: $e");
    }
  }

  Future<void> toggleFavorite() async {
    final FirebaseAuth _auth = FirebaseAuth.instance;
    final User? user = _auth.currentUser;
    if (user == null) {
      print("User not logged in");
      return;
    }

    String uid = user.uid;
    CollectionReference favoritesCollection = FirebaseFirestore.instance
        .collection('favorites')
        .doc(uid)
        .collection('items');

    if (isFavorite) {
      // Remove from favorites
      await favoritesCollection.doc(widget.productId).delete();
      setState(() {
        isFavorite = false;
      });
    } else {
      // Add to favorites
      await favoritesCollection.doc(widget.productId).set({
        'productId': widget.productId,
        'productName': productData?['name'], // Ensure correct field names
        'imageUrl': imageUrls.isNotEmpty ? imageUrls[0] : '',
        'vendorId': vendorId,
        'addedAt': FieldValue.serverTimestamp(),
      });
      print("Product Detail.......... ${widget.productId}");
      setState(() {
        isFavorite = true;
      });
    }
  }

  // Function to update the price based on the selected plan
  void updatePrice() {
    if (selectedPlan == '1 Year') {
      price = 100.0; // Price for 1 Year plan
    } else if (selectedPlan == '6 Month') {
      price = 60.0; // Price for 6 Month plan
    }
  }

  // Add the product to the user's cart
  Future<void> addToCart() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print("User not logged in");
      return;
    }

    String uid = user.uid;
    CollectionReference cartCollection = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('cart');

    // Add product to cart
    try {
      await cartCollection.doc(widget.productId).set({
        'productId': widget.productId,
        'productName': productData?['name'],
        'price': productData?['price'],
        'imageUrl': imageUrls.isNotEmpty ? imageUrls[0] : '',
        'quantity': quantity,
        'addedAt': FieldValue.serverTimestamp(),
      });
      print("Product added to cart");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${productData?['name']} added to cart!')),
      );
    } catch (e) {
      print("Error adding to cart: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Product Detail", style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xFF033015),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      backgroundColor: Colors.white,
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    productData?['name'] ?? 'Product Name',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),

                  imageUrls.isNotEmpty
                      ? CarouselSlider.builder(
                          itemCount: imageUrls.length,
                          itemBuilder: (context, index, realIndex) {
                            return ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.network(
                                imageUrls[index],
                                fit: BoxFit.cover,
                                width: double.infinity,
                                loadingBuilder:
                                    (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return Center(
                                      child: CircularProgressIndicator());
                                },
                                errorBuilder: (context, error, stackTrace) {
                                  return Center(
                                    child: Icon(Icons.image_not_supported,
                                        size: 50, color: Colors.red),
                                  );
                                },
                              ),
                            );
                          },
                          options: CarouselOptions(
                            height: 200,
                            enlargeCenterPage: true,
                            autoPlay: true,
                            autoPlayInterval: Duration(seconds: 5),
                          ),
                        )
                      : Center(
                          child: Text(
                            "No Images Available",
                            style: TextStyle(color: Colors.grey, fontSize: 16),
                          ),
                        ),

                  SizedBox(height: 10),

                  // Favorite Button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        icon: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: Colors.red,
                          size: 30,
                        ),
                        onPressed: toggleFavorite, //  Corrected function call
                      ),
                    ],
                  ),

                  Divider(thickness: 2, color: Colors.brown),
                  SizedBox(height: 10),

                  GestureDetector(
                    onTap: () => showVendorDetailsPopup(),
                    child: Text(
                      "Company: $vendorName",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),

                  SizedBox(height: 10),

                  Text('₹${productData?['price'] ?? '0'}',
                      style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF380230))),

                  SizedBox(height: 10),

                  // Export signal card
                  Positioned(
                    right: 10,
                    top: 5,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 3, vertical: 2),
                      decoration: BoxDecoration(
                        color: Color(0xFF033015),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Text(
                        'Exporting International',
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),

                  Row(
                    children: [
                      Text("Quantity: ", style: TextStyle(fontSize: 16)),
                      IconButton(
                        icon: Icon(Icons.remove),
                        onPressed: () => setState(() =>
                            quantity = quantity > 1 ? quantity - 1 : quantity),
                      ),
                      Text(quantity.toString(), style: TextStyle(fontSize: 16)),
                      IconButton(
                        icon: Icon(Icons.add),
                        onPressed: () => setState(() => quantity++),
                      ),
                    ],
                  ),

                  SizedBox(height: 20),

                  Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    child: Padding(
                      padding: EdgeInsets.all(10),
                      child: Text(
                        productData?['description'] ??
                            'No description available.',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),

                  if (productData?['isExporting'] == true)
                    Stack(
                      children: [
                        Center(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Card(
                                color: Color(0xFF033015),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Padding(
                                  padding: EdgeInsets.all(30),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Exporting Details",
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      SizedBox(height: 5),
                                      if (productData?['exportingDetails'] !=
                                          null)
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children:
                                              productData!['exportingDetails']
                                                  .map<Widget>((export) {
                                            var pricing = export['exportPricing'];
                                            return Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text("${export['country']}:",
                                                    style: TextStyle(
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.white)),
                                                SizedBox(height: 3),
                                                GestureDetector(
                                                  onTap: () {},
                                                  child: Container(
                                                    color: Colors.white,
                                                    width: 230,
                                                    height:40,
                                                    child: Center(
                                                      child: Text(
                                                          "Min Quantity: ${pricing['minQuantity']} - Cost: ${pricing['costPerWeightMin']}",
                                                          style: TextStyle(
                                                              color: Colors.black)),
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(height: 8),
                                                GestureDetector(
                                                  onTap: () {},
                                                  child: Container(
                                                    color: Colors.white,
                                                    width: 230,
                                                    height:40,
                                                    child: Center(
                                                      child: Text(
                                                          "Max Quantity: ${pricing['maxQuantity']} - Cost: ${pricing['costPerWeightMax']}",
                                                          style: TextStyle(
                                                              color: Colors.black)),
                                                    ),
                                                  ),
                                                ),
                                                Text(
                                                    "Insurance Cost: ${pricing['insuranceCost']}",
                                                    style: TextStyle(
                                                        color: Colors.white)),
                                                Text(
                                                    "Port Cost: ${pricing['portCost']}",
                                                    style: TextStyle(
                                                        color: Colors.white)),
                                                SizedBox(height: 8),
                                              ],
                                            );
                                          }).toList(),
                                        )
                                      else
                                        Text(
                                          "No exporting details available",
                                          style: TextStyle(color: Colors.white70),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                  SizedBox(height: 10),

                  // Subscription Card (Only visible if isSubscription is true)
                  if (productData?['isSubscription'] == true)
                    Card(
                      color: Colors.green,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                      child: Padding(
                        padding: EdgeInsets.all(10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Subscription Plans",
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            ),
                            SizedBox(height: 5),
                            if (productData?['subscriptionDetails'] != null)
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: productData!['subscriptionDetails']
                                    .map<Widget>((plan) => Text(
                                          "${plan['duration']} - ₹${plan['price']}",
                                          style: TextStyle(color: Colors.white),
                                        ))
                                    .toList(),
                              )
                            else
                              Text("No subscription plans available",
                                  style: TextStyle(color: Colors.white70)),
                          ],
                        ),
                      ),
                    ),
                  SizedBox(height: 40),

                  Center(
                    child: Column(
                      children: [
                        SizedBox(
                          width: 200,
                          child: ElevatedButton(
                            onPressed:
                                addToCart, // Call the addToCart function here
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF033015),
                              foregroundColor: Colors.white,
                            ),
                            child: Text('Add to Cart'),
                          ),
                        ),
                        SizedBox(height: 10),
                        SizedBox(
                          width: 200,
                          child: ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFF033015),
                                foregroundColor: Colors.white),
                            child: Text('Buy'),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 50),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatScreen(
              vendorId: vendorId!,
              businessName: vendorName,
            ),
          ),
        ),
        backgroundColor: Colors.grey,
        child: Icon(Icons.chat, color: Color(0xFF033015)),
        tooltip: 'Message us',
      ),
    );
  }
}
