import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class InfoProvider extends ChangeNotifier {

  String baseUrl = "https://restaurantepos.xyz";

  Future<void> getTestData() async {
    var url = Uri.parse(
        "$baseUrl/api/testdatas/1");
    try {
      var headers = {
        "Accept": "application/json",
      };
      var response = await http.get(url, headers: headers);
      var extractedData = json.decode(response.body);
      if (response.statusCode == 200) {
        print(extractedData);
      }
      notifyListeners();
    } catch (e) {
      // ignore: avoid_print
      print(e);
    }
  }

}