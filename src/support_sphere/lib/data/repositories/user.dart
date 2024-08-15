import 'dart:async';

import 'package:support_sphere/data/models/user.dart';
import 'package:uuid/uuid.dart';

class UserRepository {
  User? _user;

  Future<User?> getUser() async {
    if (_user != null) return _user;
    // TODO: Fetch user from API
    return Future.delayed(
      const Duration(milliseconds: 300),
      () => _user = User(uuid: const Uuid().v4()),
    );
  }
}