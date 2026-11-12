
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../models/giang_vien_model.dart';
import '../services/firestore_service.dart';
import '../services/cloudinary_service.dart';

class AddGiangVienScreen extends StatefulWidget {
  const AddGiangVienScreen({super.key});

  @override
  State<AddGiangVienScreen> createState() => _AddGiangVienScreenState();
}

class _AddGiangVienScreenState extends State<AddGiangVienScreen> {
  final _formKey = GlobalKey<FormState>();

  final _idController = TextEditingController();
  final _fullnameController = TextEditingController();
  final _sumClassController = TextEditingController();

  final FirestoreService _firestoreService = FirestoreService();
  final CloudinaryService _cloudinaryService = CloudinaryService();

  XFile? _image;
  bool _isLoading = false;

  static const Color primaryColor = Color(0xFF5146E5);

  @override
  void dispose() {
    _idController.dispose();
    _fullnameController.dispose();
    _sumClassController.dispose();
    super.dispose();
  }

  // Chọn ảnh giảng viên
  Future<void> _pickImage() async {
    final picker = ImagePicker();

    final pickedImage = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (pickedImage != null && mounted) {
      setState(() => _image = pickedImage);
    }
  }

  // Thêm giảng viên
  Future<void> _addGiangVien() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // Upload ảnh nếu người dùng có chọn ảnh
      String imageUrl = '';

      if (_image != null) {
        imageUrl = await _cloudinaryService.uploadImage(_image!);

        if (imageUrl.isEmpty) {
          throw Exception('Image upload failed');
        }
      }

      // Tạo đối tượng giảng viên
      final giangVien = GiangVien(
        idgv: _idController.text.trim(),
        fullname: _fullnameController.text.trim(),
        image: imageUrl,
        sumClass: int.parse(_sumClassController.text.trim()),
      );

      // Lưu vào Firestore
      await _firestoreService.addGiangVien(giangVien);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lecturer added successfully'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error adding lecturer: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // Input decoration
  InputDecoration _inputDecoration(
    String label,
    IconData icon,
  ) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(
        icon,
        color: primaryColor,
      ),
      filled: true,
      fillColor: const Color(0xFFF5F6FA),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: Color(0xFFE8EAF0),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: primaryColor,
          width: 1.5,
        ),
      ),
    );
  }

  // Hiển thị ảnh xem trước hoặc hình người mặc định
  Widget _buildImagePreview() {
    if (_image == null) {
      return Container(
        width: double.infinity,
        color: const Color(0xFFF1F5F9),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.account_circle,
              size: 120,
              color: Color(0xFF94A3B8),
            ),
            SizedBox(height: 8),
            Text(
              'No image selected',
              style: TextStyle(
                color: Color(0xFF64748B),
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    return FutureBuilder(
      future: _image!.readAsBytes(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Image.memory(
            snapshot.data!,
            fit: BoxFit.cover,
            width: double.infinity,
          );
        }

        if (snapshot.hasError) {
          return const Center(
            child: Icon(
              Icons.broken_image_outlined,
              size: 60,
              color: Colors.grey,
            ),
          );
        }

        return const Center(
          child: CircularProgressIndicator(
            color: primaryColor,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),

      appBar: AppBar(
        title: const Text(
          'Add Lecturer',
          style: TextStyle(
            color: Color(0xFF20243A),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF20243A),
        elevation: 0,
      ),

      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 550,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Lecturer Information',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF20243A),
                      ),
                    ),

                    const SizedBox(height: 6),

                    const Text(
                      'Enter the information of the new lecturer.',
                      style: TextStyle(color: Colors.grey),
                    ),

                    const SizedBox(height: 22),

                    // Lecturer Image
                    const Text(
                      'Lecturer Image',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 10),

                    GestureDetector(
                      onTap: _isLoading ? null : _pickImage,
                      child: Container(
                        height: 220,
                        clipBehavior: Clip.antiAlias,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: const Color(0xFFE8EAF0),
                          ),
                        ),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            _buildImagePreview(),

                            Positioned(
                              bottom: 12,
                              right: 12,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: primaryColor,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.camera_alt_outlined,
                                      color: Colors.white,
                                      size: 18,
                                    ),
                                    SizedBox(width: 7),
                                    Text(
                                      'Choose Image',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            if (_image != null)
                              Positioned(
                                top: 10,
                                right: 10,
                                child: IconButton(
                                  onPressed: _isLoading
                                      ? null
                                      : () {
                                          setState(() => _image = null);
                                        },
                                  style: IconButton.styleFrom(
                                    backgroundColor: Colors.white,
                                  ),
                                  icon: const Icon(
                                    Icons.close,
                                    color: Colors.red,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // IDGV
                    TextFormField(
                      controller: _idController,
                      textCapitalization: TextCapitalization.characters,
                      decoration: _inputDecoration(
                        'Lecturer ID',
                        Icons.badge_outlined,
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter lecturer ID';
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    // Fullname
                    TextFormField(
                      controller: _fullnameController,
                      textCapitalization: TextCapitalization.words,
                      decoration: _inputDecoration(
                        'Full Name',
                        Icons.person_outline,
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter full name';
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    // SumClass
                    TextFormField(
                      controller: _sumClassController,
                      keyboardType: TextInputType.number,
                      decoration: _inputDecoration(
                        'Total Classes',
                        Icons.class_outlined,
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter total classes';
                        }

                        final sumClass = int.tryParse(value.trim());

                        if (sumClass == null || sumClass < 0) {
                          return 'Enter a valid non-negative integer';
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 28),

                    // Save Button
                    SizedBox(
                      height: 54,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _addGiangVien,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 0,
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : const Text(
                                'Save Lecturer',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
