import 'dart:convert';
import 'dart:io';

import 'package:epos_application/components/data.dart';
import 'package:epos_application/components/models.dart';
import 'package:epos_application/screens/error_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class MenuProvider extends ChangeNotifier {
  List<Specials> totalSpecialsList = [];
  List<Specials> activeSpecialsList = [];

  void getActiveSpecials() {
    activeSpecialsList =
        totalSpecialsList.where((element) => element.status).toList();
    notifyListeners();
  }

  void updateSpecialsImageLocally(
      {required String imageUrl, required int index}) {
    ///change data in main list
    totalSpecialsList[index].image = imageUrl;

    ///recalculate active specials list
    getActiveSpecials();
    notifyListeners();
  }

  void updateSpecialsLocally(
      {required Specials editedSpecials, required int index}) {
    ///change data in main list
    totalSpecialsList[index] = editedSpecials;

    ///recalculate active specials list
    getActiveSpecials();
    notifyListeners();
  }

  void removeSpecialsLocally({required int index}) {
    ///remove data in main list
    totalSpecialsList.removeAt(index);

    ///recalculate active specials list
    getActiveSpecials();
    notifyListeners();
  }

  void addSpecialsLocally({required Specials specials}) {
    ///add data in main list
    totalSpecialsList.add(specials);

    ///recalculate active specials list
    getActiveSpecials();
    notifyListeners();
  }

  Future<void> getMenuList({
    bool isSpecials = false,
    bool isCategory = false,
    bool isItem = false,
    required String accessToken,
    required BuildContext context,
  }) async {
    late Uri url;
    if (isSpecials) {
      url = Uri.parse("${Data.baseUrl}/api/specials?populate=image");
    } else if (isCategory) {
      url = Uri.parse("${Data.baseUrl}/api/categories?populate=image");
    } else if (isItem) {
      // url = Uri.parse("${Data.baseUrl}/api/testdatas/1");
    }

    try {
      var headers = {
        "Accept": "application/json",
        'Authorization': 'Bearer $accessToken',
      };
      var response = await http.get(url, headers: headers);
      var extractedData = json.decode(response.body);
      var data = extractedData['data'];
      print("data = $data");
      if (response.statusCode == 200) {
        if (isSpecials) {
          //empty list before fetching new data
          totalSpecialsList = [];
          data.forEach((specialItem) {
            totalSpecialsList.add(Specials(
              id: specialItem['id'],
              name: specialItem['attributes']['name'],
              image: specialItem['attributes']['image']['data'] == null
                  ? null
                  : "${Data.baseUrl}${specialItem['attributes']['image']['data']['attributes']['formats']['small']['url']}",
              status: specialItem['attributes']['isActive'],
            ));
          });
          getActiveSpecials();
        } else if (isCategory) {
          //empty list before fetching new data
          categoryList = [];
          data.forEach((categoryItem) {
            categoryList.add(Category(
              id: categoryItem['id'],
              name: categoryItem['attributes']['name'],
              image: categoryItem['attributes']['image']['data'] == null
                  ? null
                  : "${Data.baseUrl}${categoryItem['attributes']['image']['data']['attributes']['formats']['small']['url']}",
              status: categoryItem['attributes']['isActive'],
            ));
          });
        } else if (isItem) {
          //empty list before fetching new data
          menuItemsByCategory = [];
        }
      }
      notifyListeners();
    } on SocketException {
      if (context.mounted) {
        // Navigate to Error Page
        await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ErrorScreen(
                isConnectedToInternet: false,
                trace: "getMenuList",
              ),
            ));
      }
      if (context.mounted) {
        //retry api
        await getMenuList(
          isSpecials: isSpecials,
          isCategory: isCategory,
          isItem: isItem,
          accessToken: accessToken,
          context: context,
        );
      }
    } catch (e) {
      if (context.mounted) {
        // Navigate to Error Page
        await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ErrorScreen(
                trace: "getMenuList",
              ),
            ));
      }
      if (context.mounted) {
        //retry api
        await getMenuList(
          isSpecials: isSpecials,
          isCategory: isCategory,
          isItem: isItem,
          accessToken: accessToken,
          context: context,
        );
      }
    }
  }

  Future<bool> createMenuItem({
    bool isSpecials = false,
    bool isCategory = false,
    bool isItem = false,
    Specials? specials,
    Category? category,
    MenuItems? menuItem,
    required String accessToken,
    required BuildContext context,
  }) async {
    print("creating menu item");
    late Uri url;
    if (isSpecials) {
      url = Uri.parse("${Data.baseUrl}/api/specials");
    } else if (isCategory) {
      url = Uri.parse("${Data.baseUrl}/api/categories");
    } else if (isItem) {
      // url = Uri.parse("${Data.baseUrl}/api/testdatas/1");
    }

    try {
      var headers = {
        "Accept": "application/json",
        "Content-Type": "application/json",
        'Authorization': 'Bearer $accessToken',
      };
      late Map<String, dynamic> payloadBody;
      if (isSpecials) {
        payloadBody = {
          "data": {
            "name": specials!.name,
          }
        };
      } else if (isCategory) {
        payloadBody = {
          "data": {
            "name": category!.name,
          }
        };
      } else if (isItem) {}

      var response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(payloadBody),
      );
      var extractedData = json.decode(response.body);
      var data = extractedData['data'];
      print("status code = ${response.statusCode}");
      print("data = $data");
      if (response.statusCode == 200) {
        if (isSpecials) {
          Specials newSpecials = Specials(
            id: data['id'],
            name: data['attributes']['name'],
            status: data['attributes']['isActive'],
          );
          addSpecialsLocally(specials: newSpecials);
        } else if (isCategory) {
          Category newCategory = Category(
            id: data['id'],
            name: data['attributes']['name'],
            status: data['attributes']['isActive'],
          );
          addCategoryLocally(category: newCategory);
        } else if (isItem) {
          addMenuItemLocally(menuItem: menuItem!);
        }
        notifyListeners();
        return true;
      }
      return false;
    } on SocketException {
      if (context.mounted) {
        // Navigate to Error Page
        await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ErrorScreen(
                isConnectedToInternet: false,
                trace: "createMenuItem",
              ),
            ));
      }
      if (context.mounted) {
        //retry api
        await createMenuItem(
          isSpecials: isSpecials,
          isCategory: isCategory,
          isItem: isItem,
          specials: specials,
          category: category,
          menuItem: menuItem,
          accessToken: accessToken,
          context: context,
        );
      }
      return false;
    } catch (e) {
      if (context.mounted) {
        // Navigate to Error Page
        await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ErrorScreen(
                trace: "createMenuItem",
              ),
            ));
      }
      if (context.mounted) {
        //retry api
        await createMenuItem(
          isSpecials: isSpecials,
          isCategory: isCategory,
          isItem: isItem,
          specials: specials,
          category: category,
          menuItem: menuItem,
          accessToken: accessToken,
          context: context,
        );
      }
      return false;
    }
  }

  Future<bool> deleteMenuItem({
    bool isSpecials = false,
    bool isCategory = false,
    bool isItem = false,
    required int id,
    required int index,
    required String accessToken,
    required BuildContext context,
  }) async {
    print("deleting menu item");
    late Uri url;
    if (isSpecials) {
      url = Uri.parse("${Data.baseUrl}/api/specials/$id");
    } else if (isCategory) {
      url = Uri.parse("${Data.baseUrl}/api/categories/$id");
    } else if (isItem) {
      // url = Uri.parse("${Data.baseUrl}/api/testdatas/1");
    }

    try {
      var headers = {
        "Accept": "application/json",
        "Content-Type": "application/json",
        'Authorization': 'Bearer $accessToken',
      };
      var response = await http.delete(
        url,
        headers: headers,
      );
      var extractedData = json.decode(response.body);
      var data = extractedData['data'];
      print("delete status code = ${response.statusCode}");
      print("delete data = $data");
      if (response.statusCode == 200) {
        if (isSpecials) {
          removeSpecialsLocally(index: index);
        } else if (isCategory) {
          removeCategoryLocally(index: index);
        } else if (isItem) {
          removeMenuItemLocally(itemIndex: index);
        }
        notifyListeners();
        return true;
      }
      return false;
    } on SocketException {
      if (context.mounted) {
        // Navigate to Error Page
        await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ErrorScreen(
                isConnectedToInternet: false,
                trace: "deleteMenuItem",
              ),
            ));
      }
      if (context.mounted) {
        //retry api
        await deleteMenuItem(
          isSpecials: isSpecials,
          isCategory: isCategory,
          isItem: isItem,
          id: id,
          index: index,
          accessToken: accessToken,
          context: context,
        );
      }
      return false;
    } catch (e) {
      if (context.mounted) {
        // Navigate to Error Page
        await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ErrorScreen(
                trace: "deleteMenuItem",
              ),
            ));
      }
      if (context.mounted) {
        //retry api
        await deleteMenuItem(
          isSpecials: isSpecials,
          isCategory: isCategory,
          isItem: isItem,
          id: id,
          index: index,
          accessToken: accessToken,
          context: context,
        );
      }
      return false;
    }
  }

  Future<bool> updateMenuItem({
    bool isSpecials = false,
    bool isCategory = false,
    bool isItem = false,
    required int index,
    required String accessToken,
    required BuildContext context,
    Specials? editedSpecials,
    Category? editedCategory,
    MenuItems? editedMenuItems,
  }) async {
    print("updating menu item");
    late Uri url;
    if (isSpecials) {
      url = Uri.parse("${Data.baseUrl}/api/specials/${editedSpecials!.id}");
    } else if (isCategory) {
      url = Uri.parse("${Data.baseUrl}/api/categories/${editedCategory!.id}");
    } else if (isItem) {
      // url = Uri.parse("${Data.baseUrl}/api/testdatas/1");
    }

    try {
      var headers = {
        "Accept": "application/json",
        "Content-Type": "application/json",
        'Authorization': 'Bearer $accessToken',
      };
      late Map<String, dynamic> payloadBody;
      if (isSpecials) {
        payloadBody = {
          "data": {
            "name": editedSpecials!.name,
            "isActive": editedSpecials.status,
          }
        };
      } else if (isCategory) {
        payloadBody = {
          "data": {
            "name": editedCategory!.name,
            "isActive": editedCategory.status,
          }
        };
      } else if (isItem) {}

      var response = await http.put(
        url,
        headers: headers,
        body: jsonEncode(payloadBody),
      );

      var extractedData = json.decode(response.body);
      var data = extractedData['data'];
      print("updating status code = ${response.statusCode}");
      print("updating data = $data");
      if (response.statusCode == 200) {
        if (isSpecials) {
          updateSpecialsLocally(editedSpecials: editedSpecials!, index: index);
        } else if (isCategory) {
          updateCategoryLocally(editedCategory: editedCategory!, index: index);
        } else if (isItem) {
          removeMenuItemLocally(itemIndex: index);
        }
        notifyListeners();
        return true;
      }
      return false;
    } on SocketException {
      if (context.mounted) {
        // Navigate to Error Page
        await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ErrorScreen(
                isConnectedToInternet: false,
                trace: "updateMenuItem",
              ),
            ));
      }
      if (context.mounted) {
        //retry api
        await updateMenuItem(
          isSpecials: isSpecials,
          isCategory: isCategory,
          isItem: isItem,
          index: index,
          accessToken: accessToken,
          context: context,
          editedSpecials: editedSpecials,
          editedCategory: editedCategory,
          editedMenuItems: editedMenuItems,
        );
      }
      return false;
    } catch (e) {
      if (context.mounted) {
        // Navigate to Error Page
        await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ErrorScreen(
                trace: "updateMenuItem",
              ),
            ));
      }
      if (context.mounted) {
        //retry api
        await updateMenuItem(
          isSpecials: isSpecials,
          isCategory: isCategory,
          isItem: isItem,
          index: index,
          accessToken: accessToken,
          context: context,
          editedSpecials: editedSpecials,
          editedCategory: editedCategory,
          editedMenuItems: editedMenuItems,
        );
      }
      return false;
    }
  }

  List<Category> categoryList = [];
  int selectedCategoryIndex = 0;

  /// to manage case where no item is active
  int getActiveCategoriesCount() {
    List<Category> activeCategoryList =
        categoryList.where((element) => element.status).toList();
    return activeCategoryList.length;
  }

  void updateCategoryLocally(
      {required Category editedCategory, required int index}) {
    categoryList[index] = editedCategory;
    notifyListeners();
  }

  void updateCategoryImageLocally(
      {required String imageUrl, required int index}) {
    categoryList[index].image = imageUrl;

    notifyListeners();
  }

  void removeCategoryLocally({required int index}) {
    categoryList.removeAt(index);
    notifyListeners();
  }

  void addCategoryLocally({required Category category}) {
    categoryList.add(category);
    notifyListeners();
  }

  void resetCategory() {
    int indexToSelect = 0;
    for (int i = 0; i < categoryList.length; i++) {
      if (i == indexToSelect) {
        categoryList[i].isSelected = true;
      } else {
        categoryList[i].isSelected = false;
      }
    }
    selectedCategoryIndex = indexToSelect;
    notifyListeners();
  }

  void changeSelectedCategory(int index) {
    for (int i = 0; i < categoryList.length; i++) {
      if (i == index) {
        categoryList[i].isSelected = true;
      } else {
        categoryList[i].isSelected = false;
      }
    }
    selectedCategoryIndex = index;
    notifyListeners();
  }

  List<MenuItemsByCategory> menuItemsByCategory = [];
  void changeMenuItemStatusLocally({required int itemIndex}) {
    menuItemsByCategory[selectedCategoryIndex].menuItems[itemIndex].status =
        !menuItemsByCategory[selectedCategoryIndex].menuItems[itemIndex].status;
    notifyListeners();
  }

  void removeMenuItemLocally({required int itemIndex}) {
    menuItemsByCategory[selectedCategoryIndex].menuItems.removeAt(itemIndex);
    notifyListeners();
  }

  void addMenuItemLocally({required MenuItems menuItem}) {
    menuItemsByCategory[selectedCategoryIndex].menuItems.add(menuItem);
    notifyListeners();
  }

  Future<void> getMenuItemsByCategory({required bool init}) async {
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
      menuItemsByCategory = [
        MenuItemsByCategory(
          category: Category(
            name: "Breakfast",
            image: "assets/category/breakfast.png",
            status: true,
          ),
          menuItems: [
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
              description: "Some description about food",
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
              name: "Sausage",
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
          ],
        ),
        MenuItemsByCategory(
          category: Category(
            name: "Appetizers",
            image: "assets/category/burger.jpeg",
            status: true,
          ),
          menuItems: [
            MenuItems(
              name: "Burger",
              image: "assets/category/burger.jpeg",
              description: "Some description about food",
              ingredients: "Ingredient 1, Ingredient 2",
              price: 10,
              status: true,
            ),
          ],
        ),
        MenuItemsByCategory(
          category: Category(
            name: "Sides",
            image: "assets/category/fries.jpeg",
            status: true,
          ),
          menuItems: [],
        ),
        MenuItemsByCategory(
          category: Category(
            name: "Salads",
            image: "assets/category/salad.png",
            status: true,
          ),
          menuItems: [],
        ),
        MenuItemsByCategory(
          category: Category(
            name: "Soups",
            image: "assets/category/soup.jpeg",
            status: true,
          ),
          menuItems: [],
        ),
        MenuItemsByCategory(
          category: Category(
            name: "Coffee",
            image: "assets/category/coffee1.jpeg",
            status: true,
          ),
          menuItems: [],
        ),
        MenuItemsByCategory(
          category: Category(
            name: "Beverages",
            image: "assets/category/beverages1.jpeg",
            status: true,
          ),
          menuItems: [],
        ),
      ];
      if (!init) {
        notifyListeners();
      }
    } catch (e) {
      // ignore: avoid_print
      print(e);
      rethrow;
    }
  }
}
