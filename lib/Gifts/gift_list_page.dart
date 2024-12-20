import 'package:celebratio/Model/event.dart';
import 'package:celebratio/Gifts/gift_details_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../smart_widget.dart';
import 'add_gift_page.dart';
import 'gift_controller.dart';

class GiftList extends StatefulWidget {
  final FbEvent eventData;

  const GiftList({super.key, required this.eventData});

  @override
  State<StatefulWidget> createState() => _GiftListState();
}

class _GiftListState extends State<GiftList> {
  late GiftController _controller;
  final loggedInUserId = FirebaseAuth.instance.currentUser!.uid;
  late bool isGiftInPastEvent;

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  @override
  void initState() {
    super.initState();
    final eventDate = widget.eventData.date;
    isGiftInPastEvent = eventDate.isBefore(DateTime.now()) &&
        !_isSameDay(eventDate, DateTime.now());
    _controller = GiftController(
      context: context,
      event: widget.eventData,
    );
    _controller.init();
    _controller.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _addNewGift() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddGiftPage(
          controller: _controller,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SmartWidget(
      title: _controller.currentEvent.name,
      topWidget: EventCard(
        name: _controller.currentEvent.name,
        location: _controller.currentEvent.location,
        date: _controller.currentEvent.date.toString().split(' ')[0],
        description: _controller.currentEvent.description,
        createdBy: _controller.currentEventCreatorName ?? '',
        isDraft: _controller.currentEvent.syncAction == 'draft',
        onPublish: _controller.currentEvent.syncAction == 'draft'
            ? () async {
                try {
                  // Publish the event
                  await _controller.publishEvent();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Event published successfully'),
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error publishing event: $e'),
                      ),
                    );
                  }
                }
              }
            : null,
      ),
      filterButtons: [
        FilterButton(
          label: 'All',
          onPressed: () => _controller.updateFilter('All'),
        ),
        FilterButton(
          label: 'Available',
          onPressed: () => _controller.updateFilter('Available'),
        ),
        FilterButton(
          label: 'Pledged',
          onPressed: () => _controller.updateFilter('Pledged'),
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
      onClearSortOptionsSelected: _controller.clearSort,
      tileBuilder: (context, idx) {
        final gift = _controller.filteredGifts[idx];
        final pledgerName = _controller.getPledgerName(gift.pledgedBy);
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: ListTile(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => GiftDetails(
                    event: _controller.currentEvent,
                    controller: _controller,
                    giftId: gift.id,
                  ),
                ),
              ).then((_) => _controller.fetchGifts());
            },
            onLongPress: _controller.currentEvent.createdBy == loggedInUserId
                ? () {
                    if (gift.status == 'Available') {
                      showModalBottomSheet(
                        context: context,
                        builder: (BuildContext context) {
                          return Wrap(
                            children: <Widget>[
                              ListTile(
                                leading: const Icon(Icons.delete),
                                title: const Text('Delete'),
                                onTap: () async {
                                  try {
                                    bool result =
                                        await _controller.deleteGift(gift.id);
                                    if (result && context.mounted) {
                                      Navigator.pop(context);
                                    } else if (context.mounted) {
                                      Navigator.pop(context);
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                              'Error deleting gift you may be'
                                              ' offline or the gift is already pledged'),
                                        ),
                                      );
                                    }
                                  } catch (e) {
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content:
                                              Text('Error deleting gift: $e'),
                                        ),
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
                  }
                : null,
            title: gift.syncAction == 'draft'
                ? Text(
                    gift.name,
                    style: TextStyle(
                        color: Colors.grey[600], fontWeight: FontWeight.normal),
                  )
                : Text(gift.name,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: gift.syncAction == 'draft'
                ? Text(
                    'This is a draft',
                    style: TextStyle(
                        color: Colors.grey[600], fontWeight: FontWeight.normal),
                  )
                : Text(
                    pledgerName == null
                        ? 'No one has pledged yet'
                        : 'Pledged by: $pledgerName',
                  ),
            trailing: gift.syncAction == 'draft'
                ? null
                : Stack(
                    alignment: Alignment.center,
                    children: [
                      CircleAvatar(
                        radius: 9,
                        backgroundColor: gift.status == 'Available'
                            ? Colors.green
                            : Colors.red,
                      ),
                    ],
                  ),
          ),
        );
      },
      itemCount: _controller.filteredGifts.length,
      newButton: _controller.currentEvent.createdBy == loggedInUserId &&
              !isGiftInPastEvent
          ? NewButton(
              label: 'New Gift',
              onPressed: _addNewGift,
            )
          : null,
    );
  }
}

class EventCard extends StatelessWidget {
  final String name;
  final String location;
  final String date;
  final String description;
  final String createdBy;
  final bool isDraft;
  final VoidCallback? onPublish;

  const EventCard({
    super.key,
    required this.name,
    required this.location,
    required this.date,
    required this.description,
    required this.createdBy,
    this.isDraft = false,
    this.onPublish,
  });

  @override
  Widget build(BuildContext context) {
    // Define colors from palette
    const Color darkBlue = Color(0xFF10375C);
    const Color yellow = Color(0xFFF3C623);
    const Color lightBlue = Color(0xFFF4F6FF);

    return Card(
      elevation: 4,
      color: darkBlue,
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: yellow,
                    ),
                  ),
                ),
                if (isDraft)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: yellow.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'DRAFT',
                      style: TextStyle(
                        color: yellow,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.location_on, color: yellow),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    location,
                    style: const TextStyle(color: lightBlue, fontSize: 16),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.calendar_today, color: yellow),
                const SizedBox(width: 8),
                Text(
                  date,
                  style: const TextStyle(color: lightBlue, fontSize: 16),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              description,
              style: const TextStyle(
                color: lightBlue,
                fontSize: 16,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (!isDraft)
                  Text(
                    createdBy,
                    style: TextStyle(
                      color: lightBlue.withOpacity(0.7),
                      fontSize: 14,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                if (isDraft && onPublish != null)
                  ElevatedButton.icon(
                    onPressed: onPublish,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: lightBlue,
                      foregroundColor: darkBlue,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    icon: const Icon(Icons.publish, color: darkBlue),
                    label: const Text(
                      'Publish Event',
                      style: TextStyle(color: darkBlue),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
