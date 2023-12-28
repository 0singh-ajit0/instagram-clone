import 'package:flutter/widgets.dart';
import 'package:instagram_flutter/models/user.dart';
import 'package:instagram_flutter/resources/auth_methods.dart';

class UserProvider extends ChangeNotifier {
  User? _user;
  User? get getUser => _user;

  Future<void> refreshUser() async {
    User user = await AuthMethods.getUserDetails();
    _user = user;
    notifyListeners();
  }
}
