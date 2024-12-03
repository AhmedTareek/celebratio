class FbEvent {
  final String id;  // Add this field
  String name;
  String description;
  DateTime date;
  String location;
  String category;
  String createdBy;

  FbEvent({
    required this.id,  // Add this to constructor
    required this.name,
    required this.description,
    required this.date,
    required this.location,
    required this.category,
    required this.createdBy,
  });

  factory FbEvent.fromFirestore(Map<String, dynamic> data, String id) {  // Add id parameter
    return FbEvent(
      id: id,  // Pass the id
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
}