// import 'package:celebratio/Model/fb_gift.dart';
// import 'package:flutter/material.dart';
// import 'gift_controller.dart';
//
// class AddGiftPage extends StatefulWidget {
//   final GiftController controller;
//
//   const AddGiftPage({
//     super.key,
//     required this.controller,
//   });
//
//   @override
//   State<AddGiftPage> createState() => _AddGiftPageState();
// }
//
// class _AddGiftPageState extends State<AddGiftPage> {
//   final _formKey = GlobalKey<FormState>();
//   final _nameController = TextEditingController();
//   final _descriptionController = TextEditingController();
//   final _categoryController = TextEditingController();
//   final _priceController = TextEditingController();
//
//   @override
//   void dispose() {
//     _nameController.dispose();
//     _descriptionController.dispose();
//     _categoryController.dispose();
//     _priceController.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Add New Gift'),
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16),
//         child: Form(
//           key: _formKey,
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.stretch,
//             children: [
//               TextFormField(
//                 controller: _nameController,
//                 decoration: const InputDecoration(
//                   labelText: 'Name',
//                   border: OutlineInputBorder(),
//                 ),
//                 validator: (value) {
//                   if (value?.isEmpty ?? true) {
//                     return 'Please enter a name';
//                   }
//                   return null;
//                 },
//               ),
//               const SizedBox(height: 16),
//               TextFormField(
//                 controller: _descriptionController,
//                 decoration: const InputDecoration(
//                   labelText: 'Description',
//                   border: OutlineInputBorder(),
//                 ),
//                 validator: (value) {
//                   if (value?.isEmpty ?? true) {
//                     return 'Please enter a description';
//                   }
//                   return null;
//                 },
//               ),
//               const SizedBox(height: 16),
//               TextFormField(
//                 controller: _categoryController,
//                 decoration: const InputDecoration(
//                   labelText: 'Category',
//                   border: OutlineInputBorder(),
//                 ),
//                 validator: (value) {
//                   if (value?.isEmpty ?? true) {
//                     return 'Please enter a category';
//                   }
//                   return null;
//                 },
//               ),
//               const SizedBox(height: 16),
//               TextFormField(
//                 controller: _priceController,
//                 keyboardType: TextInputType.number,
//                 decoration: const InputDecoration(
//                   labelText: 'Price',
//                   border: OutlineInputBorder(),
//                 ),
//                 validator: (value) {
//                   if (value?.isEmpty ?? true) {
//                     return 'Please enter a price';
//                   }
//                   if (double.tryParse(value!) == null) {
//                     return 'Please enter a valid number';
//                   }
//                   return null;
//                 },
//               ),
//               const SizedBox(height: 24),
//               ElevatedButton(
//                 onPressed: () async {
//                   if (_formKey.currentState?.validate() ?? false) {
//                     try {
//                       FbGift gift = FbGift(
//                         id: '',
//                         eventId: '',
//                         name: _nameController.text,
//                         description: _descriptionController.text,
//                         category: _categoryController.text,
//                         price: double.parse(_priceController.text),
//                         status: 'Available',
//                         imageUrl: null,
//                       );
//                       await widget.controller.addGift(gift);
//                       if (mounted) {
//                         ScaffoldMessenger.of(context).showSnackBar(
//                           const SnackBar(
//                               content: Text('Gift added successfully')),
//                         );
//                         Navigator.pop(context);
//                       }
//                     } catch (e) {
//                       if (mounted) {
//                         ScaffoldMessenger.of(context).showSnackBar(
//                           SnackBar(
//                               content:
//                                   Text('Error adding gift: ${e.toString()}')),
//                         );
//                       }
//                     }
//                   }
//                 },
//                 child: const Text('Add Gift'),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'dart:io';
import 'dart:convert';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Gift'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Please enter a name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _categoryController,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Please enter a category';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Price',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Please enter a price';
                  }
                  if (double.tryParse(value!) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              if (_imageFile != null)
                Image.file(_imageFile!, height: 200)
              else
                const Text('No image selected'),
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
                child: const Text('Pick Image'),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState?.validate() ?? false) {
                    String? imageUrl =
                        await widget.controller.uploadImage(_imageFile);
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
                          const SnackBar(
                              content: Text('Gift added successfully')),
                        );
                        Navigator.pop(context);
                      }
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content:
                                  Text('Error adding gift: ${e.toString()}')),
                        );
                      }
                    }
                  }
                },
                child: const Text('Add Gift'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
