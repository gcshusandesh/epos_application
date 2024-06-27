import 'package:flutter/material.dart';

class RestaurantInfo {
  final String name;
  final String vatNumber;
  final String address;
  final String postcode;
  final String countryOfOperation;
  final String logoUrl;

  RestaurantInfo({
    required this.name,
    required this.vatNumber,
    required this.address,
    required this.postcode,
    required this.countryOfOperation,
    required this.logoUrl,
  });
}

class SystemInfo {
  final String versionNumber;
  final String language;
  final String currencySymbol;
  Color primaryColor;
  Color iconsColor;

  SystemInfo({
    required this.versionNumber,
    required this.language,
    required this.currencySymbol,
    required this.primaryColor,
    required this.iconsColor,
  });
}

class Employee {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String gender;
  bool status;
  bool isOwner = false;

  Employee({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.gender,
    required this.status,
    this.isOwner = false,
  });
}

class Specials {
  final String name;
  final String image;
  bool status;

  Specials({
    required this.name,
    required this.image,
    required this.status,
  });
}

class Category {
  final String name;
  final String image;
  bool status;
  bool isSelected = false;

  Category({
    required this.name,
    required this.image,
    required this.status,
  });
}

class MenuItemsByCategory {
  Category category;
  List<MenuItems> menuItems;
  MenuItemsByCategory({
    required this.category,
    required this.menuItems,
  });
}

class MenuItems {
  final String name;
  final String image;
  final String description;
  final String ingredients;
  final int price;
  bool status;

  MenuItems({
    required this.name,
    required this.image,
    required this.description,
    required this.ingredients,
    required this.price,
    required this.status,
  });
}
