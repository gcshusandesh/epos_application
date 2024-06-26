import 'package:epos_application/components/models.dart';
import 'package:flutter/material.dart';

class MenuProvider extends ChangeNotifier {
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
            image: "assets/featured/featured_burger1.jpg",
            status: true),
        Specials(
            name: "Featured Breakfast",
            image: "assets/featured/breakfast_featured.jpg",
            status: true),
        Specials(
            name: "Featured Coffee",
            image: "assets/featured/coffee_featured.jpg",
            status: true),
      ];
      notifyListeners();
    } catch (e) {
      // ignore: avoid_print
      print(e);
    }
  }

  List<Category> categoryList = [];
  void changeCategoryStatus(int index) {
    categoryList[index].status = !categoryList[index].status;
    notifyListeners();
  }

  void removeCategory(int index) {
    categoryList.removeAt(index);
    notifyListeners();
  }

  void resetCategory() {
    for (int i = 0; i < categoryList.length; i++) {
      if (i == 0) {
        categoryList[i].status = true;
      } else {
        categoryList[i].status = false;
      }
    }
    //no need notify listeners as this will be shown in new page
  }

  void changeSelectedCategory(int index) {
    for (int i = 0; i < categoryList.length; i++) {
      if (i == index) {
        categoryList[index].status = true;
        print("selected category is $index");
      } else {
        categoryList[index].status = false;
      }
    }
    notifyListeners();
  }

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

  List<MenuItems> menuItems = [];
  void changeMenuItemStatus(int index) {
    menuItems[index].status = !menuItems[index].status;
    notifyListeners();
  }

  void removeMenuItem(int index) {
    menuItems.removeAt(index);
    notifyListeners();
  }

  Future<void> getMenuItems() async {
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
      menuItems = [
        MenuItems(
          name: "Eggs",
          image: "assets/food/eggs.jpg",
          description: "Some description about food",
          ingredients: "Ingredient 1, Ingredient 2",
          price: 8,
          status: true,
        ),
        MenuItems(
          name: "Pancake",
          image: "assets/food/pancakes_cropped.jpg",
          description: "Some description about food",
          ingredients: "Ingredient 1, Ingredient 2",
          price: 10,
          status: true,
        ),
        MenuItems(
          name: "French Toast",
          image: "assets/food/toast.jpg",
          description:
              "Some description about food ldjlsjalfdjslfj slsjdflksjal flsajf sjdfjsjflsdj lfslkjf ljsafsdlkjflsj fldslfjlasjflksdjfl ",
          ingredients: "Ingredient 1, Ingredient 2",
          price: 10,
          status: true,
        ),
        MenuItems(
          name: "Bacon",
          image: "assets/food/bacon.jpg",
          description: "Some description about food",
          ingredients: "Ingredient 1, Ingredient 2",
          price: 8,
          status: true,
        ),
        MenuItems(
          name: "Sausage(chicken)",
          image: "assets/food/sausage1.jpg",
          description: "Some description about food",
          ingredients: "Ingredient 1, Ingredient 2",
          price: 8,
          status: true,
        ),
        MenuItems(
          name: "Cereal",
          image: "assets/food/cereal.jpg",
          description: "Some description about food",
          ingredients: "Ingredient 1, Ingredient 2",
          price: 8,
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
