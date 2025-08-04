class Friend{
  String id;
  String name;
  String email;

  Friend({
    required this.id,
    required this.name,
    required this.email,
  });

  factory Friend.fromFirestore(Map<String, dynamic> data, String id) {
    return Friend(
      id: id,
      name: data['name'] as String,
      email: data['email'] as String,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'email': email,
    };
  }
}