import 'package:celebratio/CustomWidget.dart';
import 'package:celebratio/EventDetails.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Events extends StatefulWidget {
  @override
  State<Events> createState() => _EventState();
}

class _EventState extends State<Events> {
  int selectedButtonIndex = 0;
  final DateTime today = DateTime.now();
  final List<Map<String, dynamic>> allEvents = [
    // Example events with name and date
    {"name": "Past Event", "date": DateTime(2024, 11, 20)},
    {
      "name": "Today's Event",
      "date": DateTime(
          DateTime.now().year, DateTime.now().month, DateTime.now().day)
    },
    {"name": "Upcoming Event", "date": DateTime(2024, 12, 5)},
    {"name": "A past Event", "date": DateTime(2024, 11, 15)},
  ];
  List<Map<String, dynamic>> filteredEvents = [];

  void _filterEvents() {
    setState(() {
      if (selectedButtonIndex == 0) {
        // Past
        filteredEvents = allEvents
            .where((event) =>
                event['date'].isBefore(today) &&
                !(event['date'].year == today.year &&
                    event['date'].month == today.month &&
                    event['date'].day == today.day))
            .toList();
      } else if (selectedButtonIndex == 1) {
        // Current
        filteredEvents = allEvents
            .where((event) =>
                event['date'].year == today.year &&
                event['date'].month == today.month &&
                event['date'].day == today.day)
            .toList();
      } else if (selectedButtonIndex == 2) {
        // Upcoming
        filteredEvents =
            allEvents.where((event) => event['date'].isAfter(today)).toList();
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
              },
            ),
            ListTile(
              leading: Icon(Icons.delete),
              title: Text('Delete'),
              onTap: () {
                print('deleted $index');
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _filterEvents(); // Initialize filtered events
  }

  @override
  Widget build(BuildContext context) {
    return CustomWidget(
        newButton: NewButton(label: 'New Event', onPressed: () {}),
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
        sortOptions: [SortOption(label: 'Name'), SortOption(label: 'Category')],
        tileBuilder: (context, index) {
          final formatter = DateFormat('yyyy-MM-dd');
          final event = filteredEvents[index];
          return ListTile(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      EventDetails(eventName: 'Wedding $index'),
                ),
              );
            },
            onLongPress: () => _showOptionsDialog(index),
            trailing: Text(formatter.format(event['date'])),
            title: Text(event['name']),
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
