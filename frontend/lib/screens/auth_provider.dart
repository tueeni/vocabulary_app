import 'package:flutter/material.dart';

class AuthProvider with ChangeNotifier {
  String? _token;

  bool get isAuthenticated => _token != null;

  void login(String token) {
    _token = token;
    notifyListeners();
  }

  void logout() {
    _token = null;
    notifyListeners();
  }

  String? get token => _token;
}
