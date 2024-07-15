import 'dart:convert';
import 'dart:io';

import 'package:epos_application/components/data.dart';
import 'package:epos_application/components/models.dart';
import 'package:epos_application/screens/error_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class InfoProvider extends ChangeNotifier {
  RestaurantInfo restaurantInfo = RestaurantInfo(
    name: null,
    imageUrl: null,
    vatNumber: null,
    address: null,
    postcode: null,
    countryOfOperation: null,
    logoUrl: null,
  );

  SystemInfo systemInfo = SystemInfo(
    versionNumber: "X.X.X",
    language: "English",
    currencySymbol: "£",
    primaryColor: const Color(0xff063B9D),
    iconsColor: const Color(0xff4071B6),
  );

  void resetDefaultSystemSettingsLocally() {
    systemInfo = SystemInfo(
      versionNumber: "X.X.X",
      language: "English",
      currencySymbol: "£",
      primaryColor: const Color(0xff063B9D),
      iconsColor: const Color(0xff4071B6),
    );
    notifyListeners();
  }

  void updateSystemSettingsLocally({required SystemInfo editedSystemInfo}) {
    systemInfo = editedSystemInfo;
    notifyListeners();
  }

  Future<bool> updateSystemSettings({
    required BuildContext context,
    required UserDataModel user,
    required SystemInfo editedSystemInfo,
    bool isDefault = false,
  }) async {
    var url = Uri.parse("${Data.baseUrl}/api/users/${user.id}");
    try {
      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer ${user.accessToken!}',
      };
      late Map<String, String> body;
      if (isDefault) {
        body = {
          "primaryColor": "063B9E",
          "iconColor": "4071B6",
          "currency": "£",
        };
      } else {
        body = {
          "primaryColor": colorToHexString(systemInfo.primaryColor),
          "iconColor": colorToHexString(systemInfo.iconsColor),
          "currency": systemInfo.currencySymbol,
        };
      }

      Map<String, String> payloadBody = {
        "data": jsonEncode(body),
      };
      final response = await http.put(Uri.parse(url.toString()),
          headers: headers, body: jsonEncode(payloadBody));
      if (response.statusCode == 200) {
        print("body = ${response.body}");
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
        await updateSystemSettings(
            context: context, user: user, editedSystemInfo: editedSystemInfo);
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
        await updateSystemSettings(
            context: context, user: user, editedSystemInfo: editedSystemInfo);
      }
    }
    return false;
  }

  Future<bool> updateRestaurantSettings(
      {required BuildContext context,
      required UserDataModel user,
      required RestaurantInfo editedRestaurantInfo}) async {
    var url = Uri.parse("${Data.baseUrl}/api/users/${user.id}");
    try {
      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer ${user.accessToken!}',
      };
      Map<String, String> body = {
        "name": editedRestaurantInfo.name!,
        "vat": editedRestaurantInfo.vatNumber!,
        "address": editedRestaurantInfo.address!,
        "postcode": editedRestaurantInfo.postcode!,
        "country": editedRestaurantInfo.name!,
      };

      Map<String, String> payloadBody = {
        "data": jsonEncode(body),
      };

      final response = await http.put(Uri.parse(url.toString()),
          headers: headers, body: jsonEncode(payloadBody));
      if (response.statusCode == 200) {
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
        await updateRestaurantSettings(
            context: context,
            user: user,
            editedRestaurantInfo: editedRestaurantInfo);
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
        await updateRestaurantSettings(
            context: context,
            user: user,
            editedRestaurantInfo: editedRestaurantInfo);
      }
    }
    return false;
  }

  Future<void> getSettings({required BuildContext context}) async {
    var url = Uri.parse("${Data.baseUrl}/api/setting?populate=*");
    try {
      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };
      final response =
          await http.get(Uri.parse(url.toString()), headers: headers);
      final data = json.decode(response.body);
      final result = data["data"]["attributes"];
      print("System settings = $result");
      if (response.statusCode == 200) {
        restaurantInfo = RestaurantInfo(
          name: result["name"],
          imageUrl: result["image"]["data"] == null
              ? null
              : "${Data.baseUrl}${result["image"]["formats"]["small"]["url"]}",
          vatNumber: result["vat"],
          address: result["address"],
          postcode: result["postcode"],
          countryOfOperation: result["country"],
          logoUrl: result["logo"]["data"] == null
              ? null
              : "${Data.baseUrl}${result["image"]["formats"]["small"]["url"]}",
        );
        systemInfo = SystemInfo(
          versionNumber: result["version"],
          language: result["language"],
          currencySymbol: result["currency"],
          primaryColor: hexStringToColor(result["primaryColor"]),
          iconsColor: hexStringToColor(result["iconColor"]),
        );
        notifyListeners();
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
        await getSettings(context: context);
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
        await getSettings(context: context);
      }
    }
  }

  Color hexStringToColor(String hexColor) {
    final int colorInt = int.parse('0xff$hexColor');
    // Return the Color object
    return Color(colorInt);
  }

  String colorToHexString(Color color) {
    // Get the ARGB values from the color
    int alpha = color.alpha;
    int red = color.red;
    int green = color.green;
    int blue = color.blue;

    // Format the ARGB values into a hex string
    return '#${alpha.toRadixString(16).padLeft(2, '0')}'
        '${red.toRadixString(16).padLeft(2, '0')}'
        '${green.toRadixString(16).padLeft(2, '0')}'
        '${blue.toRadixString(16).padLeft(2, '0')}';
  }
}
