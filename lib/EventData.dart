class EventData{
  String name;
  String description;
  DateTime date;
  String location;
  String category;
  int id;

  EventData({required this.name, required this.description, required this.date,
    required this.location, required this.id, required this.category});

  factory EventData.fromJson(Map<String, dynamic> json){
    return EventData(
      name: json['name'],
      description: json['description'],
      date: json['date'],
      location: json['location'],
      category: json['category'],
      id: json['id']
    );
  }
}