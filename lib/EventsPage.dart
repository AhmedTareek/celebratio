import 'package:celebratio/CustomWidget.dart';
import 'package:celebratio/EventData.dart';
import 'package:celebratio/EventDetails.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';

import 'edit_event_page.dart';
import 'local_db.dart';

class EventsPage extends StatefulWidget {
  const EventsPage({super.key});

  @override
  State<EventsPage> createState() => _EventState();
}

class _EventState extends State<EventsPage> {
  final db = DataBase();
  int selectedButtonIndex = 0;
  final DateTime today = DateTime.now();

  // List<Map<String, dynamic>> allEvents = [];
  List<EventData> filteredEvents = [];
  List<EventData> allEvents = [];

  Future<void> fetchEvents() async {
    try {
      var temp = await db.getAllEvents();
      setState(() {
        allEvents = List<EventData>.from(temp);
        _filterEvents();
      });
    } catch (e) {
      // print('Error fetching events: $e');
    }
  }

  String sortType = "";

  void _filterEvents() {
    setState(() {
      filteredEvents = allEvents.where((event) {
        final date = event.date;
        if (selectedButtonIndex == 0) {
          return date.isBefore(today) && !_isSameDay(date, today);
        } else if (selectedButtonIndex == 1) {
          return _isSameDay(date, today);
        }
        return date.isAfter(today);
      }).toList();
      _sortEvents();
    });
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  void _sortEvents() {
    setState(() {
      if (sortType == "Category") {
        filteredEvents.sort((a, b) => a.category.compareTo(b.category));
      } else if (sortType == "Name") {
        filteredEvents.sort((a, b) => a.category.compareTo(b.category));
      }
    });
  }

  void _showOptionsDialog(int index) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Wrap(
          children: <Widget>[
            ListTile(
              leading: Icon(Icons.edit),
              title: Text('Edit'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditEventPage(event: filteredEvents[index]),
                  ),
                ).then((_) => fetchEvents()); // Refresh after editing
              },
            ),
            ListTile(
              leading: Icon(Icons.delete),
              title: Text('Delete'),
              onTap: () {
                try {
                  db.deleteEventById(filteredEvents[index].id!);
                  allEvents.remove(filteredEvents[index]);
                  setState(() {
                    _filterEvents();
                  });
                } catch (e) {
                  print('Error deleting event: $e');
                }
                print('deleted $index');
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  // void _addNewEvent() {
  //   final TextEditingController nameController = TextEditingController();
  //   final TextEditingController locationController = TextEditingController();
  //   final TextEditingController descriptionController = TextEditingController();
  //   final TextEditingController categoryController = TextEditingController();
  //   DateTime? selectedDate;
  //
  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         title: Text('Add New Event'),
  //         content: SingleChildScrollView(
  //           child: Column(
  //             mainAxisSize: MainAxisSize.min,
  //             children: [
  //               TextField(
  //                 controller: nameController,
  //                 decoration: InputDecoration(
  //                   labelText: 'Event Name',
  //                   border: OutlineInputBorder(),
  //                 ),
  //               ),
  //               SizedBox(height: 10),
  //               ElevatedButton(
  //                 onPressed: () async {
  //                   DateTime? pickedDate = await showDatePicker(
  //                     context: context,
  //                     initialDate: DateTime.now(),
  //                     firstDate: DateTime(2000),
  //                     lastDate: DateTime(2100),
  //                   );
  //                   if (pickedDate != null) {
  //                     selectedDate = pickedDate;
  //                   }
  //                 },
  //                 child: Text(
  //                   selectedDate == null
  //                       ? 'Select Event Date'
  //                       : 'Date: ${selectedDate!.toLocal()}'.split(' ')[0],
  //                 ),
  //               ),
  //               SizedBox(height: 10),
  //               TextField(
  //                 controller: locationController,
  //                 decoration: InputDecoration(
  //                   labelText: 'Location',
  //                   border: OutlineInputBorder(),
  //                 ),
  //               ),
  //               SizedBox(height: 10),
  //               TextField(
  //                 controller: descriptionController,
  //                 decoration: InputDecoration(
  //                   labelText: 'Description',
  //                   border: OutlineInputBorder(),
  //                 ),
  //                 maxLines: 3,
  //               ),
  //               SizedBox(height: 10),
  //               TextField(
  //                 controller: categoryController,
  //                 decoration: InputDecoration(
  //                   labelText: 'Category',
  //                   border: OutlineInputBorder(),
  //                 ),
  //               ),
  //             ],
  //           ),
  //         ),
  //         actions: [
  //           TextButton(
  //             onPressed: () {
  //               Navigator.pop(context); // Close the dialog without adding
  //             },
  //             child: Text('Cancel'),
  //           ),
  //           ElevatedButton(
  //             onPressed: () {
  //               if (nameController.text.isNotEmpty &&
  //                   selectedDate != null &&
  //                   locationController.text.isNotEmpty &&
  //                   descriptionController.text.isNotEmpty &&
  //                   categoryController.text.isNotEmpty) {
  //                 setState(() {
  //                   allEvents.add({
  //                     "name": nameController.text,
  //                     "date": selectedDate!,
  //                     "location": locationController.text,
  //                     "description": descriptionController.text,
  //                     "category": categoryController.text,
  //                   });
  //                   _filterEvents(); // Refresh the filtered list
  //                 });
  //                 Navigator.pop(context); // Close the dialog
  //               } else {
  //                 ScaffoldMessenger.of(context).showSnackBar(
  //                   SnackBar(content: Text('Please fill all fields')),
  //                 );
  //               }
  //             },
  //             child: Text('Add'),
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }

  void _addNewEvent() {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController locationController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();
    final TextEditingController categoryController = TextEditingController();
    DateTime? selectedDate;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add New Event'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Event Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () async {
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (pickedDate != null) {
                      selectedDate = pickedDate;
                    }
                  },
                  child: Text(
                    selectedDate == null
                        ? 'Select Event Date'
                        : 'Date: ${selectedDate!.toLocal()}'.split(' ')[0],
                  ),
                ),
                SizedBox(height: 10),
                TextField(
                  controller: locationController,
                  decoration: InputDecoration(
                    labelText: 'Location',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 10),
                TextField(
                  controller: descriptionController,
                  decoration: InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                SizedBox(height: 10),
                TextField(
                  controller: categoryController,
                  decoration: InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog without adding
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.isNotEmpty &&
                    selectedDate != null &&
                    locationController.text.isNotEmpty &&
                    descriptionController.text.isNotEmpty &&
                    categoryController.text.isNotEmpty) {
                  try {
                    var event = EventData(
                        name: nameController.text,
                        description: descriptionController.text,
                        date: selectedDate!,
                        location: locationController.text,
                        category: categoryController.text);
                    final response = await db.insertNewEvent(event);
                    if (response > 0) {
                      // Add to list if database insert was successful
                      setState(() {
                        allEvents.add(event);
                        _filterEvents(); // Refresh the filtered list
                      });
                      Navigator.pop(context); // Close the dialog
                      // Show success message
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Event added successfully')),
                      );
                    } else {
                      throw Exception('Failed to insert data');
                    }
                  } catch (e) {
                    print(e);
                    // Show error message if database operation fails
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text('Error adding event: ${e.toString()}')),
                    );
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Please fill all fields')),
                  );
                }
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }

  @override
  initState() {
    super.initState();
    fetchEvents();
    _filterEvents(); // Initialize filtered events
  }

  @override
  Widget build(BuildContext context) {
    return CustomWidget(
        newButton: NewButton(
            label: 'New Event',
            onPressed: () {
              _addNewEvent();
            }),
        filterButtons: [
          FilterButton(
              label: 'Past',
              onPressed: () {
                setState(() {
                  selectedButtonIndex = 0;
                  _filterEvents();
                });
              }),
          FilterButton(
              label: 'Current',
              onPressed: () {
                setState(() {
                  selectedButtonIndex = 1;
                  _filterEvents();
                });
              }),
          FilterButton(
            label: 'Upcoming',
            onPressed: () {
              setState(() {
                selectedButtonIndex = 2;
                _filterEvents();
              });
            },
          ),
        ],
        sortOptions: [
          SortOption(
              label: 'Name',
              onSelected: () {
                sortType = 'Name';
                _sortEvents();
              }),
          SortOption(
              label: 'Category',
              onSelected: () {
                sortType = 'Category';
                _sortEvents();
              })
        ],
        tileBuilder: (context, index) {
          final formatter = DateFormat('yyyy-MM-dd');
          final event = filteredEvents[index];
          return ListTile(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EventDetails(
                    eventData: event,
                  ),
                ),
              );
            },
            onLongPress: () => _showOptionsDialog(index),
            trailing: Text(formatter.format(DateTime.parse(event.date.toString()))),
            title: Text(event.name),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Ahmed Tarek'),
                Text('one line from the description ...')
              ],
            ),
          );
        },
        itemCount: filteredEvents.length);
  }
}

class SortDialog extends StatefulWidget {
  final int? initialSelection;

  const SortDialog({super.key, this.initialSelection});

  @override
  State<StatefulWidget> createState() {
    return _SortDialogState();
  }
}

class _SortDialogState extends State<SortDialog> {
  int? selectedButtonIndex;

  @override
  void initState() {
    super.initState();
    selectedButtonIndex = widget.initialSelection;
  }

  void clearSelection() {
    setState(() {
      selectedButtonIndex = -1;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Sort By'),
      content:
          const Text('Please choose one of the following options to sort by:'),
      actions: [
        // Using Wrap to handle multiple buttons
        Wrap(
          spacing: 8.0,
          children: List.generate(2, (index) {
            return TextButton(
              onPressed: () {
                setState(() {
                  // Toggle selection
                  selectedButtonIndex =
                      selectedButtonIndex == index ? null : index;
                });
              },
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all(
                  selectedButtonIndex == index
                      ? Theme.of(context)
                          .primaryColorLight //Colors.blue.withOpacity(0.2)
                      : Colors.transparent,
                ),
                // Add a nice ripple effect
                overlayColor: WidgetStateProperty.all(
                  Colors.blue.withOpacity(0.1),
                ),
                // Add padding for better touch target
                padding: WidgetStateProperty.all(
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
                // Add shape for better visual appeal
                shape: WidgetStateProperty.all(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(
                      color: selectedButtonIndex == index
                          ? Colors.blue
                          : Colors.transparent,
                    ),
                  ),
                ),
              ),
              child: Text(
                index == 0 ? 'Name' : 'Category',
                style: TextStyle(
                  color: selectedButtonIndex == index
                      ? Colors.blue
                      : Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton.icon(
              onPressed: selectedButtonIndex != null ? clearSelection : null,
              icon: const Icon(Icons.clear_all),
              label: const Text('Clear'),
              style: ButtonStyle(
                // Disable the button when nothing is selected
                foregroundColor: WidgetStateProperty.resolveWith<Color>(
                  (Set<WidgetState> states) {
                    if (states.contains(WidgetState.disabled)) {
                      return Colors.grey;
                    }
                    return Colors.red; // Red color when enabled
                  },
                ),
              ),
            ),
            Row(
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(null);
                  },
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    // Handle the selection
                    Navigator.of(context).pop(selectedButtonIndex);
                  },
                  child: const Text('Confirm'),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
