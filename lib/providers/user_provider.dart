import 'package:epos_application/components/models.dart';
import 'package:flutter/material.dart';

class UserProvider extends ChangeNotifier {
  List<User> userList = [];

  void changeUserStatus(int index) {
    userList[index].status = !userList[index].status;
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
          id: "1",
          name: "Shusandesh G C",
          imageUrl: "assets/profile_picture.png",
          email: "shusandesh@gmail.com",
          phone: "+44 9999999990",
          gender: "Male",
          status: true,
          userType: UserType.chef,
        ),
        User(
          id: "2",
          name: "Shreen Subedi",
          imageUrl: "assets/profile_picture.png",
          email: "shreeno@gmail.com",
          phone: "+44 9999999991",
          gender: "Female",
          status: true,
          userType: UserType.chef,
        ),
        User(
          id: "3",
          name: "Jayant Kundal",
          imageUrl: "assets/profile_picture.png",
          email: "kundal@gmail.com",
          phone: "+44 9999999992",
          gender: "Male",
          status: true,
          userType: UserType.waiter,
        ),
        User(
          id: "4",
          name: "Rajes Shenoy",
          imageUrl: "assets/profile_picture.png",
          email: "rajes@gmail.com",
          phone: "+44 9999999993",
          gender: "Male",
          status: true,
          userType: UserType.waiter,
        ),
        User(
          id: "5",
          name: "Utkarsh Bhoumick",
          imageUrl: "assets/profile_picture.png",
          email: "utki@gmail.com",
          phone: "+44 9999999994",
          gender: "Male",
          status: true,
          userType: UserType.waiter,
        ),
        User(
          id: "6",
          name: "Meghna Ghosh",
          imageUrl: "assets/profile_picture.png",
          email: "meg@gmail.com",
          phone: "+44 9999999995",
          gender: "Female",
          status: true,
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
