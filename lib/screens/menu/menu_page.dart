import 'package:carousel_slider/carousel_slider.dart';
import 'package:el_tooltip/el_tooltip.dart';
import 'package:epos_application/components/buttons.dart';
import 'package:epos_application/components/common_widgets.dart';
import 'package:epos_application/components/data.dart';
import 'package:epos_application/components/size_config.dart';
import 'package:epos_application/providers/auth_provider.dart';
import 'package:epos_application/screens/menu/edit_category.dart';
import 'package:epos_application/screens/menu/edit_menu.dart';
import 'package:epos_application/screens/menu/edit_specials.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

import '../../providers/info_provider.dart';
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
    _setPreferredOrientations();
    _fetchData();
  }

  void _setPreferredOrientations() async {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  Future<void> _fetchData() async {
    setState(() {
      isLoading = true;
    });
    // Get Specials Data from API
    await Provider.of<MenuProvider>(context, listen: false).getMenuList(
        accessToken:
            Provider.of<AuthProvider>(context, listen: false).user.accessToken!,
        isSpecials: true,
        context: context);
    if (mounted) {
      // Get Category Data from API
      await Provider.of<MenuProvider>(context, listen: false).getMenuList(
          accessToken: Provider.of<AuthProvider>(context, listen: false)
              .user
              .accessToken!,
          isCategory: true,
          context: context);
    }

    if (mounted) {
      // Get Menu Item Data from API
      // await Provider.of<MenuProvider>(context, listen: false).getMenuList(
      //     accessToken: Provider.of<AuthProvider>(context, listen: false)
      //         .user
      //         .accessToken!,
      //     isItem: true,
      //     context: context);
    }

    setState(() {
      isLoading = false;
    });
  }

  bool isLoading = false;
  bool init = true;
  late double height;
  late double width;

  @override
  void didChangeDependencies() async {
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
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvoked: (bool value) async {
        //for faster swapping of orientation
        SystemChrome.setPreferredOrientations([
          DeviceOrientation.landscapeLeft,
          DeviceOrientation.landscapeRight,
        ]);
      },
      child: Stack(
        children: [
          mainBody(context),
          isLoading
              ? Center(
                  child: onLoading(width: width, context: context),
                )
              : const SizedBox(),
        ],
      ),
    );
  }

  Scaffold mainBody(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            customTopSection(
                context: context, height: height, text: "Menu", width: width),
            specials(),
            buildCarousel(context),
            SizedBox(height: height * 2),
            category(),
            SizedBox(height: height),
            optionsSection(context),
            SizedBox(height: height * 2),
            menu(),
            SizedBox(height: height * 2),
            Expanded(
              flex: 3,
              child: Provider.of<MenuProvider>(context, listen: true)
                      .menuItemsByCategory[
                          Provider.of<MenuProvider>(context, listen: true)
                              .selectedCategoryIndex]
                      .menuItems
                      .isEmpty
                  ? Center(
                      child: buildBodyText(
                        "No Data Available",
                        Data.darkTextColor,
                        width * 1.3,
                        fontFamily: "RobotoMedium",
                      ),
                    )
                  : GridView.builder(
                      itemCount: Provider.of<MenuProvider>(context,
                              listen: true)
                          .menuItemsByCategory[
                              Provider.of<MenuProvider>(context, listen: true)
                                  .selectedCategoryIndex]
                          .menuItems
                          .length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        mainAxisSpacing: 10.0, // spacing between rows
                        crossAxisSpacing: 10.0, // spacing between columns
                      ),
                      itemBuilder: (BuildContext context, int itemIndex) {
                        return menuItem(itemIndex);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Row customTopSection(
      {required BuildContext context,
      required double height,
      required String text,
      required double width}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        iconButton(
          "assets/svg/arrow_back.svg",
          height,
          width,
          () {
            Navigator.pop(context);
            //for faster swapping of orientation
            SystemChrome.setPreferredOrientations([
              DeviceOrientation.landscapeLeft,
              DeviceOrientation.landscapeRight,
            ]);
          },
          context: context,
        ),
        buildTitleText(text, Data.darkTextColor, width),
        SizedBox(
          width: width * 5,
        ),
      ],
    );
  }

  Container menuItem(int itemIndex) {
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: height * 1.5,
      ),
      height: width * 10,
      width: width * 10,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Provider.of<InfoProvider>(context, listen: true)
              .systemInfo
              .iconsColor, // Outline color
          width: 0.5, // Outline width
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25), // Shadow color
            spreadRadius: 0, // How much the shadow spreads
            blurRadius: 4, // How much the shadow blurs
            offset: const Offset(0, 5), // The offset of the shadow
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            height: width * 12, // Define the size of the SVG image
            width: width * 12,
            child: Image.asset(
              Provider.of<MenuProvider>(context, listen: true)
                  .menuItemsByCategory[
                      Provider.of<MenuProvider>(context, listen: true)
                          .selectedCategoryIndex]
                  .menuItems[itemIndex]
                  .image!,
              fit: BoxFit.fill,
            ),
          ),
          const Flexible(child: SizedBox(height: 10)),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: width),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    // to balance the UI
                    Opacity(
                      opacity: 0,
                      child: customIconButton(
                        "assets/svg/info.svg",
                        height,
                        width,
                      ),
                    ),
                    SizedBox(
                      width: width * 8,
                      child: Center(
                        child: buildCustomText(
                          "${Provider.of<MenuProvider>(context, listen: true).menuItemsByCategory[Provider.of<MenuProvider>(context, listen: true).selectedCategoryIndex].menuItems[itemIndex].name}"
                          "\n${Provider.of<InfoProvider>(context, listen: true).systemInfo.currencySymbol}"
                          " ${Provider.of<MenuProvider>(context, listen: true).menuItemsByCategory[Provider.of<MenuProvider>(context, listen: true).selectedCategoryIndex].menuItems[itemIndex].price}",
                          Data.greyTextColor,
                          width * 1.3,
                          fontFamily: "RobotoMedium",
                        ),
                      ),
                    ),
                  ],
                ),
                ElTooltip(
                  showChildAboveOverlay: false,
                  content: buildSmallText(
                      "${Provider.of<MenuProvider>(context, listen: true).menuItemsByCategory[Provider.of<MenuProvider>(context, listen: true).selectedCategoryIndex].menuItems[itemIndex].description}"
                      "\nIngredients: ${Provider.of<MenuProvider>(context, listen: true).menuItemsByCategory[Provider.of<MenuProvider>(context, listen: true).selectedCategoryIndex].menuItems[itemIndex].description}",
                      Data.lightGreyTextColor,
                      width),
                  position: itemIndex % 3 == 0
                      ? ElTooltipPosition.bottomEnd
                      : itemIndex % 2 == 0
                          ? ElTooltipPosition.bottomCenter
                          : ElTooltipPosition.bottomStart,
                  child: customIconButton(
                    "assets/svg/info.svg",
                    height,
                    width,
                  ),
                ),
                // MyTooltip(
                //   message: Provider.of<MenuProvider>(context, listen: true)
                //       .menuItemsByCategory[
                //           Provider.of<MenuProvider>(context, listen: true)
                //               .selectedCategoryIndex]
                //       .menuItems[itemIndex]
                //       .description,
                //   child: customIconButton(
                //       "assets/svg/info.svg", height, width, () {}),
                // )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget customIconButton(
    String svg,
    double height,
    double width,
  ) {
    return Container(
      height: height * 3,
      width: width * 3,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: Provider.of<InfoProvider>(context, listen: true)
              .systemInfo
              .iconsColor, // Outline color
          width: 0.5, // Outline width
        ),
        borderRadius: BorderRadius.circular(6.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25), // Shadow color
            spreadRadius: 0, // How much the shadow spreads
            blurRadius: 4, // How much the shadow blurs
            offset: const Offset(0, 5), // The offset of the shadow
          ),
        ],
      ),
      child: Center(
          child: SvgPicture.asset(
        svg,
        colorFilter: ColorFilter.mode(
            Provider.of<InfoProvider>(context, listen: true)
                .systemInfo
                .iconsColor,
            BlendMode.srcIn),
        height: width * 1.5,
        width: width * 1.5,
        fit: BoxFit.contain,
      )),
    );
  }

  Row specials() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        buildBodyText(
          "Specials",
          Data.greyTextColor,
          width * 0.9,
          fontFamily: "RobotoMedium",
        ),
        iconButton(
          "assets/svg/edit.svg",
          height,
          width,
          () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const EditSpecials()),
            );
          },
          context: context,
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
          width * 0.9,
          fontFamily: "RobotoMedium",
        ),
        iconButton(
          "assets/svg/edit.svg",
          height,
          width,
          () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const EditCategory()),
            );
          },
          context: context,
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
              width * 0.9,
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
              text: "Take Order",
              height: height,
              width: width,
              textColor: Provider.of<InfoProvider>(context, listen: true)
                  .systemInfo
                  .iconsColor,
              buttonColor: Provider.of<InfoProvider>(context, listen: true)
                  .systemInfo
                  .iconsColor,
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
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const EditMenu()),
                );
              },
              context: context,
            ),
          ],
        )
      ],
    );
  }

  Expanded buildCarousel(BuildContext context) {
    return Expanded(
      flex: 1,
      child: Provider.of<MenuProvider>(context, listen: true)
                  .activeSpecialsList
                  .isEmpty ||
              Provider.of<MenuProvider>(context, listen: true)
                      .activeSpecialsList
                      .length ==
                  1
          ? Center(
              child: Padding(
                padding: EdgeInsets.only(top: height),
                child: Provider.of<MenuProvider>(context, listen: true)
                            .activeSpecialsList
                            .length ==
                        1
                    ? SizedBox(
                        height: height * 25,
                        width: width * 50,
                        child: Image.network(
                          Provider.of<MenuProvider>(context, listen: true)
                              .activeSpecialsList[0]
                              .image!,
                          fit: BoxFit.fill,
                        ),
                      )
                    : Container(
                        width: width * 60,
                        color: Data.lightGreyBodyColor.withOpacity(0.4),
                        child: Center(
                            child: buildCustomText(
                                "No Image", Data.darkTextColor, width * 2)),
                      ),
              ),
            )
          : SizedBox(
              height: height * 30,
              child: CarouselSlider.builder(
                itemCount: Provider.of<MenuProvider>(context, listen: true)
                    .activeSpecialsList
                    .length,
                itemBuilder:
                    (BuildContext context, int itemIndex, int pageViewIndex) {
                  return Provider.of<MenuProvider>(context, listen: true)
                              .activeSpecialsList[itemIndex]
                              .image ==
                          null
                      ? Container(
                          color: Data.lightGreyBodyColor,
                          child: buildCustomText(
                              "No Image", Data.darkTextColor, width),
                        )
                      : SizedBox(
                          width: width * 50,
                          child: Image.network(
                            Provider.of<MenuProvider>(context, listen: true)
                                .activeSpecialsList[itemIndex]
                                .image!,
                            fit: BoxFit.fill,
                          ),
                        );
                },
                options: CarouselOptions(
                  autoPlay: true,
                  enlargeCenterPage: true,
                  aspectRatio: 3.5,
                ),
              ),
            ),
    );
  }

  Widget optionsSection(BuildContext context) {
    if (Provider.of<MenuProvider>(context, listen: true).categoryList.isEmpty ||
        Provider.of<MenuProvider>(context, listen: true)
                .getActiveCategoriesCount() ==
            0) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            height: width * 12,
            width: width * 12,
            color: Data.lightGreyBodyColor,
            child: Center(
              child: buildCustomText(
                "No Data",
                Data.darkTextColor,
                width,
              ),
            ),
          ),
        ],
      );
    } else {
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
            if (category.status) {
              return Row(
                children: [
                  menuOption(
                    category.name,
                    category.image!,
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
            }
            return null;
          },
        ),
      );
    }
  }
}
