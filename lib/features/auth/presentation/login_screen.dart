import 'package:flutter/material.dart';

import '../../../core/services/supabase_config.dart';
import '../data/auth_repository.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, required this.authRepository});

  final AuthRepository authRepository;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleEmailLogin() async {
    FocusScope.of(context).unfocus();
    setState(() => _isSubmitting = true);
    final error = await widget.authRepository.signInWithEmail(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );
    if (!mounted) {
      return;
    }
    setState(() => _isSubmitting = false);
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error)),
      );
    }
  }

  Future<void> _handleGuestLogin() async {
    setState(() => _isSubmitting = true);
    await widget.authRepository.signInAsGuest();
    if (!mounted) {
      return;
    }
    setState(() => _isSubmitting = false);
  }

  Future<void> _handleGoogleLogin() async {
    setState(() => _isSubmitting = true);
    final error = await widget.authRepository.signInWithGoogle();
    if (!mounted) {
      return;
    }
    setState(() => _isSubmitting = false);
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isConfigured = SupabaseConfig.isConfigured;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1080),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth >= 860;

                  return isWide
                      ? Row(
                          children: [
                            const Expanded(child: _LoginHero()),
                            const SizedBox(width: 24),
                            Expanded(
                              child: _LoginCard(
                                emailController: _emailController,
                                passwordController: _passwordController,
                                isSubmitting: _isSubmitting,
                                isConfigured: isConfigured,
                                onEmailLogin: _handleEmailLogin,
                                onGuestLogin: _handleGuestLogin,
                                onGoogleLogin: _handleGoogleLogin,
                              ),
                            ),
                          ],
                        )
                      : ListView(
                          children: [
                            const _LoginHero(),
                            const SizedBox(height: 20),
                            _LoginCard(
                              emailController: _emailController,
                              passwordController: _passwordController,
                              isSubmitting: _isSubmitting,
                              isConfigured: isConfigured,
                              onEmailLogin: _handleEmailLogin,
                              onGuestLogin: _handleGuestLogin,
                              onGoogleLogin: _handleGoogleLogin,
                            ),
                          ],
                        );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LoginHero extends StatelessWidget {
  const _LoginHero();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        gradient: const LinearGradient(
          colors: [Color(0xFF3B2418), Color(0xFF9A5B37)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Login Screen',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 14),
          Text(
            'Davao Coffee and Study Space Admin',
            style: TextStyle(
              color: Colors.white,
              fontSize: 34,
              fontWeight: FontWeight.w800,
              height: 1.1,
            ),
          ),
          SizedBox(height: 14),
          Text(
            'Use Guest, Email and Password, or Google to enter the dashboard, inspect cafe data, open item details, visit My Account, and log out back to this screen.',
            style: TextStyle(color: Colors.white70, height: 1.5),
          ),
        ],
      ),
    );
  }
}

class _LoginCard extends StatelessWidget {
  const _LoginCard({
    required this.emailController,
    required this.passwordController,
    required this.isSubmitting,
    required this.isConfigured,
    required this.onEmailLogin,
    required this.onGuestLogin,
    required this.onGoogleLogin,
  });

  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool isSubmitting;
  final bool isConfigured;
  final Future<void> Function() onEmailLogin;
  final Future<void> Function() onGuestLogin;
  final Future<void> Function() onGoogleLogin;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Sign In',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text(
              isConfigured
                  ? 'Supabase is connected. You can use guest, email/password, or Google.'
                  : 'Supabase keys are not set yet. Guest mode works now, and online login will work after you add your project URL and anon key.',
              style: const TextStyle(height: 1.5, color: Colors.black54),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Password'),
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: isSubmitting ? null : onEmailLogin,
                child: const Text('Login with Email / Password'),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton.tonal(
                onPressed: isSubmitting ? null : onGoogleLogin,
                child: const Text('Login with Gmail'),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: isSubmitting ? null : onGuestLogin,
                child: const Text('Continue as Guest'),
              ),
            ),
            if (!isConfigured) ...[
              const SizedBox(height: 16),
              const Text(
                'Run with --dart-define=SUPABASE_URL=... and --dart-define=SUPABASE_ANON_KEY=...',
                style: TextStyle(color: Colors.black45),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
