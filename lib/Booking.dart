import 'package:flutter/material.dart';

class BookingPage extends StatefulWidget {
  final int index;
  final String serviceName;
  final String companyName;
  final double price;

  BookingPage({
    required this.index,
    required this.serviceName,
    required this.companyName,
    required this.price,
  });

  @override
  _BookingPageState createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  TextEditingController pickupDateController = TextEditingController();
  TextEditingController returnDateController = TextEditingController();

  Future<void> _selectDate(BuildContext context, TextEditingController controller) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        controller.text = "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Book Service", style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xFF033015),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Service: ${widget.serviceName}", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                SizedBox(height: 10),
                Text("Company: ${widget.companyName}", style: TextStyle(fontSize: 16, color: Colors.grey[700])),
                SizedBox(height: 10),
                Text("Price: \$${widget.price.toStringAsFixed(2)}", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF380230))),
                SizedBox(height: 20),
                TextField(
                  decoration: InputDecoration(
                    labelText: "Enter your address",
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30)
                    ),
                  ),
                ),
                SizedBox(height: 20),
                TextField(
                  decoration: InputDecoration(
                    labelText: "Something to tell ?...Enter Details",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30)
                    ),
                  ),
                ),
                SizedBox(height: 20),
                TextField(
                  controller: pickupDateController,
                  decoration: InputDecoration(
                    labelText: "Select Pickup Date",
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30)
                    ),
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  readOnly: true,
                  onTap: () => _selectDate(context, pickupDateController),
                ),
                SizedBox(height: 20),
                TextField(
                  controller: returnDateController,
                  decoration: InputDecoration(
                    labelText: "Select Return Date",
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30)
                    ),
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  readOnly: true,
                  onTap: () => _selectDate(context, returnDateController),
                ),
                SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF033015),
                    ),
                    onPressed: () {
                      // Handle booking confirmation
                    },
                    child: Text("Confirm Booking", style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
