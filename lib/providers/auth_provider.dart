import 'dart:convert';

import 'package:epos_application/components/data.dart';
import 'package:epos_application/components/models.dart';
import 'package:epos_application/screens/error_screen.dart';
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

  Future<bool> login(
      {required bool init,
      required String username,
      required String password,
      required BuildContext context}) async {
    var url = Uri.parse("${Data.baseUrl}/api/auth/local?populate=*");
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
          id: userData["id"],
          name: userData["name"],
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
        return true;
      } else {
        return false;
      }
    } catch (e) {
      // TODO: need to handle this error
      if (context.mounted) {
        // Navigate to Error Page
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ErrorScreen()),
        );
      }
      if (context.mounted) {
        //retry api
        await login(
            init: init,
            username: username,
            password: password,
            context: context);
      }
      return false;
    }
  }

  Future<void> getUserImage(
      {required bool init, required BuildContext context}) async {
    var url = Uri.parse("${Data.baseUrl}/api/users/me?populate=image");
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
        user.imageUrl =
            "${Data.baseUrl}${data["image"]["formats"]["small"]["url"]}";
        if (!init) {
          notifyListeners();
        }
      }
    } catch (e) {
      // TODO: need to handle this error
      if (context.mounted) {
        // Navigate to Error Page
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ErrorScreen()),
        );
      }
      if (context.mounted) {
        //retry api
        await getUserImage(init: init, context: context);
      }
    }
  }

  void updateUserDetailsLocally(User editedDetails) {
    user = editedDetails;
    notifyListeners();
  }

  Future<bool> updateUserDetails(
      {required BuildContext context, required User editedDetails}) async {
    var url = Uri.parse("${Data.baseUrl}/api/users/${user.id}");
    try {
      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer ${user.accessToken!}',
      };
      print("Gender ${editedDetails.gender}");
      Map<String, String> body = {
        "name": editedDetails.name,
        "email": editedDetails.email,
        "phone": editedDetails.phone,
        "gender": editedDetails.gender,
      };

      final response = await http.put(Uri.parse(url.toString()),
          headers: headers, body: jsonEncode(body));
      if (response.statusCode == 200) {
        updateUserDetailsLocally(editedDetails);
        return true;
      }
      return false;
    } catch (e) {
      // TODO: need to handle this error
      if (context.mounted) {
        // Navigate to Error Page
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ErrorScreen()),
        );
      }
      if (context.mounted) {
        //retry api
        await updateUserDetails(editedDetails: editedDetails, context: context);
      }
    }
    return false;
  }

  Future<int> updateUserPassword(
      {required BuildContext context,
      required String currentPassword,
      required newPassword}) async {
    var url = Uri.parse("${Data.baseUrl}/api/auth/change-password");
    try {
      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer ${user.accessToken!}',
      };
      Map<String, String> body = {
        "currentPassword": currentPassword,
        "password": newPassword,
        "passwordConfirmation": newPassword
      };
      final response = await http.post(Uri.parse(url.toString()),
          headers: headers, body: jsonEncode(body));
      if (response.statusCode == 200) {}
      return response.statusCode;
    } catch (e) {
      // TODO: need to handle this error
      if (context.mounted) {
        // Navigate to Error Page
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ErrorScreen()),
        );
      }
      if (context.mounted) {
        //retry api
        await updateUserPassword(
            context: context,
            currentPassword: currentPassword,
            newPassword: newPassword);
      }
      return 0;
    }
  }

  UserType assignUserType(String userType) {
    return user.userType;
  }
}
