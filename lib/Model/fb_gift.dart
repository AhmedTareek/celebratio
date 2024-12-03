class FbGift{
  String id;
  String eventId;
  String name;
  String description;
  String category;
  double price;
  String status;
  String? imageUrl;
  String? pledgedBy;

  FbGift({
    required this.id,
    required this.eventId,
    required this.name,
    required this.description,
    required this.category,
    required this.price,
    required this.status,
    this.imageUrl,
    this.pledgedBy,
  });

  factory FbGift.fromFirestore(Map<String, dynamic> data, String id) {
    return FbGift(
      id: id,
      eventId: data['event'] as String,
      name: data['name'] as String,
      description: data['description'] as String,
      category: data['category'] as String,
      price: data['price'] as double,
      status: data['status'] as String,
      imageUrl: data['imageUrl'] as String?,
      pledgedBy: data['pledgedBy'] as String?,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'event': eventId,
      'name': name,
      'description': description,
      'category': category,
      'price': price,
      'status': status,
      'imageUrl': imageUrl,
      'pledgedBy': pledgedBy,
    };
  }


}