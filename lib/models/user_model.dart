class User {
  final String id;
  final String name;
  final String role;
  final String department;
  
  User({
    required this.id,
    required this.name,
    required this.role,
    required this.department,
  });
  
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      role: json['role'] ?? '',
      department: json['department'] ?? '',
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'role': role,
      'department': department,
    };
  }
}
