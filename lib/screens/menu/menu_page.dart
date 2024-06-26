import 'package:carousel_slider/carousel_slider.dart';
import 'package:epos_application/components/buttons.dart';
import 'package:epos_application/components/common_widgets.dart';
import 'package:epos_application/components/data.dart';
import 'package:epos_application/components/size_config.dart';
import 'package:epos_application/screens/menu/edit_category.dart';
import 'package:epos_application/screens/menu/edit_menu.dart';
import 'package:epos_application/screens/menu/edit_specials.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../providers/menu_provider.dart';

class MenuPage extends StatefulWidget {
  const MenuPage({super.key});
  static const routeName = "menuPage";

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  bool init = true;
  late double height;
  late double width;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (init) {
      //initialize size config at the very beginning
      SizeConfig().init(context);
      height = SizeConfig.safeBlockVertical;
      width = SizeConfig.safeBlockHorizontal;

      init = false;
    }
  }

  @override
  dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            topSection(
                context: context, height: height, text: "Menu", width: width),
            specials(),
            buildCarousel(context),
            SizedBox(height: height * 2),
            category(),
            optionsSection(context),
            SizedBox(height: height * 2),
            menu(),
            SizedBox(height: height * 2),
            Expanded(
              flex: 3,
              child: GridView.builder(
                itemCount: 6,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                ),
                itemBuilder: (BuildContext context, int index) {
                  return const Card(
                    child: GridTile(
                      footer: Text("Hey"),
                      child: Text(
                          "low"), //just for testing, will fill with image later
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Row specials() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        buildBodyText(
          "Specials",
          Data.greyTextColor,
          width * 0.8,
          fontFamily: "RobotoMedium",
        ),
        iconButton(
          "assets/svg/edit.svg",
          height,
          width,
          () {
            animatedNavigatorPush(
              context: context,
              screen: const EditSpecials(),
            );
          },
        ),
      ],
    );
  }

  Row category() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        buildBodyText(
          "Category",
          Data.greyTextColor,
          width * 0.8,
          fontFamily: "RobotoMedium",
        ),
        iconButton(
          "assets/svg/edit.svg",
          height,
          width,
          () {
            animatedNavigatorPush(
              context: context,
              screen: const EditCategory(),
            );
          },
        ),
      ],
    );
  }

  Row menu() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            buildBodyText(
              "Menu Items",
              Data.greyTextColor,
              width * 0.8,
              fontFamily: "RobotoMedium",
            ),
            SizedBox(width: width),
            buildSmallText(
                "(Price Inclusive of VAT)", Data.lightGreyTextColor, width)
          ],
        ),
        Row(
          children: [
            textButton(
              text: "Change Priority",
              height: height,
              width: width,
              textColor: Data.iconsColor,
              buttonColor: Data.iconsColor,
              onTap: () {},
            ),
            SizedBox(width: width),
            iconButton(
              "assets/svg/edit.svg",
              height,
              width,
              () {
                //can be used to initialise category as well
                Provider.of<MenuProvider>(context, listen: false)
                    .resetCategory();
                animatedNavigatorPush(
                  context: context,
                  screen: const EditMenu(),
                );
              },
            ),
          ],
        )
      ],
    );
  }

  Expanded buildCarousel(BuildContext context) {
    return Expanded(
      flex: 1,
      child: CarouselSlider.builder(
        itemCount: Provider.of<MenuProvider>(context, listen: true)
            .specialsList
            .length,
        itemBuilder: (BuildContext context, int itemIndex, int pageViewIndex) {
          return Image.asset(
            Provider.of<MenuProvider>(context, listen: true)
                .specialsList[itemIndex]
                .image,
            fit: BoxFit.contain,
          );
        },
        options: CarouselOptions(
          autoPlay: true,
          enlargeCenterPage: true,
          aspectRatio: 3,
        ),
      ),
    );
  }

  Expanded optionsSection(BuildContext context) {
    return Expanded(
      flex: 1,
      child: ListView.builder(
        padding: EdgeInsets.zero,
        scrollDirection:
            Axis.horizontal, // Assuming you want a horizontal list view
        itemCount: Provider.of<MenuProvider>(context, listen: true)
            .categoryList
            .length,
        itemBuilder: (context, index) {
          final category = Provider.of<MenuProvider>(context, listen: true)
              .categoryList[index];
          return Row(
            children: [
              menuOption(
                category.name,
                category.image,
                height,
                width,
                () {
                  Provider.of<MenuProvider>(context, listen: false)
                      .changeSelectedCategory(index);
                },
                index: index,
                context: context,
              ),
              SizedBox(width: width),
            ],
          );
        },
      ),
    );
  }
}
