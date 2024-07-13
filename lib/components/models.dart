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

enum UserType {
  owner,
  manager,
  waiter,
  chef,
}

class UserDataModel {
  final int? id;
  String name;
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
