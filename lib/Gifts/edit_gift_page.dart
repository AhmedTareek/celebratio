import 'dart:io';
import 'package:celebratio/Gifts/gift_controller.dart';
import 'package:flutter/material.dart';
import 'package:celebratio/Model/gift.dart';
import 'package:image_picker/image_picker.dart';

class EditGiftPage extends StatefulWidget {
  final Gift gift;
  final Function(Gift) onSave;
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
  final _formKey = GlobalKey<FormState>();
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
    _priceController =
        TextEditingController(text: widget.gift.price.toString());
    _descriptionController =
        TextEditingController(text: widget.gift.description);
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
        final String? uploadedUrl =
            await widget.controller.uploadImage(imageFile);

        if (uploadedUrl != null) {
          setState(() {
            _imageUrl = uploadedUrl;
          });
          if(mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Image uploaded successfully!',
              ),
            ),
          );
          }
        } else {
          if(mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Failed to upload image',
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
              backgroundColor: Theme.of(context).colorScheme.errorContainer,
            ),
          );
          }
        }
      } else {
        if(mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'No image selected',
            ),
          ),
        );
        }
      }
    } catch (e) {
      if(mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error uploading image: $e',
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
          backgroundColor: Theme.of(context).colorScheme.errorContainer,
        ),
      );
      }
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  void _saveChanges() {
    if (_formKey.currentState!.validate()) {
      widget.gift.name = _nameController.text;
      widget.gift.price = double.parse(_priceController.text);
      widget.gift.description = _descriptionController.text;
      widget.gift.category = _categoryController.text;
      widget.gift.imageUrl = _imageUrl; // Save the updated image URL

      widget.onSave(widget.gift); // Send the updated gift back
      Navigator.pop(context); // Go back to the previous page
    }
  }

  Widget _buildTextField(String labelText, TextEditingController controller,
      {int maxLines = 1}) {
    final theme = Theme.of(context);

    return TextFormField(
      keyboardType:
          labelText == 'Price' ? TextInputType.number : TextInputType.text,
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: theme.colorScheme.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: theme.colorScheme.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
        ),
        filled: true,
        fillColor: theme.colorScheme.surface,
        labelStyle: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onSurface.withOpacity(0.7),
        ),
        contentPadding: const EdgeInsets.all(16),
      ),
      style: theme.textTheme.bodyLarge?.copyWith(
        color: theme.colorScheme.onSurface,
      ),
      maxLines: maxLines,
      cursorColor: theme.colorScheme.primary,
      validator: (value) =>
          value!.isEmpty ? '$labelText cannot be empty' : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Edit Gift',
          style: theme.textTheme.titleLarge?.copyWith(
            color: theme.colorScheme.primary,
          ),
        ),
        backgroundColor: theme.secondaryHeaderColor,
        iconTheme: IconThemeData(color: theme.colorScheme.primary),
        elevation: 2,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildTextField('Name', _nameController),
              const SizedBox(height: 16),
              _buildTextField('Price', _priceController),
              const SizedBox(height: 16),
              _buildTextField('Description', _descriptionController,
                  maxLines: 3),
              const SizedBox(height: 16),
              _buildTextField('Category', _categoryController),
              const SizedBox(height: 16),
              _imageUrl != null
                  ? Image.network(
                      _imageUrl!,
                      height: 150,
                      fit: BoxFit.cover,
                    )
                  : Text('No image selected',
                      style: theme.textTheme.bodyMedium),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _isUploading ? null : _uploadNewImage,
                child: _isUploading
                    ? const CircularProgressIndicator()
                    : Text('Upload New Image',
                        style: theme.textTheme.labelLarge),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('Cancel',
                          style: TextStyle(color: Colors.red[800])),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isUploading ? null : _saveChanges,
                      child: const Text('Save Changes'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
