import 'package:epos_application/components/buttons.dart';
import 'package:epos_application/components/common_widgets.dart';
import 'package:epos_application/components/data.dart';
import 'package:epos_application/components/models.dart';
import 'package:epos_application/components/size_config.dart';
import 'package:epos_application/providers/auth_provider.dart';
import 'package:epos_application/providers/info_provider.dart';
import 'package:epos_application/providers/menu_provider.dart';
import 'package:epos_application/providers/order_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

class OrderTaker extends StatefulWidget {
  const OrderTaker({super.key});

  @override
  State<OrderTaker> createState() => _OrderTakerState();
}

class _OrderTakerState extends State<OrderTaker> {
  // Add any state variables you need here
  int itemCount = 3; // Example state variable

  bool isLoading = false;
  bool init = true;
  late double height;
  late double width;
  TextEditingController tableNumberController = TextEditingController();
  TextEditingController specialInstructionController = TextEditingController();
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
    specialInstructionController.dispose();
  }

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height * 60,
      child: Stack(
        children: [
          mainBody(context),
          isLoading
              ? onLoading(width: width, context: context)
              : const SizedBox(),
        ],
      ),
    );
  }

  Padding mainBody(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: width * 5),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: height * 0.5),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                buildCustomText(
                    "                  ", Data.greyTextColor, width * 3),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(
                      color: Colors.black, // Outline color
                      width: 0.5, // Outline width
                    ),
                    borderRadius: BorderRadius.circular(6.0),
                  ),
                  height: 10,
                  width: width * 20,
                ),
                buildCustomText("Order ID: #3", Data.greyTextColor, width * 3,
                    fontWeight: FontWeight.bold),
              ],
            ),
            SizedBox(
              height: height,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [
                    buildCustomText(
                        "Total Items Ordered: ${Provider.of<MenuProvider>(context, listen: true).totalCount}",
                        Data.greyTextColor,
                        width * 2.5),
                    buildCustomText(
                        "Total Amount:  ${Provider.of<InfoProvider>(context, listen: true).systemInfo.currencySymbol!} ${Provider.of<MenuProvider>(context, listen: true).totalAmount.toStringAsFixed(2)}",
                        Data.greyTextColor,
                        width * 2.5),
                  ],
                ),
                Column(
                  children: [
                    dataBox(
                      title: "Table Number",
                      hintText: "Table Number",
                      isRequired: true,
                      controller: tableNumberController,
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Enter a valid name!';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
                Row(
                  children: [
                    textButton(
                      text: "Discard",
                      height: height * 0.8,
                      width: width * 1.5,
                      textColor: Data.redColor,
                      buttonColor: Data.redColor,
                      onTap: () {
                        showDialog(
                          barrierDismissible: false,
                          context: context,
                          builder: (BuildContext context) {
                            return discardAlert();
                          },
                        );
                      },
                    ),
                    SizedBox(width: width * 2),
                    textButton(
                      text: "Confirm",
                      height: height * 0.8,
                      width: width * 1.5,
                      textColor:
                          Provider.of<InfoProvider>(context, listen: true)
                              .systemInfo
                              .primaryColor,
                      buttonColor:
                          Provider.of<InfoProvider>(context, listen: true)
                              .systemInfo
                              .primaryColor,
                      onTap: () async {
                        final overlay = Overlay.of(context);
                        if (Provider.of<MenuProvider>(context, listen: false)
                                .totalCount ==
                            0) {
                          showTopSnackBar(
                            overlay,
                            const CustomSnackBar.error(
                              message: "Please select items to place an order",
                            ),
                          );
                        } else if (_formKey.currentState!.validate()) {
                          showDialog(
                            barrierDismissible: false,
                            context: context,
                            builder: (BuildContext context) {
                              return confirmAlert();
                            },
                          );
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: height * 2),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                specialDataBox(
                  title: "Special Instructions",
                  hintText: "Special Instructions",
                  controller: specialInstructionController,
                  validator: (value) {},
                ),
              ],
            ),
            SizedBox(height: height),
            tableSection(context),
          ],
        ),
      ),
    );
  }

  Widget confirmAlert() {
    return AlertDialog(
      backgroundColor: Colors.white,
      title: const Text("Confirm Order"),
      content: const Text("Are you sure you want to confirm this order?"),
      actions: [
        SizedBox(height: height * 2),
        alertTextButton(
          text: "Confirm",
          height: height,
          width: width,
          textColor: Data.greenColor,
          buttonColor: Data.greenColor,
          onTap: () async {
            final overlay = Overlay.of(context);
            Navigator.pop(context);
            setState(() {
              isLoading = true;
            });
            bool isSuccessful =
                await Provider.of<OrderProvider>(context, listen: false)
                    .createOrders(
              accessToken: Provider.of<AuthProvider>(context, listen: false)
                  .user
                  .accessToken!,
              context: context,
              order: ProcessedOrder(
                tableNumber: tableNumberController.text,
                items: Provider.of<OrderProvider>(context, listen: false)
                    .formatOrderItems(
                        Provider.of<MenuProvider>(context, listen: false)
                            .order
                            .items),
                instructions: specialInstructionController.text,
                price: Provider.of<MenuProvider>(context, listen: false)
                    .totalAmount,

                /// while placing the order, the discount is not applied, status is processing and isPaid is false
                discount: 0,
                status: OrderStatus.processing,
                isPaid: false,
              ),
            );
            setState(() {
              isLoading = false;
            });
            if (isSuccessful) {
              showTopSnackBar(
                overlay,
                const CustomSnackBar.success(
                  message: "Order placed successfully",
                ),
              );
            } else {
              showTopSnackBar(
                overlay,
                const CustomSnackBar.error(
                  message: "Failed to place order",
                ),
              );
            }
            if (mounted) {
              Provider.of<MenuProvider>(context, listen: false)
                  .resetAllOrders();
              // close the order taker
              Navigator.pop(context);
            }
          },
        ),
        SizedBox(
          height: height,
        ),
        alertTextButton(
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
    );
  }

  Widget discardAlert() {
    return AlertDialog(
      backgroundColor: Colors.white,
      title: const Text("Discard Order"),
      content: const Text(
          "Are you sure you want to discard this order? This action cannot be undone."),
      actions: [
        SizedBox(height: height * 2),
        alertTextButton(
          text: "Confirm",
          height: height,
          width: width,
          textColor: Data.greenColor,
          buttonColor: Data.greenColor,
          onTap: () {
            Provider.of<MenuProvider>(context, listen: false).resetAllOrders();
            // close dialog box and the order taker
            Navigator.pop(context);
            Navigator.pop(context);
            showTopSnackBar(
              Overlay.of(context),
              const CustomSnackBar.success(
                message: "Order Successfully Discarded",
              ),
            );
          },
        ),
        SizedBox(
          height: height,
        ),
        alertTextButton(
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
    );
  }

  Widget alertTextButton({
    required String text,
    required double height,
    required double width,
    required Color textColor,
    required Color buttonColor,
    required Function() onTap,
    bool isSelected = false,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: height * 5,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            color: buttonColor, // Outline color
            width: isSelected ? 3 : 0.5, // Outline width
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
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: buildBodyText(text, textColor, width,
                fontFamily: "RobotoMedium"),
          ),
        ),
      ),
    );
  }

  Widget tableSection(BuildContext context) {
    return Expanded(
      child: SingleChildScrollView(
        child: Container(
          color: Colors.white,
          padding: const EdgeInsets.all(5),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Provider.of<MenuProvider>(context, listen: true)
                    .order
                    .items
                    .isEmpty
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
                                tableTitle("Quantity", width),
                                tableTitle("Price", width),
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
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: height),
                            child: buildSmallText(
                              "No Data Available",
                              Data.lightGreyTextColor,
                              width * 2,
                            ),
                          ),
                        ),
                      )
                    ],
                  )
                : Column(
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
                                tableTitle("Quantity", width),
                                tableTitle("Price", width),
                                tableTitle("Action", width),
                              ]),
                          for (int index = 0;
                              index <
                                  Provider.of<MenuProvider>(context,
                                          listen: true)
                                      .order
                                      .items
                                      .length;
                              index++)
                            buildOrdersRow(
                              index: index,
                              item: Provider.of<MenuProvider>(context,
                                      listen: true)
                                  .order
                                  .items[index],
                            ),
                        ],
                      ),
                      Container(
                          height: height * 5,
                          width: double.infinity,
                          decoration: const BoxDecoration(
                            color: Data.lightGreyBodyColor,
                            border: Border(
                              left: BorderSide(color: Colors.black, width: 1),
                              right: BorderSide(color: Colors.black, width: 1),
                              bottom: BorderSide(color: Colors.black, width: 1),
                            ),
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(5),
                              bottomRight: Radius.circular(5),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Column(
                                children: [
                                  buildCustomText(
                                      "Bill Amount: ${Provider.of<InfoProvider>(context, listen: true).systemInfo.currencySymbol!} ${Provider.of<MenuProvider>(context, listen: true).totalAmount.toStringAsFixed(2)}",
                                      Data.greyTextColor,
                                      width * 2.5),
                                  buildCustomText(
                                      "(Inclusive 20% VAT @${Provider.of<InfoProvider>(context, listen: true).systemInfo.currencySymbol!}${Provider.of<MenuProvider>(context, listen: true).vatAmount.toStringAsFixed(2)})",
                                      Data.greyTextColor,
                                      width * 2),
                                ],
                              ),
                              SizedBox(width: width * 5),
                            ],
                          )),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  TableRow buildOrdersRow({required int index, required OrderItem item}) {
    return TableRow(
      decoration: const BoxDecoration(color: Data.lightGreyBodyColor),
      children: [
        tableItem((index + 1).toString(), width),
        tableItem(item.name, width),
        tableItem("x${item.quantity}", width),
        tableItem(item.price.toString(), width),
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: width * 3.5,
            vertical: height,
          ),
          child: textButton(
            text: "Delete",
            height: height * 0.6,
            width: width * 1.2,
            textColor: Data.redColor,
            buttonColor: Data.redColor,
            onTap: () async {
              Provider.of<MenuProvider>(context, listen: false)
                  .deleteItemFromOrderLocally(
                      itemIndex: index, itemName: item.name);
            },
          ),
        ),
      ],
    );
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
      width: width * 31,
      padding: EdgeInsets.symmetric(vertical: height, horizontal: width * 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              buildCustomText(title, Data.lightGreyTextColor, width * 2.5,
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

  Widget specialDataBox({
    required String title,
    required String hintText,
    required TextEditingController controller,
    bool isRequired = false,
    bool isNumber = false,
    bool isSpecial = false,
    Function? validator,
  }) {
    return Row(
      children: [
        buildCustomText("$title:", Data.lightGreyTextColor, width * 3,
            fontFamily: "RobotoMedium"),
        isRequired
            ? buildSmallText(
                "*",
                Data.redColor,
                width * 2,
              )
            : const SizedBox(),
        SizedBox(
          width: width * 2,
        ),
        Container(
          color: Colors.white,
          child: buildInputField(hintText, height, width, context, controller,
              isNumber: isNumber, validator: validator),
        ),
      ],
    );
  }

  Widget tableTitle(String text, double width) {
    return Center(
        child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 15.0),
      child: buildBodyText(
        text,
        Data.lightGreyTextColor,
        width * 1.25,
        fontFamily: "RobotoMedium",
      ),
    ));
  }

  Widget tableItem(String text, double width) {
    return Center(
        child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: buildSmallText(
        text,
        Data.lightGreyTextColor,
        width * 1.75,
      ),
    ));
  }
}
