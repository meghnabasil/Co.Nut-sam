import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/fav_model.dart';

class FavoriteController {
  final CollectionReference favoritesCollection =
  FirebaseFirestore.instance.collection('favorites');

  // Fetch favorite items as a stream
  Stream<List<FavoriteModel>> getFavorites() {
    return favoritesCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return FavoriteModel.fromFirestore(doc as DocumentSnapshot<Map<String, dynamic>>);
      }).toList();
    });
  }

  // Add a product to favorites
  Future<void> addToFavorites(FavoriteModel favorite) async {
    await favoritesCollection.doc(favorite.id).set(favorite.toMap());
  }

  // Remove a product from favorites
  Future<void> removeFromFavorites(String id) async {
    await favoritesCollection.doc(id).delete();
  }

  // Check if a product is already in favorites
  Future<bool> isFavorite(String productId) async {
    DocumentSnapshot doc = await favoritesCollection.doc(productId).get();
    return doc.exists;
  }
}
