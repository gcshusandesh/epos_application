import 'package:epos_application/components/models.dart';
import 'package:flutter/material.dart';

class UserProvider extends ChangeNotifier {
  List<User> userList = [];

  void changeUserStatus(int index) {
    userList[index].isBlocked = !userList[index].isBlocked;
    notifyListeners();
  }

  void addUser(User employee) {
    userList.add(employee);
    notifyListeners();
  }

  Future<void> getUsersList({required bool init}) async {
    // var url = Uri.parse("${Data.baseUrl}/api/testdatas/1");
    try {
      // var headers = {
      //   "Accept": "application/json",
      // };
      // var response = await http.get(url, headers: headers);
      // var extractedData = json.decode(response.body);
      // if (response.statusCode == 200) {
      //   print(extractedData);
      // }
      userList = [
        User(
          name: "Shusandesh G C",
          imageUrl: "assets/profile_picture.png",
          email: "shusandesh@gmail.com",
          phone: "+44 9999999990",
          gender: "Male",
          isBlocked: false,
          userType: UserType.chef,
        ),
        User(
          name: "Shreen Subedi",
          imageUrl: "assets/profile_picture.png",
          email: "shreeno@gmail.com",
          phone: "+44 9999999991",
          gender: "Female",
          isBlocked: false,
          userType: UserType.chef,
        ),
        User(
          name: "Jayant Kundal",
          imageUrl: "assets/profile_picture.png",
          email: "kundal@gmail.com",
          phone: "+44 9999999992",
          gender: "Male",
          isBlocked: false,
          userType: UserType.waiter,
        ),
        User(
          name: "Rajes Shenoy",
          imageUrl: "assets/profile_picture.png",
          email: "rajes@gmail.com",
          phone: "+44 9999999993",
          gender: "Male",
          isBlocked: false,
          userType: UserType.waiter,
        ),
        User(
          name: "Utkarsh Bhoumick",
          imageUrl: "assets/profile_picture.png",
          email: "utki@gmail.com",
          phone: "+44 9999999994",
          gender: "Male",
          isBlocked: false,
          userType: UserType.waiter,
        ),
        User(
          name: "Meghna Ghosh",
          imageUrl: "assets/profile_picture.png",
          email: "meg@gmail.com",
          phone: "+44 9999999995",
          gender: "Female",
          isBlocked: true,
          userType: UserType.waiter,
        ),
      ];
      if (!init) {
        notifyListeners();
      }
    } catch (e) {
      // ignore: avoid_print
      print(e);
      // TODO: need to handle this error
      rethrow;
    }
  }
}
