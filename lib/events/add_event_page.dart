// import 'package:celebratio/Model/fb_event.dart';
// import 'package:celebratio/events/events_controller.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
//
// class AddEventPage extends StatefulWidget {
//   final EventsController controller;
//
//   const AddEventPage({super.key, required this.controller});
//
//   @override
//   State<AddEventPage> createState() => _AddEventPageState();
// }
//
// class _AddEventPageState extends State<AddEventPage> {
//   final TextEditingController nameController = TextEditingController();
//   final TextEditingController locationController = TextEditingController();
//   final TextEditingController descriptionController = TextEditingController();
//   final TextEditingController categoryController = TextEditingController();
//   DateTime? selectedDate;
//
//   @override
//   void dispose() {
//     nameController.dispose();
//     locationController.dispose();
//     descriptionController.dispose();
//     categoryController.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Add New Event'),
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             TextField(
//               controller: nameController,
//               decoration: const InputDecoration(
//                 labelText: 'Event Name',
//                 border: OutlineInputBorder(),
//               ),
//             ),
//             const SizedBox(height: 16),
//             ElevatedButton(
//               onPressed: () async {
//                 DateTime? pickedDate = await showDatePicker(
//                   context: context,
//                   initialDate: DateTime.now(),
//                   firstDate: DateTime(2000),
//                   lastDate: DateTime(2100),
//                 );
//                 if (pickedDate != null) {
//                   setState(() {
//                     selectedDate = pickedDate;
//                   });
//                 }
//               },
//               child: Text(
//                 selectedDate == null
//                     ? 'Select Event Date'
//                     : '${selectedDate!.toLocal()}'.split(' ')[0],
//               ),
//             ),
//             const SizedBox(height: 16),
//             TextField(
//               controller: locationController,
//               decoration: const InputDecoration(
//                 labelText: 'Location',
//                 border: OutlineInputBorder(),
//               ),
//             ),
//             const SizedBox(height: 16),
//             TextField(
//               controller: descriptionController,
//               decoration: const InputDecoration(
//                 labelText: 'Description',
//                 border: OutlineInputBorder(),
//               ),
//               maxLines: 3,
//             ),
//             const SizedBox(height: 16),
//             TextField(
//               controller: categoryController,
//               decoration: const InputDecoration(
//                 labelText: 'Category',
//                 border: OutlineInputBorder(),
//               ),
//             ),
//             const SizedBox(height: 24),
//             ElevatedButton(
//               onPressed: () => _saveEvent(context),
//               child: const Text('Save Event'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Future<void> _saveEvent(BuildContext context) async {
//     if (nameController.text.isNotEmpty &&
//         selectedDate != null &&
//         locationController.text.isNotEmpty &&
//         descriptionController.text.isNotEmpty &&
//         categoryController.text.isNotEmpty) {
//       try {
//         FbEvent event = FbEvent(
//           name: nameController.text,
//           date: selectedDate!,
//           location: locationController.text,
//           description: descriptionController.text,
//           category: categoryController.text,
//           createdBy: FirebaseAuth.instance.currentUser!.uid,
//         );
//         await widget.controller.addEvent(event);
//         if (context.mounted) {
//           Navigator.pop(context, true); // Return true to indicate success
//         }
//         if (context.mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(content: Text('Event added successfully')),
//           );
//         }
//       } catch (e) {
//         if (context.mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content: Text('Error adding event: ${e.toString()}')),
//           );
//         }
//       }
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Please fill all fields')),
//       );
//     }
//   }
// }
import 'package:celebratio/Model/fb_event.dart';
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
    return Scaffold(
      appBar: AppBar(
        title: Text('Add New Event',
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(color: Theme.of(context).colorScheme.onPrimary)),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildTextField('Event Name', nameController),
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
              style: ElevatedButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                backgroundColor: Theme.of(context).colorScheme.primary,
              ),
              child: Text(
                selectedDate == null
                    ? 'Select Event Date'
                    : '${selectedDate!.toLocal()}'.split(' ')[0],
              ),
            ),
            const SizedBox(height: 16),
            _buildTextField('Location', locationController),
            const SizedBox(height: 16),
            _buildTextField('Description', descriptionController, maxLines: 3),
            const SizedBox(height: 16),
            _buildTextField('Category', categoryController),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _saveDraft(context),
                    style: ElevatedButton.styleFrom(
                      foregroundColor:
                          Theme.of(context).colorScheme.onSecondary,
                      backgroundColor: Theme.of(context).colorScheme.secondary,
                    ),
                    child: Text('Save Draft'),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _saveEvent(context),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                      backgroundColor: Theme.of(context).colorScheme.primary,
                    ),
                    child: Text('Save Event'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String labelText, TextEditingController controller,
      {int maxLines = 1}) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        filled: true,
        fillColor: Theme.of(context).colorScheme.surface,
        labelStyle: Theme.of(context)
            .textTheme
            .bodyMedium
            ?.copyWith(color: Theme.of(context).hintColor),
      ),
      maxLines: maxLines,
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
          Navigator.pop(context, true); // Return true to indicate success
        }
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Event draft added successfully')),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error saving draft: ${e.toString()}')),
          );
        }
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
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
          Navigator.pop(context, true); // Return true to indicate success
        }
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Event added successfully')),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error adding event: ${e.toString()}')),
          );
        }
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
    }
  }
}
