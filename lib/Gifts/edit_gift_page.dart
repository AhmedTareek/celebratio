import 'package:flutter/material.dart';
import 'package:celebratio/Model/fb_gift.dart';

class EditGiftPage extends StatefulWidget {
  final FbGift gift;
  final Function(FbGift) onSave;

  const EditGiftPage({Key? key, required this.gift, required this.onSave}) : super(key: key);

  @override
  _EditGiftPageState createState() => _EditGiftPageState();
}

class _EditGiftPageState extends State<EditGiftPage> {
  late TextEditingController _nameController;
  late TextEditingController _priceController;
  late TextEditingController _descriptionController;
  late TextEditingController _categoryController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.gift.name);
    _priceController = TextEditingController(text: widget.gift.price.toString());
    _descriptionController = TextEditingController(text: widget.gift.description);
    _categoryController = TextEditingController(text: widget.gift.category);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  void _saveChanges() {
    widget.gift.name = _nameController.text;
    widget.gift.price = double.parse(_priceController.text);
    widget.gift.description = _descriptionController.text;
    widget.gift.category = _categoryController.text;

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
            onPressed: _saveChanges,
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
          ],
        ),
      ),
    );
  }
}
