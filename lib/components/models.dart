import 'package:flutter/material.dart';

class RestaurantInfo {
  String? name;
  String? imageUrl;
  String? vatNumber;
  String? address;
  String? postcode;
  String? countryOfOperation;
  String? logoUrl;

  RestaurantInfo({
    required this.name,
    required this.imageUrl,
    required this.vatNumber,
    required this.address,
    required this.postcode,
    required this.countryOfOperation,
    required this.logoUrl,
  });

  static Map<String, dynamic> toMap(RestaurantInfo restaurantInfo) => {
        'name': restaurantInfo.name,
        'imageUrl': restaurantInfo.imageUrl,
        'vatNumber': restaurantInfo.vatNumber,
        'address': restaurantInfo.address,
        'postcode': restaurantInfo.postcode,
        'countryOfOperation': restaurantInfo.countryOfOperation,
        'logoUrl': restaurantInfo.logoUrl,
      };

  factory RestaurantInfo.fromJson(Map<String, dynamic> jsonData) {
    return RestaurantInfo(
      name: jsonData['name'],
      imageUrl: jsonData['imageUrl'],
      vatNumber: jsonData['vatNumber'],
      address: jsonData['address'],
      postcode: jsonData['postcode'],
      countryOfOperation: jsonData['countryOfOperation'],
      logoUrl: jsonData['logoUrl'],
    );
  }
}

class SystemInfo {
  String versionNumber;
  String language;
  String currencySymbol;
  Color primaryColor;
  Color iconsColor;

  SystemInfo({
    required this.versionNumber,
    required this.language,
    required this.currencySymbol,
    required this.primaryColor,
    required this.iconsColor,
  });

  // Convert a SystemInfo object to a map
  static Map<String, dynamic> toMap(SystemInfo systemInfo) => {
        'versionNumber': systemInfo.versionNumber,
        'language': systemInfo.language,
        'currencySymbol': systemInfo.currencySymbol,
        'primaryColor': systemInfo.primaryColor.value,
        'iconsColor': systemInfo.iconsColor.value,
      };

  // Create a SystemInfo object from JSON data
  factory SystemInfo.fromJson(Map<String, dynamic> jsonData) {
    return SystemInfo(
      versionNumber: jsonData['versionNumber'],
      language: jsonData['language'],
      currencySymbol: jsonData['currencySymbol'],
      primaryColor: Color(jsonData['primaryColor']),
      iconsColor: Color(jsonData['iconsColor']),
    );
  }
}

enum UserType {
  owner,
  manager,
  waiter,
  chef,
}

class UserDataModel {
  final int? id;
  String name;
  String username;
  String? imageUrl;
  String email;
  String phone;
  String gender;
  bool isBlocked;
  UserType userType;
  String? accessToken;
  bool isLoggedIn;

  UserDataModel({
    this.id,
    required this.name,
    required this.username,
    this.imageUrl,
    required this.email,
    required this.phone,
    required this.gender,
    required this.isBlocked,
    required this.userType,
    this.accessToken,
    this.isLoggedIn = false,
  });

  static Map<String, dynamic> toMap(UserDataModel user) => {
        'id': user.id,
        'name': user.name,
        'username': user.username,
        'imageUrl': user.imageUrl,
        'email': user.email,
        'phone': user.phone,
        'gender': user.gender,
        'isBlocked': user.isBlocked,
        'userType': user.userType.toString(),
        'accessToken': user.accessToken,
        'isLoggedIn': user.isLoggedIn,
      };

  factory UserDataModel.fromJson(Map<String, dynamic> jsonData) {
    UserType userType;
    try {
      userType = UserType.values
          .firstWhere((e) => e.toString() == jsonData['userType']);
    } catch (e) {
      userType = UserType.waiter; // Provide a default value here
    }
    return UserDataModel(
      id: jsonData['id'],
      name: jsonData['name'],
      username: jsonData['username'],
      imageUrl: jsonData['imageUrl'],
      email: jsonData['email'],
      phone: jsonData['phone'],
      gender: jsonData['gender'],
      isBlocked: jsonData['isBlocked'],
      userType: userType,
      accessToken: jsonData['accessToken'],
      isLoggedIn: jsonData['isLoggedIn'],
    );
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

class Specials {
  String name;
  String? image;
  bool status;

  Specials({
    required this.name,
    this.image,
    required this.status,
  });
}

class Category {
  String name;
  String image;
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
  String name;
  String image;
  String description;
  String ingredients;
  int price;
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
