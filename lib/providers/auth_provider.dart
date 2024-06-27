import 'package:epos_application/components/models.dart';
import 'package:flutter/material.dart';

class InfoProvider extends ChangeNotifier {
  Employee user = Employee(
    id: "1",
    name: "Bob Smith",
    email: "bob@gmail.com",
    phone: "+44 999999999",
    gender: "Male",
    status: true,
    isOwner: true,
  );

  void editUserDetails(Employee editedDetails) {
    user = editedDetails;
    notifyListeners();
  }
}
