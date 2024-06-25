import 'package:epos_application/components/data.dart';
import 'package:flutter/material.dart';

Widget onLoading({required double width}) {
  return ClipRRect(
    borderRadius: BorderRadius.circular(10),
    child: Material(
      color: Colors.white,
      child: Container(
        height: width * 32,
        width: width * 32,
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey,
              offset: Offset(0, 0), //(x,y)
              blurRadius: 6.0,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: width * 2,
            ),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Data.primaryColor),
            ),
            SizedBox(
              height: width * 4,
            ),
            buildCustomText("Loading...", Colors.black, width * 3.5),
          ],
        ),
      ),
    ),
  );
}
