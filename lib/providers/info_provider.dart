import 'dart:convert';

import 'package:epos_application/components/models.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class InfoProvider extends ChangeNotifier {
  RestaurantInfo restaurantInfo = RestaurantInfo(
    name: "Bob's Diner",
    vatNumber: "113468",
    address: "Oxford Road",
    postcode: "OX1 1XX",
    countryOfOperation: "United Kingdom",
    logoUrl: "assets/logo.png",
  );

  SystemInfo systemInfo = SystemInfo(
    versionNumber: "1.0.0",
    language: "English",
    currencySymbol: "£",
    primaryColor: const Color(0xff063B9D),
    iconsColor: const Color(0xff4071B6),
  );

  String baseUrl = "https://restaurantepos.xyz";

  Future<void> getTestData() async {
    var url = Uri.parse("$baseUrl/api/testdatas/1");
    try {
      var headers = {
        "Accept": "application/json",
      };
      var response = await http.get(url, headers: headers);
      var extractedData = json.decode(response.body);
      if (response.statusCode == 200) {
        // ignore: avoid_print
        print(extractedData);
      }
      notifyListeners();
    } catch (e) {
      // ignore: avoid_print
      print(e);
    }
  }
}
