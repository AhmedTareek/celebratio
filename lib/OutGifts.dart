import 'package:celebratio/CustomWidget.dart';
import 'package:flutter/material.dart';

class OutGifts extends StatefulWidget {
  @override
  State<OutGifts> createState() => _OutGiftsState();
}

class _OutGiftsState extends State<OutGifts> {
  @override
  Widget build(BuildContext context) {
    return CustomWidget(
        title: 'Gifts You are Giving',
        filterButtons: [],
        sortOptions: [],
        tileBuilder: (context, idx) {
          return ListTile(
              trailing: Text('20-10-2024'),
              title: Text('Gift Name'),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Event Name'),
                  Text('Friend Name who hosts the Event')
                ],)
          );
        },
        itemCount:20 );
  }
}