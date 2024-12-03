import 'fb_gift.dart';

class PledgedGift {
  final FbGift gift;
  final String eventName;
  final String eventHost;
  final DateTime eventDate;

  PledgedGift({
    required this.gift,
    required this.eventName,
    required this.eventHost,
    required this.eventDate,
  });

  factory PledgedGift.fromData(Map<String, dynamic> giftData, String giftId,
      Map<String, dynamic>? eventData) {
    return PledgedGift(
      gift: FbGift.fromFirestore(giftData, giftId),
      eventName: eventData?['name'] ?? '',
      eventHost: eventData?['createdBy'] ?? '',
      eventDate: DateTime.parse(
          eventData?['date'] as String? ?? DateTime.now().toIso8601String()),
    );
  }
}
