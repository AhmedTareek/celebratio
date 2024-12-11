import 'package:celebratio/CustomWidget.dart';
import 'package:celebratio/Model/fb_event.dart';
import 'package:celebratio/event_details_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'app_state.dart';
import 'edit_event_page.dart';
import 'Model/local_db.dart';

class EventsPage extends StatefulWidget {
  final String? userUid;
  final String? userDisplayName;

  const EventsPage({super.key, this.userUid, this.userDisplayName});

  @override
  State<EventsPage> createState() => _EventState();
}

class _EventState extends State<EventsPage> {
  final loggedInUserId = FirebaseAuth.instance.currentUser!.uid;
  int selectedButtonIndex = 0;
  String sortType = "";
  final DateTime today = DateTime.now();
  List<FbEvent> filteredEvents = [];
  List<FbEvent> allEvents = [];

  // var user =  FirebaseAuth.instance.currentUser!;
  var currUid;


  @override
  initState() {
    super.initState();
    fetchEvents();
    _filterEvents(); // Initialize filtered events
  }

  @override
  Widget build(BuildContext context) {
    return CustomWidget(
        title: _setAppBarTitle(),
        // disable new button for events not created by the logged in user
        newButton: currUid == loggedInUserId
            ? NewButton(
                label: 'New Event',
                onPressed: () {
                  _addNewEvent();
                })
            : null,
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
            // disable long press for events not created by the logged in user
            onLongPress: currUid == loggedInUserId
                ? () => _showOptionsDialog(index)
                : null,
            trailing:
                Text(formatter.format(DateTime.parse(event.date.toString()))),
            title: Text(event.name),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(event.id.toString()),
                Text(event.description,
                    maxLines: 1, overflow: TextOverflow.ellipsis),
              ],
            ),
          );
        },
        itemCount: filteredEvents.length);
  }



  Future<void> fetchEvents() async {
    List<FbEvent> friendsEvents;
    var appState = Provider.of<ApplicationState>(context, listen: false);

    if (currUid == null) {
      if (widget.userUid != null) {
        currUid = widget.userUid;
      } else {
        currUid = FirebaseAuth.instance.currentUser!.uid;
      }
    }

    friendsEvents = await appState.getEventsByFriendId(currUid);
    setState(() {
      allEvents = friendsEvents.toList();
      _filterEvents();
    });
  }

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
              leading: const Icon(Icons.edit),
              title: const Text('Edit'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        EditEventPage(event: filteredEvents[index]),
                  ),
                ).then((_) => fetchEvents()); // Refresh after editing
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete),
              title: const Text('Delete'),
              onTap: () {
                try {
                  var appState =
                  Provider.of<ApplicationState>(context, listen: false);
                  appState.deleteEvent(eventId: filteredEvents[index].id);
                  allEvents.remove(filteredEvents[index]);
                  _filterEvents();
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
          title: const Text('Add New Event'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Event Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
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
                    var appState =
                    Provider.of<ApplicationState>(context, listen: false);
                    await appState.addEvent(
                        name: nameController.text,
                        description: descriptionController.text,
                        date: selectedDate!,
                        location: locationController.text,
                        category: categoryController.text);
                    // final response = await db.insertNewEvent(event);

                    // Add to list if database insert was successful
                    setState(() {
                      // allEvents.add(event);
                      fetchEvents(); // Refresh the filtered list
                    });
                    Navigator.pop(context); // Close the dialog
                    // Show success message
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Event added successfully')),
                    );
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

  String _setAppBarTitle() {
    if (currUid == null) {
      return 'Events';
    }
    if (currUid == loggedInUserId) {
      return 'My Events';
    }
    return widget.userDisplayName ?? '' + "'s Events";
  }

}
