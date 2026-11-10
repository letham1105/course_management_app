import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ProductImagePicker extends StatelessWidget {
  final XFile? image;
  final Function(XFile) onImagePicked;
  final String defaultAssetImagePath;

  const ProductImagePicker({
    super.key,
    required this.image,
    required this.onImagePicked,
    required this.defaultAssetImagePath,
  });

  Future<void> _pickImage() async {
    final picker = ImagePicker();

    final XFile? pickedImage = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (pickedImage != null) {
      onImagePicked(pickedImage);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _pickImage,
      child: Container(
        width: 120,
        height: 120,
        color: Colors.grey[300],
        child: image == null
            ? Image.asset(
                defaultAssetImagePath,
                fit: BoxFit.cover,
              )
            : FutureBuilder(
                future: image!.readAsBytes(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return Image.memory(
                      snapshot.data!,
                      fit: BoxFit.cover,
                    );
                  }

                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                },
              ),
      ),
    );
  }
}