import 'dart:convert';
import 'dart:io';

import 'package:epos_application/components/data.dart';
import 'package:epos_application/components/models.dart';
import 'package:epos_application/screens/error_screen.dart';
import 'package:epos_application/screens/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

class AuthProvider extends ChangeNotifier {
  UserDataModel user = UserDataModel(
    name: "Placeholder",
    username: "Placeholder",
    email: "Placeholder",
    phone: "Placeholder",
    gender: "Male",
    isBlocked: false,
    userType: UserType.owner,
  );

  bool stayLoggedIn = false;

  void changeStayLoggedInStatus({required bool stayLoggedIn}) {
    this.stayLoggedIn = stayLoggedIn;
    notifyListeners();
  }

  Future<bool> login({
    required bool init,
    required String username,
    required String password,
    required BuildContext context,
  }) async {
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
        user = UserDataModel(
          id: userData["id"],
          name: userData["name"],
          username: userData["username"],
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
                trace: "login",
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
              builder: (context) => ErrorScreen(
                trace: "login",
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
    }
  }

  ///cache management started
  // save user data to cache
  void addUserDataToSF() async {
    /// add user data to cache if only user has selected remember me
    if (stayLoggedIn) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String store = jsonEncode(UserDataModel.toMap(user));
      prefs.setString("userData", store);
      prefs.setBool("stayLoggedIn", stayLoggedIn);
      notifyListeners();
    }
  }

  // get user data from cache
  Future<void> getUserDataFromSF() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? retrieved = prefs.getString("userData");
    bool? retrievedStayLoggedInData = prefs.getBool("stayLoggedIn");

    if (retrieved != null) {
      Map<String, dynamic> decodedData = jsonDecode(retrieved);
      user = UserDataModel.fromJson(decodedData);
    }
    if (retrievedStayLoggedInData != null) {
      stayLoggedIn = prefs.getBool('stayLoggedIn')!;
    }
    notifyListeners();
  }

  void clearALLDataFromSF() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.clear();
    notifyListeners();
  }

  void logout({required BuildContext context}) {
    stayLoggedIn = false;
    user.isLoggedIn = false;
    clearALLDataFromSF();
    // Clear navigation stack
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const SplashScreen()),
        (Route<dynamic> route) => false);
    //show success messsage
    showTopSnackBar(
      Overlay.of(context),
      const CustomSnackBar.success(
        message: "Logged Out Successfully",
      ),
    );
  }

  Future<void> getUserDetails(
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
        String jwt = user.accessToken!;
        user = UserDataModel(
          id: data["id"],
          name: data["name"],
          username: data["username"],
          imageUrl: data["image"] == null
              ? null
              : "${Data.baseUrl}${data["image"]["formats"]["small"]["url"]}",
          email: data["email"],
          phone: data["phone"],
          gender: data["gender"],
          isBlocked: data["blocked"],
          userType: assignUserType(data["userType"]),
          accessToken: jwt,
          isLoggedIn: true,
        );

        /// add above login data along with image data to cache at once
        addUserDataToSF();

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
                trace: "getUserDetails",
              ),
            ));
      }
      if (context.mounted) {
        //retry api
        await getUserDetails(init: init, context: context);
      }
    } catch (e) {
      if (context.mounted) {
        // Navigate to Error Page
        await Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => ErrorScreen(
                    trace: "getUserDetails",
                  )),
        );
      }
      if (context.mounted) {
        //retry api
        await getUserDetails(init: init, context: context);
      }
    }
  }

  void updateUserDetailsLocally(UserDataModel editedDetails) {
    user = editedDetails;
    notifyListeners();
  }

  Future<bool> updateUserDetails(
      {required BuildContext context,
      required UserDataModel editedDetails,
      bool isLoggedIn = false}) async {
    var url = Uri.parse("${Data.baseUrl}/api/users/${editedDetails.id}");
    try {
      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer ${user.accessToken!}',
      };
      Map<String, String> body = {
        "username": editedDetails.username,
        "name": editedDetails.name,
        "email": editedDetails.email,
        "phone": editedDetails.phone,
        "gender": editedDetails.gender,
        "userType": editedDetails.userType.name,
      };

      final response = await http.put(Uri.parse(url.toString()),
          headers: headers, body: jsonEncode(body));
      if (response.statusCode == 200) {
        if (isLoggedIn) {
          updateUserDetailsLocally(editedDetails);

          ///save changes to cache
          addUserDataToSF();
        }

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
                trace: "updateUserDetails",
              ),
            ));
      }
      if (context.mounted) {
        //retry api
        await updateUserDetails(
            editedDetails: editedDetails,
            isLoggedIn: isLoggedIn,
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
                    trace: "updateUserDetails",
                  )),
        );
      }
      if (context.mounted) {
        //retry api
        await updateUserDetails(
            editedDetails: editedDetails,
            isLoggedIn: isLoggedIn,
            context: context);
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
      if (response.statusCode == 400 &&
          response.body.contains("Passwords do not match")) {
        return 403;
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
                trace: "updateUserPassword",
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
      if (context.mounted) {
        // Navigate to Error Page
        await Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => ErrorScreen(
                    trace: "updateUserPassword",
                  )),
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

  Future<int> resetUserPassword(
      {required BuildContext context, required String email}) async {
    var url = Uri.parse("${Data.baseUrl}/api/users/reset-password");
    try {
      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };
      Map<String, String> body = {
        "email": email,
      };
      final response = await http.post(Uri.parse(url.toString()),
          headers: headers, body: jsonEncode(body));
      if (response.statusCode == 400 &&
          response.body.contains("User not found")) {
        return 404;
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
                trace: "resetUserPassword",
              ),
            ));
      }
      if (context.mounted) {
        //retry api
        await resetUserPassword(
          context: context,
          email: email,
        );
      }
      return 0;
    } catch (e) {
      if (context.mounted) {
        // Navigate to Error Page
        await Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => ErrorScreen(
                    trace: "resetUserPassword",
                  )),
        );
      }
      if (context.mounted) {
        //retry api
        await resetUserPassword(
          context: context,
          email: email,
        );
      }
      return 0;
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

  void updateUserProfilePictureLocally({required String imageUrl}) {
    user.imageUrl = imageUrl;
    addUserDataToSF();
    notifyListeners();
  }
}
