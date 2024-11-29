class Gift {
  int? id;
  String name;
  String description;
  String category;
  double price;
  String status;
  int eventId;
  int? pledgerId;

  Gift(
      {this.id,
      required this.name,
      required this.description,
      required this.category,
      required this.price,
      required this.status,
      required this.eventId,
      this.pledgerId});

  Gift copyWith({
    int? id,
    String? name,
    String? description,
    String? category,
    double? price,
    String? status,
    int? eventId,
    int? pledgerId,
  }) {
    return Gift(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      price: price ?? this.price,
      status: status ?? this.status,
      eventId: eventId ?? this.eventId,
      pledgerId: pledgerId ?? this.pledgerId,
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
        id: json['id'],
        pledgerId: json['pledgerId']);
  }

  Map<String, Object?> toMap() {
    return {
      'name': name,
      'description': description,
      'category': category,
      'price': price,
      'status': status,
      'eventId': eventId,
      'id': id,
      'pledgerId': pledgerId
    };
  }
}