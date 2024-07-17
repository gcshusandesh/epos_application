import 'dart:convert';
import 'dart:io';

import 'package:epos_application/components/data.dart';
import 'package:epos_application/components/models.dart';
import 'package:epos_application/screens/error_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class UserProvider extends ChangeNotifier {
  List<UserDataModel> userList = [];

  void changeUserStatusLocally(int index) {
    userList[index].isBlocked = !userList[index].isBlocked;
    notifyListeners();
  }

  void addUser(UserDataModel user) {
    userList.add(user);
    notifyListeners();
  }

  Future<void> getUserList(
      {required UserDataModel user, required BuildContext context}) async {
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
      if (response.statusCode == 200) {
        //empty list before fetching new data
        userList = [];
        data.forEach((user) {
          if (assignUserType(user["userType"]) != UserType.owner) {
            //exclude owner from the list
            userList.add(UserDataModel(
              id: user["id"],
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
    } on SocketException {
      if (context.mounted) {
        // Navigate to Error Page
        await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ErrorScreen(
                isConnectedToInternet: false,
              ),
            ));
      }
      if (context.mounted) {
        //retry api
        await getUserList(user: user, context: context);
      }
    } catch (e) {
      if (context.mounted) {
        // Navigate to Error Page
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ErrorScreen()),
        );
      }
      if (context.mounted) {
        //retry api
        await getUserList(user: user, context: context);
      }
    }
  }

  Future<bool> updateUserStatus({
    required BuildContext context,
    required String accessToken,
    required int id,
    required bool isBlocked,
  }) async {
    var url = Uri.parse("${Data.baseUrl}/api/users/$id");
    try {
      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $accessToken',
      };
      Map<String, dynamic> body = {"blocked": isBlocked};

      final response = await http.put(Uri.parse(url.toString()),
          headers: headers, body: jsonEncode(body));
      if (response.statusCode == 200) {
        // TODO: reflect change locally
        notifyListeners();
        return true;
      }
      return false;
    } on SocketException {
      if (context.mounted) {
        // Navigate to Error Page
        await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ErrorScreen(
                isConnectedToInternet: false,
              ),
            ));
      }
      if (context.mounted) {
        //retry api
        await updateUserStatus(
            accessToken: accessToken,
            id: id,
            isBlocked: isBlocked,
            context: context);
      }
      return false;
    } catch (e) {
      if (context.mounted) {
        // Navigate to Error Page
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ErrorScreen()),
        );
      }
      if (context.mounted) {
        //retry api
        await updateUserStatus(
            accessToken: accessToken,
            id: id,
            isBlocked: isBlocked,
            context: context);
      }
    }
    return false;
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
