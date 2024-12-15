class FbEvent {
  String? id; // Add this field
  String name;
  String description;
  DateTime date;
  String location;
  String category;
  String createdBy;

  // following are used only in local db
  int? needSync;
  String? syncAction;
  int? lastModified;

  FbEvent({
    this.id, // Add this to constructor
    required this.name,
    required this.description,
    required this.date,
    required this.location,
    required this.category,
    required this.createdBy,
    this.needSync,
    this.syncAction,
    this.lastModified,
  });

  factory FbEvent.fromFirestore(Map<String, dynamic> data, String id) {
    // Add id parameter
    return FbEvent(
      id: id,
      // Pass the id
      name: data['name'] as String,
      description: data['description'] as String,
      date: DateTime.parse(data['date'] as String),
      location: data['location'] as String,
      category: data['category'] as String,
      createdBy: data['createdBy'] as String,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      'date': date.toIso8601String(),
      'location': location,
      'category': category,
      'createdBy': createdBy,
      // Note: We don't include id in toFirestore() as it's managed by Firestore
    };
  }

  toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'date': date.toIso8601String(),
      'location': location,
      'category': category,
      'createdBy': createdBy,
      'needSync': needSync,
      'syncAction': syncAction,
      'lastModified': lastModified,
    };
  }

  factory FbEvent.fromJson(Map<String, dynamic> json) {
    return FbEvent(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      date: DateTime.parse(json['date']),
      location: json['location'],
      category: json['category'],
      createdBy: json['createdBy'],
      needSync: json['needSync'],
      syncAction: json['syncAction'],
      lastModified: json['lastModified'],
    );
  }

  copyWith({
    String? id,
    String? name,
    String? description,
    DateTime? date,
    String? location,
    String? category,
    String? createdBy,
    int? needSync,
    String? syncAction,
    int? lastModified,
  }) {
    return FbEvent(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      date: date ?? this.date,
      location: location ?? this.location,
      category: category ?? this.category,
      createdBy: createdBy ?? this.createdBy,
      needSync: needSync ?? this.needSync,
      syncAction: syncAction ?? this.syncAction,
      lastModified: lastModified ?? this.lastModified,
    );
  }

  @override
  String toString() {
    return 'FbEvent{id: $id, name: $name, description: $description, '
        'date: $date, location: $location, category: $category, '
        'createdBy: $createdBy, needSync: $needSync, '
        'syncAction: $syncAction, lastModified: $lastModified}';
  }
}
