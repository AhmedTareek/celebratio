import 'package:celebratio/CustomWidget.dart';
import 'package:flutter/material.dart';

class InGifts extends StatefulWidget {
  @override
  State<InGifts> createState() => _InGiftsState();
}

class _InGiftsState extends State<InGifts> {
  @override
  Widget build(BuildContext context) {
    return CustomWidget(
      title: 'Gifts You are Getting',
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
              Text('Friend Name who pledged the gift')
            ],)
          );
        },
        itemCount: 10);
  }
}
