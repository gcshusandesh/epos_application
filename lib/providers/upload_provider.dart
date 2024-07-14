import 'dart:io';

import 'package:epos_application/components/data.dart';
import 'package:epos_application/screens/error_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class UploadProvider extends ChangeNotifier {
  Future<String> uploadDocuments({
    required String accessToken,
    required BuildContext context,
    required String incomingFilePath,
  }) async {
    var url = "${Data.baseUrl}/api/upload";
    String output = "";
    try {
      File filePath = File(incomingFilePath);
      var stream = http.ByteStream(Stream.castFrom((filePath.openRead())));
      var length = await filePath.length();
      var request = http.MultipartRequest('POST', Uri.parse(url));
      request.headers.addAll({
        "Accept": "application/json",
        "Content-Type": "multipart/form-data",
        "Authorization": "Bearer $accessToken"
      });

      request.files.add(http.MultipartFile(
        'files',
        stream,
        length,
        filename: filePath.path.split("/").last,
      ));

      var response = await request.send();

      if (response.statusCode == 200) {
        print('success');
        final reply = await http.Response.fromStream(response);
        output = reply.body.toString();
      } else if (response.statusCode == 401) {
        //authentication error handling
      }
      notifyListeners();
    } on SocketException {
      if (context.mounted) {
        await Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => ErrorScreen(
                    isConnectedToInternet: false,
                  )),
        );
      }
      if (context.mounted) {
        //retry api
        await uploadDocuments(
            accessToken: accessToken,
            context: context,
            incomingFilePath: incomingFilePath);
      }
    } catch (e) {
      if (context.mounted) {
        print(e);
        //general error handling
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ErrorScreen()),
        );
      }
      if (context.mounted) {
        //retry api
        await uploadDocuments(
            accessToken: accessToken,
            context: context,
            incomingFilePath: incomingFilePath);
      }
    }
    return output;
  }
}
