import 'dart:convert';
import 'dart:io';

import 'package:epos_application/components/data.dart';
import 'package:epos_application/components/models.dart';
import 'package:epos_application/screens/error_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class InfoProvider extends ChangeNotifier {
  RestaurantInfo restaurantInfo = RestaurantInfo(
    name: null,
    imageUrl: null,
    vatNumber: null,
    address: null,
    postcode: null,
    countryOfOperation: "United Kingdom",
    logoUrl: null,
  );

  SystemInfo systemInfo = SystemInfo(
    versionNumber: "1.0.0",
    language: "English",
    currencySymbol: "£",
    primaryColor: const Color(0xff063B9D),
    iconsColor: const Color(0xff4071B6),
  );

  void resetDefaultSystemSettingsLocally() {
    systemInfo = SystemInfo(
      versionNumber: "1.0.0",
      language: "English",
      currencySymbol: "£",
      primaryColor: const Color(0xff063B9D),
      iconsColor: const Color(0xff4071B6),
    );
    notifyListeners();
  }

  void updateRestaurantImageLocally({required String imageUrl}) {
    restaurantInfo.imageUrl = imageUrl;
    addSettingsDataToSF();
    notifyListeners();
  }

  void updateRestaurantLogoLocally({required String logoUrl}) {
    restaurantInfo.logoUrl = logoUrl;
    addSettingsDataToSF();
    notifyListeners();
  }

  void updateSystemSettingsLocally({required SystemInfo editedSystemInfo}) {
    systemInfo = editedSystemInfo;
    notifyListeners();
  }

  /// cache management
  // save settings data to cache
  void addSettingsDataToSF() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String storeRestaurantInfo =
        jsonEncode(RestaurantInfo.toMap(restaurantInfo));
    String storeSystemInfo = jsonEncode(SystemInfo.toMap(systemInfo));
    prefs.setString("restaurantInfo", storeRestaurantInfo);
    prefs.setString("systemInfo", storeSystemInfo);
    notifyListeners();
  }

  // get settings data from cache
  Future<void> getSettingsDataFromSF() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? retrievedRestaurantInfo = prefs.getString("restaurantInfo");
    String? retrievedSystemInfo = prefs.getString("systemInfo");

    if (retrievedRestaurantInfo != null) {
      Map<String, dynamic> decodedRestaurantInfo =
          jsonDecode(retrievedRestaurantInfo);
      restaurantInfo = RestaurantInfo.fromJson(decodedRestaurantInfo);
    }
    if (retrievedSystemInfo != null) {
      Map<String, dynamic> decodedSystemInfo = jsonDecode(retrievedSystemInfo);
      systemInfo = SystemInfo.fromJson(decodedSystemInfo);
    }
    notifyListeners();
  }

  Future<bool> updateSystemSettings({
    required BuildContext context,
    required SystemInfo editedSystemInfo,
    bool isDefault = false,
  }) async {
    print("setting data");
    var url = Uri.parse("${Data.baseUrl}/api/setting");
    try {
      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };
      late Map<String, String> body;
      if (isDefault) {
        body = {
          "version": "1.0.0",
          "language": "English",
          "primaryColor": "063B9E",
          "iconColor": "4071B6",
          "currency": "£",
        };
      } else {
        body = {
          "primaryColor": colorToHexString(editedSystemInfo.primaryColor),
          "iconColor": colorToHexString(editedSystemInfo.iconsColor),
          "currency": editedSystemInfo.currencySymbol ?? "£",
        };
      }

      Map<String, dynamic> payloadBody = {
        "data": body,
      };
      final response = await http.put(Uri.parse(url.toString()),
          headers: headers, body: jsonEncode(payloadBody));
      if (response.statusCode == 200) {
        ///save data to cache
        addSettingsDataToSF();

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
                trace: "updateSystemSettings",
              ),
            ));
      }
      if (context.mounted) {
        //retry api
        await updateSystemSettings(
            context: context, editedSystemInfo: editedSystemInfo);
      }
      return false;
    } catch (e) {
      print("error = $e");
      if (context.mounted) {
        // Navigate to Error Page
        await Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => ErrorScreen(
                    trace: "updateSystemSettings",
                  )),
        );
      }
      if (context.mounted) {
        //retry api
        await updateSystemSettings(
            context: context, editedSystemInfo: editedSystemInfo);
      }
    }
    return false;
  }

  void updateRestaurantInfoLocally(
      {required RestaurantInfo editedRestaurantInfo}) {
    restaurantInfo = editedRestaurantInfo;
    notifyListeners();
  }

  void updateCountryInfoLocally({required String countryInfo}) {
    restaurantInfo.countryOfOperation = countryInfo;
    notifyListeners();
  }

  Future<bool> updateRestaurantSettings(
      {required BuildContext context,
      required UserDataModel user,
      required RestaurantInfo editedRestaurantInfo}) async {
    var url = Uri.parse("${Data.baseUrl}/api/setting");
    try {
      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };
      Map<String, String> body = {
        "name": editedRestaurantInfo.name!,
        "vat": editedRestaurantInfo.vatNumber!,
        "address": editedRestaurantInfo.address!,
        "postcode": editedRestaurantInfo.postcode!,
        "country": editedRestaurantInfo.countryOfOperation!,
      };

      Map<String, dynamic> payloadBody = {
        "data": body,
      };
      final response = await http.put(Uri.parse(url.toString()),
          headers: headers, body: jsonEncode(payloadBody));
      if (response.statusCode == 200) {
        updateRestaurantInfoLocally(editedRestaurantInfo: editedRestaurantInfo);

        ///save data to cache
        addSettingsDataToSF();
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
                trace: "updateRestaurantSettings",
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
      print("error = $e");
      if (context.mounted) {
        // Navigate to Error Page
        await Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => ErrorScreen(
                    trace: "updateRestaurantSettings",
                  )),
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
      if (response.statusCode == 200) {
        restaurantInfo = RestaurantInfo(
          name: result["name"],
          imageUrl: result["image"]["data"] == null
              ? null
              : "${Data.baseUrl}${result["image"]["data"]["attributes"]["formats"]["small"]["url"]}",
          vatNumber: result["vat"],
          address: result["address"],
          postcode: result["postcode"],
          countryOfOperation: result["country"] ?? "United Kingdom",
          logoUrl: result["logo"]["data"] == null
              ? null
              : "${Data.baseUrl}${result["logo"]["data"]["attributes"]["url"]}",
          hasAdmin: result["hasAdmin"] ?? false,
        );
        systemInfo = SystemInfo(
          versionNumber: result["version"],
          language: result["language"],
          currencySymbol: result["currency"],
          primaryColor: hexStringToColor(
              result["primaryColor"] ?? "populateDefaultPrimaryColor"),
          iconsColor: hexStringToColor(
              result["iconColor"] ?? "populateDefaultIconsColor"),
        );

        ///save data to cache
        addSettingsDataToSF();
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
                trace: "getSettings",
              ),
            ));
      }
      if (context.mounted) {
        //retry api
        await getSettings(context: context);
      }
    } catch (e) {
      if (context.mounted) {
        print(e);
        // Navigate to Error Page
        await Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => ErrorScreen(
                    trace: "getSettings",
                  )),
        );
      }
      if (context.mounted) {
        //retry api
        await getSettings(context: context);
      }
    }
  }

  Color hexStringToColor(String hexColor) {
    if (hexColor == "populateDefaultPrimaryColor") {
      return const Color(0xff063B9D);
    } else if (hexColor == "populateDefaultIconsColor") {
      return const Color(0xff4071B6);
    } else {
      final int colorInt = int.parse('0xff$hexColor');
      // Return the Color object
      return Color(colorInt);
    }
  }

  String colorToHexString(Color color) {
    // Get the ARGB values from the color
    int alpha = color.alpha;
    int red = color.red;
    int green = color.green;
    int blue = color.blue;

    // Format the ARGB values into a hex string
    return '${alpha.toRadixString(16).padLeft(2, '0')}'
        '${red.toRadixString(16).padLeft(2, '0')}'
        '${green.toRadixString(16).padLeft(2, '0')}'
        '${blue.toRadixString(16).padLeft(2, '0')}';
  }
}
