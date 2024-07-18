import 'dart:convert';
import 'dart:io';
import 'dart:math';

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

  void editUserLocally(
      {required int index, required UserDataModel editedUser}) {
    userList[index].name = editedUser.name;
    userList[index].email = editedUser.email;
    userList[index].phone = editedUser.phone;
    userList[index].gender = editedUser.gender;
    userList[index].userType = editedUser.userType;
    notifyListeners();
  }

  void addUserLocally(UserDataModel user) {
    userList.add(user);
    notifyListeners();
  }

  Future<bool> createUser({
    required String name,
    required String email,
    required String password,
    required String phone,
    required String gender,
    required String userType,
    required BuildContext context,
  }) async {
    var url = Uri.parse("${Data.baseUrl}/api/auth/local/register");
    // Function to generate a random username
    String generateUsername(String name) {
      String firstName = name.split(' ')[0];
      int randomNumber = Random().nextInt(90) +
          10; // Generates a random number between 10 and 99
      return '$firstName$randomNumber';
    }

    try {
      Map<String, String> body = {
        "username": generateUsername(name),
        "name": name,
        "email": email,
        "password": password,
        "phone": phone,
        "gender": gender,
        "userType": userType,
      };
      final response = await http.post(
        Uri.parse(url.toString()),
        body: body,
      );
      final data = json.decode(response.body);
      if (response.statusCode == 200) {
        print("data = $data");
        notifyListeners();
        return true;
      } else {
        return false;
      }
    } on SocketException {
      if (context.mounted) {
        // Navigate to Error Page
        await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ErrorScreen(
                isConnectedToInternet: false,
                trace: "createUser",
              ),
            ));
      }
      if (context.mounted) {
        //retry api
        await createUser(
            name: name,
            email: email,
            password: password,
            phone: phone,
            gender: gender,
            userType: userType,
            context: context);
      }
      return false;
    } catch (e) {
      if (context.mounted) {
        // Navigate to Error Page
        await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ErrorScreen(
                trace: "createUser",
              ),
            ));
      }
      if (context.mounted) {
        //retry api
        await createUser(
            name: name,
            email: email,
            password: password,
            phone: phone,
            gender: gender,
            userType: userType,
            context: context);
      }
      return false;
    }
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
        UserType loggedInUserType = user.userType;
        data.forEach((user) {
          if (loggedInUserType == UserType.owner) {
            // Owner should see all employees, including managers, chefs, and waiters, but not other owners
            if (assignUserType(user["userType"]) != UserType.owner) {
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
          } else if (loggedInUserType == UserType.manager) {
            // Manager should see all employees except owners and managers
            if (assignUserType(user["userType"]) != UserType.owner &&
                assignUserType(user["userType"]) != UserType.manager) {
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
                trace: "getUserList",
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
          MaterialPageRoute(
              builder: (context) => ErrorScreen(
                    trace: "getUserList",
                  )),
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
                trace: "updateUserStatus",
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
          MaterialPageRoute(
              builder: (context) => ErrorScreen(
                    trace: "updateUserStatus",
                  )),
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
