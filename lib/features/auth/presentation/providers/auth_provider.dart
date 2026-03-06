import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Default credentials for demo
const _defaultEmail = 'demo@techgadol.com';
const _defaultPassword = 'Demo1234';

const _prefsKeyLoggedIn = 'is_logged_in';
const _prefsKeySessionExpiry = 'session_expiry';
const _prefsKeyUsers = 'registered_users';
const _prefsKeyCurrentUser = 'current_user_email';

// Session lasts 30 days
const _sessionDurationDays = 30;

class AuthState {
  final bool isLoggedIn;
  final bool isLoading;
  final String? errorMessage;
  final String? currentUserEmail;
  final String? currentUserName;

  const AuthState({
    this.isLoggedIn = false,
    this.isLoading = false,
    this.errorMessage,
    this.currentUserEmail,
    this.currentUserName,
  });

  AuthState copyWith({
    bool? isLoggedIn,
    bool? isLoading,
    String? errorMessage,
    String? currentUserEmail,
    String? currentUserName,
  }) {
    return AuthState(
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      currentUserEmail: currentUserEmail ?? this.currentUserEmail,
      currentUserName: currentUserName ?? this.currentUserName,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(const AuthState()) {
    _checkSession();
  }

  Future<void> _checkSession() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool(_prefsKeyLoggedIn) ?? false;
    final expiryMs = prefs.getInt(_prefsKeySessionExpiry) ?? 0;
    final now = DateTime.now().millisecondsSinceEpoch;

    if (isLoggedIn && expiryMs > now) {
      final email = prefs.getString(_prefsKeyCurrentUser) ?? '';
      final name = _getUserName(prefs, email);
      state = state.copyWith(
        isLoggedIn: true,
        currentUserEmail: email,
        currentUserName: name,
      );
    } else if (isLoggedIn) {
      // Session expired
      await _clearSession(prefs);
    }
  }

  String _getUserName(SharedPreferences prefs, String email) {
    final usersJson = prefs.getString(_prefsKeyUsers);
    if (usersJson != null) {
      final users = jsonDecode(usersJson) as Map<String, dynamic>;
      if (users.containsKey(email)) {
        return (users[email] as Map<String, dynamic>)['name'] as String? ?? '';
      }
    }
    if (email == _defaultEmail) return 'Demo User';
    return '';
  }

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));

    final prefs = await SharedPreferences.getInstance();

    // Check default credentials
    if (email == _defaultEmail && password == _defaultPassword) {
      await _saveSession(prefs, email, 'Demo User');
      return true;
    }

    // Check registered users
    final usersJson = prefs.getString(_prefsKeyUsers);
    if (usersJson != null) {
      final users = jsonDecode(usersJson) as Map<String, dynamic>;
      if (users.containsKey(email)) {
        final user = users[email] as Map<String, dynamic>;
        if (user['password'] == password) {
          await _saveSession(prefs, email, user['name'] as String);
          return true;
        }
      }
    }

    state = state.copyWith(
      isLoading: false,
      errorMessage: 'Invalid email or password. Try demo@techgadol.com / Demo1234',
    );
    return false;
  }

  Future<bool> signup({
    required String fullName,
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    await Future.delayed(const Duration(milliseconds: 800));

    final prefs = await SharedPreferences.getInstance();

    // Check if user exists
    final usersJson = prefs.getString(_prefsKeyUsers);
    Map<String, dynamic> users = {};
    if (usersJson != null) {
      users = jsonDecode(usersJson) as Map<String, dynamic>;
    }

    if (users.containsKey(email) || email == _defaultEmail) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'An account with this email already exists.',
      );
      return false;
    }

    // Register user
    users[email] = {
      'name': fullName,
      'password': password,
    };
    await prefs.setString(_prefsKeyUsers, jsonEncode(users));

    state = state.copyWith(isLoading: false);
    return true;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await _clearSession(prefs);
    state = const AuthState();
  }

  Future<void> _saveSession(SharedPreferences prefs, String email, String name) async {
    final expiry = DateTime.now()
        .add(const Duration(days: _sessionDurationDays))
        .millisecondsSinceEpoch;
    await prefs.setBool(_prefsKeyLoggedIn, true);
    await prefs.setInt(_prefsKeySessionExpiry, expiry);
    await prefs.setString(_prefsKeyCurrentUser, email);

    state = state.copyWith(
      isLoggedIn: true,
      isLoading: false,
      currentUserEmail: email,
      currentUserName: name,
    );
  }

  Future<void> _clearSession(SharedPreferences prefs) async {
    await prefs.remove(_prefsKeyLoggedIn);
    await prefs.remove(_prefsKeySessionExpiry);
    await prefs.remove(_prefsKeyCurrentUser);
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});
