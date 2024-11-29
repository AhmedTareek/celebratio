import 'gift.dart';

class GiftDetailsModel {
  final Gift gift;
  final String eventName;
  final DateTime eventDate;
  final String pledgerName;
  final String? hostName;
  final int? hostId;

  GiftDetailsModel({
    required this.gift,
    required this.eventName,
    required this.eventDate,
    required this.pledgerName,
    this.hostName,
    this.hostId,
  });

  factory GiftDetailsModel.fromMap(Map<String, dynamic> map) {
    return GiftDetailsModel(
      gift: Gift(
        id: map['giftId'],
        name: map['name'],
        description: map['description'],
        category: map['category'],
        price: map['price'],
        status: map['status'],
        eventId: map['eventId'],
        pledgerId: map['pledgerId'],
      ),
      eventName: map['eventName'],
      eventDate: DateTime.parse(map['eventDate']),
      pledgerName: map['pledgerName'],
      hostName: map['hostName'],
      hostId: map['hostId'],
    );
  }
}