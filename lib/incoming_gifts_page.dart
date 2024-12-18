import 'package:celebratio/CustomWidget.dart';
import 'package:celebratio/Model/fb_pledged_gifts_to_me.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app_state.dart';

class InGifts extends StatefulWidget {
  const InGifts({super.key});

  @override
  State<InGifts> createState() => _InGiftsState();
}

class _InGiftsState extends State<InGifts> {
  List<PledgedGiftToMe> incomingGifts = [];
  late ApplicationState appState;
  bool isLoading = true; // New variable to track loading state

  @override
  void initState() {
    super.initState();
    appState = Provider.of<ApplicationState>(context, listen: false);
    _fetchIncomingGifts();
  }

  Future<void> _fetchIncomingGifts() async {
    try {
      var temp = await appState.getGiftsToBeGivenToMe();
      // var temp = await db.getIncomingGiftsWithDetails(loggedInUserId);
      // filter temp based on the event date being today or after
      temp = temp.where((gift) {
        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day); // strip time
        final giftDate = DateTime(gift.eventDate.year, gift.eventDate.month,
            gift.eventDate.day); // Strip time

        // Check if the gift's eventDate is today or after today
        return giftDate.isAtSameMomentAs(today) || giftDate.isAfter(today);
      }).toList();
      // check if the name is present in userNames in appState if its not add it
      for (var gift in temp) {
        if (!appState.userNames.containsKey(gift.pledgedBy)) {
          appState.getUserNameById(gift.pledgedBy).then((name) {
            appState.userNames[gift.pledgedBy] = name;
          });
        }
      }

      if (mounted) {
        setState(() {
          incomingGifts = temp;
          isLoading = false; // Set loading to false once data is fetched
        });
      }
    } catch (e) {
      print('Error fetching incoming gifts: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomWidget(
      title: 'Gifts You are Getting',
      filterButtons: const [],
      sortOptions: const [],
      topWidget: isLoading
          ? const Padding(
              padding: EdgeInsets.all(80.0),
              child:
                  Center(child: CircularProgressIndicator()),
            )
          : null,
      tileBuilder: (context, idx) {
        if (!isLoading && incomingGifts.isEmpty) {
          return const ListTile(
            title: Text('No outgoing gifts found'),
          );
        }
        if (incomingGifts.isEmpty) {
          return const ListTile(
            title: Text('No incoming gifts found'),
          );
        }

        final giftDetail = incomingGifts[idx];
        final formattedDate =
            '${giftDetail.eventDate.day}-${giftDetail.eventDate.month}-'
            '${giftDetail.eventDate.year}';

        return ListTile(
          trailing: Text(formattedDate),
          title: Text(giftDetail.gift.name),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(giftDetail.eventName),
              Text('Pledged by: ${appState.userNames[giftDetail.pledgedBy]}'),
            ],
          ),
        );
      },
      itemCount: incomingGifts.length,
    );
  }
}
