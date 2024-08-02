import 'dart:io';

import 'package:epos_application/components/buttons.dart';
import 'package:epos_application/components/common_widgets.dart';
import 'package:epos_application/components/data.dart';
import 'package:epos_application/components/models.dart';
import 'package:epos_application/components/size_config.dart';
import 'package:epos_application/providers/auth_provider.dart';
import 'package:epos_application/providers/info_provider.dart';
import 'package:epos_application/providers/menu_provider.dart';
import 'package:epos_application/providers/order_provider.dart';
import 'package:epos_application/screens/payment/invoice_pdf.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

class Payment extends StatefulWidget {
  const Payment({
    super.key,
    this.isSales = false,
    this.divertedFromPayment = false,
    this.orderId,
  });
  final bool isSales;
  final bool divertedFromPayment;
  final int? orderId;

  @override
  State<Payment> createState() => _PaymentState();
}

class _PaymentState extends State<Payment> {
  bool init = true;
  late double height;
  late double width;
  bool isEditing = false;
  bool isLoading = false;
  TextEditingController emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

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

  void _fetchData() async {
    //fetch data from api
    setState(() {
      isLoading = true;
    });
    await Provider.of<OrderProvider>(context, listen: false).getOrders(
      accessToken:
          Provider.of<AuthProvider>(context, listen: false).user.accessToken!,
      context: context,
    );
    if (widget.isSales && mounted) {
      // if sales history get menuItems from API to make fresh pricelist for invoice
      await Provider.of<MenuProvider>(context, listen: false).getMenuList(
          accessToken: Provider.of<AuthProvider>(context, listen: false)
              .user
              .accessToken!,
          isItem: true,
          context: context);
    }
    setState(() {
      isLoading = false;
    });
    if (mounted && widget.divertedFromPayment) {
      showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return ratingAlert();
        },
      );
    }
  }

  @override
  void dispose() {
    super.dispose();
    emailController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvoked: (bool value) async {
        if (widget.divertedFromPayment && mounted) {
          // if this is a diverted page, go back to the payment page
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.pop(context);
          });
        }
      },
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

  Row topSection(
      {required BuildContext context,
      required double height,
      required String text,
      required double width,
      bool initialSetup = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        !initialSetup
            ? iconButton(
                "assets/svg/arrow_back.svg",
                height,
                width,
                () {
                  Navigator.pop(context);
                },
                context: context,
              )
            : SizedBox(
                width: width * 5,
              ),
        buildTitleText(text, Data.darkTextColor, width),
        SizedBox(
          width: width * 5,
        ),
      ],
    );
  }

  Scaffold mainBody(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            topSection(
                context: context,
                text: widget.isSales ? "Sales History" : "Payment",
                height: height,
                width: width),
            SizedBox(height: height * 2),
            editSection(),
            SizedBox(height: height * 2),
            tableSection(context),
          ],
        ),
      ),
    );
  }

  Expanded tableSection(BuildContext context) {
    return Expanded(
      child: SingleChildScrollView(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: Provider.of<OrderProvider>(context, listen: true)
                      .processedOrders
                      .isEmpty ||
                  (!widget.isSales &&
                      Provider.of<OrderProvider>(context, listen: true)
                              .getPaymentListCount() ==
                          0) ||
                  (widget.isSales &&
                      Provider.of<OrderProvider>(context, listen: true)
                              .getSalesListCount() ==
                          0)
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
                            children: widget.isSales
                                ? [
                                    tableTitle("Order ID", width),
                                    tableTitle("Table Number", width),
                                    tableTitle("Items", width),
                                    tableTitle("Paid Price", width),
                                    tableTitle("Payment Mode", width),
                                    tableTitle("Payment Time", width),
                                    tableTitle("Action", width),
                                  ]
                                : [
                                    tableTitle("Order ID", width),
                                    tableTitle("Table Number", width),
                                    tableTitle("Items", width),
                                    tableTitle("Price", width),
                                    tableTitle("Adjusted Price", width),
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
                            width * 1.5,
                          ),
                        ),
                      ),
                    )
                  ],
                )
              : Table(
                  border: TableBorder.all(color: Colors.black),
                  defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                  children: [
                    TableRow(
                        decoration:
                            const BoxDecoration(color: Data.lightGreyBodyColor),
                        children: widget.isSales
                            ? [
                                tableTitle("Order ID", width),
                                tableTitle("Table Number", width),
                                tableTitle("Items", width),
                                tableTitle("Paid Price", width),
                                tableTitle("Payment Mode", width),
                                tableTitle("Payment Time", width),
                                tableTitle("Action", width),
                              ]
                            : [
                                tableTitle("Order ID", width),
                                tableTitle("Table Number", width),
                                tableTitle("Items", width),
                                tableTitle("Price", width),
                                tableTitle("Adjusted Price", width),
                                tableTitle("Action", width),
                              ]),
                    for (int index = 0;
                        index <
                            Provider.of<OrderProvider>(context, listen: true)
                                .processedOrders
                                .length;
                        index++)
                      buildPaymentRow(
                          index: index,
                          order:
                              Provider.of<OrderProvider>(context, listen: true)
                                  .processedOrders[index]),
                  ],
                ),
        ),
      ),
    );
  }

  void viewPDF({required ProcessedOrder order}) async {
    setState(() {
      isLoading = true;
    });
    String pdfPath = await generateInvoicePdf(
      context: context,
      order: order,
      currency: Provider.of<InfoProvider>(context, listen: false)
          .systemInfo
          .currencySymbol!,
      priceList: Provider.of<MenuProvider>(context, listen: false).priceList,
      logoUrl: Provider.of<InfoProvider>(context, listen: false)
          .restaurantInfo
          .logoUrl!,
    );
    setState(() {
      isLoading = false;
    });
    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PdfViewerScreen(pdfPath: pdfPath),
        ),
      );
    }
  }

  TableRow buildPaymentRow(
      {required int index, required ProcessedOrder order}) {
    if (widget.isSales &&
        (order.status == OrderStatus.served) &&
        order.isPaid) {
      return TableRow(
        decoration: const BoxDecoration(color: Data.lightGreyBodyColor),
        children: [
          tableItem("#${order.id}", width, context),
          tableItem(order.tableNumber, width, context),
          tableItem(order.items, width, context),
          tableItem(
              "${Provider.of<InfoProvider>(context, listen: true).systemInfo.currencySymbol!}${(order.price - order.discount).toStringAsFixed(2)}",
              width,
              context),
          tableItem(order.paymentMode!, width, context),
          tableItem(order.paymentTime!, width, context),
          Padding(
            padding: EdgeInsets.symmetric(vertical: height, horizontal: width),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                textButton(
                  text: "View",
                  height: height,
                  width: width,
                  textColor: Provider.of<InfoProvider>(context, listen: true)
                      .systemInfo
                      .primaryColor,
                  buttonColor: Provider.of<InfoProvider>(context, listen: true)
                      .systemInfo
                      .primaryColor,
                  onTap: () async {
                    return viewPDF(order: order);
                  },
                ),
                SizedBox(width: width),
                textButton(
                  text: "Send",
                  height: height,
                  width: width,
                  textColor: const Color(0xff063B9D),
                  buttonColor: const Color(0xff063B9D),
                  onTap: () async {
                    // Show the email input dialog
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return Dialog(
                          child: Container(
                            height: MediaQuery.of(context).size.height * 0.5,
                            width: MediaQuery.of(context).size.width * 0.5,
                            color: Colors.white,
                            child: alert(order: order),
                          ),
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      );
    } else if (!widget.isSales &&
        (order.status == OrderStatus.served) &&
        !order.isPaid) {
      // Display only served but unpaid items in normal Payment page
      return TableRow(
        decoration: const BoxDecoration(color: Data.lightGreyBodyColor),
        children: [
          tableItem("#${order.id}", width, context),
          tableItem(order.tableNumber, width, context),
          tableItem(order.items, width, context),
          tableItem(
              "${Provider.of<InfoProvider>(context, listen: true).systemInfo.currencySymbol!}${order.price.toStringAsFixed(2)}",
              width,
              context),
          tableItem(
              "${Provider.of<InfoProvider>(context, listen: true).systemInfo.currencySymbol!}${(order.price - order.discount).toStringAsFixed(2)}",
              width,
              context),
          Padding(
            padding:
                EdgeInsets.symmetric(horizontal: width * 3, vertical: height),
            child: textButton(
              text: "Pay",
              height: height,
              width: width,
              textColor: Provider.of<InfoProvider>(context, listen: true)
                  .systemInfo
                  .primaryColor,
              buttonColor: Provider.of<InfoProvider>(context, listen: true)
                  .systemInfo
                  .primaryColor,
              onTap: () async {
                showMaterialModalBottomSheet(
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(12.0),
                      topRight: Radius.circular(12.0),
                    ),
                  ),
                  backgroundColor: Data.lightGreyBodyColor,
                  context: context,
                  builder: (context) => Pay(
                    index: index,
                    order: order,
                  ),
                );
              },
            ),
          ),
        ],
      );
    } else if (widget.isSales) {
      // Return an empty TableRow if the order does not meet the conditions
      return const TableRow(children: [
        SizedBox(),
        SizedBox(),
        SizedBox(),
        SizedBox(),
        SizedBox(),
        SizedBox(),
        SizedBox(),
      ]);
    } else {
      return const TableRow(children: [
        SizedBox(),
        SizedBox(),
        SizedBox(),
        SizedBox(),
        SizedBox(),
        SizedBox(),
      ]);
    }
  }

  Widget tableTitle(String text, double width) {
    return Center(
        child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 5),
      child: buildBodyText(
        text,
        Data.lightGreyTextColor,
        width,
        fontFamily: "RobotoMedium",
      ),
    ));
  }

  Row editSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        iconButton(
          isSvg: false,
          "",
          icon: Icons.refresh,
          height,
          width,
          () {
            _fetchData();
          },
          context: context,
        ),
        // widget.isSales
        //     ? Row(
        //         children: [
        //           SizedBox(width: width),
        //           textButton(
        //               text: "Export",
        //               height: height,
        //               width: width,
        //               textColor:
        //                   Provider.of<InfoProvider>(context, listen: true)
        //                       .systemInfo
        //                       .primaryColor,
        //               buttonColor:
        //                   Provider.of<InfoProvider>(context, listen: true)
        //                       .systemInfo
        //                       .primaryColor,
        //               onTap: () {}),
        //         ],
        //       )
        //     : const SizedBox(),
      ],
    );
  }

  // set up the AlertDialog
  Widget alert({required ProcessedOrder order}) {
    return AlertDialog(
      backgroundColor: Colors.white,
      title: const Text("Send Invoice"),
      content: const Text(
          "Please enter an email address to send a copy of the invoice."),
      actions: [
        Form(
          key: _formKey,
          child: Column(
            children: [
              Row(
                children: [
                  buildDataBox(
                    context: context,
                    title: "Email",
                    controller: emailController,
                    validator: (value) {
                      if (value.isEmpty ||
                          !RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                              .hasMatch(value)) {
                        return 'Enter a valid email!';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
        SizedBox(
          height: height * 2,
        ),
        textButton(
          text: "Send",
          height: height,
          width: width,
          textColor: Data.greenColor,
          buttonColor: Data.greenColor,
          onTap: () async {
            if (_formKey.currentState!.validate()) {
              Navigator.pop(context);
              final overlayContext = Overlay.of(context);
              setState(() {
                isLoading = true;
              });

              String pdfPath = await generateInvoicePdf(
                context: context,
                order: order,
                currency: Provider.of<InfoProvider>(context, listen: false)
                    .systemInfo
                    .currencySymbol!,
                priceList:
                    Provider.of<MenuProvider>(context, listen: false).priceList,
                logoUrl: Provider.of<InfoProvider>(context, listen: false)
                    .restaurantInfo
                    .logoUrl!,
              );
              if (mounted) {
                bool isSendSuccessful =
                    await Provider.of<OrderProvider>(context, listen: false)
                        .sendInvoiceEmail(
                  email: emailController.text,
                  filePath: pdfPath,
                  restaurantName:
                      Provider.of<InfoProvider>(context, listen: false)
                          .restaurantInfo
                          .name!,
                  context: context,
                );

                setState(() {
                  isLoading = false;
                });

                if (isSendSuccessful) {
                  showTopSnackBar(
                    overlayContext,
                    CustomSnackBar.success(
                      message:
                          "Invoice has been successfully sent to ${emailController.text}.",
                    ),
                  );
                } else {
                  showTopSnackBar(
                    overlayContext,
                    const CustomSnackBar.error(
                      message:
                          "Failed to send invoice. Please try again later.",
                    ),
                  );
                }
                emailController.clear();
              }
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
    );
  }

  Column buildDataBox(
      {required BuildContext context,
      required String title,
      required TextEditingController controller,
      required validator}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        buildInputField(title, height, width, context, controller,
            validator: validator),
      ],
    );
  }

  // default value for staffRating
  double staffRating = 3;
  // set up the AlertDialog
  Widget ratingAlert() {
    return PopScope(
      canPop: false,
      child: AlertDialog(
        backgroundColor: Colors.white,
        title: const Text("Give Rating"),
        content:
            const Text("Please give feedback on the service you received?"),
        actions: [
          Column(
            children: [
              RatingBar.builder(
                initialRating: 3,
                minRating: 0.5,
                direction: Axis.horizontal,
                allowHalfRating: true,
                itemCount: 5,
                itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                itemBuilder: (context, _) => const Icon(
                  Icons.star,
                  color: Colors.amber,
                ),
                onRatingUpdate: (rating) {
                  print("rating = $rating");
                  staffRating = rating;
                },
              ),
              SizedBox(height: height * 2),
              textButton(
                text: "Confirm",
                height: height,
                width: width,
                textColor: Data.greenColor,
                buttonColor: Data.greenColor,
                onTap: () async {
                  // close dialog box
                  Navigator.pop(context);
                  var overlay = Overlay.of(context);
                  setState(() {
                    isLoading = true;
                  });

                  bool isRatingSuccessful =
                      await Provider.of<OrderProvider>(context, listen: false)
                          .updateOrders(
                    accessToken:
                        Provider.of<AuthProvider>(context, listen: false)
                            .user
                            .accessToken!,
                    context: context,
                    orderID: widget.orderId!,
                    isRating: true,
                    rating: staffRating,
                  );
                  setState(() {
                    isLoading = false;
                  });
                  if (isRatingSuccessful) {
                    showTopSnackBar(
                      overlay,
                      const CustomSnackBar.success(
                        message: "Feedback successfully recorded",
                      ),
                    );
                  } else {
                    showTopSnackBar(
                      overlay,
                      const CustomSnackBar.error(
                        message: "Feedback not successful. Please try again.",
                      ),
                    );
                  }
                },
              ),
              SizedBox(height: height * 2),
              textButton(
                text: "Skip",
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
      ),
    );
  }
}

// Add a new screen for viewing the PDF
class PdfViewerScreen extends StatefulWidget {
  final String pdfPath;
  const PdfViewerScreen({super.key, required this.pdfPath});

  @override
  State<PdfViewerScreen> createState() => _PdfViewerScreenState();
}

class _PdfViewerScreenState extends State<PdfViewerScreen> {
  @override
  void initState() {
    super.initState();
    // Lock the orientation to portrait
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  @override
  void dispose() {
    // Reset the orientation to the default when leaving the screen
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PDF Viewer'),
      ),
      body: PdfPreview(
        canChangeOrientation: false,
        build: (format) => File(widget.pdfPath).readAsBytesSync(),
        canDebug: false,
      ),
    );
  }
}

class Pay extends StatefulWidget {
  const Pay({super.key, required this.index, required this.order});
  final int index;
  final ProcessedOrder order;

  @override
  State<Pay> createState() => _PayState();
}

class _PayState extends State<Pay> {
  bool isLoading = false;
  bool init = true;
  late double height;
  late double width;
  TextEditingController billedToController = TextEditingController();
  TextEditingController discountController = TextEditingController();
  TextEditingController paidAmountController = TextEditingController();

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    if (init) {
      //initialize size config at the very beginning
      SizeConfig().init(context);
      height = SizeConfig.safeBlockVertical;
      width = SizeConfig.safeBlockHorizontal;
      discountController.text = "0";
      paidAmountController.text = "0";
      billAmount = widget.order.price;
      revisedBillAmount = billAmount;
      init = false;
    }
  }

  @override
  dispose() {
    super.dispose();
    billedToController.dispose();
    discountController.dispose();
    paidAmountController.dispose();
  }

  bool isPayByCard = true;
  late double billAmount;
  late double revisedBillAmount;
  double change = 0;

  void calculateDiscount() {
    setState(() {
      double discount = double.parse(discountController.text);
      revisedBillAmount = billAmount - discount;
    });
  }

  void calculateChange() {
    setState(() {
      double paidAmount = double.parse(paidAmountController.text);
      if (revisedBillAmount > paidAmount) {
        change = 0;
      } else {
        change = paidAmount - revisedBillAmount;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height * 55,
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
      child: Column(
        children: [
          SizedBox(height: height * 0.5),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              buildCustomText("             ", Data.greyTextColor, width * 3),
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
              buildCustomText("Order ID: #${widget.order.id}",
                  Data.greyTextColor, width * 2,
                  fontWeight: FontWeight.bold),
            ],
          ),
          buildCustomText("Payment Details", Data.greyTextColor, width * 3,
              fontWeight: FontWeight.bold),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  textButton(
                    text: "Pay by Card",
                    height: height,
                    width: width,
                    textColor: const Color(0xff063B9D),
                    buttonColor: const Color(0xff063B9D),
                    isSelected: isPayByCard,
                    onTap: () async {
                      setState(() {
                        isPayByCard = true;
                      });
                    },
                  ),
                  SizedBox(
                    width: width * 2,
                  ),
                  textButton(
                    text: "Pay by Cash",
                    height: height,
                    width: width,
                    textColor: const Color(0xff063B9D),
                    buttonColor: const Color(0xff063B9D),
                    isSelected: !isPayByCard,
                    onTap: () async {
                      setState(() {
                        isPayByCard = false;
                      });
                    },
                  ),
                ],
              ),
              billedToBox(
                title: "Billed To:",
                hintText: "Billed To",
                isRequired: false,
                controller: billedToController,
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: height * 2),
                  Row(
                    children: [
                      buildCustomText(
                          "Bill Amount", Data.greyTextColor, width * 1.5,
                          fontWeight: FontWeight.bold),
                      SizedBox(width: width * 2),
                      buildCustomText(
                          "${Provider.of<InfoProvider>(context, listen: true).systemInfo.currencySymbol!}${billAmount.toStringAsFixed(2)}",
                          Data.lightGreyTextColor,
                          width * 1.5,
                          fontWeight: FontWeight.bold),
                    ],
                  ),
                  Row(
                    children: [
                      dataBox(
                        title: "Discount",
                        hintText: "Discount",
                        isNumber: true,
                        isRequired: false,
                        controller: discountController,
                        isDiscount: true,
                      ),
                      isPayByCard
                          ? const SizedBox()
                          : dataBox(
                              title: "Paid Amount",
                              hintText: "Paid Amount",
                              isNumber: true,
                              isRequired: true,
                              controller: paidAmountController,
                              isPaidAmount: true,
                            ),
                      isPayByCard
                          ? const SizedBox()
                          : calculatedBox(
                              title: "Change",
                              hintText: "Change",
                              data: change.toStringAsFixed(2),
                              isChange: true,
                            ),
                    ],
                  ),
                  SizedBox(
                    height: height * 2,
                  ),
                  Row(
                    children: [
                      buildCustomText(
                          "Revised Bill Amount", Data.greyTextColor, width * 2,
                          fontWeight: FontWeight.bold),
                      SizedBox(width: width * 2),
                      buildCustomText(
                          "${Provider.of<InfoProvider>(context, listen: true).systemInfo.currencySymbol!}${revisedBillAmount.toStringAsFixed(2)}",
                          Data.lightGreyTextColor,
                          width * 2,
                          fontWeight: FontWeight.bold),
                      SizedBox(width: width * 2),
                      buildCustomText(
                          "(Inclusive 20%VAT@${Provider.of<InfoProvider>(context, listen: true).systemInfo.currencySymbol!}${(revisedBillAmount * 0.2).toStringAsFixed(2)})",
                          Data.lightGreyTextColor,
                          width * 1.5),
                    ],
                  ),
                ],
              ),
              InkWell(
                onTap: () async {
                  var overlay = Overlay.of(context);
                  if (!isPayByCard &&
                      (double.parse(discountController.text) > billAmount)) {
                    showTopSnackBar(
                      overlay,
                      const CustomSnackBar.error(
                        message:
                            "Discount Amount cannot be greater than Bill Amount",
                      ),
                    );
                  } else if (!isPayByCard &&
                      (double.parse(paidAmountController.text) <
                          revisedBillAmount)) {
                    showTopSnackBar(
                      overlay,
                      const CustomSnackBar.error(
                        message:
                            "Paid Amount cannot be smaller than Bill Amount",
                      ),
                    );
                  } else {
                    showDialog(
                      barrierDismissible: false,
                      context: context,
                      builder: (BuildContext context) {
                        return confirmAlert();
                      },
                    );
                  }
                },
                child: Container(
                  margin: EdgeInsets.only(
                    top: height * 2,
                  ),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(5.0),
                      border: Border.all(
                        color: Data.darkTextColor, // Outline color
                        width: 1, // Outline width
                      )),
                  height: height * 25,
                  width: width * 30,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      isPayByCard
                          ? SizedBox(
                              height: width * 10,
                              width: width * 10,
                              child: SvgPicture.asset(
                                "assets/svg/payment.svg",
                                colorFilter: ColorFilter.mode(
                                    Provider.of<InfoProvider>(context,
                                            listen: true)
                                        .systemInfo
                                        .iconsColor,
                                    BlendMode.srcIn),
                              ),
                            )
                          : const SizedBox(),
                      buildCustomText(
                          isPayByCard
                              ? "Pay by Contactless/Card"
                              : "Pay by Cash",
                          Data.lightGreyTextColor,
                          width * 1.5),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget confirmAlert() {
    return AlertDialog(
      backgroundColor: Colors.white,
      title: const Text("Confirm Payment"),
      content: const Text("Proceed with Payment?"),
      actions: [
        SizedBox(height: height * 2),
        textButton(
          text: "Confirm",
          height: height,
          width: width,
          textColor: Data.greenColor,
          buttonColor: Data.greenColor,
          onTap: () async {
            Navigator.pop(context);
            var overlay = Overlay.of(context);
            setState(() {
              isLoading = true;
            });

            bool isPaymentSuccessful =
                await Provider.of<OrderProvider>(context, listen: false)
                    .updateOrders(
              accessToken: Provider.of<AuthProvider>(context, listen: false)
                  .user
                  .accessToken!,
              context: context,
              orderID: Provider.of<OrderProvider>(context, listen: false)
                  .processedOrders[widget.index]
                  .id!,
              itemIndex: widget.index,
              isPaid: true,
              discount: discountController.text == ""
                  ? 0
                  : double.parse(discountController.text),
              paymentMode: isPayByCard ? "Card" : "Cash",
              billedTo: billedToController.text,
            );
            setState(() {
              isLoading = false;
            });
            if (isPaymentSuccessful && mounted) {
              showTopSnackBar(
                overlay,
                const CustomSnackBar.success(
                  message: "Payment Successful",
                ),
              );
              if (mounted) {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => Payment(
                            isSales: true,
                            divertedFromPayment: true,
                            orderId: Provider.of<OrderProvider>(context,
                                    listen: false)
                                .processedOrders[widget.index]
                                .id,
                          )),
                );
              }
            } else {
              showTopSnackBar(
                overlay,
                const CustomSnackBar.success(
                  message: "Payment Not Successful. Please try again.",
                ),
              );
            }
          },
        ),
        SizedBox(
          height: height,
        ),
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
    );
  }

  Container dataBox({
    required String title,
    required String hintText,
    required TextEditingController controller,
    Function? validator,
    bool isRequired = false,
    bool isNumber = false,
    bool isDiscount = false,
    bool isPaidAmount = false,
  }) {
    return Container(
      width: width * 12,
      padding: EdgeInsets.symmetric(vertical: height),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SizedBox(
                width: width * 1.25,
              ),
              buildCustomText(title, Data.lightGreyTextColor, width * 1.5,
                  fontFamily: "RobotoMedium"),
              isRequired
                  ? buildSmallText(
                      "*",
                      Data.redColor,
                      width,
                    )
                  : const SizedBox(),
            ],
          ),
          SizedBox(height: height),
          Row(
            children: [
              buildCustomText(
                Provider.of<InfoProvider>(context, listen: true)
                    .systemInfo
                    .currencySymbol!,
                Data.lightGreyTextColor,
                width * 1.5,
                fontFamily: "RobotoMedium",
              ),
              SizedBox(
                width: width,
              ),
              Container(
                width: width * 6,
                color: Colors.white,
                child: buildInputField(
                  "0",
                  height,
                  width,
                  context,
                  controller,
                  validator: validator,
                  isNumber: isNumber,
                  isDiscount: isDiscount,
                  isPaidAmount: isPaidAmount,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Container calculatedBox({
    required String title,
    required String hintText,
    required String data,
    bool isChange = false,
  }) {
    return Container(
      width: width * 12,
      padding: EdgeInsets.symmetric(vertical: height),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SizedBox(
                width: isChange ? width * 1.25 : 0,
              ),
              buildCustomText(title, Data.lightGreyTextColor, width * 1.5,
                  fontFamily: "RobotoMedium"),
            ],
          ),
          SizedBox(height: height),
          Row(
            children: [
              buildCustomText(
                Provider.of<InfoProvider>(context, listen: true)
                    .systemInfo
                    .currencySymbol!,
                Data.lightGreyTextColor,
                width * 1.5,
                fontFamily: "RobotoMedium",
              ),
              SizedBox(width: width),
              Container(
                color: Colors.white,
                child: Container(
                  width: width * 6,
                  padding: EdgeInsets.only(
                    top: height,
                    bottom: height,
                    left: width * 0.5,
                  ),
                  decoration: BoxDecoration(
                      color: Colors.grey[400],
                      borderRadius: BorderRadius.circular(5.0),
                      border: Border.all(
                        color: Data.darkTextColor, // Outline color
                        width: 1, // Outline width
                      )),
                  child: buildCustomText(
                    data,
                    Data.lightGreyTextColor,
                    16,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget billedToBox({
    required String title,
    required String hintText,
    required TextEditingController controller,
    required Function? validator,
    bool isRequired = false,
    bool isNumber = false,
    bool isSpecial = false,
  }) {
    return Row(
      children: [
        buildCustomText(title, Data.lightGreyTextColor, width * 2,
            fontFamily: "RobotoMedium"),
        isRequired
            ? buildSmallText(
                "*",
                Data.redColor,
                width,
              )
            : const SizedBox(),
        SizedBox(
          width: width,
        ),
        Container(
          color: Colors.white,
          width: width * 20,
          child: buildInputField(hintText, height, width, context, controller,
              validator: validator, isNumber: isNumber),
        ),
      ],
    );
  }

  Widget buildInputField(
    String hintText,
    double height,
    double width,
    BuildContext context,
    TextEditingController controller, {
    Function? validator,
    bool isNumber = false,
    bool isDiscount = false,
    bool isPaidAmount = false,
  }) {
    return Container(
      // height: height * 6,
      width: width * 40,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5.0),
      ),
      child: TextFormField(
        cursorColor: Provider.of<InfoProvider>(context, listen: true)
            .systemInfo
            .primaryColor,
        controller: controller,
        onChanged: (value) {
          if (isDiscount) {
            calculateDiscount();
          }
          if (isPaidAmount) {
            calculateChange();
          }
        },
        validator: (value) {
          return validator!(value);
        },
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          isDense: true,
          contentPadding:
              EdgeInsets.symmetric(vertical: height * 1.1, horizontal: 5),
          enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(
              color: Data.darkTextColor, // Custom focused border color
              width: 1, // Custom focused border width (optional)
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Provider.of<InfoProvider>(context, listen: true)
                  .systemInfo
                  .primaryColor, // Custom focused border color
              width: 2.0, // Custom focused border width (optional)
            ),
          ),
          hintText: hintText,
        ),
      ),
    );
  }
}
