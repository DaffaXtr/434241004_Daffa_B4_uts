import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../main.dart'; // import supabase client

class UserNotifier extends Notifier<List<UserModel>> {
  @override
  List<UserModel> build() {
    Future.microtask(() => _loadUsers());
    return [];
  }

  Future<void> _loadUsers() async {
    try {
      final response = await supabase.from('users').select();
      final users = response.map((data) => UserModel.fromJson(data)).toList();
      state = users;
    } catch (e) {
      debugPrint('Error loading users: $e');
    }
  }
}

final allUsersProvider = NotifierProvider<UserNotifier, List<UserModel>>(() => UserNotifier());
