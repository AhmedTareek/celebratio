import 'package:celebratio/EventData.dart';
import 'package:celebratio/GiftDetails.dart';
import 'package:flutter/material.dart';
import 'CustomWidget.dart';

class EventDetails extends StatefulWidget {
  final EventData eventData;

  const EventDetails({super.key, required this.eventData});

  @override
  State<StatefulWidget> createState() {
    return _EventDetailsState();
  }
}

class _EventDetailsState extends State<EventDetails> {




  @override
  Widget build(BuildContext context) {
    var currentEvent = widget.eventData;
    return CustomWidget(
      title: currentEvent.name,
      topWidget: EventCard(
          name: currentEvent.name,
          location: currentEvent.location,
          date: currentEvent.date.toString(),
          description: currentEvent.description,
          createdBy: 'createdBy'),
      filterButtons: [
        FilterButton(label: 'All'),
        FilterButton(label: 'Available'),
        FilterButton(label: 'Pledged'),
      ],
      sortOptions: [
        SortOption(label: 'Name'),
        SortOption(label: 'category'),
      ],
      tileBuilder: (context, idx) {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: ListTile(
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => GiftDetails()));
            },
            onLongPress: () {
              if (idx % 4 == 0) {
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
                            Navigator.pop(context);
                          },
                        ),
                      ],
                    );
                  },
                );
              }
            },
            title: Text(
              'Gift Name $idx',
            ),
            subtitle: idx % 4 != 0 ? Text('Sarah pledged this gift') : null,
            trailing: Stack(
              alignment: Alignment.center,
              children: [
                CircleAvatar(
                  radius: 5,
                  backgroundColor: idx % 4 == 0 ? Colors.green : Colors.red,
                ),
              ],
            ),
          ),
        );
      },
      itemCount: 25,
      newButton: NewButton(label: 'New Gift', onPressed: () {}),
    );
  }
}

class EventCard extends StatelessWidget {
  final String name;
  final String location;
  final String date;
  final String description;
  final String createdBy;

  EventCard({
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
