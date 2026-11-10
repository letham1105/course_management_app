import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product_model.dart';

class FirestoreService {
  final CollectionReference<Map<String, dynamic>> _productsRef =
      FirebaseFirestore.instance.collection('products');

  // CREATE
  Future<String> addProduct(Product product) async {
    try {
      final docRef = _productsRef.doc();

      final newProduct = Product(
        id: docRef.id,
        name: product.name,
        type: product.type,
        price: product.price,
        imageUrl: product.imageUrl,
      );

      await docRef.set(newProduct.toMap());

      return docRef.id;
    } catch (e) {
      throw Exception('Error adding product: $e');
    }
  }

  // READ
  Stream<List<Product>> getProductsStream() {
    return _productsRef.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Product.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }

  // UPDATE
  Future<void> updateProduct(Product product) async {
    try {
      await _productsRef.doc(product.id).update(product.toMap());
    } catch (e) {
      throw Exception('Error updating product: $e');
    }
  }

  // DELETE
  Future<void> deleteProduct(Product product) async {
    try {
      await _productsRef.doc(product.id).delete();
    } catch (e) {
      throw Exception('Error deleting product: $e');
    }
  }
}