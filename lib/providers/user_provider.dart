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
    required String username,
    required String email,
    required String phone,
    required String gender,
    required String userType,
    required BuildContext context,
  }) async {
    var url = Uri.parse("${Data.baseUrl}/api/auth/local/register");

    String generatePassword({int length = 8}) {
      const String chars =
          "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
      Random random = Random.secure();
      return List.generate(
          length, (index) => chars[random.nextInt(chars.length)]).join('');
    }

    String password = generatePassword();
    try {
      Map<String, String> body = {
        "username": username,
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
      if (response.statusCode == 200) {
        // Send account creation email
        if (context.mounted) {
          sendAccountCreationEmail(
              email: email,
              username: username,
              password: password,
              context: context);
        }
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
            username: username,
            email: email,
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
            username: username,
            email: email,
            phone: phone,
            gender: gender,
            userType: userType,
            context: context);
      }
      return false;
    }
  }

  Future<bool> sendAccountCreationEmail({
    required String email,
    required String username,
    required String password,
    required BuildContext context,
  }) async {
    var url = Uri.parse("${Data.baseUrl}/api/email");
    try {
      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };
      Map<String, String> body = {
        "to": email,
        "subject": "Account Creation",
        "html":
            "<!DOCTYPE html>\n<html lang=\"en\">\n<head>\n<meta charset=\"UTF-8\">\n<meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0\">\n<title>Account Creation</title>\n<style>\nbody {\nfont-family: Arial, sans-serif;\nbackground-color: #f4f4f4;\nmargin: 0;\npadding: 0;\n}\n.container {\nbackground-color: #ffffff;\nmargin: 50px auto;\npadding: 20px;\nborder-radius: 8px;\nbox-shadow: 0 0 10px rgba(0, 0, 0, 0.1);\nwidth: 80%;\nmax-width: 600px;\n}\n.header {\ntext-align: center;\nborder-bottom: 1px solid #dddddd;\npadding-bottom: 20px;\n}\n.header h1 {\nmargin: 0;\ncolor: #333333;\n}\n.content {\nmargin-top: 20px;\n}\n.content p {\nline-height: 1.6;\ncolor: #555555;\n}\n.details {\nmargin-top: 20px;\npadding: 10px;\nbackground-color: #f9f9f9;\nborder: 1px solid #dddddd;\nborder-radius: 4px;\n}\n.details p {\nmargin: 5px 0;\n}\n.footer {\nmargin-top: 20px;\ntext-align: center;\ncolor: #888888;\n}\n</style>\n</head>\n<body>\n<div class=\"container\">\n<div class=\"header\">\n<h1>Account Creation</h1>\n</div>\n<div class=\"content\">\n<p>A new user account has been created for you in the Restaurant EPOS App. Please note your details:</p>\n<div class=\"details\">\n<p><strong>Username:</strong> $username</p>\n<p><strong>Password:</strong> $password</p>\n</div>\n</div>\n<div class=\"footer\">\n<p>&copy; 2024 Restaurant EPOS App</p>\n</div>\n</div>\n</body>\n</html>"
      };
      final response = await http.post(
        Uri.parse(url.toString()),
        headers: headers,
        body: jsonEncode(body),
      );
      if (response.statusCode == 200) {
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
                trace: " sendAccountCreationEmail",
              ),
            ));
      }
      if (context.mounted) {
        //retry api
        await sendAccountCreationEmail(
            username: username,
            email: email,
            password: password,
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
                trace: " sendAccountCreationEmail",
              ),
            ));
      }
      if (context.mounted) {
        //retry api
        await sendAccountCreationEmail(
            username: username,
            email: email,
            password: password,
            context: context);
      }
      return false;
    }
  }

  Future<void> getUserList(
      {required UserDataModel user, required BuildContext context}) async {
    var url = Uri.parse("${Data.baseUrl}/api/users?populate=image");
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
                imageUrl: user["image"] == null
                    ? null
                    : "${Data.baseUrl}${user["image"]["formats"]["small"]["url"]}",
                name: user["name"],
                username: user["username"],
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
                imageUrl: user["image"] == null
                    ? null
                    : "${Data.baseUrl}${user["image"]["formats"]["small"]["url"]}",
                name: user["name"],
                username: user["username"],
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
