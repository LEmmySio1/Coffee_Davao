import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import '../features/auth/data/auth_repository.dart';
import '../features/auth/presentation/auth_gate.dart';

class DavaoCoffeeApp extends StatelessWidget {
  const DavaoCoffeeApp({super.key, required this.authRepository});

  final AuthRepository authRepository;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Davao Coffee and Study Space',
      theme: AppTheme.light,
      home: AuthGate(authRepository: authRepository),
    );
  }
}
