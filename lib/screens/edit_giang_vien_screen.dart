
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../models/giang_vien_model.dart';
import '../services/firestore_service.dart';
import '../services/cloudinary_service.dart';

class EditGiangVienScreen extends StatefulWidget {
  final GiangVien giangVien;

  const EditGiangVienScreen({
    super.key,
    required this.giangVien,
  });

  @override
  State<EditGiangVienScreen> createState() =>
      _EditGiangVienScreenState();
}

class _EditGiangVienScreenState extends State<EditGiangVienScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _idController;
  late final TextEditingController _fullnameController;
  late final TextEditingController _sumClassController;

  final FirestoreService _firestoreService = FirestoreService();
  final CloudinaryService _cloudinaryService = CloudinaryService();

  XFile? _newImage;
  late String _currentImageUrl;

  bool _isLoading = false;

  static const Color primaryColor = Color(0xFF5146E5);

  static const String defaultAssetImagePath =
      'assets/default_product.png';

  @override
  void initState() {
    super.initState();

    _idController = TextEditingController(
      text: widget.giangVien.idgv,
    );

    _fullnameController = TextEditingController(
      text: widget.giangVien.fullname,
    );

    _sumClassController = TextEditingController(
      text: widget.giangVien.sumClass.toString(),
    );

    _currentImageUrl = widget.giangVien.image;
  }

  @override
  void dispose() {
    _idController.dispose();
    _fullnameController.dispose();
    _sumClassController.dispose();
    super.dispose();
  }

  // Chọn ảnh mới
  Future<void> _pickNewImage() async {
    final picker = ImagePicker();

    final pickedImage = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (pickedImage != null && mounted) {
      setState(() => _newImage = pickedImage);
    }
  }

  // Cập nhật thông tin giảng viên
  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      String imageUrl = _currentImageUrl;

      // Upload ảnh mới nếu người dùng chọn
      if (_newImage != null) {
        imageUrl = await _cloudinaryService.uploadImage(_newImage!);

        if (imageUrl.isEmpty) {
          throw Exception('Image upload failed');
        }
      }

      // Tạo đối tượng giảng viên đã cập nhật
      final updatedGiangVien = GiangVien(
        idgv: _idController.text.trim(),
        fullname: _fullnameController.text.trim(),
        image: imageUrl,
        sumClass: int.parse(_sumClassController.text.trim()),
      );

      // Cập nhật Firestore
      await _firestoreService.updateGiangVien(
        widget.giangVien.idgv,
        updatedGiangVien,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lecturer updated successfully'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating lecturer: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // Hiển thị ảnh giảng viên
  Widget _buildGiangVienImage() {
    if (_newImage != null) {
      return FutureBuilder(
        future: _newImage!.readAsBytes(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Image.memory(
              snapshot.data!,
              fit: BoxFit.cover,
              width: double.infinity,
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

    if (_currentImageUrl.isNotEmpty) {
      return Image.network(
        _currentImageUrl,
        fit: BoxFit.cover,
        width: double.infinity,
        errorBuilder: (_, __, ___) {
          return Image.asset(
            defaultAssetImagePath,
            fit: BoxFit.cover,
          );
        },
      );
    }

    return Image.asset(
      defaultAssetImagePath,
      fit: BoxFit.cover,
      width: double.infinity,
    );
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

  @override
  Widget build(BuildContext context) {
    final hasImage =
        _newImage != null || _currentImageUrl.isNotEmpty;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),

      appBar: AppBar(
        title: const Text(
          'Edit Lecturer',
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
                      'Edit Lecturer Information',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF20243A),
                      ),
                    ),

                    const SizedBox(height: 6),

                    const Text(
                      'Update lecturer information below.',
                      style: TextStyle(color: Colors.grey),
                    ),

                    const SizedBox(height: 22),

                    // Lecturer Image
                    Container(
                      height: 240,
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
                          _buildGiangVienImage(),

                          Positioned(
                            bottom: 12,
                            right: 12,
                            child: ElevatedButton.icon(
                              onPressed: _isLoading
                                  ? null
                                  : _pickNewImage,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryColor,
                                foregroundColor: Colors.white,
                              ),
                              icon: const Icon(
                                Icons.camera_alt_outlined,
                              ),
                              label: const Text('Change Image'),
                            ),
                          ),

                          if (hasImage)
                            Positioned(
                              top: 8,
                              right: 8,
                              child: IconButton(
                                onPressed: _isLoading
                                    ? null
                                    : () {
                                        setState(() {
                                          _newImage = null;
                                          _currentImageUrl = '';
                                        });
                                      },
                                style: IconButton.styleFrom(
                                  backgroundColor: Colors.white,
                                ),
                                icon: const Icon(
                                  Icons.delete_outline,
                                  color: Colors.red,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // IDGV
                    TextFormField(
                      controller: _idController,
                      textCapitalization:
                          TextCapitalization.characters,
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
                      textCapitalization:
                          TextCapitalization.words,
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

                        final sumClass =
                            int.tryParse(value.trim());

                        if (sumClass == null || sumClass < 0) {
                          return 'Enter a valid non-negative integer';
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 28),

                    // Save Changes
                    SizedBox(
                      height: 54,
                      child: ElevatedButton(
                        onPressed:
                            _isLoading ? null : _saveChanges,
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
                                'Save Changes',
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
