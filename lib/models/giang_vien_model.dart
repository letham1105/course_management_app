
class GiangVien {
  final String idgv;
  final String fullname;
  final String image;
  final int sumClass;

  GiangVien({
    required this.idgv,
    required this.fullname,
    required this.image,
    required this.sumClass,
  });

  factory GiangVien.fromMap(Map<String, dynamic> map) {
    return GiangVien(
      idgv: map['IDGV'] ?? '',
      fullname: map['Fullname'] ?? '',
      image: map['Image'] ?? '',
      sumClass: (map['SumClass'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'IDGV': idgv,
      'Fullname': fullname,
      'Image': image,
      'SumClass': sumClass,
    };
  }
}
