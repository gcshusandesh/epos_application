import 'dart:io';

import 'package:epos_application/components/data.dart';
import 'package:epos_application/components/models.dart';
import 'package:epos_application/screens/error_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class UploadProvider extends ChangeNotifier {
  Future<String> uploadImage({
    required UserDataModel user,
    required BuildContext context,
    required String incomingFilePath,
    bool isUserDP = false,
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
        "Authorization": "Bearer ${user.accessToken}"
      });

      request.files.add(http.MultipartFile(
        'files',
        stream,
        length,
        filename: filePath.path.split("/").last,
      ));

      if (isUserDP) {
        request.fields['ref'] = "plugin::users-permissions.user";
        request.fields['refId'] = "${user.id}";
        request.fields['field'] = "image";
      }

      var response = await request.send();
      print("status code = ${response.statusCode}");

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
        await uploadImage(
            user: user,
            context: context,
            incomingFilePath: incomingFilePath,
            isUserDP: isUserDP);
      }
    } catch (e) {
      if (context.mounted) {
        //general error handling
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ErrorScreen()),
        );
      }
      if (context.mounted) {
        //retry api
        await uploadImage(
          user: user,
          context: context,
          incomingFilePath: incomingFilePath,
          isUserDP: isUserDP,
        );
      }
    }
    return output;
  }
}
