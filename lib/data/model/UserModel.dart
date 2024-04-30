

class User {
  final String email;
  final String name;
  final String? fullName;
  final String? address;
  final String? role;
  // final DateTime createdAt;

  User({
    required this.email,
    required this.name,
    this.fullName,
    this.address,
    this.role,
    // required this.createdAt,
  });


   factory User.fromJson(Map<String, dynamic> json) {
    return User(
      email: json['email'] as String,
      name: json['name'] as String,
      fullName: json['fullName'] as String?,
      address: json['address'] as String?,
      role: json['role'] as String?,
      // createdAt: json['created_at'] is DateTime ? json['created_at'] : DateTime.now(),
    );
  }

  Map<String, dynamic>  toJson() {
    return {
      'email': email,
      'name': name,
      'fullName': fullName,
      'address': address,
      'role': role,
      // 'createdAt': createdAt,
    };
  }
}
