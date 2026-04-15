import 'package:flutter/material.dart';

import '../../account/presentation/my_account_screen.dart';
import '../../dashboard/presentation/dashboard_screen.dart';
import '../data/auth_repository.dart';
import 'login_screen.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key, required this.authRepository});

  final AuthRepository authRepository;

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    widget.authRepository.restoreSession();
    widget.authRepository.addListener(_handleAuthChanged);
  }

  @override
  void dispose() {
    widget.authRepository.removeListener(_handleAuthChanged);
    super.dispose();
  }

  void _handleAuthChanged() {
    if (!mounted) {
      return;
    }
    if (widget.authRepository.authMode == AuthMode.unauthenticated) {
      _selectedIndex = 0;
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (widget.authRepository.authMode == AuthMode.unauthenticated) {
      return LoginScreen(authRepository: widget.authRepository);
    }

    final screens = [
      DashboardScreen(authRepository: widget.authRepository),
      MyAccountScreen(authRepository: widget.authRepository),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(_selectedIndex == 0 ? 'Complete Dashboard' : 'My Account'),
        actions: [
          TextButton.icon(
            onPressed: () async {
              await widget.authRepository.signOut();
            },
            icon: const Icon(Icons.logout),
            label: const Text('Logout'),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: screens[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() => _selectedIndex = index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'My Account',
          ),
        ],
      ),
    );
  }
}
