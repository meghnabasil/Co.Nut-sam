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
  TextEditingController addressController = TextEditingController();
  TextEditingController detailsController = TextEditingController();

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
            child: Card(
              elevation: 5,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(widget.serviceName, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black)),
                    SizedBox(height: 5),
                    Text(widget.companyName, style: TextStyle(fontSize: 16, color: Colors.grey[700])),
                    SizedBox(height: 10),
                    Text("Price: \$${widget.price.toStringAsFixed(2)}", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF380230))),
                    Divider(thickness: 1, color: Colors.grey[300]),
                    SizedBox(height: 10),
                    _buildTextField(addressController, "Enter your address"),
                    SizedBox(height: 15),
                    _buildTextField(detailsController, "Something to tell?... Enter Details"),
                    SizedBox(height: 15),
                    _buildDateField(pickupDateController, "Select Pickup Date"),
                    SizedBox(height: 15),
                    _buildDateField(returnDateController, "Select Return Date"),
                    SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF033015),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                          padding: EdgeInsets.symmetric(vertical: 12),
                        ),
                        onPressed: () {
                          // Handle booking confirmation
                        },
                        child: Text("Confirm Booking", style: TextStyle(color: Colors.white, fontSize: 16)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String labelText) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
      ),
    );
  }

  Widget _buildDateField(TextEditingController controller, String labelText) {
    return TextField(
      controller: controller,
      readOnly: true,
      decoration: InputDecoration(
        labelText: labelText,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
        suffixIcon: Icon(Icons.calendar_today, color: Colors.grey[600]),
      ),
      onTap: () => _selectDate(context, controller),
    );
  }
}
