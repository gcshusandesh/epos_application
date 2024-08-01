import 'package:carousel_slider/carousel_slider.dart';
import 'package:el_tooltip/el_tooltip.dart';
import 'package:epos_application/components/buttons.dart';
import 'package:epos_application/components/common_widgets.dart';
import 'package:epos_application/components/data.dart';
import 'package:epos_application/components/models.dart';
import 'package:epos_application/components/size_config.dart';
import 'package:epos_application/providers/auth_provider.dart';
import 'package:epos_application/screens/menu/edit_category.dart';
import 'package:epos_application/screens/menu/edit_menu.dart';
import 'package:epos_application/screens/menu/edit_specials.dart';
import 'package:epos_application/screens/order/take_orders.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:pinput/pinput.dart';
import 'package:provider/provider.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

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

  TextEditingController pinController = TextEditingController();
  TextEditingController tableNumberController = TextEditingController();

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
      ///choose first category by default
      Provider.of<MenuProvider>(context, listen: false).resetCategory();
      // Get menuItems from API
      await Provider.of<MenuProvider>(context, listen: false).getMenuList(
          accessToken: Provider.of<AuthProvider>(context, listen: false)
              .user
              .accessToken!,
          isItem: true,
          context: context);
    }
    if (mounted) {
      // Get guest mode pin
      await Provider.of<MenuProvider>(context, listen: false).getGuestPin(
          accessToken: Provider.of<AuthProvider>(context, listen: false)
              .user
              .accessToken!,
          context: context);
    }
    if (mounted &&
        Provider.of<MenuProvider>(context, listen: false).hasPin == false) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showDialog(
          barrierDismissible: false,
          context: context,
          builder: (BuildContext context) {
            return setPinAlert();
          },
        );
      });
    }
    setState(() {
      isLoading = false;
    });
  }

  bool isLoading = false;
  bool init = true;
  late double height;
  late double width;
  bool isTakingOrder = false;
  bool isGuestMode = false;

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
  void dispose() {
    super.dispose();
    tableNumberController.dispose();
    pinController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: isGuestMode ||
              Provider.of<MenuProvider>(context, listen: true).hasPin == false
          ? false
          : true,
      onPopInvoked: (bool value) async {
        if (Provider.of<MenuProvider>(context, listen: true).hasPin == false) {
          print("do nothing");
          // do nothing
        } else if (isGuestMode) {
          showDialog(
            barrierDismissible: false,
            context: context,
            builder: (BuildContext context) {
              return exitAlert();
            },
          );
        } else if (!isGuestMode) {
          SystemChrome.setPreferredOrientations([
            DeviceOrientation.landscapeLeft,
            DeviceOrientation.landscapeRight,
          ]);
        }
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

  Widget mainBody(BuildContext context) {
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
                          .menuItemsByCategory
                          .isEmpty ||
                      Provider.of<MenuProvider>(context, listen: true)
                          .menuItemsByCategory[
                              Provider.of<MenuProvider>(context, listen: true)
                                  .selectedCategoryIndex]
                          .menuItems
                          .isEmpty ||
                      Provider.of<MenuProvider>(context, listen: false)
                              .getActiveItemsCountByCategory() ==
                          0 ||
                      Provider.of<MenuProvider>(context, listen: false)
                              .getActiveCategoryCount() ==
                          0
                  ? Center(
                      child: buildBodyText(
                        "No Data Available",
                        Data.darkTextColor,
                        width * 1,
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
                        if (Provider.of<MenuProvider>(context, listen: true)
                            .menuItemsByCategory[
                                Provider.of<MenuProvider>(context, listen: true)
                                    .selectedCategoryIndex]
                            .menuItems[itemIndex]
                            .status) {
                          return menuItem(itemIndex);
                        }
                        return null;
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
        !isGuestMode
            ? Padding(
                padding: EdgeInsets.only(right: width * 12),
                child: iconButton(
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
              )
            : SizedBox(width: width * 9.4),
        buildTitleText(text, Data.darkTextColor, width),
        Row(
          children: [
            ((Provider.of<AuthProvider>(context, listen: false).user.userType ==
                            UserType.owner) ||
                        (Provider.of<AuthProvider>(context, listen: false)
                                .user
                                .userType ==
                            UserType.manager)) &&
                    !isGuestMode
                ? Padding(
                    padding: EdgeInsets.only(right: width),
                    child: textButton(
                      text: "Reset Pin",
                      height: height,
                      width: width,
                      textColor:
                          Provider.of<InfoProvider>(context, listen: true)
                              .systemInfo
                              .iconsColor,
                      buttonColor:
                          Provider.of<InfoProvider>(context, listen: true)
                              .systemInfo
                              .iconsColor,
                      onTap: () {
                        showDialog(
                          barrierDismissible: false,
                          context: context,
                          builder: (BuildContext context) {
                            return setPinAlert(isReset: true);
                          },
                        );
                      },
                    ),
                  )
                : SizedBox(
                    width: width * 2,
                  ),
            textButton(
              text: "  Guest Mode  ",
              height: height,
              width: width,
              textColor: Provider.of<InfoProvider>(context, listen: true)
                  .systemInfo
                  .iconsColor,
              buttonColor: Provider.of<InfoProvider>(context, listen: true)
                  .systemInfo
                  .iconsColor,
              isSelected: isGuestMode,
              onTap: () {
                if (!isGuestMode) {
                  showDialog(
                    barrierDismissible: false,
                    context: context,
                    builder: (BuildContext context) {
                      return entryAlert();
                    },
                  );
                }
              },
            ),
          ],
        ),
      ],
    );
  }

  Container menuItem(int itemIndex) {
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: width * 1,
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
          Flexible(
            flex: 9,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10.0),
              child: Provider.of<MenuProvider>(context, listen: true)
                          .menuItemsByCategory[
                              Provider.of<MenuProvider>(context, listen: true)
                                  .selectedCategoryIndex]
                          .menuItems[itemIndex]
                          .image ==
                      null
                  ? SizedBox(
                      height: isTakingOrder ? width * 8 : width * 12,
                      width: width * 12,
                      child: Center(
                        child: buildCustomText(
                          "No Image",
                          Data.darkTextColor,
                          width * 1.5,
                        ),
                      ),
                    )
                  : buildImage(
                      Provider.of<MenuProvider>(context, listen: true)
                          .menuItemsByCategory[
                              Provider.of<MenuProvider>(context, listen: true)
                                  .selectedCategoryIndex]
                          .menuItems[itemIndex]
                          .image!,
                      isTakingOrder ? width * 8 : width * 12,
                      width * 12,
                      isNetworkImage: true,
                      context: context),
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
                      width: width * 10,
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
                      "\nIngredients: ${Provider.of<MenuProvider>(context, listen: true).menuItemsByCategory[Provider.of<MenuProvider>(context, listen: true).selectedCategoryIndex].menuItems[itemIndex].ingredients}",
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
              ],
            ),
          ),

          ///add new code here
          isTakingOrder
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    countButton(
                      Icons.remove,
                      height,
                      width,
                      () {
                        Provider.of<MenuProvider>(context, listen: false)
                            .decreaseMenuItemQuantity(itemIndex: itemIndex);
                      },
                    ),
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: width),
                      padding: EdgeInsets.symmetric(horizontal: width),
                      decoration: BoxDecoration(
                        color: Colors.white, // Inside color
                        borderRadius: BorderRadius.circular(5), // Border radius
                        border: Border.all(
                            color: Data.lightGreyTextColor,
                            width: 1.0), // Black border
                      ),
                      child: buildCustomText(
                        "x${Provider.of<MenuProvider>(context, listen: false).menuItemsByCategory[Provider.of<MenuProvider>(context, listen: true).selectedCategoryIndex].menuItems[itemIndex].quantity}",
                        Data.lightGreyTextColor,
                        width * 1.8,
                      ),
                    ),
                    countButton(
                      Icons.add,
                      height,
                      width,
                      () {
                        Provider.of<MenuProvider>(context, listen: false)
                            .increaseMenuItemQuantity(itemIndex: itemIndex);
                      },
                    ),
                  ],
                )
              : const SizedBox(),
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
      width: width * 2,
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

  Widget countButton(
    IconData icon,
    double height,
    double width,
    Function() onTap,
  ) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: height * 5,
        width: width * 4,
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
            child: Icon(
          icon,
          color: Provider.of<InfoProvider>(context, listen: false)
              .systemInfo
              .iconsColor,
          size: width * 2,
        )),
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
          width * 0.9,
          fontFamily: "RobotoMedium",
        ),
        Row(
          children: [
            !isGuestMode
                ? iconButton(
                    isSvg: false,
                    "",
                    icon: Icons.refresh,
                    height,
                    width,
                    () {
                      _fetchData();
                    },
                    context: context,
                  )
                : const SizedBox(),
            ((Provider.of<AuthProvider>(context, listen: false).user.userType ==
                            UserType.owner) ||
                        (Provider.of<AuthProvider>(context, listen: false)
                                .user
                                .userType ==
                            UserType.manager)) &&
                    !isGuestMode
                ? Row(
                    children: [
                      SizedBox(width: width),
                      iconButton(
                        "assets/svg/edit.svg",
                        height,
                        width,
                        () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const EditSpecials()),
                          );
                        },
                        context: context,
                      ),
                    ],
                  )
                : const SizedBox(),
          ],
        ),
      ],
    );
  }

  Row category() {
    return Row(
      mainAxisAlignment:
          ((Provider.of<AuthProvider>(context, listen: false).user.userType ==
                          UserType.owner) ||
                      (Provider.of<AuthProvider>(context, listen: false)
                              .user
                              .userType ==
                          UserType.manager)) &&
                  !isGuestMode
              ? MainAxisAlignment.spaceBetween
              : MainAxisAlignment.start,
      children: [
        buildBodyText(
          "Category",
          Data.greyTextColor,
          width * 0.9,
          fontFamily: "RobotoMedium",
        ),
        ((Provider.of<AuthProvider>(context, listen: false).user.userType ==
                        UserType.owner) ||
                    (Provider.of<AuthProvider>(context, listen: false)
                            .user
                            .userType ==
                        UserType.manager)) &&
                !isGuestMode
            ? iconButton(
                "assets/svg/edit.svg",
                height,
                width,
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const EditCategory()),
                  );
                },
                context: context,
              )
            : const SizedBox(),
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
            isTakingOrder
                ? textButton(
                    text: "Proceed",
                    height: height,
                    width: width,
                    textColor: Provider.of<InfoProvider>(context, listen: true)
                        .systemInfo
                        .iconsColor,
                    buttonColor:
                        Provider.of<InfoProvider>(context, listen: true)
                            .systemInfo
                            .iconsColor,
                    onTap: () {
                      Provider.of<MenuProvider>(context, listen: false)
                          .calculateTotal();
                      showMaterialModalBottomSheet(
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(12.0),
                            topRight: Radius.circular(12.0),
                          ),
                        ),
                        backgroundColor: Data.lightGreyBodyColor,
                        context: context,
                        builder: (context) => const OrderTaker(),
                      );
                    },
                  )
                : const SizedBox(),
            SizedBox(
              width: width,
            ),
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
              isSelected: isTakingOrder,
              onTap: () {
                setState(() {
                  isTakingOrder = !isTakingOrder;
                });
              },
            ),
            ((Provider.of<AuthProvider>(context, listen: false).user.userType ==
                            UserType.owner) ||
                        (Provider.of<AuthProvider>(context, listen: false)
                                .user
                                .userType ==
                            UserType.manager)) &&
                    !isGuestMode
                ? Row(
                    children: [
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
                            MaterialPageRoute(
                                builder: (context) => const EditMenu()),
                          );
                        },
                        context: context,
                      ),
                    ],
                  )
                : const SizedBox(),
          ],
        )
      ],
    );
  }

  Widget buildCarousel(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: height),
      child: Provider.of<MenuProvider>(context, listen: true)
                  .activeSpecialsList
                  .isEmpty ||
              Provider.of<MenuProvider>(context, listen: true)
                      .activeSpecialsList
                      .length ==
                  1
          ? Center(
              child: Provider.of<MenuProvider>(context, listen: true)
                          .activeSpecialsList
                          .length ==
                      1
                  ? buildImage(
                      Provider.of<MenuProvider>(context, listen: true)
                          .activeSpecialsList[0]
                          .image!,
                      height * 25,
                      width * 50,
                      context: context,
                      isNetworkImage: true,
                    )
                  : Container(
                      width: width * 60,
                      height: height * 25,
                      color: Data.lightGreyBodyColor.withOpacity(0.4),
                      child: Center(
                          child: buildCustomText(
                              "No Image", Data.darkTextColor, width * 2)),
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
                      : buildImage(
                          Provider.of<MenuProvider>(context, listen: true)
                              .activeSpecialsList[itemIndex]
                              .image!,
                          height * 25,
                          width * 50,
                          context: context,
                          isNetworkImage: true,
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
            padding: EdgeInsets.symmetric(
              vertical: width * 1,
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
            child: Center(
              child: buildCustomText(
                "No Data",
                Data.darkTextColor,
                width * 1.5,
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
            var category = Provider.of<MenuProvider>(context, listen: true)
                .categoryList[index];

            return category.status
                ? Row(
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
                  )
                : const SizedBox();
          },
        ),
      );
    }
  }

  Container dataBox({
    required String title,
    required String hintText,
    required TextEditingController controller,
    required Function? validator,
    bool isRequired = false,
    bool isNumber = false,
  }) {
    return Container(
      width: width * 15,
      padding: EdgeInsets.symmetric(vertical: height, horizontal: width),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              buildCustomText(title, Data.lightGreyTextColor, width * 1.75,
                  fontFamily: "RobotoMedium"),
              isRequired
                  ? buildSmallText(
                      "*",
                      Data.redColor,
                      width * 2,
                    )
                  : const SizedBox(),
            ],
          ),
          SizedBox(height: height),
          Container(
            color: Colors.white,
            child: buildInputField(hintText, height, width, context, controller,
                validator: validator, isNumber: isNumber),
          ),
        ],
      ),
    );
  }

  // set up the AlertDialog
  Widget entryAlert() {
    return AlertDialog(
      backgroundColor: Colors.white,
      title: const Text("Enter Guest Mode"),
      content: const Text("Are you sure you want to enter Guest Mode?"),
      actions: [
        Column(
          children: [
            SizedBox(height: height * 2),
            textButton(
              text: "Confirm",
              height: height,
              width: width,
              textColor: Data.greenColor,
              buttonColor: Data.greenColor,
              onTap: () {
                setState(() {
                  isGuestMode = true;
                });
                showTopSnackBar(
                  Overlay.of(context),
                  const CustomSnackBar.success(
                    message: "Successfully entered Guest Mode",
                  ),
                );
                // close dialog box
                Navigator.pop(context);
              },
            ),
            SizedBox(height: height * 2),
            textButton(
              text: "Cancel",
              height: height,
              width: width,
              textColor: Data.redColor,
              buttonColor: Data.redColor,
              onTap: () {
                // close dialog box
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ],
    );
  }

  // set up the AlertDialog
  Widget exitAlert() {
    return AlertDialog(
      backgroundColor: Colors.white,
      title: const Text("Exit Guest Mode"),
      content: const Text("Are you sure you want to exit Guest Mode?"),
      actions: [
        Column(
          children: [
            Center(
              child: Pinput(
                controller: pinController,
              ),
            ),
            SizedBox(height: height * 2),
            textButton(
              text: "Confirm",
              height: height,
              width: width,
              textColor: Data.greenColor,
              buttonColor: Data.greenColor,
              onTap: () {
                if (pinController.length == 4) {
                  if (pinController.text ==
                      Provider.of<MenuProvider>(context, listen: false)
                          .guestPin) {
                    setState(() {
                      isGuestMode = false;
                    });
                    // close dialog box
                    Navigator.pop(context);
                    showTopSnackBar(
                      Overlay.of(context),
                      const CustomSnackBar.success(
                        message: "Exited Guest Mode",
                      ),
                    );
                  } else {
                    //wrong pin
                    showTopSnackBar(
                      Overlay.of(context),
                      const CustomSnackBar.error(
                        message: "Wrong Pin",
                      ),
                    );
                  }
                  pinController.clear();
                } else {
                  /// Pin must be 4 digit
                  showTopSnackBar(
                    Overlay.of(context),
                    const CustomSnackBar.error(
                      message: "Pin must be 4 digits",
                    ),
                  );
                }
              },
            ),
            SizedBox(height: height * 2),
            textButton(
              text: "Cancel",
              height: height,
              width: width,
              textColor: Data.redColor,
              buttonColor: Data.redColor,
              onTap: () {
                // close dialog box
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ],
    );
  }

  // set up the AlertDialog
  Widget setPinAlert({bool isReset = false}) {
    return AlertDialog(
      backgroundColor: Colors.white,
      title: const Text("Set Guest Mode Pin"),
      content: const Text("Please enter your 4 digit pin code."),
      actions: [
        Column(
          children: [
            Center(
              child: Pinput(
                controller: pinController,
              ),
            ),
            SizedBox(height: height * 2),
            textButton(
              text: "Confirm",
              height: height,
              width: width,
              textColor: Data.greenColor,
              buttonColor: Data.greenColor,
              onTap: () async {
                final overlay = Overlay.of(context);
                if (pinController.length == 4) {
                  Navigator.pop(context);
                  setState(() {
                    isLoading = true;
                  });
                  bool isSetPinSuccess =
                      await Provider.of<MenuProvider>(context, listen: false)
                          .setGuestPin(
                              accessToken: Provider.of<AuthProvider>(context,
                                      listen: false)
                                  .user
                                  .accessToken!,
                              newPin: pinController.text,
                              context: context);
                  setState(() {
                    isLoading = false;
                  });
                  if (isSetPinSuccess) {
                    showTopSnackBar(
                      overlay,
                      const CustomSnackBar.success(
                        message: "Guest Mode pin set successfully",
                      ),
                    );
                  } else {
                    showTopSnackBar(
                      overlay,
                      const CustomSnackBar.error(
                        message:
                            "Guest Mode pin could not be set. Please try again",
                      ),
                    );
                  }
                  pinController.clear();
                } else {
                  /// Pin must be 4 digit
                  showTopSnackBar(
                    overlay,
                    const CustomSnackBar.error(
                      message: "Pin must be 4 digits",
                    ),
                  );
                }
              },
            ),
            isReset
                ? Padding(
                    padding: EdgeInsets.only(top: height),
                    child: textButton(
                      text: "Cancel",
                      height: height,
                      width: width,
                      textColor: Data.redColor,
                      buttonColor: Data.redColor,
                      onTap: () async {
                        Navigator.pop(context);
                      },
                    ),
                  )
                : const SizedBox(),
          ],
        ),
      ],
    );
  }
}
