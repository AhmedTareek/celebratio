import 'package:celebratio/globals.dart';
import 'package:flutter/material.dart';

import 'Model/gift.dart';
import 'Model/local_db.dart';

class GiftDetails extends StatefulWidget {
  final Gift gift;
  final int giftOwnerId;

  const GiftDetails({super.key, required this.gift, required this.giftOwnerId});

  @override
  State<StatefulWidget> createState() => _GiftDetailsState();
}

class _GiftDetailsState extends State<GiftDetails> {
  final db = DataBase();
  bool isEditing = false;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();

  void toggleEditMode() {
    var gift = widget.gift;
    setState(() {
      isEditing = !isEditing;
      _nameController.text = gift.name;
      _priceController.text = gift.price.toString();
      _descriptionController.text = gift.description;
      _categoryController.text = gift.category;
    });
  }

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.gift.name;
    _priceController.text = widget.gift.price.toString();
    _descriptionController.text = widget.gift.description;
    _categoryController.text = widget.gift.category;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    var gift = widget.gift;
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: isEditing
          ? AppBar(
              leading: IconButton(
                icon: const Icon(Icons.close),
                onPressed: toggleEditMode,
              ),
              title: const Text('Edit Gift'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.save),
                  onPressed: () async {
                    await _saveChanges(gift);
                  },
                ),
              ],
            )
          : null,
      floatingActionButton: !isEditing &&
              widget.giftOwnerId == loggedInUserId &&
              widget.gift.status == 'Available'
          ? FloatingActionButton(
              onPressed: toggleEditMode,
              child: const Icon(Icons.edit),
            )
          : null,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  Image.network(
                    'https://platform.vox.com/wp-content/uploads/sites/2/chorus/uploads/chorus_asset/file/23324816/elden_1.png?quality=90&strip=all&crop=7.8125,0,84.375,100',
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: 250,
                  ),
                  !isEditing
                      ? Positioned(
                          top: 16,
                          left: 16,
                          child: CircleAvatar(
                            backgroundColor:
                                theme.colorScheme.onSurface.withOpacity(0.7),
                            child: IconButton(
                              icon: Icon(Icons.arrow_back,
                                  color: theme.colorScheme.primary),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                            ),
                          ),
                        )
                      : Container(),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    isEditing
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TextField(
                                controller: _nameController,
                                decoration: const InputDecoration(
                                  labelText: 'Name',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                              const SizedBox(height: 8.0),
                              // Add some space between the fields
                              TextField(
                                controller: _categoryController,
                                decoration: const InputDecoration(
                                  labelText: 'Category',
                                  border: OutlineInputBorder(),
                                ),
                              )
                            ],
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                gift.name,
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                gift.category,
                                style: theme.textTheme.bodyMedium,
                              ),
                            ],
                          ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    isEditing
                        ? Expanded(
                            child: TextField(
                              controller: _priceController,
                              keyboardType: TextInputType.number,
                              style: theme.textTheme.titleLarge?.copyWith(
                                color: theme.colorScheme.secondary,
                              ),
                              decoration: const InputDecoration(
                                labelText: 'Price',
                                border: OutlineInputBorder(),
                                prefixText: '\$',
                              ),
                            ),
                          )
                        : Text(
                            '\$${gift.price.toString()}',
                            style: theme.textTheme.titleLarge?.copyWith(
                              color: theme.colorScheme.secondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                    if (!isEditing)
                      CircleAvatar(
                        backgroundColor: gift.status == 'Available'
                            ? Colors.green
                            : Colors.red,
                        radius: 15,
                      ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: isEditing
                    ? TextField(
                        controller: _descriptionController,
                        maxLines: 6,
                        decoration: const InputDecoration(
                          labelText: 'Description',
                          border: OutlineInputBorder(),
                        ),
                        style: theme.textTheme.bodyMedium,
                      )
                    : Text(
                        gift.description,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.8),
                        ),
                        textAlign: TextAlign.justify,
                      ),
              ),
              if (!isEditing &&
                  widget.giftOwnerId != loggedInUserId &&
                  widget.gift.status == 'Available')
                Container(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 20.0),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.all(16),
                          backgroundColor: theme.colorScheme.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: () async {
                          Gift updatedGift = gift.copyWith(
                            status: 'Pledged',
                            pledgerId: loggedInUserId,
                          );
                          await db.updateGift(updatedGift);
                          setState(() {
                            widget.gift.status = 'Pledged';
                            widget.gift.pledgerId = loggedInUserId;
                          });
                        },
                        child: Text(
                          'Pledge This Gift',
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: theme.colorScheme.onPrimary,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _saveChanges(Gift gift) async {
    Gift updatedGift = gift.copyWith(
      name: _nameController.text,
      price: double.parse(_priceController.text),
      description: _descriptionController.text,
      category: _categoryController.text,
    );
    await db.updateGift(updatedGift);
    widget.gift.name = _nameController.text;
    widget.gift.price = double.parse(_priceController.text);
    widget.gift.description = _descriptionController.text;
    widget.gift.category = _categoryController.text;
    toggleEditMode();
  }
}
