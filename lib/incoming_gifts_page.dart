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

  @override
  void initState() {
    super.initState();
    _fetchIncomingGifts();
  }

  Future<void> _fetchIncomingGifts() async {
    try {
      var appState = Provider.of<ApplicationState>(context, listen: false);
      var temp = await appState.getGiftsToBeGivenToMe();
      print('temp: $temp');
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

      setState(() {
        incomingGifts = temp;
      });
    } catch (e) {
      print('Error fetching incoming gifts: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomWidget(
      title: 'Gifts You are Getting',
      filterButtons: [],
      sortOptions: [],
      tileBuilder: (context, idx) {
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
              Text('Pledged by: ${giftDetail.pledgedBy}'),
            ],
          ),
        );
      },
      itemCount: incomingGifts.isEmpty ? 1 : incomingGifts.length,
    );
  }
}
