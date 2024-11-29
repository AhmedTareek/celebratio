class Event {
  String name;
  String description;
  DateTime date;
  String location;
  String category;
  int? id;
  int? userId = 1;

  Event(
      {required this.name,
      required this.description,
      required this.date,
      required this.location,
      this.id,
      this.userId,
      required this.category});

  Event copyWith({
    String? name,
    String? description,
    DateTime? date,
    String? location,
    String? category,
    int? id,
    int? userId,
  }) {
    return Event(
      name: name ?? this.name,
      description: description ?? this.description,
      date: date ?? this.date,
      location: location ?? this.location,
      category: category ?? this.category,
      id: id ?? this.id,
      userId: userId ?? this.userId,
    );
  }

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
        name: json['name'],
        description: json['description'],
        date: DateTime.parse(json['date']),
        location: json['location'],
        category: json['category'],
        id: json['id'],
        userId: json['userId']);
  }

  Map<String, Object?> toMap() {
    return {
      'name': name,
      'description': description,
      'date': date.toIso8601String(),
      'location': location,
      'category': category,
      'id': id,
      'userId': userId
    };
  }

  @override
  String toString() {
    return 'EventData{name: $name, description: $description,'
        ' date: $date, location: $location, category: $category, id: $id, userId: $userId}';
  }
}
