import 'package:celebratio/CustomWidget.dart';
import 'package:celebratio/Model/fb_event.dart';
import 'package:celebratio/event_details_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'add_event_page.dart';
import 'app_state.dart';
import 'edit_event_page.dart';


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

  String? currUid;


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

    friendsEvents = await appState.getEventsByFriendId(currUid!);
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
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddEventPage(),
      ),
    ).then((value) {
      if (value == true) {
        fetchEvents(); // Refresh the events list if a new event was added
      }
    });
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


