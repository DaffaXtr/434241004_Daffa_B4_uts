import '/models/user_model.dart';

final dummyUsers = [
  const UserModel(
    id: 'u001',
    name: 'Budi Santoso',
    email: 'budi@student.unair.ac.id',
    username: 'budi',
    role: UserRole.user,
    department: 'Teknik Informatika',
  ),
  const UserModel(
    id: 'u002',
    name: 'Siti Rahayu',
    email: 'siti@student.unair.ac.id',
    username: 'siti',
    role: UserRole.user,
    department: 'Sistem Informasi',
  ),
  const UserModel(
    id: 'h001',
    name: 'Andi Wijaya',
    email: 'andi@helpdesk.unair.ac.id',
    username: 'andi_hd',
    role: UserRole.helpdesk,
    department: 'IT Support',
  ),
  const UserModel(
    id: 'a001',
    name: 'Dr. Rini Kusuma',
    email: 'rini@admin.unair.ac.id',
    username: 'admin_rini',
    role: UserRole.admin,
    department: 'IT Management',
  ),
];

// Akun dummy untuk login
// username: budi      | password: 123456  | role: User
// username: siti      | password: 123456  | role: User
// username: andi_hd   | password: 123456  | role: Helpdesk
// username: admin_rini| password: 123456  | role: Admin
