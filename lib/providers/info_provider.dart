import 'package:epos_application/components/models.dart';
import 'package:flutter/material.dart';

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
}
