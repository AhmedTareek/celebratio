class FbFriend{
  String id;
  String name;
  String email;

  FbFriend({
    required this.id,
    required this.name,
    required this.email,
  });

  factory FbFriend.fromFirestore(Map<String, dynamic> data, String id) {
    return FbFriend(
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