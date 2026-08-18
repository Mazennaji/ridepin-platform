class AppUser {
  final int id;
  final String name;
  final String email;
  final String? phone;
  final int roleId;
  final String? roleName;

  AppUser({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    required this.roleId,
    this.roleName,
  });

  bool get isRider => roleName == 'rider';
  bool get isDriver => roleName == 'driver';
  bool get isAdmin => roleName == 'admin';

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String?,
      roleId: json['role_id'] as int? ?? 0,
      roleName: json['role'] is Map ? json['role']['name'] as String? : null,
    );
  }
}
