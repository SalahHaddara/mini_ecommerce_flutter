class User {
  final String id;
  final String email;
  final String? role;

  User({
    required this.id,
    required this.email,
    String? role,
  }) : role = role?.toLowerCase();

  factory User.fromJson(Map<String, dynamic> json) {
    final dynamic rawId = json['id'];
    final String id = rawId == null ? '' : rawId.toString();
    final String email = json['email'] ?? '';
    final String? role = (json['role'] as String?)?.toLowerCase();
    return User(
      id: id.isEmpty ? email : id,
      email: email,
      role: role,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'role': role,
    };
  }

  bool get isAdmin => (role ?? '').contains('admin');
}
