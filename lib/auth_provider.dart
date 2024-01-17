import 'package:flutter/material.dart';

class LocalAuthProvider with ChangeNotifier {
  String _userType = '';

  String get userType => _userType;

  void setUserType(String userType) {
    _userType = userType;
    notifyListeners();
  }
}
