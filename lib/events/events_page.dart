import 'package:celebratio/smart_widget.dart';
import '/Gifts/gift_list_page.dart';
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
    var draftTextStyle = TextStyle(
      color: Colors.grey[600],
    );
    return SmartWidget(
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
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(12), // Reduced radius for subtlety
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => GiftList(eventData: event),
              ),
            );
          },
          onLongPress: widget.userUid == loggedInUserId
              ? () => _showOptionsDialog(index)
              : null,
          title: Text(
            event.name,
            style: event.syncAction == 'draft'
                ? draftTextStyle
                : const TextStyle(
                    fontSize: 16, // Slightly reduced size
                    fontWeight: FontWeight.w600, // Less bold
                  ),
          ),
          subtitle: event.syncAction == 'draft'
              ? Text(
                  'This is a draft event',
                  style: draftTextStyle,
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.description,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(event.category),
                  ],
                ),
          trailing: Text(
            formatter.format(event.date),
            style: event.syncAction == 'draft' ? draftTextStyle : null,
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
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Event deleted')),
                    );
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
    if (widget.userUid == null || widget.userUid == loggedInUserId) {
      return 'My Events';
    }
    return '${widget.userDisplayName ?? ""}\'s Events';
  }
}
