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
    versionNumber: "1.0.0",
    language: "English",
    currencySymbol: "£",
    primaryColor: const Color(0xff063B9D),
    iconsColor: const Color(0xff4071B6),
  );

  void resetDefaultSystemSettings() {
    systemInfo = SystemInfo(
      versionNumber: "1.0.0",
      language: "English",
      currencySymbol: "£",
      primaryColor: const Color(0xff063B9D),
      iconsColor: const Color(0xff4071B6),
    );
    notifyListeners();
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
        restaurantInfo.imageUrl = result["image"]["data"] == null
            ? null
            : "${Data.baseUrl}${result["image"]["formats"]["small"]["url"]}";
        restaurantInfo.logoUrl = result["logo"]["data"] == null
            ? null
            : "${Data.baseUrl}${result["image"]["formats"]["small"]["url"]}";

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
}
