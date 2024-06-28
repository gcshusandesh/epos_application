import 'package:epos_application/components/models.dart';
import 'package:flutter/material.dart';

class AuthProvider extends ChangeNotifier {
  User user = User(
    id: "1",
    name: "Bob Smith",
    imageUrl: "assets/profile_picture.png",
    email: "bob@gmail.com",
    phone: "+44 999999999",
    gender: "Male",
    status: true,
    userType: UserType.owner,
  );

  void updateUserDetails(User editedDetails) {
    user = editedDetails;
    notifyListeners();
  }
}
