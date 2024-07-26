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
          discount: 0,
          timestamp: "2021-09-01 12:00:00",
          status: OrderStatus.processing));
      processedOrders.add(ProcessedOrder(
          id: 1,
          tableNumber: "1A",
          items: "Sausage x1, Cereal x2",
          instructions: "Less Salt",
          price: 24,
          discount: 2,
          timestamp: "2021-09-01 12:00:00",
          status: OrderStatus.preparing));
      processedOrders.add(ProcessedOrder(
          id: 1,
          tableNumber: "1A",
          items: "Burger x1",
          instructions: "Less Salt",
          price: 10.0,
          discount: 0,
          timestamp: "2021-09-01 12:00:00",
          status: OrderStatus.ready));
      processedOrders.add(
        ProcessedOrder(
            id: 1,
            tableNumber: "1A",
            items: "Sausage x1, Cereal x2",
            instructions: "Less Salt",
            price: 24,
            discount: 0,
            timestamp: "2021-09-01 12:00:00",
            status: OrderStatus.served,
            isPaid: true,
            billedTo: "Shusandesh"),
      );
      processedOrders.add(
        ProcessedOrder(
          id: 1,
          tableNumber: "1A",
          items: "Burger x1",
          instructions: "Less Salt",
          price: 10.0,
          discount: 0,
          timestamp: "2021-09-01 12:00:00",
          status: OrderStatus.served,
        ),
      );
      processedOrders.add(ProcessedOrder(
          id: 1,
          tableNumber: "1A",
          items: "Burger x1",
          instructions: "Less Salt",
          price: 10.0,
          discount: 0,
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

  Future<bool> sendInvoiceEmail({
    required String email,
    required String filePath,
    required BuildContext context,
    required String restaurantName,
  }) async {
    var url = Uri.parse("${Data.baseUrl}/api/email");
    try {
      final fileBytes = File(filePath).readAsBytesSync();
      final base64File = base64Encode(fileBytes);

      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };
      Map<String, dynamic> body = {
        "to": email,
        "subject": "Invoice",
        "html": """
        <!DOCTYPE html>
        <html lang="en">
        <head>
          <meta charset="UTF-8">
          <meta name="viewport" content="width=device-width, initial-scale=1.0">
          <title>Invoice</title>
          <style>
            body {
              font-family: Arial, sans-serif;
              background-color: #f4f4f4;
              margin: 0;
              padding: 0;
            }
            .container {
              background-color: #ffffff;
              margin: 50px auto;
              padding: 20px;
              border-radius: 8px;
              box-shadow: 0 0 10px rgba(0, 0, 0, 0.1);
              width: 80%;
              max-width: 600px;
            }
            .header {
              text-align: center;
              border-bottom: 1px solid #dddddd;
              padding-bottom: 20px;
            }
            .header h1 {
              margin: 0;
              color: #333333;
            }
            .content {
              margin-top: 20px;
            }
            .content p {
              line-height: 1.6;
              color: #555555;
            }
            .footer {
              margin-top: 20px;
              text-align: center;
              color: #888888;
            }
          </style>
        </head>
        <body>
          <div class="container">
            <div class="header">
              <h1>Invoice</h1>
            </div>
            <div class="content">
              <p>Dear Customer,</p>
              <p>Thank you for visiting $restaurantName. We are pleased to attach your invoice for the recent transaction.</p>
              <p>If you have any questions, please do not hesitate to contact us.</p>
            </div>
            <div class="footer">
              <p>&copy; 2024 $restaurantName. All Rights Reserved.</p>
            </div>
          </div>
        </body>
        </html>
      """,
        "attachments": [
          {
            "filename": "invoice.pdf",
            "content": base64File,
            "encoding": "base64",
          }
        ],
      };
      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(body),
      );
      return response.statusCode == 200;
    } on SocketException {
      if (context.mounted) {
        // Navigate to Error Page
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ErrorScreen(
              isConnectedToInternet: false,
              trace: "sendInvoiceEmail",
            ),
          ),
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
              trace: "sendInvoiceEmail",
            ),
          ),
        );
      }
      return false;
    }
  }
}
