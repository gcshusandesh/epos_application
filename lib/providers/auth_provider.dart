import 'dart:convert';

import 'package:epos_application/components/data.dart';
import 'package:epos_application/components/models.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AuthProvider extends ChangeNotifier {
  User user = User(
    name: "Bob Smith",
    imageUrl: "assets/profile_picture.png",
    email: "bob@gmail.com",
    phone: "+44 999999999",
    gender: "Male",
    isBlocked: false,
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
        final userData = data["user"];
        user = User(
          name: userData["name"],
          // TODO: solve image issue
          imageUrl: "",
          email: userData["email"],
          phone: userData["phone"],
          gender: userData["gender"],
          isBlocked: userData["blocked"],
          userType: assignUserType(userData["userType"]),
          accessToken: data["jwt"],
        );
        if (!init) {
          notifyListeners();
        }
        print(user);
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

  UserType assignUserType(String userType) {
    return user.userType;
  }
}
