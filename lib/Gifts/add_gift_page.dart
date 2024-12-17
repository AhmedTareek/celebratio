import 'dart:io';
import 'package:celebratio/Model/fb_gift.dart';
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

  // @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     appBar: AppBar(
  //       title: Text('Add New Gift', style: TextStyle(color: Colors.white)),
  //       backgroundColor: Colors.blue.shade700,
  //     ),
  //     body: SingleChildScrollView(
  //       padding: EdgeInsets.all(16.0),
  //       child: Form(
  //         key: _formKey,
  //         child: Column(
  //           crossAxisAlignment: CrossAxisAlignment.stretch,
  //           children: [
  //             _buildTextField('Name', _nameController),
  //             SizedBox(height: 16),
  //             _buildTextField('Description', _descriptionController, maxLines: 4),
  //             SizedBox(height: 16),
  //             _buildTextField('Category', _categoryController),
  //             SizedBox(height: 16),
  //             _buildTextField('Price', _priceController, keyboardType: TextInputType.number),
  //             SizedBox(height: 16),
  //             _imageFile != null
  //                 ? ClipRRect(
  //               borderRadius: BorderRadius.circular(8),
  //               child: Image.file(_imageFile!, height: 200, fit: BoxFit.cover),
  //             )
  //                 : Text('No image selected', style: TextStyle(color: Colors.grey)),
  //             SizedBox(height: 16),
  //             ElevatedButton(
  //               onPressed: () async {
  //                 final pickedFile = await widget.controller.pickImage();
  //                 if (pickedFile != null) {
  //                   setState(() {
  //                     _imageFile = File(pickedFile.path);
  //                   });
  //                 }
  //               },
  //               style: ElevatedButton.styleFrom(
  //                 foregroundColor: Colors.white, backgroundColor: Colors.blue.shade300,
  //               ),
  //               child: Text('Pick Image'),
  //             ),
  //             SizedBox(height: 24),
  //             Row(
  //               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  //               children: [
  //                 Expanded(
  //                   child: ElevatedButton(
  //                     onPressed: () {
  //                       _saveDraft();
  //                     },
  //                     style: ElevatedButton.styleFrom(
  //                       foregroundColor: Colors.white, backgroundColor: Colors.grey.shade600,
  //                     ),
  //                     child: Text('Save Draft'),
  //                   ),
  //                 ),
  //                 SizedBox(width: 10),
  //                 Expanded(
  //                   child: ElevatedButton(
  //                     onPressed: _submitForm,
  //                     style: ElevatedButton.styleFrom(
  //                       foregroundColor: Colors.white, backgroundColor: Colors.green,
  //                     ),
  //                     child: Text('Add Gift'),
  //                   ),
  //                 ),
  //               ],
  //             ),
  //           ],
  //         ),
  //       ),
  //     ),
  //   );
  // }
  //
  // Widget _buildTextField(String label, TextEditingController controller, {int maxLines = 1, TextInputType? keyboardType}) {
  //   return TextFormField(
  //     controller: controller,
  //     maxLines: maxLines,
  //     keyboardType: keyboardType,
  //     decoration: InputDecoration(
  //       labelText: label,
  //       border: OutlineInputBorder(
  //         borderRadius: BorderRadius.circular(10),
  //       ),
  //       filled: true,
  //       fillColor: Colors.grey[100],
  //     ),
  //     validator: (value) {
  //       if (value?.isEmpty ?? true) {
  //         return 'Please enter a $label';
  //       }
  //       if (keyboardType == TextInputType.number && double.tryParse(value!) == null) {
  //         return 'Please enter a valid number';
  //       }
  //       return null;
  //     },
  //   );
  // }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Add New Gift',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Theme.of(context).colorScheme.onPrimary),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
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
                Text('No image selected', style: TextStyle(color: Theme.of(context).hintColor)),
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
                style: ElevatedButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  backgroundColor: Theme.of(context).colorScheme.primary,
                ),
                child: const Text('Pick Image'),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        _saveDraft();
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Theme.of(context).colorScheme.onPrimary,
                        backgroundColor: Theme.of(context).colorScheme.secondary,
                      ),
                      child: const Text('Save Draft'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _submitForm,
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Theme.of(context).colorScheme.onPrimary,
                        backgroundColor: Theme.of(context).colorScheme.primary,
                      ),
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

  Widget _buildTextField(String label, TextEditingController controller, {int maxLines = 1, TextInputType? keyboardType}) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        filled: true,
        fillColor: Theme.of(context).colorScheme.surface,
        labelStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).hintColor),
      ),
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

  void _submitForm() async {
    if(widget.controller.event.syncAction == 'draft') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please publish the event before adding gifts')),
      );
      return;
    }
    if (_formKey.currentState?.validate() ?? false) {
      String? imageUrl = await widget.controller.uploadImage(_imageFile);
      try {
        FbGift gift = FbGift(
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
            const SnackBar(content: Text('Gift added successfully')),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error adding gift: ${e.toString()}')),
          );
        }
      }
    }
  }

  void _saveDraft() async {
    if (_formKey.currentState?.validate() ?? false) {
      String? imageUrl = await widget.controller.uploadImage(_imageFile);
      try {
        FbGift gift = FbGift(
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
            const SnackBar(content: Text('Gift draft added successfully')),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error saving draft: ${e.toString()}')),
          );
        }
      }
    }
  }
}


