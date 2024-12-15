// import 'package:celebratio/Gifts/gift_controller.dart';
// import 'package:flutter/material.dart';
// import 'package:celebratio/Model/fb_gift.dart';
//
// class EditGiftPage extends StatefulWidget {
//   final FbGift gift;
//   final Function(FbGift) onSave;
//   final GiftController controller;
//
//   const EditGiftPage({super.key, required this.gift, required this.onSave, required this.controller});
//
//   @override
//   State<EditGiftPage> createState() => _EditGiftPageState();
// }
//
// class _EditGiftPageState extends State<EditGiftPage> {
//   late TextEditingController _nameController;
//   late TextEditingController _priceController;
//   late TextEditingController _descriptionController;
//   late TextEditingController _categoryController;
//
//   @override
//   void initState() {
//     super.initState();
//     _nameController = TextEditingController(text: widget.gift.name);
//     _priceController = TextEditingController(text: widget.gift.price.toString());
//     _descriptionController = TextEditingController(text: widget.gift.description);
//     _categoryController = TextEditingController(text: widget.gift.category);
//   }
//
//   @override
//   void dispose() {
//     _nameController.dispose();
//     _priceController.dispose();
//     _descriptionController.dispose();
//     _categoryController.dispose();
//     super.dispose();
//   }
//
//   void _saveChanges() {
//     widget.gift.name = _nameController.text;
//     widget.gift.price = double.parse(_priceController.text);
//     widget.gift.description = _descriptionController.text;
//     widget.gift.category = _categoryController.text;
//
//     widget.onSave(widget.gift); // Send the updated gift back
//     Navigator.pop(context); // Go back to the previous page
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Edit Gift'),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.save),
//             onPressed: _saveChanges,
//           ),
//         ],
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             TextField(
//               controller: _nameController,
//               decoration: const InputDecoration(labelText: 'Name'),
//             ),
//             const SizedBox(height: 8),
//             TextField(
//               controller: _priceController,
//               keyboardType: TextInputType.number,
//               decoration: const InputDecoration(labelText: 'Price'),
//             ),
//             const SizedBox(height: 8),
//             TextField(
//               controller: _descriptionController,
//               maxLines: 3,
//               decoration: const InputDecoration(labelText: 'Description'),
//             ),
//             const SizedBox(height: 8),
//             TextField(
//               controller: _categoryController,
//               decoration: const InputDecoration(labelText: 'Category'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'dart:io';
import 'package:celebratio/Gifts/gift_controller.dart';
import 'package:flutter/material.dart';
import 'package:celebratio/Model/fb_gift.dart';
import 'package:image_picker/image_picker.dart';

class EditGiftPage extends StatefulWidget {
  final FbGift gift;
  final Function(FbGift) onSave;
  final GiftController controller;

  const EditGiftPage({
    super.key,
    required this.gift,
    required this.onSave,
    required this.controller,
  });

  @override
  State<EditGiftPage> createState() => _EditGiftPageState();
}

class _EditGiftPageState extends State<EditGiftPage> {
  late TextEditingController _nameController;
  late TextEditingController _priceController;
  late TextEditingController _descriptionController;
  late TextEditingController _categoryController;

  String? _imageUrl;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.gift.name);
    _priceController = TextEditingController(text: widget.gift.price.toString());
    _descriptionController = TextEditingController(text: widget.gift.description);
    _categoryController = TextEditingController(text: widget.gift.category);
    _imageUrl = widget.gift.imageUrl;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  Future<void> _uploadNewImage() async {
    try {
      setState(() {
        _isUploading = true;
      });

      final XFile? pickedFile = await widget.controller.pickImage();
      if (pickedFile != null) {
        final File imageFile = File(pickedFile.path);
        final String? uploadedUrl = await widget.controller.uploadImage(imageFile);

        if (uploadedUrl != null) {
          setState(() {
            _imageUrl = uploadedUrl;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Image uploaded successfully!')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to upload image')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No image selected')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error uploading image: $e')),
      );
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  void _saveChanges() {
    widget.gift.name = _nameController.text;
    widget.gift.price = double.parse(_priceController.text);
    widget.gift.description = _descriptionController.text;
    widget.gift.category = _categoryController.text;
    widget.gift.imageUrl = _imageUrl; // Save the updated image URL

    widget.onSave(widget.gift); // Send the updated gift back
    Navigator.pop(context); // Go back to the previous page
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Gift'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _isUploading ? null : _saveChanges,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _priceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Price'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _descriptionController,
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _categoryController,
              decoration: const InputDecoration(labelText: 'Category'),
            ),
            const SizedBox(height: 16),
            _imageUrl != null
                ? Image.network(
              _imageUrl!,
              height: 150,
            )
                : const Text('No image selected'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isUploading ? null : _uploadNewImage,
              child: _isUploading
                  ? const CircularProgressIndicator()
                  : const Text('Upload New Image'),
            ),
          ],
        ),
      ),
    );
  }
}
