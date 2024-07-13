import 'dart:convert';
import 'dart:io';

import 'package:epos_application/components/data.dart';
import 'package:epos_application/components/models.dart';
import 'package:epos_application/screens/error_screen.dart';
import 'package:epos_application/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

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
          isLoggedIn: true,
        );
        if (!init) {
          notifyListeners();
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
              ),
            ));
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
    } catch (e) {
      if (context.mounted) {
        // Navigate to Error Page
        await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ErrorScreen(),
            ));
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

  void logout({required BuildContext context}) {
    user.isLoggedIn = false;
    // Clear navigation stack
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (Route<dynamic> route) => false);
    //show success messsage
    showTopSnackBar(
      Overlay.of(context),
      const CustomSnackBar.success(
        message: "Logged Out Successfully",
      ),
    );
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
        await getUserImage(init: init, context: context);
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
        await updateUserDetails(editedDetails: editedDetails, context: context);
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
      required String newPassword,
      required String confirmNewPassword}) async {
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
        "passwordConfirmation": confirmNewPassword
      };
      final response = await http.post(Uri.parse(url.toString()),
          headers: headers, body: jsonEncode(body));
      if (response.statusCode == 200) {}
      if (response.statusCode == 400 &&
          response.body.contains("Passwords do not match")) {
        return 401;
      }
      return response.statusCode;
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
        await updateUserPassword(
            context: context,
            currentPassword: currentPassword,
            newPassword: newPassword,
            confirmNewPassword: confirmNewPassword);
      }
      return 0;
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
            newPassword: newPassword,
            confirmNewPassword: confirmNewPassword);
      }
      return 0;
    }
  }

  UserType assignUserType(String userType) {
    return user.userType;
  }
}
