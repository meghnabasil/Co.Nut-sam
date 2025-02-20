import 'package:dup/view/vendormessagescreen.dart';
import 'package:flutter/material.dart';
import 'package:dup/controller/vendor_controller.dart';
import 'package:dup/view/CompanyDetail.dart';
import 'package:dup/view/chat.dart';
import 'package:dup/view/chatdetailscreen.dart';
import 'package:dup/view/international.dart';
import 'package:carousel_slider/carousel_slider.dart';

class ProductDetail extends StatefulWidget {
  final int productIndex;
  final String vendorId;

  ProductDetail({required this.productIndex, required this.vendorId});

  @override
  _ProductDetailState createState() => _ProductDetailState();
}

class _ProductDetailState extends State<ProductDetail> {
  String selectedOption = 'Retail';
  bool isFavorite = false;
  List<int> favoriteProducts = [];
  int quantity = 1;

  // Flags to toggle visibility of containers
  bool showExportDetails = false;
  bool showSubscriptionCard = false;
  String selectedPlan = '1 Year';
  double price = 100.0; // Base price, can be adjusted

  // to show company detail
  void showCompanyDetailsPopup() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CompanyDetail(vendorId: widget.vendorId); // Pass vendor ID to popup
      },
    );
  }

  void toggleFavorite() {
    setState(() {
      if (isFavorite) {
        favoriteProducts.remove(widget.productIndex);
      } else {
        favoriteProducts.add(widget.productIndex);
      }
      isFavorite = !isFavorite;
    });
  }

  void showWholesalePopup() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.grey[400],
          title: Text("Select Wholesale Type", style: TextStyle(fontSize: 15)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text("Local"),
                leading: Radio(
                  value: 'Local',
                  groupValue: selectedOption,
                  onChanged: (value) {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => International()),
                    );
                  },
                ),
              ),
              ListTile(
                title: Text("International"),
                leading: Radio(
                  value: 'International',
                  groupValue: selectedOption,
                  onChanged: (value) {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => International()),
                    );
                  },
                ),
              ),
            ],
          ),
        );
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
      body: SingleChildScrollView(
        padding: EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Product ' + (widget.productIndex + 1).toString() + ' - A great choice for your needs!',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 40),
            CarouselSlider(
              items: [
                'asset/210379377.png',
                'asset/img1.jpg',
                'asset/music.jpg',
              ].map((item) => Image.asset(
                item,
                fit: BoxFit.cover,
                width: double.infinity,
              )).toList(),
              options: CarouselOptions(
                height: 150,
                enlargeCenterPage: true,
                enableInfiniteScroll: true,
                autoPlay: true,
                autoPlayInterval: Duration(seconds: 5),
                aspectRatio: 16 / 9,
                viewportFraction: 0.8,
              ),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border_outlined,
                    color: Colors.red,
                    size: 30,
                  ),
                  onPressed: toggleFavorite,
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Divider(thickness: 2, color: Colors.brown),
            const SizedBox(height: 10),

            GestureDetector(
              onTap: showCompanyDetailsPopup,
              child: Text('Company Name', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black, decoration: TextDecoration.underline)),
            ),
            SizedBox(height: 10),
            Text(
              '₹${(widget.productIndex + 1) * 20}',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF380230)),
            ),
            SizedBox(height: 6),
            Row(
              children: [
                Text("Quantity: ", style: TextStyle(fontSize: 16)),
                IconButton(
                  icon: Icon(Icons.remove),
                  onPressed: () {
                    setState(() {
                      if (quantity > 1) quantity--;
                    });
                  },
                ),
                Text(quantity.toString(), style: TextStyle(fontSize: 16)),
                IconButton(
                  icon: Icon(Icons.add),
                  onPressed: () {
                    setState(() {
                      quantity++;
                    });
                  },
                ),
              ],
            ),
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


            SizedBox(height: 20),
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              child: Padding(
                padding: EdgeInsets.all(10),
                child: Text(
                  'This price includes all applicable taxes and fees. Export',
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
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF033015),
                        foregroundColor: Color(0xFFFFFFFF),
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
                        foregroundColor: Color(0xFFFFFFFF),
                      ),
                      child: Text('Buy'),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 80),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Vendor_ChatScreen(companyName: "Company Name"),
            ),
          );
        },
        backgroundColor: Colors.grey,
        child: Icon(Icons.chat, color: Color(0xFF033015)),
        tooltip: 'Message us',
      ),

    );
  }
}
