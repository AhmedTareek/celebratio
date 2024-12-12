import 'package:celebratio/CustomWidget.dart';
import 'package:celebratio/event_details_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'add_event_page.dart';
import 'edit_event_page.dart';
import 'events_controller.dart';

class EventsPage extends StatefulWidget {
  final String? userUid;
  final String? userDisplayName;

  const EventsPage({super.key, this.userUid, this.userDisplayName});

  @override
  State<EventsPage> createState() => _EventState();
}

class _EventState extends State<EventsPage> {
  late EventsController _controller;
  final loggedInUserId = FirebaseAuth.instance.currentUser!.uid;

  @override
  void initState() {
    super.initState();
    _controller = EventsController(context: context, userUid: widget.userUid);
    _controller.init();
    _controller.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomWidget(
      title: _setAppBarTitle(),
      newButton: widget.userUid == loggedInUserId
          ? NewButton(
              label: 'New Event',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddEventPage(
                      controller: _controller,
                    ),
                  ),
                ).then((value) {
                  if (value == true) {
                    _controller.fetchEvents();
                  }
                });
              },
            )
          : null,
      filterButtons: [
        FilterButton(
          label: 'Past',
          onPressed: () => _controller.updateFilter(0),
        ),
        FilterButton(
          label: 'Current',
          onPressed: () => _controller.updateFilter(1),
        ),
        FilterButton(
          label: 'Upcoming',
          onPressed: () => _controller.updateFilter(2),
        ),
      ],
      sortOptions: [
        SortOption(
          label: 'Name',
          onSelected: () => _controller.updateSortType('Name'),
        ),
        SortOption(
          label: 'Category',
          onSelected: () => _controller.updateSortType('Category'),
        ),
      ],
      tileBuilder: (context, index) {
        final formatter = DateFormat('yyyy-MM-dd');
        final event = _controller.filteredEvents[index];
        return ListTile(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => EventDetails(eventData: event),
              ),
            );
          },
          onLongPress: widget.userUid == loggedInUserId
              ? () => _showOptionsDialog(index)
              : null,
          trailing: Text(formatter.format(event.date)),
          title: Text(event.name),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(event.id!),
              Text(
                event.description,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        );
      },
      itemCount: _controller.filteredEvents.length,
    );
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
                    builder: (context) => EditEventPage(
                      event: _controller.filteredEvents[index],
                      controller: _controller,
                    ),
                  ),
                ).then((_) => _controller.fetchEvents());
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete),
              title: const Text('Delete'),
              onTap: () async {
                try {
                  await _controller.deleteEvent(
                    _controller.filteredEvents[index].id!,
                  );
                  if (context.mounted) {
                    Navigator.pop(context);
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error deleting event: $e')),
                    );
                  }
                }
              },
            ),
          ],
        );
      },
    );
  }

  String _setAppBarTitle() {
    if (widget.userUid == null) {
      return 'Events';
    }
    if (widget.userUid == loggedInUserId) {
      return 'My Events';
    }
    return '${widget.userDisplayName ?? ""}\'s Events';
  }
}
