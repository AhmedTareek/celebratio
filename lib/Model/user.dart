class User {
  String name;
  String email;
  String? preferences;
  int? id;

  User({required this.name, required this.email, this.preferences, this.id});

  User copyWith({
    String? name,
    String? email,
    String? preferences,
    int? id,
  }) {
    return User(
      name: name ?? this.name,
      email: email ?? this.email,
      preferences: preferences ?? this.preferences,
      id: id ?? this.id,
    );
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
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

  @override
  String toString() {
    return 'User{name: $name, email: $email,'
        ' preferences: $preferences, id: $id}';
  }
}
