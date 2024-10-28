import 'package:flutter/material.dart';

class GiftDetails extends StatefulWidget {
  const GiftDetails({super.key});

  @override
  State<StatefulWidget> createState() => _GiftDetailsState();
}

class _GiftDetailsState extends State<GiftDetails> {
  bool isEditing = false;
  final TextEditingController _nameController =
      TextEditingController(text: 'Gift Name');
  final TextEditingController _priceController =
      TextEditingController(text: '32');
  final TextEditingController _descriptionController = TextEditingController(
    text:
        'Elden Ring is a 2022 action role-playing game developed by FromSoftware...',
  );
  String? _selectedCategory = 'Electronics';

  void toggleEditMode() {
    setState(() {
      isEditing = !isEditing;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: isEditing
          ? AppBar(
              title: const Text('Edit Gift'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.save),
                  onPressed: () {
                    // Save changes and exit edit mode
                    toggleEditMode();
                  },
                ),
              ],
            )
          : null,
      floatingActionButton: !isEditing
          ? FloatingActionButton(
              onPressed: toggleEditMode,
              child: Icon(Icons.edit),
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
                  Positioned(
                    top: 16,
                    left: 16,
                    child: CircleAvatar(
                      backgroundColor:
                          theme.colorScheme.onBackground.withOpacity(0.7),
                      child: IconButton(
                        icon: Icon(Icons.arrow_back,
                            color: theme.colorScheme.primary),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                    ),
                  ),
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
                                  labelText: 'Gift Name',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                              const SizedBox(height: 8.0),
                              // Add some space between the fields
                              DropdownMenu(
                                label: const Text('Category'),
                                onSelected: (value) {
                                  _selectedCategory = value;
                                  setState(() {});
                                },
                                dropdownMenuEntries: const [
                                  DropdownMenuEntry(
                                      value: 'Electronics',
                                      label: 'Electronics'),
                                  DropdownMenuEntry(
                                      value: 'Books', label: 'Books'),
                                  DropdownMenuEntry(
                                      value: 'Other', label: 'Other'),
                                ],
                              ),
                            ],
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _nameController.text,
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                _selectedCategory ?? 'Category',
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
                              decoration: InputDecoration(
                                labelText: 'Price',
                                border: OutlineInputBorder(),
                                prefixText: '\$',
                              ),
                            ),
                          )
                        : Text(
                            '\$${_priceController.text}',
                            style: theme.textTheme.titleLarge?.copyWith(
                              color: theme.colorScheme.secondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                    if (!isEditing)
                      CircleAvatar(
                        backgroundColor: Colors.green,
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
                        decoration: InputDecoration(
                          labelText: 'Description',
                          border: OutlineInputBorder(),
                        ),
                        style: theme.textTheme.bodyMedium,
                      )
                    : Text(
                        _descriptionController.text,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.8),
                        ),
                        textAlign: TextAlign.justify,
                      ),
              ),
              if (!isEditing)
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
                        onPressed: () {},
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
}
