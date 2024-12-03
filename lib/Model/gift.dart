class Gift {
  final String id;
  final String name;
  final String description;
  final String category;
  final double price;
  final String status;
  final String eventId;
  final String? pledgedBy;

  Gift({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.price,
    required this.status,
    required this.eventId,
    this.pledgedBy,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'description': description,
    'category': category,
    'price': price,
    'status': status,
    'eventId': eventId,
    'pledgedBy': pledgedBy,
  };

  static Gift fromMap(Map<String, dynamic> map) => Gift(
    id: map['id'],
    name: map['name'],
    description: map['description'],
    category: map['category'],
    price: map['price'],
    status: map['status'],
    eventId: map['eventId'],
    pledgedBy: map['pledgedBy'],
  );
}