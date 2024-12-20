import 'package:celebratio/smart_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:developer';

import 'app_state.dart';

class InOutGifts extends StatefulWidget {
  final bool isIncoming; // Parameter to switch between incoming and outgoing

  const InOutGifts({super.key, required this.isIncoming});

  @override
  State<InOutGifts> createState() => _InOutGiftsState();
}

class _InOutGiftsState extends State<InOutGifts> {
  late ApplicationState appState;
  bool isLoading = true;
  List<dynamic> gifts = [];

  @override
  void initState() {
    super.initState();
    appState = Provider.of<ApplicationState>(context, listen: false);
    widget.isIncoming ? _fetchIncomingGifts() : _fetchOutgoingGifts();
  }

  @override
  void dispose() {
    gifts.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SmartWidget(
      title:
      widget.isIncoming ? 'Gifts You are Getting' : 'Gifts You are Giving',
      filterButtons: const [],
      sortOptions: const [],
      topWidget: isLoading
          ? const Padding(
        padding: EdgeInsets.all(80.0),
        child: Center(child: CircularProgressIndicator()),
      )
          : gifts.isEmpty
          ? const ListTile(
        title: Text('It looks so empty here!'),
      )
          : null,
      tileBuilder: (context, idx) {
        final giftDetail = gifts[idx];
        final formattedDate =
            '${giftDetail.eventDate.day}-${giftDetail.eventDate
            .month}-${giftDetail.eventDate.year}';
        return ListTile(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
                12), // Reduced radius for subtlety
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          trailing: Text(
            formattedDate,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black54,
            ),
          ),
          title: Text(
            giftDetail.gift.name,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600, // Less bold, removed italic
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                giftDetail.eventName,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                ),
              ),
              Text(
                widget.isIncoming
                    ? 'Pledged by: ${appState.userNames[giftDetail.pledgedBy]}'
                    : 'Event hosted by: ${appState.userNames[giftDetail
                    .eventHost] ?? 'Loading...'}',
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
        );
      },
      itemCount: gifts.length,
    );
  }

  Future<void> _fetchIncomingGifts() async {
    try {
      var temp = await appState.getGiftsToBeGivenToMe();
      temp = temp.where((gift) {
        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);
        final giftDate = DateTime(
            gift.eventDate.year, gift.eventDate.month, gift.eventDate.day);
        return giftDate.isAtSameMomentAs(today) || giftDate.isAfter(today);
      }).toList();

      for (var gift in temp) {
        if (!appState.userNames.containsKey(gift.pledgedBy)) {
          appState.getUserNameById(gift.pledgedBy).then((name) {
            appState.userNames[gift.pledgedBy] = name;
          });
        }
      }

      if (mounted) {
        setState(() {
          gifts = temp;
          isLoading = false;
        });
      }
    } catch (e) {
      log('Error fetching incoming gifts: $e');
    }
  }

  Future<void> _fetchOutgoingGifts() async {
    try {
      var temp = await appState.getMyPledgedGifts();
      temp = temp.where((gift) {
        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);
        final giftDate = DateTime(
            gift.eventDate.year, gift.eventDate.month, gift.eventDate.day);
        return giftDate.isAtSameMomentAs(today) || giftDate.isAfter(today);
      }).toList();

      for (var gift in temp) {
        if (!appState.userNames.containsKey(gift.eventHost)) {
          appState.getUserNameById(gift.eventHost).then((name) {
            setState(() {
              appState.userNames[gift.eventHost] = name;
            });
          });
        }
      }

      if (mounted) {
        setState(() {
          gifts = temp;
          isLoading = false;
        });
      }
    } catch (e) {
      log('Error fetching outgoing gifts:', error: e.toString());
      setState(() {
        isLoading = false;
      });
    }
  }
}
