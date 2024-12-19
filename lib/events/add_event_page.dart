import 'package:celebratio/Model/event.dart';
import 'package:celebratio/events/events_controller.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AddEventPage extends StatefulWidget {
  final EventsController controller;

  const AddEventPage({super.key, required this.controller});

  @override
  State<AddEventPage> createState() => _AddEventPageState();
}

class _AddEventPageState extends State<AddEventPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController categoryController = TextEditingController();
  DateTime? selectedDate;

  @override
  void dispose() {
    nameController.dispose();
    locationController.dispose();
    descriptionController.dispose();
    categoryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Add New Event',
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildTextField('Event Name', nameController),
            const SizedBox(height: 16),
            _buildDatePicker(theme),
            const SizedBox(height: 16),
            _buildTextField('Location', locationController),
            const SizedBox(height: 16),
            _buildTextField('Description', descriptionController,
                maxLines: 3),
            const SizedBox(height: 16),
            _buildTextField('Category', categoryController),
            const SizedBox(height: 24),
            _buildActionButtons(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildDatePicker(ThemeData theme) {
    return OutlinedButton(
      onPressed: () async {
        DateTime? pickedDate = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime.now(),
          lastDate: DateTime(2100),
          builder: (context, child) {
            return Theme(
              data: theme.copyWith(
                colorScheme: theme.colorScheme.copyWith(
                  primary: theme.primaryColor,
                  onPrimary: theme.colorScheme.onPrimary,
                  surface: theme.colorScheme.surface,
                  onSurface: theme.colorScheme.onSurface,
                ),
              ),
              child: child!,
            );
          },
        );
        if (pickedDate != null) {
          setState(() {
            selectedDate = pickedDate;
          });
        }
      },
      child: Text(
        selectedDate == null
            ? 'Select Event Date'
            : '${selectedDate!.toLocal()}'.split(' ')[0],
        // style: theme.textTheme.bodyLarge?.copyWith(
        //   color: Color(0xFFF4F6FF),
        // ),
      ),
    );
  }

  Widget _buildTextField(String labelText, TextEditingController controller,
      {int maxLines = 1}) {
    final theme = Theme.of(context);

    return TextField(
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
    );
  }

  Widget _buildActionButtons(ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Expanded(
          child: TextButton(
            onPressed: () => _saveDraft(context),
            child: const Text(
              'Save Draft',
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
            child: OutlinedButton(
                onPressed: () {
                  _saveEvent(context);
                },
                child: const Text(
                  'Save Event',
                ))),
      ],
    );
  }

  Future<void> _saveDraft(BuildContext context) async {
    if (nameController.text.isNotEmpty &&
        selectedDate != null &&
        locationController.text.isNotEmpty &&
        descriptionController.text.isNotEmpty &&
        categoryController.text.isNotEmpty) {
      try {
        FbEvent event = FbEvent(
          name: nameController.text,
          date: selectedDate!,
          location: locationController.text,
          description: descriptionController.text,
          category: categoryController.text,
          createdBy: FirebaseAuth.instance.currentUser!.uid,
          syncAction: 'draft',
        );
        await widget.controller.addEvent(event);
        if (context.mounted) {
          Navigator.pop(context, true);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Event draft added successfully',
              ),
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Error saving draft: ${e.toString()}',
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
              backgroundColor: Theme.of(context).colorScheme.errorContainer,
            ),
          );
        }
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please fill all fields',
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
          backgroundColor: Theme.of(context).colorScheme.errorContainer,
        ),
      );
    }
  }

  Future<void> _saveEvent(BuildContext context) async {
    if (nameController.text.isNotEmpty &&
        selectedDate != null &&
        locationController.text.isNotEmpty &&
        descriptionController.text.isNotEmpty &&
        categoryController.text.isNotEmpty) {
      try {
        FbEvent event = FbEvent(
          name: nameController.text,
          date: selectedDate!,
          location: locationController.text,
          description: descriptionController.text,
          category: categoryController.text,
          createdBy: FirebaseAuth.instance.currentUser!.uid,
        );
        await widget.controller.addEvent(event);
        if (context.mounted) {
          Navigator.pop(context, true);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Event added successfully',
              ),
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Error adding event: ${e.toString()}',
              ),
            ),
          );
        }
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please fill all fields',
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
          backgroundColor: Theme.of(context).colorScheme.errorContainer,
        ),
      );
    }
  }
}
