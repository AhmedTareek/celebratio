import 'dart:io';
import 'package:celebratio/Model/gift.dart';
import 'package:flutter/material.dart';
import 'gift_controller.dart';

class AddGiftPage extends StatefulWidget {
  final GiftController controller;

  const AddGiftPage({
    super.key,
    required this.controller,
  });

  @override
  State<AddGiftPage> createState() => _AddGiftPageState();
}

class _AddGiftPageState extends State<AddGiftPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _categoryController = TextEditingController();
  final _priceController = TextEditingController();

  File? _imageFile;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _categoryController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Widget _buildTextField(String label, TextEditingController controller, {int maxLines = 1, TextInputType? keyboardType}) {
    final theme = Theme.of(context);

    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
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
      cursorColor: theme.colorScheme.primary,
      validator: (value) {
        if (value?.isEmpty ?? true) {
          return 'Please enter a $label';
        }
        if (keyboardType == TextInputType.number && double.tryParse(value!) == null) {
          return 'Please enter a valid number';
        }
        return null;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Add New Gift',
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
              _buildTextField('Description', _descriptionController, maxLines: 4),
              const SizedBox(height: 16),
              _buildTextField('Category', _categoryController),
              const SizedBox(height: 16),
              _buildTextField('Price', _priceController, keyboardType: TextInputType.number),
              const SizedBox(height: 16),
              if (_imageFile != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(_imageFile!, height: 200, fit: BoxFit.cover),
                )
              else
                Text('No image selected', style: theme.textTheme.bodyMedium?.copyWith(color: theme.hintColor)),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  final pickedFile = await widget.controller.pickImage();
                  if (pickedFile != null) {
                    setState(() {
                      _imageFile = File(pickedFile.path);
                    });
                  }
                },
                // style: ElevatedButton.styleFrom(
                //   foregroundColor: theme.colorScheme.onPrimary,
                //   backgroundColor: theme.colorScheme.primary,
                // ),
                child: const Text('Pick Image', style: TextStyle(color: Colors.black)),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: _saveDraft,
                      child: Text('Save Draft', style: TextStyle(color: theme.colorScheme.secondary)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _submitForm,
                      child: const Text('Add Gift'),
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

  void _submitForm() async {
    if(widget.controller.event.syncAction == 'draft') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please publish the event before adding gifts',
          ),
        ),
      );
      return;
    }
    if (_formKey.currentState?.validate() ?? false) {
      String? imageUrl = await widget.controller.uploadImage(_imageFile);
      try {
        Gift gift = Gift(
          id: '',
          eventId: '',
          name: _nameController.text,
          description: _descriptionController.text,
          category: _categoryController.text,
          price: double.parse(_priceController.text),
          status: 'Available',
          imageUrl: imageUrl,
        );
        await widget.controller.addGift(gift);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Gift added successfully',
              ),
            ),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Error adding gift: ${e.toString()}',
              ),
            ),
          );
        }
      }
    }
  }

  void _saveDraft() async {
    final theme = Theme.of(context);
    if (_formKey.currentState?.validate() ?? false) {
      String? imageUrl = await widget.controller.uploadImage(_imageFile);
      try {
        Gift gift = Gift(
          id: '',
          eventId: '',
          name: _nameController.text,
          description: _descriptionController.text,
          category: _categoryController.text,
          price: double.parse(_priceController.text),
          status: 'Available',
          imageUrl: imageUrl,
          syncAction: 'draft',  // Setting the syncAction to 'draft'
        );
        await widget.controller.addGift(gift);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Gift draft added successfully',
                style: TextStyle(color: theme.colorScheme.onSurface),
              ),
              backgroundColor: theme.colorScheme.surface,
            ),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Error saving draft: ${e.toString()}',
                style: TextStyle(color: theme.colorScheme.error),
              ),
              backgroundColor: theme.colorScheme.errorContainer,
            ),
          );
        }
      }
    }
  }
}