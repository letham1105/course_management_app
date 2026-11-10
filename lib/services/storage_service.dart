// services/storage_service.dart
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Upload image to Firebase Storage and return the download URL
  Future<String> uploadImage(File file) async {
    try {
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      Reference ref = _storage.ref().child('product_images').child(fileName);
      await ref.putFile(file);
      String downloadURL = await ref.getDownloadURL(); // Retrieve download URL
      return downloadURL;
    } catch (e) {
      throw 'Error uploading image: $e';
    }
  }
  
  // Delete image from Firebase Storage using the download URL.
  Future<void> deleteImage(String imageUrl) async {
    try {
      // Skip deletion if the URL is not from our storage (e.g., default image)
      if (!imageUrl.contains('product_images')) return;

      // Example URL:
      // https://firebasestorage.googleapis.com/v0/b/your_project_id.appspot.com/o/product_images%2F1623679200000?alt=media&token=...
      Uri uri = Uri.parse(imageUrl);
      final parts = uri.path.split('/o/');
      if (parts.length < 2) return;
      final encodedPath = parts[1];
      final decodedPath = Uri.decodeFull(encodedPath); // yields "product_images/1623679200000"
      Reference ref = _storage.ref().child(decodedPath);
      await ref.delete();
    } catch (e) {
      // Log the error; we don't want to break the user flow if deletion fails.
      print('Error deleting image: $e');
    }
  }
}
