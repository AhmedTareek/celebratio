import 'fb_gift.dart';

class PledgedGiftToMe {
  final FbGift gift;
  final String eventName;
  final DateTime eventDate;
  final String pledgedBy;

  PledgedGiftToMe({
    required this.gift,
    required this.eventName,
    required this.eventDate,
    required this.pledgedBy,
  });

  factory PledgedGiftToMe.fromData(
      Map<String, dynamic> giftData,
      String giftId,
      Map<String, dynamic>? eventData
      ) {
    return PledgedGiftToMe(
      gift: FbGift.fromFirestore(giftData, giftId),
      eventName: eventData?['name'] ?? '',
      eventDate: DateTime.parse(eventData?['date'] as String? ?? DateTime.now().toIso8601String()),
      pledgedBy: giftData['pledgedBy'] as String,
    );
  }
}
