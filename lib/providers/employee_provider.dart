import 'package:epos_application/components/models.dart';
import 'package:flutter/material.dart';

class EmployeeProvider extends ChangeNotifier {
  List<Employee> employeeList = [];

  void changeEmployeeStatus(int index) {
    employeeList[index].status = !employeeList[index].status;
    notifyListeners();
  }

  void addEmployee(Employee employee) {
    employeeList.add(employee);
    notifyListeners();
  }

  Future<void> getEmployeeData({required bool init}) async {
    // var url = Uri.parse("$baseUrl/api/testdatas/1");
    try {
      // var headers = {
      //   "Accept": "application/json",
      // };
      // var response = await http.get(url, headers: headers);
      // var extractedData = json.decode(response.body);
      // if (response.statusCode == 200) {
      //   print(extractedData);
      // }
      employeeList = [
        Employee(
          id: "1",
          name: "Shusandesh G C",
          imageUrl: "assets/profile_picture.png",
          email: "shusandesh@gmail.com",
          phone: "+44 9999999990",
          gender: "Male",
          status: true,
        ),
        Employee(
          id: "2",
          name: "Shreen Subedi",
          imageUrl: "assets/profile_picture.png",
          email: "shreeno@gmail.com",
          phone: "+44 9999999991",
          gender: "Female",
          status: true,
        ),
        Employee(
          id: "3",
          name: "Jayant Kundal",
          imageUrl: "assets/profile_picture.png",
          email: "kundal@gmail.com",
          phone: "+44 9999999992",
          gender: "Male",
          status: true,
        ),
        Employee(
          id: "4",
          name: "Rajes Shenoy",
          imageUrl: "assets/profile_picture.png",
          email: "rajes@gmail.com",
          phone: "+44 9999999993",
          gender: "Male",
          status: true,
        ),
        Employee(
          id: "5",
          name: "Utkarsh Bhoumick",
          imageUrl: "assets/profile_picture.png",
          email: "utki@gmail.com",
          phone: "+44 9999999994",
          gender: "Male",
          status: true,
        ),
        Employee(
          id: "6",
          name: "Meghna Ghosh",
          imageUrl: "assets/profile_picture.png",
          email: "meg@gmail.com",
          phone: "+44 9999999995",
          gender: "Female",
          status: true,
        ),
      ];
      if (!init) {
        notifyListeners();
      }
    } catch (e) {
      // ignore: avoid_print
      print(e);
    }
  }
}
