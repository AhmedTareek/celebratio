class EventData {
  String name;
  String description;
  DateTime date;
  String location;
  String category;
  int? id;
  int? userId = 1;

  EventData(
      {required this.name,
      required this.description,
      required this.date,
      required this.location,
      this.id,
      this.userId,
      required this.category});

  EventData copyWith({
    String? name,
    String? description,
    DateTime? date,
    String? location,
    String? category,
    int? id,
    int? userId,
  }) {
    return EventData(
      name: name ?? this.name,
      description: description ?? this.description,
      date: date ?? this.date,
      location: location ?? this.location,
      category: category ?? this.category,
      id: id ?? this.id,
      userId: userId ?? this.userId,
    );
  }

  factory EventData.fromJson(Map<String, dynamic> json) {
    return EventData(
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
      'date': date.toString(),
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
