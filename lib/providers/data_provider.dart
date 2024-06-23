import 'package:epos_application/components/models.dart';
import 'package:flutter/material.dart';

class DataProvider extends ChangeNotifier {
  List<Employee> employeeList = [];

  Future<void> getEmployeeData() async {
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
          name: "Shusandesh G C",
          email: "shusandesh@gmail.com",
          phone: "+44 9999999990",
          gender: "Male",
          status: true,
        ),
        Employee(
          name: "Shreen Subedi",
          email: "shreeno@gmail.com",
          phone: "+44 9999999991",
          gender: "Female",
          status: true,
        ),
        Employee(
          name: "Jayant Kundal",
          email: "kundal@gmail.com",
          phone: "+44 9999999992",
          gender: "Male",
          status: true,
        ),
        Employee(
          name: "Rajes Shenoy",
          email: "rajes@gmail.com",
          phone: "+44 9999999993",
          gender: "Male",
          status: true,
        ),
        Employee(
          name: "Utkarsh Bhoumick",
          email: "utki@gmail.com",
          phone: "+44 9999999994",
          gender: "Male",
          status: true,
        ),
        Employee(
          name: "Meghna Ghosh",
          email: "meg@gmail.com",
          phone: "+44 9999999995",
          gender: "Female",
          status: true,
        ),
      ];
      notifyListeners();
    } catch (e) {
      // ignore: avoid_print
      print(e);
    }
  }
}
