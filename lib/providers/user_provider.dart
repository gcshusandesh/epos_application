import 'dart:convert';

import 'package:epos_application/components/data.dart';
import 'package:epos_application/components/models.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class UserProvider extends ChangeNotifier {
  List<UserDataModel> userList = [];

  void changeUserStatus(int index) {
    userList[index].isBlocked = !userList[index].isBlocked;
    notifyListeners();
  }

  void addUser(UserDataModel user) {
    userList.add(user);
    notifyListeners();
  }

  Future<void> getUserList({required UserDataModel user}) async {
    var url = Uri.parse("${Data.baseUrl}/api/users");
    try {
      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer ${user.accessToken!}',
      };
      final response =
          await http.get(Uri.parse(url.toString()), headers: headers);
      final data = json.decode(response.body);
      print("data$data");
      if (response.statusCode == 200) {
        data.forEach((user) {
          if (assignUserType(user["userType"]) != UserType.owner) {
            //exclude owner from the list
            userList.add(UserDataModel(
              name: user["name"],
              email: user["email"],
              phone: user["phone"],
              gender: user["gender"],
              isBlocked: user["blocked"],
              userType: assignUserType(user["userType"]),
            ));
          }
        });
      }

      notifyListeners();
    } catch (e) {
      // ignore: avoid_print
      print(e);
      // TODO: need to handle this error
      rethrow;
    }
  }

  UserType assignUserType(String userType) {
    if (userType == "owner") {
      return UserType.owner;
    } else if (userType == "manager") {
      return UserType.manager;
    } else if (userType == "waiter") {
      return UserType.waiter;
    } else {
      return UserType.chef;
    }
  }
}
