import 'package:celebratio/CustomWidget.dart';
import 'package:celebratio/Model/fb_pledged_gift.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:developer';

import 'app_state.dart';

class OutGifts extends StatefulWidget {
  const OutGifts({super.key});

  @override
  State<OutGifts> createState() => _OutGiftsState();
}

class _OutGiftsState extends State<OutGifts> {
  List<PledgedGift> outgoingGifts = [];

  @override
  void initState() {
    super.initState();
    _fetchOutgoingGifts();
  }

  Future<void> _fetchOutgoingGifts() async {
    try {
      // var temp = await db.getOutgoingGiftsWithDetails(loggedInUserId);
      var appState = Provider.of<ApplicationState>(context, listen: false);
      var temp = await appState.getMyPledgedGifts();
      temp = temp.where((gift) {
        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day); // strip time
        final giftDate = DateTime(gift.eventDate.year, gift.eventDate.month,
            gift.eventDate.day); // Strip time

        // Check if the gift's eventDate is today or after today
        return giftDate.isAtSameMomentAs(today) || giftDate.isAfter(today);
      }).toList();
      setState(() {
        outgoingGifts = temp;
      });
    } catch (e) {
      log('Error fetching outgoing gifts:', error: e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomWidget(
      title: 'Gifts You are Giving',
      filterButtons: const [],
      sortOptions: const [],
      tileBuilder: (context, idx) {
        if (outgoingGifts.isEmpty) {
          return const ListTile(
            title: Text('No outgoing gifts found'),
          );
        }

        final giftDetail = outgoingGifts[idx];
        final formattedDate =
            '${giftDetail.eventDate.day}-${giftDetail.eventDate.month}'
            '-${giftDetail.eventDate.year}';

        return ListTile(
          trailing: Text(formattedDate),
          title: Text(giftDetail.gift.name),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(giftDetail.eventName),
              Text('Event hosted by: ${giftDetail.eventHost}'),
            ],
          ),
        );
      },
      itemCount: outgoingGifts.isEmpty ? 1 : outgoingGifts.length,
    );
  }
}
