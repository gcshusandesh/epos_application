import 'package:flutter/material.dart';

class ExtraProvider extends ChangeNotifier {
  bool obscureText = true;

  void changeObscureText() {
    obscureText = !obscureText;
    notifyListeners();
  }
}
