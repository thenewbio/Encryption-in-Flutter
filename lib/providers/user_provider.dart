import 'package:flutter/widgets.dart';
import 'package:pass_man/providers/auth_provider.dart';

import '../model/user.dart';

class UserProvider with ChangeNotifier {
  User? _user;
  final AuthProvider _authMethods = AuthProvider();

  User get getUser => _user!;

  Future<void> refreshUser() async {
    User? user = await _authMethods.getUserDetails();
    _user = user;
    notifyListeners();
  }
}
