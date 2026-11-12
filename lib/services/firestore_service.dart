
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/giang_vien_model.dart';

class FirestoreService {
  final CollectionReference<Map<String, dynamic>> _giangViensRef =
      FirebaseFirestore.instance.collection('GiangVien');

  // CREATE
  Future<String> addGiangVien(GiangVien giangVien) async {
    try {
      // Sử dụng IDGV làm Document ID
      final docRef = _giangViensRef.doc(giangVien.idgv);

      // Kiểm tra mã giảng viên đã tồn tại chưa
      final existingDoc = await docRef.get();

      if (existingDoc.exists) {
        throw Exception('Lecturer ID already exists');
      }

      await docRef.set(giangVien.toMap());

      return docRef.id;
    } catch (e) {
      throw Exception('Error adding lecturer: $e');
    }
  }

  // READ - REALTIME
  Stream<List<GiangVien>> getGiangViensStream() {
    return _giangViensRef.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return GiangVien.fromMap(doc.data());
      }).toList();
    });
  }

  // READ - GET BY ID
  Future<GiangVien?> getGiangVienById(String idgv) async {
    try {
      final doc = await _giangViensRef.doc(idgv).get();

      if (!doc.exists || doc.data() == null) {
        return null;
      }

      return GiangVien.fromMap(doc.data()!);
    } catch (e) {
      throw Exception('Error getting lecturer: $e');
    }
  }

  // UPDATE
  Future<void> updateGiangVien(
    String oldId,
    GiangVien updatedGiangVien,
  ) async {
    try {
      final oldDocRef = _giangViensRef.doc(oldId);
      final newId = updatedGiangVien.idgv;

      // Nếu thay đổi IDGV, kiểm tra mã mới và chuyển document
      if (oldId != newId) {
        final newDocRef = _giangViensRef.doc(newId);
        final existingDoc = await newDocRef.get();

        if (existingDoc.exists) {
          throw Exception('New lecturer ID already exists');
        }

        await newDocRef.set(updatedGiangVien.toMap());
        await oldDocRef.delete();
      } else {
        await oldDocRef.update(updatedGiangVien.toMap());
      }
    } catch (e) {
      throw Exception('Error updating lecturer: $e');
    }
  }

  // DELETE
  Future<void> deleteGiangVien(GiangVien giangVien) async {
    try {
      await _giangViensRef.doc(giangVien.idgv).delete();
    } catch (e) {
      throw Exception('Error deleting lecturer: $e');
    }
  }
}
