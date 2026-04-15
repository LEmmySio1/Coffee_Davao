class UserProfile {
  const UserProfile({
    required this.id,
    required this.role,
  });

  final String id;
  final String role;

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      id: (map['id'] ?? '').toString(),
      role: (map['role'] ?? 'User').toString(),
    );
  }
}
