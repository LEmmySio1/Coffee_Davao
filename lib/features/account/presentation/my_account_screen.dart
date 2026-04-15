import 'package:flutter/material.dart';

import '../../../core/models/user_profile.dart';
import '../../../core/services/supabase_service.dart';
import '../../auth/data/auth_repository.dart';

class MyAccountScreen extends StatefulWidget {
  const MyAccountScreen({super.key, required this.authRepository});

  final AuthRepository authRepository;

  @override
  State<MyAccountScreen> createState() => _MyAccountScreenState();
}

class _MyAccountScreenState extends State<MyAccountScreen> {
  Future<int>? _reviewCountFuture;

  @override
  void initState() {
    super.initState();
    _reviewCountFuture = _fetchReviewCount();
  }

  Future<int> _fetchReviewCount() async {
    final client = SupabaseService.client;
    if (client == null) {
      return 0;
    }

    final user = widget.authRepository.user;
    if (user == null) {
      return 0;
    }

    final data = await client
        .from('reviews')
        .select('id')
        .eq('user_id', user.email ?? user.id);

    return (data as List<dynamic>).length;
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.authRepository.user;
    final profile = widget.authRepository.profile ??
        const UserProfile(id: 'guest', role: 'Guest');

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            color: const Color(0xFF5B351F),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const CircleAvatar(
                radius: 34,
                backgroundColor: Colors.white24,
                child: Icon(Icons.person_outline, color: Colors.white, size: 32),
              ),
              const SizedBox(height: 16),
              Text(
                widget.authRepository.displayName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                widget.authRepository.emailOrLabel,
                style: const TextStyle(color: Colors.white70),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'User Details',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 14),
                _InfoRow(label: 'Role', value: profile.role),
                _InfoRow(label: 'User ID', value: user?.id ?? 'guest'),
                _InfoRow(label: 'Email', value: user?.email ?? 'Guest session'),
                _InfoRow(
                  label: 'Provider',
                  value: user == null
                      ? 'Guest'
                      : user.appMetadata['provider']?.toString() ?? 'Email',
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: FutureBuilder<int>(
              future: _reviewCountFuture,
              builder: (context, snapshot) {
                final reviewCount = snapshot.data ?? 0;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Activity Summary',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 14),
                    _InfoRow(
                      label: 'Mapped reviews',
                      value: '$reviewCount',
                    ),
                    _InfoRow(
                      label: 'Session type',
                      value: widget.authRepository.authMode == AuthMode.guest
                          ? 'Guest'
                          : 'Authenticated',
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.black54,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
