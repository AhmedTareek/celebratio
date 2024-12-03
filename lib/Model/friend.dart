import 'package:cloud_firestore/cloud_firestore.dart';

class Friend {
  String name;
  String email;
  String? preferences;
  int? id;

  Friend({required this.name, required this.email, this.preferences, this.id});

  Friend copyWith({
    String? name,
    String? email,
    String? preferences,
    int? id,
  }) {
    return Friend(
      name: name ?? this.name,
      email: email ?? this.email,
      preferences: preferences ?? this.preferences,
      id: id ?? this.id,
    );
  }

  factory Friend.fromJson(Map<String, dynamic> json) {
    return Friend(
      name: json['name'],
      email: json['email'],
      preferences: json['preferences'],
      id: json['id'],
    );
  }

  Map<String, Object?> toMap() {
    return {
      'name': name,
      'email': email,
      'preferences': preferences,
      'id': id,
    };
  }

  factory Friend.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Friend(
      name: data['name'] as String,
      email: data['email'] as String,
      preferences: data['preferences'] as String,
      id: data['id'] as int,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'email': email,
      'preferences': preferences,
    };
  }

  @override
  String toString() {
    return 'User{name: $name, email: $email,'
        ' preferences: $preferences, id: $id}';
  }
}
