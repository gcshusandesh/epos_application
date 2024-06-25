import 'package:epos_application/components/models.dart';
import 'package:flutter/material.dart';

class DataProvider extends ChangeNotifier {
  List<Employee> employeeList = [];

  void changeEmployeeStatus(int index) {
    employeeList[index].status = !employeeList[index].status;
    notifyListeners();
  }

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
      // notifyListeners();
    } catch (e) {
      // ignore: avoid_print
      print(e);
    }
  }

  List<Specials> specialsList = [];

  void changeSpecialsStatus(int index) {
    specialsList[index].status = !specialsList[index].status;
    notifyListeners();
  }

  void removeSpecials(int index) {
    specialsList.removeAt(index);
    notifyListeners();
  }

  Future<void> getSpecialsList() async {
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
      specialsList = [
        Specials(
            name: "Featured Burger",
            image: "assets/featured/featured_burger1.png",
            status: true),
        Specials(
            name: "Featured Breakfast",
            image: "assets/featured/breakfast_featured.png",
            status: true),
        Specials(
            name: "Featured Coffee",
            image: "assets/featured/coffee_featured.png",
            status: true),
      ];
      notifyListeners();
    } catch (e) {
      // ignore: avoid_print
      print(e);
    }
  }

  List<Category> categoryList = [];

  Future<void> getCategoryList() async {
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
      categoryList = [
        Category(
          name: "Breakfast",
          image: "assets/category/breakfast.png",
          status: true,
        ),
        Category(
          name: "Appetizers",
          image: "assets/category/burger.jpeg",
          status: true,
        ),
        Category(
          name: "Sides",
          image: "assets/category/fries.jpeg",
          status: true,
        ),
        Category(
          name: "Salads",
          image: "assets/category/salad.png",
          status: true,
        ),
        Category(
          name: "Soups",
          image: "assets/category/soup.jpeg",
          status: true,
        ),
        Category(
          name: "Coffee",
          image: "assets/category/coffee1.jpeg",
          status: true,
        ),
        Category(
          name: "Beverages",
          image: "assets/category/beverages1.jpeg",
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
