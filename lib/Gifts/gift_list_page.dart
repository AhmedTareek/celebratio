import 'package:celebratio/Model/fb_event.dart';
import 'package:celebratio/Gifts/gift_details_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../CustomWidget.dart';
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

  @override
  void initState() {
    super.initState();
    _controller = GiftController(
      context: context,
      event: widget.eventData,
    );
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
    return CustomWidget(
      title: _controller.currentEvent.name,
      topWidget: EventCard(
        name: _controller.currentEvent.name,
        location: _controller.currentEvent.location,
        date: _controller.currentEvent.date.toString().split(' ')[0],
        description: _controller.currentEvent.description,
        createdBy: _controller.currentEventCreatorName ?? '',
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
        final pledgerName = _controller.giftPledgerNames[idx];
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: ListTile(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => GiftDetails(
                    controller: _controller,
                    gift: gift,
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
            title: Text(gift.name),
            subtitle: Text(
              pledgerName.isEmpty
                  ? 'No one has pledged yet'
                  : 'Pledged by: $pledgerName',
            ),
            trailing: Stack(
              alignment: Alignment.center,
              children: [
                CircleAvatar(
                  radius: 5,
                  backgroundColor:
                      gift.status == 'Available' ? Colors.green : Colors.red,
                ),
              ],
            ),
          ),
        );
      },
      itemCount: _controller.filteredGifts.length,
      newButton: _controller.currentEvent.createdBy == loggedInUserId
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

  const EventCard({
    super.key,
    required this.name,
    required this.location,
    required this.date,
    required this.description,
    required this.createdBy,
  });

  @override
  Widget build(BuildContext context) {
    var textColor = Colors.white;
    var iconsColor = Colors.white;
    //var textColor = Color(0xFF10375C);
    return Card(
      color: Theme.of(context).primaryColor,
      //Color(0xFFF3C623), // Yellow background color for the card
      margin: EdgeInsets.all(16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              name,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(
                    0xFFF3C623), //Color(0xFFEB8317), // Orange color for the title
              ),
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.location_on, color: iconsColor),
                SizedBox(width: 8),
                Text(
                  location,
                  style: TextStyle(color: textColor),
                ),
              ],
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.calendar_today, color: iconsColor),
                SizedBox(width: 8),
                Text(
                  date,
                  style: TextStyle(color: textColor),
                ),
              ],
            ),
            SizedBox(height: 16),
            Text(
              description,
              style: TextStyle(
                color: textColor, // Dark blue color for the description
              ),
            ),
            SizedBox(height: 16),
            // Divider(color: Color(0xFF10375C).withOpacity(0.3)), // Divider for separation
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                '$createdBy',
                style: TextStyle(
                  color: textColor.withOpacity(0.7),
                  // Slightly lighter blue
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
