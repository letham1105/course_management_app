class Product {
  final String id;
  final String name;
  final String type;
  final double price;
  final String imageUrl;

  Product({
    required this.id,
    required this.name,
    required this.type,
    required this.price,
    required this.imageUrl,
  });

  // Convert Product to Firestore document
  Map<String, dynamic> toMap() {
    return {
      'idsanpham': id,
      'tensp': name,
      'loaisp': type,
      'gia': price,
      'hinhanh': imageUrl,
    };
  }

  // Convert Firestore document to Product
  factory Product.fromMap(Map<String, dynamic> data, String docId) {
    return Product(
      id: data['idsanpham'] ?? docId,
      name: data['tensp'] ?? '',
      type: data['loaisp'] ?? '',
      price: (data['gia'] as num?)?.toDouble() ?? 0.0,
      imageUrl: data['hinhanh'] ?? '',
    );
  }
}