import 'dart:async';

import 'package:support_sphere/data/models/auth_user.dart';
import 'package:uuid/uuid.dart';

class UserRepository {
  AuthUser? _user;

  Future<AuthUser?> getUser() async {
    if (_user != null) return _user;
    // TODO: Fetch user from API
    return Future.delayed(
      const Duration(milliseconds: 300),
      () => _user = AuthUser(uuid: const Uuid().v4()),
    );
  }
}