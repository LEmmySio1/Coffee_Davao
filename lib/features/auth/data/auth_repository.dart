import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/models/user_profile.dart';
import '../../../core/services/supabase_config.dart';
import '../../../core/services/supabase_service.dart';

enum AuthMode {
  unauthenticated,
  guest,
  authenticated,
}

class AuthRepository extends ChangeNotifier {
  AuthRepository() {
    _client = SupabaseService.client;
    _authSubscription = _client?.auth.onAuthStateChange.listen((event) async {
      final session = event.session;
      _isGuest = false;
      _user = session?.user;
      _profile = await _fetchProfile(_user?.id);
      notifyListeners();
    });
  }

  SupabaseClient? _client;
  StreamSubscription<AuthState>? _authSubscription;
  User? _user;
  UserProfile? _profile;
  bool _isGuest = false;

  User? get user => _user;
  UserProfile? get profile => _profile;
  bool get isConfigured => SupabaseConfig.isConfigured;
  AuthMode get authMode {
    if (_isGuest) {
      return AuthMode.guest;
    }
    if (_user != null) {
      return AuthMode.authenticated;
    }
    return AuthMode.unauthenticated;
  }

  String get displayName {
    if (_isGuest) {
      return 'Guest User';
    }

    final metadataName = _user?.userMetadata?['full_name']?.toString();
    if (metadataName != null && metadataName.isNotEmpty) {
      return metadataName;
    }

    final email = _user?.email;
    if (email != null && email.isNotEmpty) {
      return email.split('@').first;
    }

    return 'Coffee Admin';
  }

  String get emailOrLabel => _isGuest ? 'Guest Session' : (_user?.email ?? 'No email');

  Future<void> restoreSession() async {
    _client = SupabaseService.client;
    _user = _client?.auth.currentUser;
    _profile = await _fetchProfile(_user?.id);
    notifyListeners();
  }

  Future<void> signInAsGuest() async {
    _isGuest = true;
    _user = null;
    _profile = const UserProfile(id: 'guest', role: 'Guest');
    notifyListeners();
  }

  Future<String?> signInWithEmail({
    required String email,
    required String password,
  }) async {
    if (_client == null) {
      return 'Supabase is not configured yet. Add your URL and anon key first.';
    }

    try {
      final response = await _client!.auth.signInWithPassword(
        email: email,
        password: password,
      );
      _isGuest = false;
      _user = response.user;
      _profile = await _fetchProfile(_user?.id);
      notifyListeners();
      return null;
    } on AuthException catch (error) {
      return error.message;
    } catch (error) {
      return error.toString();
    }
  }

  Future<String?> signInWithGoogle() async {
    if (_client == null) {
      return 'Supabase is not configured yet. Add your URL and anon key first.';
    }

    try {
      await _client!.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: kIsWeb ? null : 'io.supabase.flutterquickstart://login-callback/',
      );
      return null;
    } on AuthException catch (error) {
      return error.message;
    } catch (error) {
      return error.toString();
    }
  }

  Future<void> signOut() async {
    _isGuest = false;
    _profile = null;
    final activeClient = _client;
    if (activeClient != null && activeClient.auth.currentSession != null) {
      await activeClient.auth.signOut();
    }
    _user = null;
    notifyListeners();
  }

  Future<UserProfile?> _fetchProfile(String? userId) async {
    if (userId == null || _client == null) {
      return null;
    }

    try {
      final data = await _client!
          .from('profiles')
          .select('id, role')
          .eq('id', userId)
          .maybeSingle();

      if (data == null) {
        return null;
      }

      return UserProfile.fromMap(data);
    } catch (_) {
      return null;
    }
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}
