class User {
  final int? id;
  final String email;
  final String password;
  final String fullName;

  User({
    this.id,
    required this.email,
    required this.password,
    required this.fullName,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'password': password,
      'fullName': fullName,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      email: map['email'],
      password: map['password'],
      fullName: map['fullName'],
    );
  }
}
