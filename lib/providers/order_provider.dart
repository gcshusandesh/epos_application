import 'dart:convert';
import 'dart:io';

import 'package:epos_application/components/data.dart';
import 'package:epos_application/components/models.dart';
import 'package:epos_application/screens/error_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class OrderProvider extends ChangeNotifier {
  List<ProcessedOrder> processedOrders = [];

  Future<void> getOrders(
      {required String accessToken, required BuildContext context}) async {
    // Uri url = Uri.parse("${Data.baseUrl}/api/specials?populate=image");

    try {
      // var headers = {
      //   "Accept": "application/json",
      //   'Authorization': 'Bearer $accessToken',
      // };
      // var response = await http.get(url, headers: headers);
      // var extractedData = json.decode(response.body);
      // var data = extractedData['data'];
      // print("data = $data");
      //
      // if (response.statusCode == 200) {
      //   notifyListeners();
      // }
      ///empty list before populating
      processedOrders = [];
      processedOrders.add(ProcessedOrder(
          id: 1,
          tableNumber: "1A",
          items: "Burger x1",
          instructions: "Less Salt",
          price: 10.0,
          timestamp: "2021-09-01 12:00:00",
          status: OrderStatus.processing));
      processedOrders.add(ProcessedOrder(
          id: 1,
          tableNumber: "1A",
          items: "Burger x1",
          instructions: "Less Salt",
          price: 10.0,
          timestamp: "2021-09-01 12:00:00",
          status: OrderStatus.preparing));
      processedOrders.add(ProcessedOrder(
          id: 1,
          tableNumber: "1A",
          items: "Burger x1",
          instructions: "Less Salt",
          price: 10.0,
          timestamp: "2021-09-01 12:00:00",
          status: OrderStatus.ready));
      processedOrders.add(ProcessedOrder(
          id: 1,
          tableNumber: "1A",
          items: "Burger x1",
          instructions: "Less Salt",
          price: 10.0,
          timestamp: "2021-09-01 12:00:00",
          status: OrderStatus.served));
      processedOrders.add(ProcessedOrder(
          id: 1,
          tableNumber: "1A",
          items: "Burger x1",
          instructions: "Less Salt",
          price: 10.0,
          timestamp: "2021-09-01 12:00:00",
          status: OrderStatus.cancelled));
    } on SocketException {
      if (context.mounted) {
        await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ErrorScreen(
                isConnectedToInternet: false,
                trace: "getOrders",
              ),
            ));
      }
      if (context.mounted) {
        // retry API
        await getOrders(
          accessToken: accessToken,
          context: context,
        );
      }
    } catch (e) {
      print("Error: $e");
      if (context.mounted) {
        await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ErrorScreen(
                trace: "getOrders",
              ),
            ));
      }
      if (context.mounted) {
        // retry API
        await getOrders(
          accessToken: accessToken,
          context: context,
        );
      }
    }
  }

  Future<void> updateOrders(
      {required String accessToken, required BuildContext context}) async {
    Uri url = Uri.parse("${Data.baseUrl}/api/specials?populate=image");

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
        notifyListeners();
      }
    } on SocketException {
      if (context.mounted) {
        await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ErrorScreen(
                isConnectedToInternet: false,
                trace: "updateOrders",
              ),
            ));
      }
      if (context.mounted) {
        // retry API
        await updateOrders(
          accessToken: accessToken,
          context: context,
        );
      }
    } catch (e) {
      print("Error: $e");
      if (context.mounted) {
        await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ErrorScreen(
                trace: "updateOrders",
              ),
            ));
      }
      if (context.mounted) {
        // retry API
        await updateOrders(
          accessToken: accessToken,
          context: context,
        );
      }
    }
  }
}
