import 'dart:convert';
import 'dart:io';

import 'package:epos_application/components/data.dart';
import 'package:epos_application/components/models.dart';
import 'package:epos_application/screens/error_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class UploadProvider extends ChangeNotifier {
  Future<String?> uploadImage({
    required UserDataModel user,
    required BuildContext context,
    required String incomingFilePath,
    required bool isChangeDP,
    required bool isChangeRestaurantImage,
    required bool isChangeRestaurantLogo,
    required bool isSpecialsImage,
    required bool isCategoryImage,
    required bool isItemImage,
    int? index,
    Specials? specials,
    Category? category,
    MenuItems? menuItems,
  }) async {
    var url = "${Data.baseUrl}/api/upload";
    String? imageUrl;
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

      if (isChangeDP) {
        request.fields['ref'] = "plugin::users-permissions.user";
        request.fields['refId'] = "${user.id}";
        request.fields['field'] = "image";
      } else if (isChangeRestaurantImage) {
        /// ref id is static for settings section
        request.fields['ref'] = "api::setting.setting";
        request.fields['refId'] = "2";
        request.fields['field'] = "image";
      } else if (isChangeRestaurantLogo) {
        /// ref id is static for settings section
        request.fields['ref'] = "api::setting.setting";
        request.fields['refId'] = "2";
        request.fields['field'] = "logo";
      } else if (isSpecialsImage) {
        request.fields['ref'] = "api::special.special";
        request.fields['refId'] = "${specials!.id}";
        request.fields['field'] = "image";
      } else if (isCategoryImage) {
        request.fields['ref'] = "api::category.category";
        request.fields['refId'] = "${category!.id}";
        request.fields['field'] = "image";
      } else if (isItemImage) {}

      var response = await request.send();
      if (response.statusCode == 200) {
        final reply = await http.Response.fromStream(response);
        var responseData = json.decode(reply.body);
        imageUrl = "${Data.baseUrl}${responseData[0]['url']}";
        notifyListeners();
      } else if (response.statusCode == 413) {
        return "too big";
      }
      return imageUrl;
    } on SocketException {
      if (context.mounted) {
        await Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => ErrorScreen(
                    isConnectedToInternet: false,
                    trace: "uploadImage",
                  )),
        );
      }
      if (context.mounted) {
        //retry api
        await uploadImage(
          user: user,
          context: context,
          incomingFilePath: incomingFilePath,
          isChangeDP: isChangeDP,
          isChangeRestaurantImage: isChangeRestaurantImage,
          isChangeRestaurantLogo: isChangeRestaurantLogo,
          isSpecialsImage: isSpecialsImage,
          isCategoryImage: isCategoryImage,
          isItemImage: isItemImage,
          specials: specials,
          category: category,
          menuItems: menuItems,
        );
      }
      return imageUrl;
    } catch (e) {
      if (context.mounted) {
        //general error handling
        await Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => ErrorScreen(
                    trace: "uploadImage",
                  )),
        );
      }
      if (context.mounted) {
        //retry api
        await uploadImage(
          user: user,
          context: context,
          incomingFilePath: incomingFilePath,
          isChangeDP: isChangeDP,
          isChangeRestaurantImage: isChangeRestaurantImage,
          isChangeRestaurantLogo: isChangeRestaurantLogo,
          isSpecialsImage: isSpecialsImage,
          isCategoryImage: isCategoryImage,
          isItemImage: isItemImage,
          specials: specials,
          category: category,
          menuItems: menuItems,
        );
      }
    }
    return imageUrl;
  }
}
