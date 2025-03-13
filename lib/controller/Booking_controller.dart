import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dup/model/Booking_model.dart';

class BookingController {
  final CollectionReference bookingCollection =
  FirebaseFirestore.instance.collection('bookings');

  Future<void> addBooking(Booking booking) async {
    try {
      await bookingCollection.add(booking.toMap());
    } catch (e) {
      print("Error adding booking: $e");
    }
  }

  Stream<List<Booking>> getBookings() {
    return bookingCollection.snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => Booking.fromMap(doc.data() as Map<String, dynamic>, doc.id)).toList());
  }

  Future<void> updateBooking(String id, Booking updatedBooking) async {
    try {
      await bookingCollection.doc(id).update(updatedBooking.toMap());
    } catch (e) {
      print("Error updating booking: $e");
    }
  }



  Future<void> deleteBooking(String id) async {
    try {
      await bookingCollection.doc(id).delete();
    } catch (e) {
      print("Error deleting booking: $e");
    }
  }
}
