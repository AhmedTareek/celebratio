class FbGift {
  String id;
  String eventId;
  String name;
  String description;
  String category;
  double price;
  String status;
  String? imageUrl;
  String? pledgedBy;
  int? needSync;
  String? syncAction;
  int? lastModified;

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
    this.needSync,
    this.syncAction,
    this.lastModified,
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

  toMap() {
    return {
      'id': id,
      'eventId': eventId,
      'name': name,
      'description': description,
      'category': category,
      'price': price,
      'status': status,
      'imageUrl': imageUrl,
      'pledgedBy': pledgedBy,
      'needSync': needSync,
      'syncAction': syncAction,
      'lastModified': lastModified,
    };
  }

  factory FbGift.fromJson(Map<String, dynamic> json) {
    return FbGift(
      id: json['id'],
      eventId: json['eventId'],
      name: json['name'],
      description: json['description'],
      category: json['category'],
      price: json['price'],
      status: json['status'],
      imageUrl: json['imageUrl'],
      pledgedBy: json['pledgedBy'],
      needSync: json['needSync'],
      syncAction: json['syncAction'],
      lastModified: json['lastModified'],
    );
  }

  @override
  String toString() {
    return 'FbGift{id: $id, eventId: $eventId, name: $name, description: '
        '$description, category: $category, price: $price, status: $status,'
        ' imageUrl: $imageUrl, pledgedBy: $pledgedBy, needSync: $needSync,'
        ' syncAction: $syncAction, lastModified: $lastModified}';
  }
}
