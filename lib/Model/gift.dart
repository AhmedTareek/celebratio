class Gift {
  final int? id;
  final String name;
  final String description;
  final String category;
  final double price;
  final String status;
  final int eventId;

  Gift(
      {this.id,
      required this.name,
      required this.description,
      required this.category,
      required this.price,
      required this.status,
      required this.eventId});

  Gift copyWith({
    int? id,
    String? name,
    String? description,
    String? category,
    double? price,
    String? status,
    int? eventId,
  }) {
    return Gift(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      price: price ?? this.price,
      status: status ?? this.status,
      eventId: eventId ?? this.eventId,
    );
  }

  factory Gift.fromJson(Map<String, dynamic> json) {
    return Gift(
        name: json['name'],
        description: json['description'],
        category: json['category'],
        price: json['price'],
        status: json['status'],
        eventId: json['eventId'],
        id: json['id']);
  }

  Map<String, Object?> toMap() {
    return {
      'name': name,
      'description': description,
      'category': category,
      'price': price,
      'status': status,
      'eventId': eventId,
      'id': id
    };
  }
}