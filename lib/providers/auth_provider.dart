import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';
import '../main.dart'; // import supabase client

class AuthState {
  final UserModel? currentUser;
  final bool isLoading;
  final String? errorMessage;

  const AuthState({
    this.currentUser,
    this.isLoading = false,
    this.errorMessage,
  });

  bool get isLoggedIn => currentUser != null;

  AuthState copyWith({
    UserModel? currentUser,
    bool? isLoading,
    String? errorMessage,
    bool clearUser = false,
  }) {
    return AuthState(
      currentUser: clearUser ? null : (currentUser ?? this.currentUser),
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

class AuthNotifier extends Notifier<AuthState> {
  
  @override
  AuthState build() {
    // Cek session saat ini jika user sudah login sebelumnya
    _checkCurrentSession();
    return const AuthState();
  }

  Future<void> _checkCurrentSession() async {
    final session = supabase.auth.currentSession;
    if (session != null) {
      await _fetchUserProfile(session.user.id);
    }
  }

  Future<void> _fetchUserProfile(String userId) async {
    try {
      final response = await supabase.from('users').select().eq('id', userId).single();
      final user = UserModel.fromJson(response);
      state = state.copyWith(currentUser: user, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: 'Gagal memuat profil: $e');
    }
  }

  Future<bool> login(String username, String password) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      // 1. Cari email berdasarkan username di tabel public.users
      final userRecord = await supabase.from('users').select('email').eq('username', username).maybeSingle();
      
      if (userRecord == null) {
        throw Exception('Username tidak ditemukan');
      }

      final email = userRecord['email'] as String;

      // 2. Login menggunakan Supabase Auth dengan email yang ditemukan
      final AuthResponse res = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (res.user != null) {
        await _fetchUserProfile(res.user!.id);
        return true;
      } else {
        throw Exception('Gagal login');
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e is AuthException ? e.message : e.toString().replaceAll('Exception: ', ''),
      );
      return false;
    }
  }

  Future<bool> register({
    required String name,
    required String email,
    required String username,
    required String password,
    required String department,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      // Cek apakah username sudah ada
      final existingUser = await supabase.from('users').select('id').eq('username', username).maybeSingle();
      if (existingUser != null) {
        throw Exception('Username sudah digunakan');
      }

      // 1. Register di Supabase Auth
      final AuthResponse res = await supabase.auth.signUp(
        email: email,
        password: password,
      );

      if (res.user != null) {
        // 2. Insert profil ke tabel public.users
        final newUser = UserModel(
          id: res.user!.id,
          name: name,
          email: email,
          username: username,
          role: UserRole.user, // default role
          department: department,
        );

        await supabase.from('users').insert(newUser.toJson());

        state = state.copyWith(currentUser: newUser, isLoading: false);
        return true;
      }
      return false;
    } catch (e) {
      state = state.copyWith(
        isLoading: false, 
        errorMessage: e is AuthException ? e.message : e.toString().replaceAll('Exception: ', '')
      );
      return false;
    }
  }

  Future<void> resetPassword(String email) async {
    state = state.copyWith(isLoading: true);
    try {
      await supabase.auth.resetPasswordForEmail(email);
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: 'Gagal mereset password');
    }
  }

  Future<void> logout() async {
    await supabase.auth.signOut();
    state = const AuthState();
  }

  Future<bool> updateProfilePicture(File imageFile) async {
    if (state.currentUser == null) return false;
    
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final userId = state.currentUser!.id;
      final fileExt = imageFile.path.split('.').last;
      final fileName = '$userId-${DateTime.now().millisecondsSinceEpoch}.$fileExt';
      
      // Upload ke Supabase Storage (bucket: avatars)
      await supabase.storage.from('avatars').upload(
        fileName,
        imageFile,
        fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
      );
      
      // Dapatkan public URL
      final publicUrl = supabase.storage.from('avatars').getPublicUrl(fileName);
      
      // Update tabel users
      await supabase.from('users').update({'avatar_url': publicUrl}).eq('id', userId);
      
      // Update state lokal
      final updatedUser = UserModel(
        id: state.currentUser!.id,
        name: state.currentUser!.name,
        email: state.currentUser!.email,
        username: state.currentUser!.username,
        role: state.currentUser!.role,
        department: state.currentUser!.department,
        avatarUrl: publicUrl,
      );
      
      state = state.copyWith(currentUser: updatedUser, isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Gagal mengunggah foto profil: $e'
      );
      return false;
    }
  }
}

final NotifierProvider<AuthNotifier, AuthState> authProvider = NotifierProvider<AuthNotifier, AuthState>(
  () => AuthNotifier(),
);