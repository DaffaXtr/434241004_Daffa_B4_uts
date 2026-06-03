enum UserRole { user, helpdesk, admin }

class UserModel {
  final String id;
  final String name;
  final String email;
  final String username;
  final UserRole role;
  final String? avatarUrl;
  final String department;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.username,
    required this.role,
    this.avatarUrl,
    required this.department,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      name: json['name'] ?? 'Unknown',
      email: json['email'] ?? '',
      username: json['username'] ?? '',
      role: UserRole.values.firstWhere(
        (e) => e.name == json['role'],
        orElse: () => UserRole.user,
      ),
      avatarUrl: json['avatar_url'],
      department: json['department'] ?? 'Umum',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'username': username,
      'role': role.name,
      'avatar_url': avatarUrl,
      'department': department,
    };
  }

  String get roleLabel {
    switch (role) {
      case UserRole.admin:
        return 'Administrator';
      case UserRole.helpdesk:
        return 'Helpdesk';
      case UserRole.user:
        return 'User';
    }
  }
}
