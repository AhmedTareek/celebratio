import 'package:celebratio/CustomWidget.dart';
import 'package:celebratio/EventDetails.dart';
import 'package:flutter/material.dart';

class Events extends StatefulWidget {
  @override
  State<Events> createState() => _EventState();
}

class _EventState extends State<Events> {
  final List<bool> _statusSelections = List.generate(3, (idx) => idx == 0);
  final List<bool> _filterSelections = List.generate(2, (_) => false);
  final ScrollController _scrollController = ScrollController();
  bool _isVisible = false;
  int? selectedButtonIndex;

  void _scrollToTop() {
    _scrollController.animateTo(
      0.0, // Scroll to the top (0.0 offset)
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  @override
  void initState() {
    super.initState();
    // Add a listener to the ScrollController to monitor the scroll offset
    _scrollController.addListener(() {
      if (_scrollController.offset > 300) {
        // Show button when scrolled down
        setState(() {
          _isVisible = true;
        });
      } else {
        // Hide button when at the top
        setState(() {
          _isVisible = false;
        });
      }
    });
  }

  void changeButtonBackGroundColor(int idx, list) {
    for (int i = 0; i < list.length; i++) {
      list[i] = i == idx;
    }
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
  Widget build(BuildContext context) {
    return CustomWidget(
      newButton: NewButton(label: 'New Event',onPressed: (){}),
        filterButtons: [
          FilterButton(label: 'Past'),
          FilterButton(label: 'Current'),
          FilterButton(label: 'Upcoming'),
        ],
        sortOptions: [
          SortOption(label: 'Name'),
          SortOption(label: 'Category')
        ],
        tileBuilder: (context, index) {
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
            trailing: Text('2024-12-15'),
            title: Text('Wedding $index'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Ahmed Tarek'),
                Text('one line from the description ...')
              ],
            ),
          );
        },
        itemCount: 36);

    // print(_statusSelections);
    // var theme = Theme.of(context);
    //
    // return Scaffold(
    //   appBar: AppBar(
    //     backgroundColor: theme.secondaryHeaderColor,
    //     leading: IconButton(
    //       icon: const Icon(Icons.account_circle),
    //       onPressed: () {},
    //     ),
    //     title: Text(
    //       'My Events',
    //       style: TextStyle(color: theme.primaryColor),
    //     ),
    //     actions: [
    //       Container(
    //         decoration: BoxDecoration(
    //             shape: BoxShape.circle,
    //             color: _filterSelections.any((element) => element == true)
    //                 ? theme.primaryColorLight
    //                 : null),
    //         child: IconButton(
    //           onPressed: () {
    //             print(selectedButtonIndex);
    //             showDialog(
    //               context: context,
    //               builder: (BuildContext context) => SortDialog(
    //                 initialSelection: selectedButtonIndex,
    //               ),
    //             ).then((selectedOption) {
    //               if (selectedOption != null) {
    //                 setState(() {
    //                   _filterSelections.fillRange(
    //                       0, _filterSelections.length, false);
    //                   if (selectedOption >= 0) {
    //                     selectedButtonIndex = selectedOption;
    //                     _filterSelections[selectedOption] = true;
    //                   } else {
    //                     selectedButtonIndex = null;
    //                   }
    //                 });
    //                 print('Selected option: ${selectedOption + 1}');
    //               }
    //             });
    //           },
    //           icon: Icon(Icons.sort),
    //         ),
    //       ),
    //       ElevatedButton.icon(
    //         onPressed: () {},
    //         label: const Text('New Event'),
    //         icon: const Icon(Icons.add),
    //       )
    //     ],
    //   ),
    //   body: ListView(
    //     controller: _scrollController,
    //     children: [
    //       Padding(
    //         padding: const EdgeInsets.all(8.0),
    //         child: Row(
    //           mainAxisAlignment: MainAxisAlignment.start,
    //           children: [
    //             OutlinedButton(
    //                 style: ButtonStyle(
    //                     backgroundColor: _statusSelections[0]
    //                         ? WidgetStatePropertyAll(theme.primaryColorLight)
    //                         : null),
    //                 onPressed: () {
    //                   setState(() {
    //                     changeButtonBackGroundColor(0, _statusSelections);
    //                   });
    //                 },
    //                 child: Text('Past')),
    //             SizedBox(
    //               width: 8.0,
    //             ),
    //             OutlinedButton(
    //                 style: ButtonStyle(
    //                     backgroundColor: _statusSelections[1]
    //                         ? WidgetStatePropertyAll(theme.primaryColorLight)
    //                         : null),
    //                 onPressed: () {
    //                   setState(() {
    //                     changeButtonBackGroundColor(1, _statusSelections);
    //                   });
    //                 },
    //                 child: Text('Current')),
    //             SizedBox(
    //               width: 8.0,
    //             ),
    //             OutlinedButton(
    //                 style: ButtonStyle(
    //                   backgroundColor: _statusSelections[2]
    //                       ? WidgetStatePropertyAll(theme.primaryColorLight)
    //                       : null,
    //                 ),
    //                 onPressed: () {
    //                   setState(() {
    //                     changeButtonBackGroundColor(2, _statusSelections);
    //                   });
    //                 },
    //                 child: Text('Upcomming')),
    //           ],
    //         ),
    //       ),
    //       for (int i = 0; i < 35; i++)
    //         ListTile(
    //           onTap: () {
    //             Navigator.push(
    //               context,
    //               MaterialPageRoute(
    //                 builder: (context) => EventDetails(eventName: 'Wedding $i'),
    //               ),
    //             );
    //           },
    //           onLongPress: () => _showOptionsDialog(i),
    //           trailing: Text('2024-12-15'),
    //           title: Text('Wedding $i'),
    //           subtitle: Column(
    //             crossAxisAlignment: CrossAxisAlignment.start,
    //             children: [
    //               Text('Ahmed Tarek'),
    //               Text('one line from the description ...')
    //             ],
    //           ),
    //         )
    //     ],
    //   ),
    //   floatingActionButton: _isVisible
    //       ? FloatingActionButton(
    //           onPressed: _scrollToTop, // Scroll to the top when pressed
    //           child: const Icon(Icons.arrow_upward),
    //         )
    //       : null,
    // );
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
