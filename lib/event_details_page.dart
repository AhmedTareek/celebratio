import 'package:celebratio/Model/event.dart';
import 'package:celebratio/Model/fb_event.dart';
import 'package:celebratio/Model/fb_gift.dart';
import 'package:celebratio/gift_details_page.dart';
import 'package:celebratio/Model/gift.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'CustomWidget.dart';
import 'Model/local_db.dart';
import 'app_state.dart';

class EventDetails extends StatefulWidget {
  final FbEvent eventData;

  const EventDetails({super.key, required this.eventData});

  @override
  State<StatefulWidget> createState() {
    return _EventDetailsState();
  }
}

class _EventDetailsState extends State<EventDetails> {
  var loggedInUserId = FirebaseAuth.instance.currentUser!.uid;
  final db = DataBase();
  String selectedFilter = 'All'; // Tracks the current filter
  List<FbGift> allGifts = []; // Replace with your gifts data
  List<FbGift> filteredGifts = [];
  String sortType = "";

  void _filterGifts() {
    setState(() {
      if (selectedFilter == 'All') {
        filteredGifts = allGifts.toList();
      } else {
        filteredGifts =
            allGifts.where((gift) => gift.status == selectedFilter).toList();
      }
      _sortGifts(); // Apply sorting after filtering
    });
  }

  void _sortGifts() {
    setState(() {
      if (sortType == "Category") {
        filteredGifts.sort((a, b) => a.category.compareTo(b.category));
      } else if (sortType == "Name") {
        filteredGifts.sort((a, b) => a.category.compareTo(b.category));
      }
    });
  }

  _fetchGifts() async {
    try {
      // var temp = await db.getGiftsByEventId(widget.eventData.id!);
      var appState = Provider.of<ApplicationState>(context, listen: false);
      var temp = await appState.getGiftsByEventId(widget.eventData.id);
      setState(() {
        allGifts = List.from(temp);
        _filterGifts();
      });
    } catch (e) {
       print('Error fetching gifts: $e');
    }
  }


  void _addNewGift() {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();
    final TextEditingController categoryController = TextEditingController();
    final TextEditingController priceController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add New Gift'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: categoryController,
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: priceController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Price',
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
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.isNotEmpty &&
                    descriptionController.text.isNotEmpty &&
                    categoryController.text.isNotEmpty &&
                    priceController.text.isNotEmpty) {
                  try {
                    // Parse price
                    final double price = double.parse(priceController.text);
                    var appState =
                        Provider.of<ApplicationState>(context, listen: false);
                    appState.addGift(
                        eventId: widget.eventData.id,
                        name: nameController.text,
                        description: descriptionController.text,
                        category: categoryController.text,
                        price: price);
                    setState(() {
                      // allGifts.add(gift);
                      _fetchGifts();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Gift added successfully')),
                      );
                    });
                    if (context.mounted) {
                      Navigator.of(context).pop();
                    } // Close the dialog
                  } catch (e) {
                    print(e);
                    // Show error message if database operation fails
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text('Error adding gift: ${e.toString()}')),
                    );
                  }
                } else {
                  // Show error message if fields are empty
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please fill all fields')),
                  );
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _fetchGifts();
    _filterGifts(); // Initialize the filtered list
  }

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
          createdBy: widget.eventData.createdBy),
      filterButtons: [
        FilterButton(
            label: 'All',
            onPressed: () {
              setState(() {
                selectedFilter = 'All';
                _filterGifts();
              });
            }),
        FilterButton(
            label: 'Available',
            onPressed: () {
              setState(() {
                selectedFilter = 'Available';
                _filterGifts();
              });
            }),
        FilterButton(
            label: 'Pledged',
            onPressed: () {
              setState(() {
                selectedFilter = 'Pledged';
                _filterGifts();
              });
            }),
      ],
      sortOptions: [
        SortOption(
            label: 'Name',
            onSelected: () {
              setState(() {
                sortType = "Name";
                _filterGifts();
              });
            }),
        SortOption(
            label: 'category',
            onSelected: () {
              setState(() {
                sortType = "Category";
                _filterGifts();
              });
            }),
      ],
      onClearSortOptionsSelected: () {
        setState(() {
          sortType = "";
          _filterGifts();
        });
      },
      tileBuilder: (context, idx) {
        final gift = filteredGifts[idx];
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: ListTile(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => GiftDetails(
                            gift: gift,
                            giftOwnerId: currentEvent.createdBy,
                          ))).then((value) {
                _fetchGifts();
              });
            },
            onLongPress: currentEvent.createdBy == loggedInUserId
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
                                  var appState = Provider.of<ApplicationState>(
                                      context,
                                      listen: false);
                                  await appState.deleteGift(giftId: gift.id);
                                  // await db.deleteGiftById(gift.id!);
                                  allGifts.remove(gift);
                                  _fetchGifts();
                                  if (context.mounted) {
                                    Navigator.pop(context);
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
            title: Text(
              gift.name,
            ),
            subtitle: Text(gift.pledgedBy ?? 'No one has pledged this gift'),
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
      itemCount: filteredGifts.length,
      newButton: currentEvent.createdBy == loggedInUserId
          ? NewButton(
              label: 'New Gift',
              onPressed: () {
                _addNewGift();
              })
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
