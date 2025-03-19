import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/Booking_model.dart';

class BookingHistoryScreen extends StatelessWidget {
  final String userId; // Accept userId as a parameter

  const BookingHistoryScreen({Key? key, required this.userId}) : super(key: key);

  // Fetch bookings from Firestore for the given userId
  Stream<List<Booking>> getBookingsStream() {
    return FirebaseFirestore.instance
        .collection('bookings')
        .where('userId', isEqualTo: userId) // Fetch only bookings for this user
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Booking.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    });
  }

  // Function to cancel a booking (updates status instead of deleting)
  Future<void> cancelBooking(BuildContext context, String bookingId) async {
    try {
      // Delete the booking from Firestore
      await FirebaseFirestore.instance.collection('bookings').doc(bookingId).delete();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Your booking has been Cancelled successfully."),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error deleting booking: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }



  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Booking>>(
      stream: getBookingsStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text("No bookings found."));
        }

        return ListView.builder(
          itemCount: snapshot.data!.length,
          itemBuilder: (context, index) {
            Booking booking = snapshot.data![index];

            return Card(
              margin: const EdgeInsets.all(10),
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Row to display service name and Cancel button in the top right
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            booking.serviceName,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ),
                        if (booking.status != "Cancelled") // Show cancel button only if not already cancelled
                          StatefulBuilder(
                            builder: (context, setState) {
                              bool isLoading = false;

                              return GestureDetector(
                                onTap: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text("Cancel Booking"),
                                      content: isLoading
                                          ? const Center(child: CircularProgressIndicator()) // Show loading
                                          : const Text("Are you sure you want to cancel this booking?"),
                                      actions: isLoading
                                          ? []
                                          : [
                                        TextButton(
                                          onPressed: () => Navigator.pop(context),
                                          child: const Text("No"),
                                        ),
                                        TextButton(
                                          onPressed: () async {
                                            setState(() => isLoading = true);
                                            await cancelBooking(context, booking.id);
                                            Navigator.pop(context);
                                          },
                                          child: const Text(
                                            "Yes",
                                            style: TextStyle(color: Colors.red),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                                child: const Text(
                                  "Cancel",
                                  style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                                ),
                              );
                            },
                          ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Booking Details
                    Text("Vendor: ${booking.companyName}"),
                    Text("Pickup Date: ${booking.pickupDate}"),
                    Text("Return Date: ${booking.returnDate}"),
                    Text("Quantity: ${booking.quantity} ${booking.unit}"),
                    Text("Price: ₹${booking.price}"),
                    Text("Full Name: ${booking.fullName}"),
                    Text("Mobile: ${booking.mobileNumber}"),

                    const SizedBox(height: 10),

                    // Address Section
                    const Text(
                      "📍 Your Address",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 5),
                    Text("District: ${booking.district}"),
                    Text("Town/City: ${booking.townCity}"),
                    Text("Pincode: ${booking.pincode}"),
                    Text("Area: ${booking.area}"),
                    Text("Building: ${booking.buildingDetails}"),
                    Text("Landmark: ${booking.landmark}"),

                    const SizedBox(height: 20),

                    // Booking Status Section
                    const Text(
                      "✅ Your Booking Status",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 5),
                    Card(
                      color: booking.status == "Completed"
                          ? Colors.green[100]
                          : booking.status == "Cancelled"
                          ? Colors.red[100]
                          : Colors.orange[100],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        child: Text(
                          booking.status,
                          style: TextStyle(
                            color: booking.status == "Completed"
                                ? Colors.green
                                : booking.status == "Cancelled"
                                ? Colors.red
                                : Colors.orange,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
