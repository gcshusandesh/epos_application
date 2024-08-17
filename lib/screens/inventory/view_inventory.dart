import 'package:epos_application/components/buttons.dart';
import 'package:epos_application/components/common_widgets.dart';
import 'package:epos_application/components/data.dart';
import 'package:epos_application/components/models.dart';
import 'package:epos_application/components/size_config.dart';
import 'package:epos_application/providers/auth_provider.dart';
import 'package:epos_application/providers/info_provider.dart';
import 'package:epos_application/providers/inventory_provider.dart';
import 'package:epos_application/screens/inventory/edit_unit.dart';
import 'package:epos_application/screens/inventory/update_inventory.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

class ViewInventory extends StatefulWidget {
  const ViewInventory({super.key});

  @override
  State<ViewInventory> createState() => _ViewInventoryState();
}

class _ViewInventoryState extends State<ViewInventory> {
  bool init = true;
  late double height;
  late double width;
  bool isLoading = false;
  bool isEditing = false;
  String searchQuery = "";
  final ScrollController _scrollController = ScrollController();
  TextEditingController filterController = TextEditingController();
  String? filterDropDown = "Total Items";

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchData(reload: false);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (init) {
      SizeConfig().init(context);
      height = SizeConfig.safeBlockVertical;
      width = SizeConfig.safeBlockHorizontal;
      init = false;
    }
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
    filterController.dispose();
  }

  void _fetchData({required bool reload}) async {
    setState(() {
      isLoading = true;
    });
    Provider.of<InventoryProvider>(context, listen: false)
        .calculateInventoryAnalytics();
    await Provider.of<InventoryProvider>(context, listen: false)
        .getInventoryList(
            accessToken: Provider.of<AuthProvider>(context, listen: false)
                .user
                .accessToken!,
            context: context);
    if (mounted) {
      await Provider.of<InventoryProvider>(context, listen: false).getUnitTypes(
          accessToken: Provider.of<AuthProvider>(context, listen: false)
              .user
              .accessToken!,
          context: context);
      if (!reload) {
        initialCheck = true;
      }
    }
    setState(() {
      isLoading = false;
    });
  }

  bool initialCheck = false;

  @override
  Widget build(BuildContext context) {
    if (initialCheck &&
        Provider.of<InventoryProvider>(context, listen: false)
            .unitTypes
            .isEmpty) {
      initialCheck = false;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const EditUnitType()),
        );
      });
    }
    return Stack(
      children: [
        mainBody(context),
        isLoading
            ? onLoading(width: width, context: context)
            : const SizedBox(),
      ],
    );
  }

  Widget mainBody(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        controller: _scrollController,
        child: SizedBox(
          height: height * 100,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 20, left: 20, right: 20),
                child: customTopSection(
                    context: context,
                    height: height,
                    text: "Inventory",
                    width: width,
                    onTap: () {
                      _fetchData(reload: true);
                    }),
              ),
              inventoryAnalytics(context),
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          SizedBox(
                              width: width * 40,
                              height: height * 10,
                              child: searchBar()),
                          dataBox(
                            title: "Filter",
                            hintText: "Filter",
                            isRequired: true,
                            isDropDown: true,
                            controller: filterController,
                            validator: (value) {
                              if (filterDropDown == null ||
                                  filterDropDown!.isEmpty) {
                                return 'Select a valid Filter Type';
                              }
                              return null;
                            },
                            dropDown: DropdownButtonFormField<String>(
                              padding: EdgeInsets.zero,
                              icon: const Icon(
                                  Icons.arrow_drop_down_circle_outlined),
                              iconSize: width * 2,
                              iconDisabledColor: Provider.of<InfoProvider>(
                                      context,
                                      listen: true)
                                  .systemInfo
                                  .iconsColor,
                              iconEnabledColor: Provider.of<InfoProvider>(
                                      context,
                                      listen: true)
                                  .systemInfo
                                  .iconsColor,
                              decoration: InputDecoration(
                                enabledBorder: const OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Data
                                        .lightGreyBodyColor, // Custom focused border color
                                    width:
                                        1, // Custom focused border width (optional)
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Provider.of<InfoProvider>(context,
                                            listen: true)
                                        .systemInfo
                                        .primaryColor, // Custom focused border color
                                    width:
                                        2.0, // Custom focused border width (optional)
                                  ),
                                ),
                              ),
                              hint: const Text('Select'),
                              dropdownColor: Colors.white,
                              value: filterDropDown,
                              onChanged: (String? newValue) {
                                setState(() {
                                  filterDropDown = newValue!;
                                });
                              },
                              items: [
                                "Total Items",
                                "In Stock",
                                "Low Stock",
                                "Out of Stock"
                              ].map<DropdownMenuItem<String>>((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 20, right: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            iconButton(
                              "assets/svg/add.svg",
                              height,
                              width,
                              () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const UpdateInventory()),
                                );
                              },
                              context: context,
                            ),
                            SizedBox(width: width),
                            iconButton(
                              "assets/svg/edit.svg",
                              height,
                              width,
                              () {
                                setState(() {
                                  isEditing = !isEditing;
                                });
                              },
                              isSelected: isEditing,
                              context: context,
                            ),
                            SizedBox(width: width),
                            textButton(
                              text: "Manage",
                              height: height,
                              width: width,
                              textColor: Provider.of<InfoProvider>(context,
                                      listen: true)
                                  .systemInfo
                                  .iconsColor,
                              buttonColor: Provider.of<InfoProvider>(context,
                                      listen: true)
                                  .systemInfo
                                  .iconsColor,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const EditUnitType()),
                                );
                              },
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: height * 2),
              tableSection(context),
            ],
          ),
        ),
      ),
    );
  }

  Container inventoryAnalytics(BuildContext context) {
    return Container(
      color: Provider.of<InfoProvider>(context, listen: true)
          .systemInfo
          .iconsColor
          .withOpacity(0.5),
      margin: EdgeInsets.symmetric(vertical: height * 1.5),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      height: height * 30,
      width: width * 100,
      child: Column(
        children: [
          buildCustomText(
              "Inventory Analytics", Data.darkTextColor, width * 2.2,
              fontWeight: FontWeight.bold),
          SizedBox(height: height),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              analyticsBox(
                context: context,
                count: Provider.of<InventoryProvider>(context, listen: true)
                    .totalItems
                    .toDouble(),
                title: "Total Items",
                onTap: () {
                  setState(() {
                    filterDropDown = "Total Items";
                  });
                },
              ),
              analyticsBox(
                context: context,
                count: Provider.of<InventoryProvider>(context, listen: true)
                    .lowStock
                    .toDouble(),
                title: "Low Stock",
                onTap: () {
                  setState(() {});
                  filterDropDown = "Low Stock";
                },
              ),
              analyticsBox(
                context: context,
                count: Provider.of<InventoryProvider>(context, listen: true)
                    .outOfStock
                    .toDouble(),
                title: "Out of Stock",
                onTap: () {
                  setState(() {
                    filterDropDown = "Out of Stock";
                  });
                },
              ),
              analyticsBox(
                context: context,
                count: Provider.of<InventoryProvider>(context, listen: true)
                    .inventoryWorth,
                title: "Inventory Worth",
                isWorth: true,
                onTap: () {},
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget analyticsBox({
    required BuildContext context,
    required double count,
    required String title,
    bool isWorth = false,
    Function()? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: isWorth ? width * 20 : width * 15,
        height: height * 20,
        padding: EdgeInsets.symmetric(horizontal: width * 1.5),
        decoration: BoxDecoration(
          color: Provider.of<InfoProvider>(context, listen: true)
              .systemInfo
              .primaryColor,
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: isWorth
              ? [
                  buildCustomText(title, Colors.white, width * 1.65,
                      fontWeight: FontWeight.bold),
                  SizedBox(
                    height: height,
                  ),
                  Row(
                    children: [
                      buildCustomText(
                          Provider.of<InfoProvider>(context, listen: true)
                              .systemInfo
                              .currencySymbol
                              .toString(),
                          Colors.white,
                          width * 3,
                          fontWeight: FontWeight.bold),
                      SizedBox(width: width),
                      buildCustomText(
                          count.toStringAsFixed(2), Colors.white, width * 3,
                          fontWeight: FontWeight.bold),
                    ],
                  ),
                ]
              : [
                  buildCustomText(
                      count.toStringAsFixed(0), Colors.white, width * 3,
                      fontWeight: FontWeight.bold),
                  SizedBox(
                    height: height,
                  ),
                  buildCustomText(title, Colors.white, width * 1.65,
                      fontWeight: FontWeight.bold),
                ],
        ),
      ),
    );
  }

  Widget searchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      child: TextField(
        onTapOutside: (value) {
          FocusScope.of(context).unfocus();
        },
        onTap: () {
          if (_scrollController.hasClients) {
            _scrollController.animateTo(
              330,
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
            );
          }
        },
        onChanged: (value) {
          setState(() {
            searchQuery = value.toLowerCase();
          });
          if (_scrollController.hasClients) {
            _scrollController.animateTo(
              330,
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
            );
          }
        },
        decoration: InputDecoration(
          hintText: "Search items...",
          prefixIcon: Icon(
            Icons.search,
            color: Provider.of<InfoProvider>(context, listen: true)
                .systemInfo
                .primaryColor,
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Provider.of<InfoProvider>(context, listen: true)
                  .systemInfo
                  .primaryColor, // Custom focused border color
              width: 2.0, // Custom focused border width (optional)
            ),
          ),
          enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(
              color: Data.lightGreyBodyColor, // Custom focused border color
              width: 1, // Custom focused border width (optional)
            ),
          ),
        ),
      ),
    );
  }

  Expanded tableSection(BuildContext context) {
    final inventoryItems = Provider.of<InventoryProvider>(context, listen: true)
        .inventoryItems
        .where((item) =>
            item.name.toLowerCase().contains(searchQuery) ||
            item.type.toLowerCase().contains(searchQuery))
        .toList();

    // Apply filtering based on the selected filterDropDown value
    List<InventoryItem> filteredItems;
    if (filterDropDown == "In Stock") {
      filteredItems = inventoryItems
          .where((item) => item.quantity > item.lowStockTrigger)
          .toList();
    } else if (filterDropDown == "Low Stock") {
      filteredItems = inventoryItems
          .where((item) =>
              item.quantity > 0 && item.quantity <= item.lowStockTrigger)
          .toList();
    } else if (filterDropDown == "Out of Stock") {
      filteredItems =
          inventoryItems.where((item) => item.quantity == 0).toList();
    } else {
      filteredItems = inventoryItems;
    }

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.only(left: 20, right: 20),
        child: SingleChildScrollView(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: filteredItems.isEmpty
                ? Column(
                    children: [
                      Table(
                        border: TableBorder.all(color: Colors.black),
                        defaultVerticalAlignment:
                            TableCellVerticalAlignment.middle,
                        children: [
                          TableRow(
                              decoration: const BoxDecoration(
                                  color: Data.lightGreyBodyColor),
                              children: [
                                tableTitle("S.N.", width),
                                tableTitle("Name", width),
                                tableTitle("Quantity Type", width),
                                tableTitle("Quantity", width),
                                tableTitle("Low Stock Trigger", width),
                                tableTitle("Price", width),
                                tableTitle("Total", width),
                                tableTitle("Action", width),
                              ]),
                        ],
                      ),
                      Container(
                        width: width * 100,
                        decoration: const BoxDecoration(
                          color: Data.lightGreyBodyColor,
                          border: Border(
                            left: BorderSide(color: Colors.black, width: 1),
                            right: BorderSide(color: Colors.black, width: 1),
                            bottom: BorderSide(color: Colors.black, width: 1),
                          ),
                        ),
                        child: Center(
                          child: buildSmallText("No Data Available",
                              Data.lightGreyTextColor, width),
                        ),
                      )
                    ],
                  )
                : Table(
                    border: TableBorder.all(color: Colors.black),
                    defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                    children: [
                      TableRow(
                          decoration: const BoxDecoration(
                              color: Data.lightGreyBodyColor),
                          children: [
                            tableTitle("S.N.", width),
                            tableTitle("Name", width),
                            tableTitle("Quantity Type", width),
                            tableTitle("Quantity", width),
                            tableTitle("Low Stock Trigger", width),
                            tableTitle("Price", width),
                            tableTitle("Total", width),
                            tableTitle("Action", width),
                          ]),
                      for (int index = 0; index < filteredItems.length; index++)
                        buildInventoryRows(filteredItems[index], index),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  TableRow buildInventoryRows(InventoryItem item, int index) {
    return TableRow(
      decoration: const BoxDecoration(color: Data.lightGreyBodyColor),
      children: [
        tableItem((index + 1).toString(), width, context),
        InkWell(
          onTap: () {
            if (isEditing) {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => UpdateInventory(
                          isEdit: true,
                          index: index,
                          id: item.id,
                        )),
              );
            }
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10.0),
            child: Column(
              children: [
                tableItem(item.name, width, context),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    buildCustomText(
                        item.quantity == 0
                            ? "Out of Stock"
                            : item.quantity <= item.lowStockTrigger
                                ? "Low Stock"
                                : "In Stock",
                        item.quantity == 0
                            ? Data.redColor
                            : item.quantity <= item.lowStockTrigger
                                ? Provider.of<InfoProvider>(context,
                                        listen: true)
                                    .systemInfo
                                    .iconsColor
                                : Data.greenColor,
                        width),
                    isEditing
                        ? Padding(
                            padding: EdgeInsets.only(left: width),
                            child: label(
                                text: "edit",
                                height: height,
                                width: width,
                                labelColor: Provider.of<InfoProvider>(context,
                                        listen: true)
                                    .systemInfo
                                    .iconsColor),
                          )
                        : const SizedBox(),
                  ],
                )
              ],
            ),
          ),
        ),
        tableItem(item.type, width, context),
        tableItem("x${item.quantity.toString()}", width, context),
        tableItem(item.lowStockTrigger.toString(), width, context),
        tableItem(
            "${Provider.of<InfoProvider>(context, listen: true).systemInfo.currencySymbol} ${item.price.toStringAsFixed(2)}",
            width,
            context),
        tableItem(
            "${Provider.of<InfoProvider>(context, listen: true).systemInfo.currencySymbol} ${(item.price * item.quantity).toStringAsFixed(2)}",
            width,
            context),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: width * 2),
          child: textButton(
            text: "Delete",
            height: height,
            width: width,
            textColor: Data.redColor,
            buttonColor: Data.redColor,
            onTap: () async {
              setState(() {
                isLoading = true;
              });
              bool isDeleted =
                  await Provider.of<InventoryProvider>(context, listen: false)
                      .deleteInventoryItem(
                          id: item.id!,
                          index: index,
                          accessToken:
                              Provider.of<AuthProvider>(context, listen: false)
                                  .user
                                  .accessToken!,
                          context: context);
              if (isDeleted && mounted) {
                showTopSnackBar(
                    Overlay.of(context),
                    const CustomSnackBar.success(
                      message: "Inventory Item Deleted",
                      textStyle:
                          TextStyle(fontWeight: FontWeight.w600, fontSize: 20),
                    ));
              } else if (!isDeleted && mounted) {
                showTopSnackBar(
                    Overlay.of(context),
                    const CustomSnackBar.error(
                      message: "Unable to delete item",
                      textStyle:
                          TextStyle(fontWeight: FontWeight.w600, fontSize: 20),
                    ));
              }
              setState(() {
                isLoading = false;
              });
            },
          ),
        )
      ],
    );
  }

  Container tableItem(String text, double width, BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: height),
      decoration: const BoxDecoration(
        border: Border(
          left: BorderSide(color: Colors.black, width: 1),
          right: BorderSide(color: Colors.black, width: 1),
        ),
      ),
      child: Center(
        child: buildSmallText(text, Data.darkTextColor, width),
      ),
    );
  }

  Container tableTitle(String text, double width) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: height),
      decoration: const BoxDecoration(
        border: Border(
          right: BorderSide(color: Colors.black, width: 1),
        ),
      ),
      child: Center(
        child: buildCustomText(text, Data.darkTextColor, width,
            fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget dataBox({
    required String title,
    required String hintText,
    required TextEditingController controller,
    required Function? validator,
    bool isDropDown = false,
    bool isRequired = false,
    bool isNumber = false,
    Widget dropDown = const SizedBox(),
  }) {
    return SizedBox(
      height: height * 8,
      width: width * 31,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          isDropDown
              ? dropDown
              : buildInputField(hintText, height, width, context, controller,
                  validator: validator, isNumber: isNumber),
        ],
      ),
    );
  }
}
