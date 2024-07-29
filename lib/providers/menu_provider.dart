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
      url = Uri.parse("${Data.baseUrl}/api/menu-items?populate=image");
    }

    try {
      var headers = {
        "Accept": "application/json",
        'Authorization': 'Bearer $accessToken',
      };
      var response = await http.get(url, headers: headers);
      var extractedData = json.decode(response.body);
      var data = extractedData['data'];

      if (response.statusCode == 200) {
        if (isSpecials) {
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
          // Empty list before fetching new data
          menuItemsByCategory = [];
          priceList.clear(); // Clear priceList before populating it

          // Group menu items by category
          Map<String, List<MenuItems>> groupedItems = {};

          for (var item in data) {
            var attributes = item['attributes'];
            String categoryType = attributes['categoryType'] ?? 'null';

            if (!groupedItems.containsKey(categoryType)) {
              groupedItems[categoryType] = [];
            }

            groupedItems[categoryType]!.add(MenuItems(
              id: item['id'],
              name: attributes['name'],
              image: attributes['image']['data'] == null
                  ? null
                  : "${Data.baseUrl}${attributes['image']['data'][0]['attributes']['url']}",
              description: attributes['description'],
              ingredients: attributes['ingredients'],
              price: attributes['price'].toDouble(),
              status: attributes['isActive'],
            ));
            addItemToPriceList(attributes['name'],
                attributes['price'].toDouble()); // Add to priceList
          }

          // Populate menuItemsByCategory using categoryList
          for (var category in categoryList) {
            menuItemsByCategory.add(MenuItemsByCategory(
              category: category,
              menuItems: groupedItems[category.name] ?? [],
            ));
          }
        }
        notifyListeners();
      } else {
        throw Exception('Failed to load data');
      }
    } on SocketException {
      if (context.mounted) {
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
        await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ErrorScreen(
                trace: "getMenuList",
              ),
            ));
      }
      if (context.mounted) {
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
    String? selectedCategory,
    required String accessToken,
    required BuildContext context,
  }) async {
    late Uri url;
    if (isSpecials) {
      url = Uri.parse("${Data.baseUrl}/api/specials");
    } else if (isCategory) {
      url = Uri.parse("${Data.baseUrl}/api/categories");
    } else if (isItem) {
      url = Uri.parse("${Data.baseUrl}/api/menu-items");
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
      } else if (isItem) {
        payloadBody = {
          "data": {
            "name": menuItem!.name,
            "description": menuItem.description,
            "ingredients": menuItem.ingredients,
            "price": menuItem.price,
            "categoryType": selectedCategory,
          }
        };
      }

      var response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(payloadBody),
      );
      var extractedData = json.decode(response.body);
      var data = extractedData['data'];
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
          if (context.mounted) {
            ///need to load menu items again to map ds with new category
            await getMenuList(
              isItem: isCategory,
              accessToken: accessToken,
              context: context,
            );
          }
        } else if (isItem) {
          MenuItems newMenuItem = MenuItems(
            id: data['id'],
            name: data['attributes']['name'],
            description: data['attributes']['description'],
            ingredients: data['attributes']['ingredients'],
            price: data['attributes']['price'].toDouble(),
            status: data['attributes']['isActive'],
          );
          addMenuItemLocally(menuItem: newMenuItem);
          addItemToPriceList(
              newMenuItem.name, newMenuItem.price); // Add to priceList
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
    late Uri url;
    if (isSpecials) {
      url = Uri.parse("${Data.baseUrl}/api/specials/$id");
    } else if (isCategory) {
      url = Uri.parse("${Data.baseUrl}/api/categories/$id");
    } else if (isItem) {
      url = Uri.parse("${Data.baseUrl}/api/menu-items/$id");
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
      json.decode(response.body);
      if (response.statusCode == 200) {
        if (isSpecials) {
          removeSpecialsLocally(index: index);
        } else if (isCategory) {
          removeCategoryLocally(index: index);
        } else if (isItem) {
          deleteItemInPriceList(
              menuItemsByCategory[selectedCategoryIndex].menuItems[index].name);
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
      print("error: $e");
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
    late Uri url;
    if (isSpecials) {
      url = Uri.parse("${Data.baseUrl}/api/specials/${editedSpecials!.id}");
    } else if (isCategory) {
      url = Uri.parse("${Data.baseUrl}/api/categories/${editedCategory!.id}");
    } else if (isItem) {
      url = Uri.parse("${Data.baseUrl}/api/menu-items/${editedMenuItems!.id}");
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
      } else if (isItem) {
        payloadBody = {
          "data": {
            "name": editedMenuItems!.name,
            "description": editedMenuItems.description,
            "ingredients": editedMenuItems.ingredients,
            "price": editedMenuItems.price,
            "isActive": editedMenuItems.status,
          }
        };
      }

      var response = await http.put(
        url,
        headers: headers,
        body: jsonEncode(payloadBody),
      );

      json.decode(response.body);
      if (response.statusCode == 200) {
        if (isSpecials) {
          updateSpecialsLocally(editedSpecials: editedSpecials!, index: index);
        } else if (isCategory) {
          updateCategoryLocally(editedCategory: editedCategory!, index: index);
        } else if (isItem) {
          updateMenuItemLocally(menuItem: editedMenuItems!, itemIndex: index);
          updateItemInPriceList(
              editedMenuItems.name, editedMenuItems.price); // Update priceList
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

    // Loop to find the first active category
    for (int i = 0; i < categoryList.length; i++) {
      if (categoryList[i].status == true) {
        indexToSelect = i;
        break;
      }
    }

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

  /// Function to count the number of active menu items in a selected category using its index
  int getActiveItemsCountByCategory() {
    // Check if the provided index is valid
    if (selectedCategoryIndex < 0 ||
        selectedCategoryIndex >= menuItemsByCategory.length) {
      // If the index is out of bounds, return 0
      return 0;
    }

    // Get the selected category
    var selectedCategory = menuItemsByCategory[selectedCategoryIndex];

    // Filter the menu items in the selected category to find active ones
    List<MenuItems> activeItems =
        selectedCategory.menuItems.where((item) => item.status).toList();

    // Return the count of active items in the selected category
    return activeItems.length;
  }

  List<MenuItemsByCategory> menuItemsByCategory = [];
  void changeMenuItemStatusLocally({required int itemIndex}) {
    menuItemsByCategory[selectedCategoryIndex].menuItems[itemIndex].status =
        !menuItemsByCategory[selectedCategoryIndex].menuItems[itemIndex].status;
    notifyListeners();
  }

  void updateMenuItemImageLocally(
      {required String imageUrl, required int itemIndex}) {
    menuItemsByCategory[selectedCategoryIndex].menuItems[itemIndex].image =
        imageUrl;
    notifyListeners();
  }

  void updateMenuItemLocally(
      {required int itemIndex, required MenuItems menuItem}) {
    menuItemsByCategory[selectedCategoryIndex].menuItems[itemIndex] = menuItem;
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

  void increaseMenuItemQuantity({required int itemIndex}) {
    menuItemsByCategory[selectedCategoryIndex].menuItems[itemIndex].quantity++;
    notifyListeners();
  }

  void decreaseMenuItemQuantity({required int itemIndex}) {
    if (menuItemsByCategory[selectedCategoryIndex]
            .menuItems[itemIndex]
            .quantity >
        0) {
      menuItemsByCategory[selectedCategoryIndex]
          .menuItems[itemIndex]
          .quantity--;
    }
    notifyListeners();
  }

  void resetAllOrders() {
    for (var category in menuItemsByCategory) {
      for (var menuItem in category.menuItems) {
        menuItem.quantity = 0;
      }
    }
    notifyListeners();
  }

  Order order = Order(
    id: 0,
    tableNumber: "",
    items: [],
    instructions: "",
    status: OrderStatus.processing,
  );
  double totalAmount = 0;
  int totalCount = 0;
  double vatAmount = 0;

  void deleteItemFromOrderLocally(
      {required int itemIndex, required String itemName}) {
    order.items.removeAt(itemIndex);
    resetQuantityByName(itemName: itemName);
    calculateTotal(isRecalculate: true);
  }

  void resetQuantityByName({required String itemName}) {
    // Iterate through each category
    for (var category in menuItemsByCategory) {
      // Get the list of menu items for the current category
      var menuItems = category.menuItems;

      // Iterate over the menu items to find the one with the matching name
      for (var item in menuItems) {
        if (item.name == itemName) {
          // Reset the quantity of the matching item to 0
          item.quantity = 0;
        }
      }
    }

    // Notify listeners to update the UI
    notifyListeners();
  }

  void calculateTotal({bool isRecalculate = false}) {
    double total = 0;
    int count = 0;
    //clear list before generating new one
    if (!isRecalculate) {
      order.items.clear();
    }
    for (var category in menuItemsByCategory) {
      for (var item in category.menuItems) {
        total += item.price * item.quantity;
        count += item.quantity;
        if (!isRecalculate && item.quantity > 0) {
          order.items.add(OrderItem(
              name: item.name, quantity: item.quantity, price: item.price));
        }
      }
    }
    totalAmount = total;
    totalCount = count;
    vatAmount = totalAmount * 0.20;
    notifyListeners();
  }

  /// This section is needed for invoice generation
  List<OrderItem> priceList = [];
  void addItemToPriceList(String name, double price) {
    OrderItem newItem = OrderItem(name: name, price: price);
    priceList.add(newItem);
    notifyListeners();
  }

  void updateItemInPriceList(String name, double newPrice) {
    for (var item in priceList) {
      if (item.name == name) {
        item.price = newPrice;
        break;
      }
    }
    notifyListeners();
  }

  void deleteItemInPriceList(String name) {
    priceList.removeWhere((item) => item.name == name);
    notifyListeners();
  }
}
