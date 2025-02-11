import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

class ProductDetail extends StatefulWidget {
  final int productIndex;

  ProductDetail({required this.productIndex});

  @override
  _ProductDetailState createState() => _ProductDetailState();
}

class _ProductDetailState extends State<ProductDetail> {
  String selectedOption = 'Retail';
  bool isFavorite = false;
  List<int> favoriteProducts = [];

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
                'asset/music.jpg'
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
            // Give space between the carousel and the favorite icon
            SizedBox(height: 20),

            // Place the favorite icon in a Row aligned to the right
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

            const SizedBox(height: 20), // Space between Carousel and Divider
            const Divider(thickness: 2, color: Colors.brown),
            const SizedBox(height: 10),

            SizedBox(height: 20),
            Text('Company Name', style: TextStyle(color: Colors.grey[600])),
            SizedBox(height: 10),
            Text(
              '₹${(widget.productIndex + 1) * 20}',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF380230)),
            ),

            // Added description under the price box
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
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              child: Padding(
                padding: EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Purchase Option:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    SizedBox(width: 10),
                    Row(
                      children: [
                        Expanded(
                          child: ListTile(
                            title: Text('Retail'),
                            leading: Radio(
                              value: 'Retail',
                              groupValue: selectedOption,
                              onChanged: (value) {
                                setState(() {
                                  selectedOption = value.toString();
                                });
                              },
                            ),
                          ),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: ListTile(
                            title: Text('Wholesale'),
                            leading: Radio(
                              value: 'Wholesale',
                              groupValue: selectedOption,
                              onChanged: (value) {
                                setState(() {
                                  selectedOption = value.toString();
                                });
                              },
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
          // Implement chat functionality
        },
        backgroundColor: Colors.grey,
        child: Icon(Icons.chat, color:Color(0xFF033015)),
        tooltip: 'Message us',
      ),
    );
  }
}
