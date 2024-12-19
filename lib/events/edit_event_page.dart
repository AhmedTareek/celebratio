import 'package:celebratio/events/events_controller.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../Model/event.dart';

class EditEventPage extends StatefulWidget {
  final FbEvent event;
  final EventsController controller;

  const EditEventPage({super.key, required this.event, required this.controller});

  @override
  State<EditEventPage> createState() => _EditEventPageState();
}

class _EditEventPageState extends State<EditEventPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController categoryController = TextEditingController();
  late DateTime selectedDate;

  @override
  void initState() {
    super.initState();
    nameController.text = widget.event.name;
    descriptionController.text = widget.event.description;
    selectedDate = widget.event.date;
    locationController.text = widget.event.location;
    categoryController.text = widget.event.category;
  }

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
          'Edit Event',
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
              _buildTextField('Event Name', nameController),
              const SizedBox(height: 16),
              _buildDatePicker(theme),
              const SizedBox(height: 16),
              _buildTextField('Location', locationController),
              const SizedBox(height: 16),
              _buildTextField('Description', descriptionController, maxLines: 3),
              const SizedBox(height: 16),
              _buildTextField('Category', categoryController),
              const SizedBox(height: 24),
              _buildActionButtons(theme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDatePicker(ThemeData theme) {
    return OutlinedButton(
      onPressed: () async {
        final newDate = await showDatePicker(
          context: context,
          initialDate: selectedDate,
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
        if (newDate != null) {
          setState(() {
            selectedDate = newDate;
          });
        }
      },
      child: Text(
        DateFormat.yMd().format(selectedDate),
      ),
    );
  }

  Widget _buildTextField(String labelText, TextEditingController controller,
      {int maxLines = 1}) {
    final theme = Theme.of(context);

    return TextFormField(
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
      validator: (value) => value!.isEmpty ? '$labelText cannot be empty' : null,
    );
  }

  Widget _buildActionButtons(ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Expanded(
          child: TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: Colors.red[800])),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: OutlinedButton(
            onPressed: _updateEvent,
            child: const Text('Save Changes'),
          ),
        ),
      ],
    );
  }

  void _updateEvent() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      try {
        FbEvent updatedEvent = FbEvent(
          id: widget.event.id,
          name: nameController.text,
          description: descriptionController.text,
          date: selectedDate,
          location: locationController.text,
          category: categoryController.text,
          createdBy: widget.event.createdBy,
        );
        await widget.controller.updateEvent(updatedEvent);

        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Event updated successfully',
                style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
              ),
              backgroundColor: Theme.of(context).colorScheme.surface,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Error updating event: ${e.toString()}',
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
              backgroundColor: Theme.of(context).colorScheme.errorContainer,
            ),
          );
        }
      }
    }
  }
}