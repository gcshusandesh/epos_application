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
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

class Payment extends StatefulWidget {
  const Payment({
    super.key,
    this.isSales = false,
  });
  final bool isSales;

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
  }

  @override
  void dispose() {
    super.dispose();
    emailController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        mainBody(context),
        isLoading
            ? onLoading(width: width, context: context)
            : const SizedBox(),
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
                            children: widget.isSales
                                ? [
                                    tableTitle("S.N.", width),
                                    tableTitle("Order ID", width),
                                    tableTitle("Table Number", width),
                                    tableTitle("Items", width),
                                    tableTitle("Price", width),
                                    tableTitle("Timestamp", width),
                                    tableTitle("Action", width),
                                  ]
                                : [
                                    tableTitle("S.N.", width),
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
                                tableTitle("S.N.", width),
                                tableTitle("Order ID", width),
                                tableTitle("Table Number", width),
                                tableTitle("Items", width),
                                tableTitle("Price", width),
                                tableTitle("Timestamp", width),
                                tableTitle("Action", width),
                              ]
                            : [
                                tableTitle("S.N.", width),
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

  //

  TableRow buildPaymentRow(
      {required int index, required ProcessedOrder order}) {
    if (widget.isSales && order.status == OrderStatus.served && order.isPaid) {
      return TableRow(
        decoration: const BoxDecoration(color: Data.lightGreyBodyColor),
        children: [
          tableItem((index + 1).toString(), width, context),
          tableItem("#${order.id}", width, context),
          tableItem(order.tableNumber, width, context),
          tableItem(order.items, width, context),
          tableItem("£${order.price.toStringAsFixed(2)}", width, context),
          tableItem(
              "£${order.adjustedPrice.toStringAsFixed(2)}", width, context),
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
                    setState(() {
                      isLoading = true;
                    });
                    String pdfPath = await generateInvoicePdf(
                      context: context,
                      order: order,
                      currency:
                          Provider.of<InfoProvider>(context, listen: false)
                              .systemInfo
                              .currencySymbol!,
                      priceList:
                          Provider.of<MenuProvider>(context, listen: false)
                              .priceList,
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
                          builder: (context) =>
                              PdfViewerScreen(pdfPath: pdfPath),
                        ),
                      );
                    }
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
                        return alert(order: order);
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
        order.status == OrderStatus.served &&
        !order.isPaid) {
      // Display only served but unpaid items in normal Payment page
      return TableRow(
        decoration: const BoxDecoration(color: Data.lightGreyBodyColor),
        children: [
          tableItem((index + 1).toString(), width, context),
          tableItem("#${order.id}", width, context),
          tableItem(order.tableNumber, width, context),
          tableItem(order.items, width, context),
          tableItem("£${order.price.toStringAsFixed(2)}", width, context),
          tableItem(
              "£${order.adjustedPrice.toStringAsFixed(2)}", width, context),
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
              onTap: () async {},
            ),
          ),
        ],
      );
    } else {
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
