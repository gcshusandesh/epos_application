import 'dart:convert';
import 'dart:io';

import 'package:epos_application/components/data.dart';
import 'package:epos_application/components/models.dart';
import 'package:epos_application/screens/error_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class InventoryProvider extends ChangeNotifier {
  List<UnitType> unitTypes = [];

  void addUnitTypeLocally({required UnitType unitType}) {
    unitTypes.add(unitType);
    notifyListeners();
  }

  void deleteUnitTypeLocally({required int index}) {
    unitTypes.removeAt(index);
    notifyListeners();
  }

  void updateUnitTypeLocally({required int index, required String unitType}) {
    unitTypes[index].name = unitType;
    notifyListeners();
  }

  /// Inventory Items Units
  Future<bool> createUnitType({
    required String unitType,
    required String accessToken,
    required BuildContext context,
  }) async {
    late Uri url = Uri.parse("${Data.baseUrl}/api/unit-types");
    try {
      var headers = {
        "Accept": "application/json",
        "Content-Type": "application/json",
        'Authorization': 'Bearer $accessToken',
      };
      late Map<String, dynamic> payloadBody = {
        "data": {
          "name": unitType,
        }
      };
      var response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(payloadBody),
      );
      if (response.statusCode == 200) {
        addUnitTypeLocally(unitType: UnitType(name: unitType));
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
                trace: "createUnitType",
              ),
            ));
      }
      if (context.mounted) {
        //retry api
        await createUnitType(
          unitType: unitType,
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
                trace: "createUnitType",
              ),
            ));
      }
      if (context.mounted) {
        //retry api
        await createUnitType(
          unitType: unitType,
          accessToken: accessToken,
          context: context,
        );
      }
      return false;
    }
  }

  Future<void> getUnitTypes({
    required String accessToken,
    required BuildContext context,
  }) async {
    late Uri url = Uri.parse("${Data.baseUrl}/api/unit-types");

    try {
      var headers = {
        "Accept": "application/json",
        'Authorization': 'Bearer $accessToken',
      };
      var response = await http.get(url, headers: headers);
      var extractedData = json.decode(response.body);
      var data = extractedData['data'];

      if (response.statusCode == 200) {
        unitTypes.clear();
        data.forEach((unitItem) {
          unitTypes.add(UnitType(
            id: unitItem['id'],
            name: unitItem['attributes']['name'],
          ));
        });
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
                trace: "getUnitTypes",
              ),
            ));
      }
      if (context.mounted) {
        await getUnitTypes(
          accessToken: accessToken,
          context: context,
        );
      }
    } catch (e) {
      print(e);
      if (context.mounted) {
        await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ErrorScreen(
                trace: "getUnitTypes",
              ),
            ));
      }
      if (context.mounted) {
        await getUnitTypes(
          accessToken: accessToken,
          context: context,
        );
      }
    }
  }

  Future<bool> updateUnitType({
    required int id,
    required int index,
    required String editedUnitType,
    required String accessToken,
    required BuildContext context,
  }) async {
    var url = Uri.parse("${Data.baseUrl}/api/unit-types/$id");
    try {
      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $accessToken',
      };
      late Map<String, String> body = {
        "name": editedUnitType,
      };

      Map<String, dynamic> payloadBody = {
        "data": body,
      };
      final response = await http.put(Uri.parse(url.toString()),
          headers: headers, body: jsonEncode(payloadBody));
      if (response.statusCode == 200) {
        updateUnitTypeLocally(index: index, unitType: editedUnitType);
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
                trace: "updateUnitType",
              ),
            ));
      }
      if (context.mounted) {
        //retry api
        await updateUnitType(
            id: id,
            index: index,
            editedUnitType: editedUnitType,
            context: context,
            accessToken: accessToken);
      }
      return false;
    } catch (e) {
      if (context.mounted) {
        // Navigate to Error Page
        await Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => ErrorScreen(
                    trace: "updateUnitType",
                  )),
        );
      }
      if (context.mounted) {
        //retry api
        await updateUnitType(
            id: id,
            index: index,
            editedUnitType: editedUnitType,
            context: context,
            accessToken: accessToken);
      }
    }
    return false;
  }

  Future<bool> deleteUnitType({
    required int id,
    required int index,
    required String accessToken,
    required BuildContext context,
  }) async {
    late Uri url = Uri.parse("${Data.baseUrl}/api/specials/$id");
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
                trace: "deleteUnitType",
              ),
            ));
      }
      if (context.mounted) {
        //retry api
        await deleteUnitType(
          id: id,
          index: index,
          accessToken: accessToken,
          context: context,
        );
      }
      return false;
    } catch (e) {
      // print("error: $e");
      if (context.mounted) {
        // Navigate to Error Page
        await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ErrorScreen(
                trace: "deleteUnitType",
              ),
            ));
      }
      if (context.mounted) {
        //retry api
        await deleteUnitType(
          id: id,
          index: index,
          accessToken: accessToken,
          context: context,
        );
      }
      return false;
    }
  }

  /// Inventory Items
  Future<bool> createInventoryItem({
    required String unitType,
    required String accessToken,
    required BuildContext context,
  }) async {
    late Uri url = Uri.parse("${Data.baseUrl}/api/unit-types");
    try {
      var headers = {
        "Accept": "application/json",
        "Content-Type": "application/json",
        'Authorization': 'Bearer $accessToken',
      };
      late Map<String, dynamic> payloadBody = {
        "data": {
          "name": unitType,
        }
      };

      var response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(payloadBody),
      );
      var extractedData = json.decode(response.body);
      var data = extractedData['data'];
      if (response.statusCode == 200) {
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
                trace: "createInventoryItem",
              ),
            ));
      }
      if (context.mounted) {
        //retry api
        await createInventoryItem(
          unitType: unitType,
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
                trace: "createInventoryItem",
              ),
            ));
      }
      if (context.mounted) {
        //retry api
        await createInventoryItem(
          unitType: unitType,
          accessToken: accessToken,
          context: context,
        );
      }
      return false;
    }
  }

  Future<void> getInventoryList({
    required String accessToken,
    required BuildContext context,
  }) async {
    late Uri url = Uri.parse("${Data.baseUrl}/api/unit-types");

    try {
      var headers = {
        "Accept": "application/json",
        'Authorization': 'Bearer $accessToken',
      };
      var response = await http.get(url, headers: headers);
      var extractedData = json.decode(response.body);
      var data = extractedData['data'];

      if (response.statusCode == 200) {
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
                trace: "getInventoryList",
              ),
            ));
      }
      if (context.mounted) {
        await getInventoryList(
          accessToken: accessToken,
          context: context,
        );
      }
    } catch (e) {
      print(e);
      if (context.mounted) {
        await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ErrorScreen(
                trace: "getInventoryList",
              ),
            ));
      }
      if (context.mounted) {
        await getInventoryList(
          accessToken: accessToken,
          context: context,
        );
      }
    }
  }

  Future<bool> updateInventoryItem({
    required int id,
    required BuildContext context,
    required String editedInventoryItem,
  }) async {
    var url = Uri.parse("${Data.baseUrl}/api/unit-types/$id");
    try {
      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };
      late Map<String, String> body = {
        "name": editedInventoryItem,
      };

      Map<String, dynamic> payloadBody = {
        "data": body,
      };
      final response = await http.put(Uri.parse(url.toString()),
          headers: headers, body: jsonEncode(payloadBody));
      if (response.statusCode == 200) {
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
                trace: "updateInventoryItem",
              ),
            ));
      }
      if (context.mounted) {
        //retry api
        await updateInventoryItem(
            id: id, context: context, editedInventoryItem: editedInventoryItem);
      }
      return false;
    } catch (e) {
      if (context.mounted) {
        // Navigate to Error Page
        await Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => ErrorScreen(
                    trace: "updateInventoryItem",
                  )),
        );
      }
      if (context.mounted) {
        //retry api
        await updateInventoryItem(
            id: id, context: context, editedInventoryItem: editedInventoryItem);
      }
    }
    return false;
  }

  Future<bool> deleteInventoryItem({
    required int id,
    required int index,
    required String accessToken,
    required BuildContext context,
  }) async {
    late Uri url = Uri.parse("${Data.baseUrl}/api/specials/$id");
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
                trace: "deleteInventoryItem",
              ),
            ));
      }
      if (context.mounted) {
        //retry api
        await deleteInventoryItem(
          id: id,
          index: index,
          accessToken: accessToken,
          context: context,
        );
      }
      return false;
    } catch (e) {
      // print("error: $e");
      if (context.mounted) {
        // Navigate to Error Page
        await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ErrorScreen(
                trace: "deleteInventoryItem",
              ),
            ));
      }
      if (context.mounted) {
        //retry api
        await deleteInventoryItem(
          id: id,
          index: index,
          accessToken: accessToken,
          context: context,
        );
      }
      return false;
    }
  }
}
