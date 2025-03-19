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
  String? selectedCountry;
  String? selectedQuantityType;


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
          .doc(widget.productId) // Ensure this is a valid product ID
          .collection('subscriptionData')
          .get();

      if (subscriptionSnapshot.docs.isNotEmpty) {
        List<Map<String, dynamic>> subscriptionDetails =
        subscriptionSnapshot.docs.map((doc) {
          var data = doc.data() as Map<String, dynamic>;
          print("Fetched Plan: $data"); // Debugging line
          return data;
        }).toList();

        setState(() {
          productData = {
            ...?productData,
            'subscriptionDetails': subscriptionDetails,
          };
        });

        print("Updated Product Data: $productData");
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
                      " $vendorName",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),

                  SizedBox(height: 10),

                  Row(
                    children: [
                      // Product Price on the left
                      Text(
                        '₹${productData?['price'] ?? '0'}',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF380230),
                        ),
                      ),

                      Spacer(), // Pushes the icon to the right

                      // Subscription Icon (Shown only if the product has a subscription)
                      if (productData?['isSubscription'] == true)
                        Tooltip(
                          message: "This product Available for subscription",
                          child: Icon(Icons.lock_clock, color: Colors.black, size: 40),
                        ),
                    ],
                  ),

                  SizedBox(height: 10),


                  // Export signal card
                  if (productData?['exportingDetails'] != null && productData!['exportingDetails'].isNotEmpty)
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

                  // Row(
                  //   children: [
                  //     Text("Quantity: ", style: TextStyle(fontSize: 16)),
                  //     IconButton(
                  //       icon: Icon(Icons.remove),
                  //       onPressed: () => setState(() =>
                  //           quantity = quantity > 1 ? quantity - 1 : quantity),
                  //     ),
                  //     Text(quantity.toString(), style: TextStyle(fontSize: 16)),
                  //     IconButton(
                  //       icon: Icon(Icons.add),
                  //       onPressed: () => setState(() => quantity++),
                  //     ),
                  //   ],
                  // ),
                  //
                  // SizedBox(height: 20),
                  SizedBox(height: 10),
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
                  SizedBox(height: 50),

                  Center(
                    child: Column(
                      children: [
                        SizedBox(
                          width: 200,
                          child: ElevatedButton(
                            onPressed:
                            addToCart, // Call the addToCart function here
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey[800],
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


                  if (productData?['isExporting'] == true)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Dropdown for selecting country
                        Card(

                          color: Colors.grey,
                          elevation: 4,
                          margin: EdgeInsets.all(10),
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (productData?['isExporting'] == true &&
                                    productData?['exportingDetails'] != null &&
                                    productData!['exportingDetails'].isNotEmpty) ...[
                                  RichText(
                                    text: TextSpan(
                                      children: [
                                        WidgetSpan(
                                          child: Icon(Icons.flight_takeoff, color: Colors.black, size: 20),
                                        ),
                                        TextSpan(
                                          text: " --- Select Shipping Destination ---",
                                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  DropdownButton<String>(
                                    value: selectedCountry,
                                    hint: Text("Choose  Destination"),
                                    isExpanded: true,
                                    onChanged: (String? newValue) {
                                      setState(() {
                                        selectedCountry = newValue;
                                      });
                                    },
                                    items: productData!['exportingDetails']
                                        .map<DropdownMenuItem<String>>((export) => DropdownMenuItem<String>(
                                      value: export['country'],
                                      child: Text(export['country']),
                                    ))
                                        .toList(),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),

                        // Exporting Details
                        // Exporting Details
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
                                      padding: EdgeInsets.all(45),
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
                                          Divider(thickness: 2, color: Colors.grey),

                                          if (selectedCountry == null)
                                            Center(
                                              child: Text(
                                                "This product can be exported. Select the desired destination",
                                                style: TextStyle(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.bold),
                                              ),
                                            )
                                          else if (productData?['exportingDetails'] != null)
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: productData!['exportingDetails']
                                                  .where((export) => export['country'] == selectedCountry)
                                                  .map<Widget>((export) {
                                                var pricing = export['exportPricing'];
                                                var minQuan=pricing['minQuantity'];
                                                var mxQuan=pricing['maxQuantity'];
                                                var minPrice=pricing['costPerWeightMin'];
                                                var maxPrice=pricing['costPerWeightMax'];
                                                return Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text("${export['country']}:",
                                                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                                                    SizedBox(height: 3),

                                                    // Min Quantity Selection with White Background
                                                    Container(
                                                      decoration: BoxDecoration(
                                                        color: Colors.white, // White background
                                                        borderRadius: BorderRadius.circular(8), // Rounded corners
                                                        boxShadow: [
                                                          BoxShadow(
                                                            color: Colors.black12, // Light shadow
                                                            blurRadius: 4,
                                                            spreadRadius: 2,
                                                          ),
                                                        ],
                                                      ),
                                                      padding: EdgeInsets.all(8),
                                                      margin: EdgeInsets.symmetric(vertical: 5),
                                                      child: Row(
                                                        children: [
                                                          Radio<String>(
                                                            value: "minQuantity",
                                                            groupValue: selectedQuantityType,
                                                            onChanged: (String? value) {
                                                              setState(() {
                                                                selectedQuantityType = value;
                                                              });
                                                            },
                                                          ),
                                                          Expanded(
                                                            child: Text(
                                                              "Min Quantity: $minQuan \n  Cost per Weight: $minPrice",
                                                              style: TextStyle(color: Colors.black), // Text color black for visibility
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),

                                                    // Max Quantity Selection with White Background
                                                    Container(
                                                      decoration: BoxDecoration(
                                                        color: Colors.white, // White background
                                                        borderRadius: BorderRadius.circular(8), // Rounded corners
                                                        boxShadow: [
                                                          BoxShadow(
                                                            color: Colors.black12, // Light shadow
                                                            blurRadius: 4,
                                                            spreadRadius: 2,
                                                          ),
                                                        ],
                                                      ),
                                                      padding: EdgeInsets.all(8),
                                                      margin: EdgeInsets.symmetric(vertical: 5),
                                                      child: Row(
                                                        children: [
                                                          Radio<String>(
                                                            value: "maxQuantity",
                                                            groupValue: selectedQuantityType,
                                                            onChanged: (String? value) {
                                                              setState(() {
                                                                selectedQuantityType = value;
                                                              });
                                                            },
                                                          ),
                                                          Expanded(
                                                            child: Text(
                                                              "Max Quantity: $mxQuan \n Cost per Weight: $maxPrice",
                                                              style: TextStyle(color: Colors.black), // Text color black for visibility
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),

                                                    SizedBox(height: 9),
                                                    Text("Insurance Cost: ${pricing['insuranceCost']}", style: TextStyle(color: Colors.white)),
                                                    Text("Port Cost: ${pricing['portCost']}", style: TextStyle(color: Colors.white)),
                                                    SizedBox(height: 8),

                                                    // Select Button
                                                    ElevatedButton(
                                                      onPressed: selectedQuantityType != null
                                                          ? () {
                                                        showDialog(
                                                          context: context,
                                                          builder: (context) => AlertDialog(
                                                            title: Text("Confirmation"),
                                                            content: Text("Are you sure you need this product to export?"),
                                                            actions: [
                                                              TextButton(
                                                                onPressed: () => Navigator.pop(context),
                                                                child: Text("Cancel"),
                                                              ),
                                                              ElevatedButton(
                                                                onPressed: () {
                                                                  Navigator.pop(context);
                                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                                    SnackBar(content: Text("Product selected for export")),
                                                                  );
                                                                },
                                                                child: Text("Confirm"),
                                                              ),
                                                            ],
                                                          ),
                                                        );
                                                      }
                                                          : null,
                                                      child: Text("Select"),
                                                    ),
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
                      ],
                    ),


                  SizedBox(height: 10),

                  // Subscription Card (Only visible if isSubscription is true)
                  if (productData?['isSubscription'] == true || showSubscriptionCard)
                    Card(
                      color: Color(0xFF033015),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Subscription Plans",
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                            SizedBox(height: 10),
                            if (productData?['subscriptionDetails'] != null)
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: productData!['subscriptionDetails']
                                    .map<Widget>((plan) => Row(
                                  children: [
                                    Radio(
                                      value: plan['duration'],
                                      groupValue: selectedPlan,
                                      onChanged: (value) {
                                        setState(() {
                                          selectedPlan = value.toString();
                                          price = plan['price'];
                                          quantity = plan['quantity'] ?? 1;
                                          updatePrice();
                                        });
                                      },
                                    ),
                                    Text(
                                      "${plan['duration']} - ₹${plan['price']}",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ],
                                ))
                                    .toList(),
                              )
                            else
                              Text("No subscription plans available",
                                  style: TextStyle(color: Colors.white70)),
                            SizedBox(height: 10),
                            if (selectedPlan != null)
                              Column(
                                children: [
                                  Text(
                                    'Price: ₹$price',
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white),
                                  ),
                                  Text(
                                    'Quantity: $quantity',
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white),
                                  ),
                                  SizedBox(height: 20),
                                  Card(
                                    elevation: 4,
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10)),
                                    child: Padding(
                                      padding: EdgeInsets.all(10),
                                      child: Column(
                                        children: [
                                          Text(
                                            '$selectedPlan Subscription Plan',
                                            style: TextStyle(
                                                fontSize: 16, fontWeight: FontWeight.bold),
                                          ),
                                          SizedBox(height: 10),
                                          Text(
                                            selectedPlan == '1 Year'
                                                ? 'With the 1-year subscription plan, enjoy the product benefits for a full year at a discounted price.'
                                                : 'The 6-month plan offers flexibility with a lower commitment, perfect for those seeking shorter-term access to the product.',
                                            style: TextStyle(fontSize: 14),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                    ),
                  SizedBox(height: 40),


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
