import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app_state.dart';

class AddEventPage extends StatefulWidget {
  const AddEventPage({super.key});

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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Event'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Event Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                );
                if (pickedDate != null) {
                  setState(() {
                    selectedDate = pickedDate;
                  });
                }
              },
              child: Text(
                selectedDate == null ? 'Select Event Date' : '$selectedDate',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: locationController,
              decoration: const InputDecoration(
                labelText: 'Location',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: categoryController,
              decoration: const InputDecoration(
                labelText: 'Category',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => _saveEvent(context),
              child: const Text('Save Event'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveEvent(BuildContext context) async {
    if (nameController.text.isNotEmpty &&
        selectedDate != null &&
        locationController.text.isNotEmpty &&
        descriptionController.text.isNotEmpty &&
        categoryController.text.isNotEmpty) {
      try {
        var appState = Provider.of<ApplicationState>(context, listen: false);
        await appState.addEvent(
          name: nameController.text,
          description: descriptionController.text,
          date: selectedDate!,
          location: locationController.text,
          category: categoryController.text,
        );

        Navigator.pop(context, true); // Return true to indicate success

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Event added successfully')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding event: ${e.toString()}')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
    }
  }
}
