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
