import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../Model/event.dart';
import '../Model/fb_event.dart';
import '../Model/local_db.dart';
import '../app_state.dart';

class EditEventPage extends StatefulWidget {
  final FbEvent event;

  const EditEventPage({super.key, required this.event});

  @override
  State<EditEventPage> createState() => _EditEventPageState();
}

class _EditEventPageState extends State<EditEventPage> {
  final _formKey = GlobalKey<FormState>();
  late String name;
  late String description;
  late DateTime date;
  late String location;
  late String category;

  @override
  void initState() {
    super.initState();
    name = widget.event.name;
    description = widget.event.description;
    date = widget.event.date;
    location = widget.event.location;
    category = widget.event.category;
  }

  void _updateEvent() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      var appState = Provider.of<ApplicationState>(context, listen: false);
      await appState.editEvent(eventId: widget.event.id, updatedData: {
        'name': name,
        'description': description,
        'date': date.toIso8601String(),
        'location': location,
        'category': category,
      });

      if (mounted) {
        Navigator.pop(context); // Return to the previous screen
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Event')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                initialValue: name,
                decoration: const InputDecoration(labelText: 'Name'),
                onSaved: (value) => name = value!,
                validator: (value) =>
                    value!.isEmpty ? 'Name cannot be empty' : null,
              ),
              TextFormField(
                initialValue: description,
                decoration: const InputDecoration(labelText: 'Description'),
                onSaved: (value) => description = value!,
                validator: (value) =>
                    value!.isEmpty ? 'Description cannot be empty' : null,
              ),
              // Date picker field
              ListTile(
                title: const Text('Date'),
                subtitle: Text(DateFormat.yMd().format(date)),
                onTap: () async {
                  final newDate = await showDatePicker(
                    context: context,
                    initialDate: date,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (newDate != null) {
                    setState(() {
                      date = newDate;
                    });
                  }
                },
              ),
              TextFormField(
                initialValue: location,
                decoration: const InputDecoration(labelText: 'Location'),
                onSaved: (value) => location = value!,
                validator: (value) =>
                    value!.isEmpty ? 'Location cannot be empty' : null,
              ),
              TextFormField(
                initialValue: category,
                decoration: const InputDecoration(labelText: 'Category'),
                onSaved: (value) => category = value!,
                validator: (value) =>
                    value!.isEmpty ? 'Category cannot be empty' : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _updateEvent,
                child: const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
