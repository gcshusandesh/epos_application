import 'dart:convert';

import 'package:epos_application/components/data.dart';
import 'package:epos_application/components/models.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AuthProvider extends ChangeNotifier {
  User user = User(
    id: "1",
    name: "Bob Smith",
    imageUrl: "assets/profile_picture.png",
    email: "bob@gmail.com",
    phone: "+44 999999999",
    gender: "Male",
    blocked: false,
    userType: UserType.owner,
    accessToken: "placeholder",
  );

  void updateUserDetails(User editedDetails) {
    user = editedDetails;
    notifyListeners();
  }

  Future<bool> login(
      {required bool init,
      required String username,
      required String password}) async {
    var url = Uri.parse("${Data.baseUrl}/api/auth/local");
    try {
      Map<String, String> body = {"identifier": username, "password": password};
      final response = await http.post(
        Uri.parse(url.toString()),
        // no headers passed in login API
        body: body,
      );
      final data = json.decode(response.body);
      if (response.statusCode == 200) {
        // ignore: avoid_print
        print(data);
      }
      user = User(
        id: "1",
        name: "Shusandesh G C",
        imageUrl: "assets/profile_picture.png",
        email: "shusandesh@gmail.com",
        phone: "+44 9999999990",
        gender: "Male",
        blocked: false,
        userType: UserType.chef,
        accessToken: data["jwt"],
      );
      if (!init) {
        notifyListeners();
      }
      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      // ignore: avoid_print
      print(e);
      // TODO: need to handle this error
      rethrow;
    }
  }
}
