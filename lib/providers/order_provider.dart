// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:io';

import 'package:epos_application/components/data.dart';
import 'package:epos_application/components/models.dart';
import 'package:epos_application/screens/error_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class OrderProvider extends ChangeNotifier {
  List<ProcessedOrder> processedOrders = [];

  Future<void> getOrders(
      {required String accessToken, required BuildContext context}) async {
    Uri url = Uri.parse("${Data.baseUrl}/api/processed-orders");

    try {
      var headers = {
        "Accept": "application/json",
        'Authorization': 'Bearer $accessToken',
      };
      var response = await http.get(url, headers: headers);
      var extractedData = json.decode(response.body);
      var data = extractedData['data'];

      if (response.statusCode == 200) {
        ///empty list before populating
        processedOrders = [];
        processedOrders = data.map<ProcessedOrder>((orderData) {
          var attributes = orderData['attributes'];
          return ProcessedOrder(
            id: orderData['id'],
            tableNumber: attributes['tableNumber'],
            items: attributes['items'],
            instructions: attributes['instruction'],
            price: attributes['price'].toDouble(),
            discount: attributes['discount'].toDouble(),
            timestamp: convertTimestamp(attributes['createdAt'].toString()),
            status: OrderStatus.values.firstWhere((status) =>
                status.toString() ==
                'OrderStatus.${attributes['orderStatus']}'),
            billedTo: attributes['billedTo'],
            isPaid: attributes['isPaid'],
          );
        }).toList();

        notifyListeners();
      }
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

  String convertTimestamp(String isoTimestamp) {
    // Parse the ISO 8601 timestamp
    DateTime dateTime = DateTime.parse(isoTimestamp);

    // Format the DateTime to the desired format with AM/PM
    DateFormat formatter = DateFormat('yyyy-MM-dd hh:mm:ss a');
    return formatter.format(dateTime);
  }

  Future<bool> createOrders({
    required String accessToken,
    required BuildContext context,
    required ProcessedOrder order,
  }) async {
    Uri url = Uri.parse("${Data.baseUrl}/api/processed-orders");

    try {
      var headers = {
        "Accept": "application/json",
        'Authorization': 'Bearer $accessToken',
      };

      Map<String, dynamic> payloadBody = {
        "data": {
          "tableNumber": order.tableNumber,
          "items": order.items,
          "instruction": order.items,
          "price": order.price,
          "discount": order.discount,
          "orderStatus": order.status.name,
          "billedTo": order.billedTo,
          "isPaid": order.isPaid
        }
      };

      var response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(payloadBody),
      );
      var extractedData = json.decode(response.body);

      print("body = $extractedData");
      print("response code = ${response.statusCode}");
      if (response.statusCode == 200) {
        notifyListeners();
        return true;
      }
      return false;
    } on SocketException {
      if (context.mounted) {
        await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ErrorScreen(
                isConnectedToInternet: false,
                trace: "createOrders",
              ),
            ));
      }
      if (context.mounted) {
        // retry API
        await createOrders(
          accessToken: accessToken,
          context: context,
          order: order,
        );
      }
      return false;
    } catch (e) {
      print("Error: $e");
      if (context.mounted) {
        await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ErrorScreen(
                trace: "createOrders",
              ),
            ));
      }
      if (context.mounted) {
        // retry API
        await createOrders(
          accessToken: accessToken,
          context: context,
          order: order,
        );
      }
      return false;
    }
  }

  Future<void> updateOrders({
    required String accessToken,
    required BuildContext context,
    bool isPaid = false,
    bool isChangeStatus = false,
    bool isDiscount = false,
    String? orderStatus,
    double? discount,
  }) async {
    Uri url = Uri.parse("${Data.baseUrl}/api/processed-orders");

    try {
      var headers = {
        "Accept": "application/json",
        'Authorization': 'Bearer $accessToken',
      };

      late Map<String, dynamic> payloadBody;

      if (isPaid) {
        payloadBody = {
          "data": {"isPaid": true}
        };
      } else if (isChangeStatus) {
        payloadBody = {
          "data": {"orderStatus": orderStatus!}
        };
      } else if (isDiscount) {
        payloadBody = {
          "data": {"discount": discount!}
        };
      }

      final response = await http.put(Uri.parse(url.toString()),
          headers: headers, body: jsonEncode(payloadBody));
      var extractedData = json.decode(response.body);
      var data = extractedData['data'];
      print("data = $data");
      print("response code = ${response.statusCode}");

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
          isPaid: isPaid,
          isChangeStatus: isChangeStatus,
          isDiscount: isDiscount,
          orderStatus: orderStatus,
          discount: discount,
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
          isPaid: isPaid,
          isChangeStatus: isChangeStatus,
          isDiscount: isDiscount,
          orderStatus: orderStatus,
          discount: discount,
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
