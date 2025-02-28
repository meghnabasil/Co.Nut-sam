import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:dup/view/vendormessagescreen.dart';
import 'package:dup/view/CompanyDetail.dart';

class ProductDetail extends StatefulWidget {
  final int productIndex;
  final String vendorId;

  ProductDetail({required this.productIndex, required this.vendorId});

  @override
  _ProductDetailState createState() => _ProductDetailState();
}

class _ProductDetailState extends State<ProductDetail> {
  Map<String, dynamic>? productData;
  bool isLoading = true;
  bool isFavorite = false;
  int quantity = 1;
  List<String> imageUrls = [];

  // Flags to toggle visibility of containers
  bool showExportDetails = false;
  bool showSubscriptionCard = false;
  String selectedPlan = '1 Year';
  double price = 100.0; // Base price, can be adjusted




  @override
  void initState() {
    super.initState();
    fetchProductDetails();
  }

  Future<void> fetchProductDetails() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('products').get();
      if (snapshot.docs.isNotEmpty && widget.productIndex < snapshot.docs.length) {
        String productId = snapshot.docs[widget.productIndex].id;
        DocumentSnapshot productSnapshot =
        await FirebaseFirestore.instance.collection('products').doc(productId).get();

        if (productSnapshot.exists) {
          setState(() {
            productData = productSnapshot.data() as Map<String, dynamic>?;
            imageUrls = List<String>.from(productData?['imageUrls'] ?? []);
            isLoading = false;
          });
        } else {
          setState(() => isLoading = false);
          print("Product not found");
        }
      } else {
        setState(() => isLoading = false);
        print("Invalid product index");
      }
    } catch (e) {
      setState(() => isLoading = false);
      print("Error fetching product: $e");
    }
  }

  void toggleFavorite() => setState(() => isFavorite = !isFavorite);

  void showCompanyDetailsPopup() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CompanyDetail(vendorId: widget.vendorId);
      },
    );
  }

  // Function to update the price based on the selected plan
  void updatePrice() {
    if (selectedPlan == '1 Year') {
      price = 100.0; // Price for 1 Year plan
    } else if (selectedPlan == '6 Month') {
      price = 60.0; // Price for 6 Month plan
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
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(child: CircularProgressIndicator());
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Center(
                        child: Icon(Icons.image_not_supported, size: 50, color: Colors.red),
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

            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border, color: Colors.red, size: 30),
                  onPressed: toggleFavorite,
                ),
              ],
            ),

            Divider(thickness: 2, color: Colors.brown),
            SizedBox(height: 10),

            GestureDetector(
              onTap: showCompanyDetailsPopup,
              child: Text(
                productData?['company'] ?? 'Company Name',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),

            SizedBox(height: 10),

            Text('₹${productData?['price'] ?? '0'}',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF380230))),

            SizedBox(height: 10),


            // Export signal card
            Positioned(
              right: 10,
              top: 5,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 3, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.blueGrey,
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Text(
                  'Exporting International',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),


            Row(
              children: [
                Text("Quantity: ", style: TextStyle(fontSize: 16)),
                IconButton(
                  icon: Icon(Icons.remove),
                  onPressed: () => setState(() => quantity = quantity > 1 ? quantity - 1 : quantity),
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
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              child: Padding(
                padding: EdgeInsets.all(10),
                child: Text(
                  productData?['description'] ?? 'No description available.',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ),
            ),


            SizedBox(height: 20),
            // Buttons to show the containers
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      showExportDetails = !showExportDetails;
                    });
                  },
                  child: Text(showExportDetails ? 'Hide Export Details' : 'Show Export Details'),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      showSubscriptionCard = !showSubscriptionCard;
                    });
                  },
                  child: Text(showSubscriptionCard ? 'Hide' : 'Show Plan'),
                ),
              ],
            ),
            SizedBox(height: 20),

            // 1st Container: Export Wholesale Details
            if (showExportDetails)
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Export Wholesale Details',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    Text('Here are the details for export wholesale.'),
                    // Add more export details here
                  ],
                ),
              ),
            SizedBox(height: 20),

            // 2nd Container: Subscription Card
            if (showSubscriptionCard)
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Subscription Plan',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Radio(
                          value: '1 Year',
                          groupValue: selectedPlan,
                          onChanged: (value) {
                            setState(() {
                              selectedPlan = value.toString();
                              updatePrice();
                            });
                          },
                        ),
                        Text('1 Year'),
                      ],
                    ),
                    Row(
                      children: [
                        Radio(
                          value: '6 Month',
                          groupValue: selectedPlan,
                          onChanged: (value) {
                            setState(() {
                              selectedPlan = value.toString();
                              updatePrice();
                            });
                          },
                        ),
                        Text('6 Month'),
                      ],
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Price: ₹$price',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),

                    // Plan explanation card
                    SizedBox(height: 20),
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      child: Padding(
                        padding: EdgeInsets.all(10),
                        child: Column(
                          children: [
                            Text(
                              selectedPlan == '1 Year' ? '1 Year Subscription Plan' : '6 Month Subscription Plan',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
              ),
            SizedBox(height: 40),


            Center(
              child: Column(
                children: [
                  SizedBox(
                    width: 200,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF033015), foregroundColor: Colors.white),
                      child: Text('Add to Cart'),
                    ),
                  ),
                  SizedBox(height: 10),
                  SizedBox(
                    width: 200,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF033015), foregroundColor: Colors.white),
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
          MaterialPageRoute(builder: (context) => Vendor_ChatScreen(companyName: productData?['company'] ?? 'Company Name')),
        ),
        backgroundColor: Colors.grey,
        child: Icon(Icons.chat, color: Color(0xFF033015)),
        tooltip: 'Message us',
      ),
    );
  }
}
