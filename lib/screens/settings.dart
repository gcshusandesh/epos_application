import 'package:country_picker/country_picker.dart';
import 'package:currency_picker/currency_picker.dart';
import 'package:epos_application/components/buttons.dart';
import 'package:epos_application/components/common_widgets.dart';
import 'package:epos_application/components/data.dart';
import 'package:epos_application/components/models.dart';
import 'package:epos_application/components/size_config.dart';
import 'package:epos_application/providers/auth_provider.dart';
import 'package:epos_application/providers/info_provider.dart';
import 'package:epos_application/screens/custom_color_picker.dart';
import 'package:epos_application/screens/image_upload.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

// ignore: must_be_immutable
class Settings extends StatefulWidget {
  Settings({super.key, this.initialSetup = false});
  static const routeName = "settings";
  bool initialSetup;

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;
  bool init = true;
  late double height;
  late double width;

  TextEditingController nameController = TextEditingController();
  TextEditingController vatController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController postcodeController = TextEditingController();
  TextEditingController countryController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _setData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (init) {
      //initialize size config at the very beginning
      SizeConfig().init(context);
      height = SizeConfig.safeBlockVertical;
      width = SizeConfig.safeBlockHorizontal;

      if (!widget.initialSetup) {
        /// Initialise values to controllers
        RestaurantInfo restaurantInfo =
            Provider.of<InfoProvider>(context, listen: false).restaurantInfo;
        nameController.text = restaurantInfo.name!;
        vatController.text = restaurantInfo.vatNumber!;
        addressController.text = restaurantInfo.address!;
        postcodeController.text = restaurantInfo.postcode!;
        countryController.text = restaurantInfo.countryOfOperation!;
      } else {
        isEditingRestaurantDetails = true;
        // to replace null values with default values
      }

      init = false;
    }
  }

  Future<void> _setData() async {
    setState(() {
      isLoading = true;
    });
    await Provider.of<InfoProvider>(context, listen: false)
        .updateSystemSettings(
      isDefault: true,
      context: context,
      editedSystemInfo:
          Provider.of<InfoProvider>(context, listen: false).systemInfo,
    );
    setState(() {
      isLoading = false;
    });
  }

  Future<void> _fetchData() async {
    setState(() {
      isLoading = true;
    });

    await Provider.of<InfoProvider>(context, listen: false)
        .getSettings(context: context);

    setState(() {
      isLoading = false;
    });
  }

  OverlayEntry? _overlayEntry;
  late Color newColor;

  // Method to build the color picker overlay
  void _buildColorPickerOverlay(
      {required BuildContext context, bool isIconsColor = false}) {
    final systemInfo =
        Provider.of<InfoProvider>(context, listen: false).systemInfo;

    _overlayEntry = OverlayEntry(
      builder: (BuildContext context) => Stack(
        children: [
          // Modal barrier to prevent interaction with underlying content
          ModalBarrier(
            color: Colors.black54, // Semi-transparent black color
            dismissible: true,
            onDismiss: () {
              _closeColorPickerOverlay();
            },
          ),
          Center(
            child: Material(
              color: Colors.transparent,
              child: Container(
                width: width * 20,
                padding: EdgeInsets.all(width * 2),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.25),
                      spreadRadius: 0,
                      blurRadius: 4,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CustomColorPicker(
                      initialColor: systemInfo.primaryColor,
                      onColorChanged: (Color color) {
                        // Handle color change
                        newColor = color;
                      },
                    ),
                    const SizedBox(height: 20),
                    Align(
                      alignment: Alignment.center,
                      child: textButton(
                          text: "Confirm",
                          height: height,
                          width: width,
                          textColor:
                              Provider.of<InfoProvider>(context, listen: true)
                                  .systemInfo
                                  .primaryColor,
                          buttonColor:
                              Provider.of<InfoProvider>(context, listen: true)
                                  .systemInfo
                                  .primaryColor,
                          onTap: () {
                            Provider.of<InfoProvider>(context, listen: false)
                                .updateSystemSettingsLocally(
                              editedSystemInfo: SystemInfo(
                                versionNumber: systemInfo.versionNumber,
                                language: systemInfo.language,
                                currencySymbol: systemInfo.currencySymbol,
                                primaryColor: isIconsColor
                                    ? systemInfo.primaryColor
                                    : newColor,
                                iconsColor: isIconsColor
                                    ? newColor
                                    : systemInfo.iconsColor,
                              ),
                            );
                            _closeColorPickerOverlay();
                          }),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  bool isEditingRestaurantDetails = false;
  bool isEditingSystemSettings = false;
  bool showColorPicker = false;

  // Function to close the color picker overlay
  void _closeColorPickerOverlay() {
    _overlayEntry?.remove(); // Remove overlay entry from the overlay
    _overlayEntry = null; // Set overlay entry to null to release resources
  }

  @override
  void dispose() {
    super.dispose();
    isEditingRestaurantDetails = false;
    isEditingSystemSettings = false;
    showColorPicker = false;
    _closeColorPickerOverlay();

    /// dispose controllers
    nameController.dispose();
    vatController.dispose();
    addressController.dispose();
    postcodeController.dispose();
    countryController.dispose();
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

  Widget mainBody(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvoked: (bool value) {
        // get settings data back again from api so that unsaved changes can be reverted
        Provider.of<InfoProvider>(context, listen: false)
            .getSettings(context: context);
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              children: [
                topSection(
                  context: context,
                  height: height,
                  text: "Settings",
                  width: width,
                  initialSetup: widget.initialSetup,
                ),
                SizedBox(height: height * 2),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    leftSection(),
                    line(),
                    rightSection(),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Container line() {
    return Container(
      height: height * 78,
      width: 1,
      color: Colors.black,
    );
  }

  Container rightSection() {
    return Container(
      height: height * 78,
      width: width * 35,
      padding:
          EdgeInsets.symmetric(vertical: height * 2, horizontal: width * 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Data.lightGreyBodyColor50,
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
        children: [
          editSection("System Details", noEdit: true, () {}, isSelected: false),
          Container(
            width: width * 31,
            padding: EdgeInsets.symmetric(
                vertical: height * 2, horizontal: width * 2),
            color: Data.lightGreyBodyColor,
            child: Column(
              children: [
                Container(
                  width: width * 30,
                  padding: EdgeInsets.symmetric(
                      vertical: height, horizontal: width * 2),
                  color: Colors.white,
                  child: systemDataBox(
                    title: "Version",
                    data:
                        "#${Provider.of<InfoProvider>(context, listen: true).systemInfo.versionNumber ?? "1.0.0"}",
                  ),
                ),
                SizedBox(height: height),
                Container(
                  width: width * 30,
                  padding: EdgeInsets.symmetric(
                      vertical: height, horizontal: width * 2),
                  color: Colors.white,
                  child: systemDataBox(
                    title: "Language",
                    data: Provider.of<InfoProvider>(context, listen: true)
                            .systemInfo
                            .language ??
                        "English",
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: height * 2),
          editSection(
            "System Settings",
            () {
              setState(() {
                isEditingSystemSettings = !isEditingSystemSettings;
              });
            },
            isSelected: isEditingSystemSettings,
          ),
          SizedBox(height: height * 2),
          Container(
            width: width * 31,
            padding: EdgeInsets.symmetric(
                vertical: height * 2, horizontal: width * 2),
            color: Data.lightGreyBodyColor,
            child: Column(
              children: [
                Container(
                  width: width * 30,
                  padding: EdgeInsets.symmetric(
                      vertical: height, horizontal: width * 2),
                  color: Colors.white,
                  child: InkWell(
                    onTap: () {
                      if (isEditingSystemSettings) {
                        setState(() {
                          if (isEditingSystemSettings) {
                            _buildColorPickerOverlay(context: context);
                          } else {
                            _overlayEntry?.remove();
                          }
                        });
                      }
                    },
                    child: systemDataBox(
                      title: "Primary Color",
                      hasColor: true,
                      color: Provider.of<InfoProvider>(context, listen: true)
                          .systemInfo
                          .primaryColor,
                      isEditable: true,
                    ),
                  ),
                ),
                SizedBox(height: height),
                Container(
                  width: width * 30,
                  padding: EdgeInsets.symmetric(
                      vertical: height, horizontal: width * 2),
                  color: Colors.white,
                  child: InkWell(
                    onTap: () {
                      if (isEditingSystemSettings) {
                        setState(() {
                          if (isEditingSystemSettings) {
                            _buildColorPickerOverlay(
                                context: context, isIconsColor: true);
                          } else {
                            _overlayEntry?.remove();
                          }
                        });
                      }
                    },
                    child: systemDataBox(
                      title: "Icons Color",
                      hasColor: true,
                      color: Provider.of<InfoProvider>(context, listen: true)
                          .systemInfo
                          .iconsColor,
                      isEditable: true,
                    ),
                  ),
                ),
                SizedBox(height: height),
                InkWell(
                  onTap: () {
                    if (isEditingSystemSettings) {
                      return showCurrencyPicker(
                        context: context,
                        showFlag: true,
                        showCurrencyName: true,
                        showCurrencyCode: true,
                        onSelect: (Currency newCurrency) {
                          final systemInfo =
                              Provider.of<InfoProvider>(context, listen: false)
                                  .systemInfo;
                          // Handle currency change
                          Provider.of<InfoProvider>(context, listen: false)
                              .updateSystemSettingsLocally(
                            editedSystemInfo: SystemInfo(
                              versionNumber: systemInfo.versionNumber,
                              language: systemInfo.language,
                              currencySymbol: newCurrency.symbol,
                              primaryColor: systemInfo.primaryColor,
                              iconsColor: systemInfo.iconsColor,
                            ),
                          );
                        },
                      );
                    }
                  },
                  child: Container(
                    width: width * 30,
                    padding: EdgeInsets.symmetric(
                        vertical: height, horizontal: width * 2),
                    color: Colors.white,
                    child: systemDataBox(
                      title: "Currency",
                      data: Provider.of<InfoProvider>(context, listen: true)
                              .systemInfo
                              .currencySymbol ??
                          "£",
                      isEditable: true,
                    ),
                  ),
                ),
                SizedBox(height: height * 2),
                buildButton(
                  isEditingSystemSettings
                      ? Icons.update
                      : Icons.restart_alt_sharp,
                  isEditingSystemSettings
                      ? "Update Settings"
                      : "Reset Default Settings",
                  height,
                  width,
                  () async {
                    final overlayContext = Overlay.of(context);
                    if (isEditingSystemSettings) {
                      setState(() {
                        isLoading = true;
                      });
                      late bool isUpdateSuccessful;
                      // update setting to user chosen values
                      isUpdateSuccessful = await Provider.of<InfoProvider>(
                              context,
                              listen: false)
                          .updateSystemSettings(
                        context: context,
                        editedSystemInfo: SystemInfo(
                          versionNumber:
                              Provider.of<InfoProvider>(context, listen: false)
                                  .systemInfo
                                  .versionNumber,
                          language:
                              Provider.of<InfoProvider>(context, listen: false)
                                  .systemInfo
                                  .language,
                          primaryColor:
                              Provider.of<InfoProvider>(context, listen: false)
                                  .systemInfo
                                  .primaryColor,
                          iconsColor:
                              Provider.of<InfoProvider>(context, listen: false)
                                  .systemInfo
                                  .iconsColor,
                          currencySymbol:
                              Provider.of<InfoProvider>(context, listen: false)
                                  .systemInfo
                                  .currencySymbol,
                        ),
                      );
                      setState(() {
                        isLoading = false;
                      });
                      if (isUpdateSuccessful) {
                        showTopSnackBar(
                          overlayContext,
                          const CustomSnackBar.success(
                            message:
                                "System settings have been updated successfully",
                          ),
                        );
                        setState(() {
                          isEditingSystemSettings = false;
                        });
                      } else {
                        showTopSnackBar(
                          overlayContext,
                          const CustomSnackBar.error(
                            message:
                                "System settings could not be updated. Please try again",
                          ),
                        );
                      }
                    } else {
                      //reset Default values
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return alert();
                        },
                      );
                    }
                  },
                  context,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void resetDefaultSystemSettings() {
    /// reset only system settings
    Provider.of<InfoProvider>(context, listen: false).updateSystemSettings(
      isDefault: true,
      context: context,
      editedSystemInfo:
          Provider.of<InfoProvider>(context, listen: false).systemInfo,
    );
  }

  // set up the AlertDialog
  Widget alert() {
    return AlertDialog(
      backgroundColor: Colors.white,
      title: const Text("Reset to Default Settings"),
      content:
          const Text("Would you like to reset the system setting to default?"),
      actions: [
        textButton(
          text: "Yes",
          height: height,
          width: width,
          textColor: Data.greenColor,
          buttonColor: Data.greenColor,
          onTap: () {
            // reset to default
            Provider.of<InfoProvider>(context, listen: false)
                .updateSystemSettings(
              isDefault: true,
              context: context,
              editedSystemInfo:
                  Provider.of<InfoProvider>(context, listen: false).systemInfo,
            );
            Provider.of<InfoProvider>(context, listen: false)
                .resetDefaultSystemSettingsLocally();
            // pop dialog box
            Navigator.pop(context);
            showTopSnackBar(
              Overlay.of(context),
              const CustomSnackBar.success(
                message:
                    "System has been reset to default settings successfully",
              ),
            );
          },
        ),
        SizedBox(height: height * 2),
        textButton(
          text: "No",
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

  Row systemDataBox({
    required String title,
    String data = "",
    bool hasColor = false,
    Color color = Colors.black,
    bool isEditable = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            SizedBox(
              width: width * 10,
              child: buildCustomText(
                  title, Data.lightGreyTextColor, width * 1.4,
                  fontFamily: "RobotoMedium"),
            ),
            SizedBox(width: width * 2),
            buildLine(),
          ],
        ),
        isEditable && isEditingSystemSettings
            ? label(
                text: "edit",
                height: height,
                width: width,
                labelColor: Provider.of<InfoProvider>(context, listen: false)
                    .systemInfo
                    .iconsColor)
            : const SizedBox(),
        hasColor
            ? Container(
                width: width * 2.5,
                height: width * 2.5,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color,
                ),
              )
            : buildCustomText(data, Data.lightGreyTextColor, width * 1.4,
                fontFamily: "RobotoMedium"),
      ],
    );
  }

  Container buildLine() {
    return Container(
      color: Data.lightGreyTextColor,
      width: 2,
      height: height * 4,
    );
  }

  Container leftSection() {
    return Container(
      height: height * 78,
      width: width * 35,
      padding:
          EdgeInsets.symmetric(vertical: height * 2, horizontal: width * 2),
      decoration: BoxDecoration(
        color: Data.lightGreyBodyColor50,
        borderRadius: BorderRadius.circular(10),
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
        children: [
          editSection(
            "Restaurant's Details",
            () {
              //dont let user toggle out of setup mode in initial setup
              if (!widget.initialSetup) {
                setState(() {
                  isEditingRestaurantDetails = !isEditingRestaurantDetails;
                });
              }
            },
            isSelected: isEditingRestaurantDetails,
          ),
          SizedBox(height: height * 2),
          Expanded(
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    InkWell(
                      onTap: () {
                        if (isEditingRestaurantDetails) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ImageUpload(
                                isChangeRestaurantImage: true,
                              ),
                            ),
                          );
                        }
                      },
                      child: Provider.of<InfoProvider>(context, listen: true)
                                  .restaurantInfo
                                  .imageUrl ==
                              null
                          ? Container(
                              height: height * 25,
                              width: width * 31,
                              color: Colors.white,
                              child: Center(
                                child: buildCustomText("No Image",
                                    Data.lightGreyTextColor, width * 3),
                              ),
                            )
                          : buildImage(
                              Provider.of<InfoProvider>(context, listen: true)
                                  .restaurantInfo
                                  .imageUrl!,
                              height * 25,
                              width * 31,
                              context: context,
                              isNetworkImage: true,
                            ),
                    ),
                    SizedBox(height: height * 2),
                    formDataBox(
                      title: "Name",
                      hintText: "Name",
                      controller: nameController,
                      data: Provider.of<InfoProvider>(context, listen: true)
                              .restaurantInfo
                              .name ??
                          "",
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Enter a valid name';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: height),
                    formDataBox(
                      title: "VAT/PAN Number",
                      hintText: "VAT/PAN Number",
                      controller: vatController,
                      data: Provider.of<InfoProvider>(context, listen: true)
                              .restaurantInfo
                              .vatNumber ??
                          "",
                      isNumber: true,
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Enter a valid VAT Number';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: height),
                    formDataBox(
                      title: "Address",
                      hintText: "Address",
                      controller: addressController,
                      data: Provider.of<InfoProvider>(context, listen: true)
                              .restaurantInfo
                              .address ??
                          "",
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Enter a valid address';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: height),
                    formDataBox(
                      title: "Postcode",
                      hintText: "Postcode",
                      controller: postcodeController,
                      data: Provider.of<InfoProvider>(context, listen: true)
                              .restaurantInfo
                              .postcode ??
                          "",
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Enter a valid postcode';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: height),
                    formDataBox(
                      title: "Country of Operation",
                      hintText: "Country of Operation",
                      controller: countryController,
                      data: Provider.of<InfoProvider>(context, listen: true)
                              .restaurantInfo
                              .countryOfOperation ??
                          "",
                      isCountry: true,
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Enter a valid country';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: height),
                    InkWell(
                      onTap: () {
                        if (isEditingRestaurantDetails) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ImageUpload(
                                isChangeRestaurantLogo: true,
                              ),
                            ),
                          );
                        }
                      },
                      child: dataBox(
                          title: "Logo",
                          isImage: true,
                          data: Provider.of<InfoProvider>(context, listen: true)
                              .restaurantInfo
                              .logoUrl),
                    ),
                    isEditingRestaurantDetails
                        ? buildButton(
                            Icons.update,
                            "Update",
                            height,
                            width,
                            () async {
                              final overlayContext = Overlay.of(context);
                              //submit form
                              if (_formKey.currentState!.validate()) {
                                setState(() {
                                  isLoading = true;
                                });

                                RestaurantInfo restaurantInfo =
                                    Provider.of<InfoProvider>(context,
                                            listen: false)
                                        .restaurantInfo;
                                // update setting to user chosen values
                                bool isUpdateSuccessful =
                                    await Provider.of<InfoProvider>(context,
                                            listen: false)
                                        .updateRestaurantSettings(
                                  context: context,
                                  user: Provider.of<AuthProvider>(context,
                                          listen: false)
                                      .user,
                                  editedRestaurantInfo: RestaurantInfo(
                                    name: nameController.text,
                                    imageUrl: restaurantInfo.imageUrl,
                                    vatNumber: vatController.text,
                                    address: addressController.text,
                                    postcode: postcodeController.text,
                                    countryOfOperation:
                                        restaurantInfo.countryOfOperation,
                                    logoUrl: restaurantInfo.logoUrl,
                                  ),
                                );
                                setState(() {
                                  isLoading = false;
                                });
                                if (isUpdateSuccessful) {
                                  // show success massage
                                  showTopSnackBar(
                                    overlayContext,
                                    const CustomSnackBar.success(
                                      message:
                                          "User Details Updated Successfully",
                                    ),
                                  );
                                  setState(() {
                                    isEditingRestaurantDetails = false;
                                  });
                                } else {
                                  // show failure massage
                                  showTopSnackBar(
                                    overlayContext,
                                    const CustomSnackBar.error(
                                      message: "User Details not updated",
                                    ),
                                  );
                                }
                              }
                            },
                            context,
                          )
                        : const SizedBox(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Row editSection(String title, Function() onPressed,
      {bool noEdit = false, required bool isSelected}) {
    return Row(
      mainAxisAlignment:
          noEdit ? MainAxisAlignment.center : MainAxisAlignment.end,
      children: noEdit
          ? [
              buildBodyText(title, Data.lightGreyTextColor, width,
                  fontFamily: "RobotoMedium"),
            ]
          : [
              buildBodyText(title, Data.lightGreyTextColor, width,
                  fontFamily: "RobotoMedium"),
              SizedBox(width: title == "System Settings" ? width * 2.5 : width),
              iconButton(
                "assets/svg/edit.svg",
                height * 0.8,
                width * 0.8,
                onPressed,
                context: context,
                isSelected: isSelected,
              ),
              title != "System Settings"
                  ? Row(
                      children: [
                        SizedBox(width: width),
                        iconButton(
                          isSvg: false,
                          "",
                          icon: Icons.refresh,
                          height * 0.8,
                          width * 0.8,
                          () {
                            _fetchData();
                          },
                          context: context,
                        ),
                      ],
                    )
                  : const SizedBox(),
            ],
    );
  }

  Container dataBox({
    required String title,
    required String? data,
    bool isImage = false,
  }) {
    return Container(
      width: width * 31,
      padding: EdgeInsets.symmetric(vertical: height, horizontal: width * 2),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildCustomText(title, Data.lightGreyTextColor, width * 1.4,
              fontFamily: "RobotoMedium"),
          isImage
              ? data == null
                  ? Icon(
                      Icons.no_photography_outlined,
                      size: width * 10,
                      color: Provider.of<InfoProvider>(context, listen: true)
                          .systemInfo
                          .iconsColor,
                    )
                  : buildImage(
                      data,
                      isNetworkImage: true,
                      width * 10,
                      width * 10,
                      context: context,
                    )
              : buildCustomText(
                  data ?? "",
                  Data.lightGreyTextColor,
                  width,
                ),
        ],
      ),
    );
  }

  Container formDataBox({
    required String title,
    required String hintText,
    required TextEditingController controller,
    bool isPasswordField = false,
    String? data = "",
    bool isCountry = false,
    bool isNumber = false,
    Function? validator,
  }) {
    return Container(
      width: width * 31,
      padding: EdgeInsets.symmetric(vertical: height, horizontal: width * 2),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildCustomText(title, Data.lightGreyTextColor, width * 1.4,
              fontFamily: "RobotoMedium"),
          !isEditingRestaurantDetails
              ? Container(
                  width: width * 31,
                  padding: EdgeInsets.symmetric(
                    vertical: height,
                    horizontal: width,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: Data.lightGreyBodyColor),
                    borderRadius: BorderRadius.circular(6.0),
                  ),
                  child: buildCustomText(
                      data!, Data.lightGreyTextColor, width * 1.4,
                      fontFamily: "RobotoMedium"),
                )
              : isCountry
                  ? InkWell(
                      onTap: () {
                        return showCountryPicker(
                          context: context,
                          showPhoneCode: false,
                          onSelect: (Country country) {
                            Provider.of<InfoProvider>(context, listen: false)
                                .updateCountryInfoLocally(
                                    countryInfo: country.name);
                          },
                        );
                      },
                      child: Container(
                        width: width * 31,
                        padding: EdgeInsets.symmetric(
                          vertical: height,
                          horizontal: width,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: Data.lightGreyBodyColor),
                          borderRadius: BorderRadius.circular(6.0),
                        ),
                        // child: buildCustomText(
                        //     data!, Data.lightGreyTextColor, width * 1.4,
                        //     fontFamily: "RobotoMedium"),
                        child: Text(data!),
                      ),
                    )
                  : buildInputField(
                      hintText, height, width, context, controller,
                      isNumber: isNumber, validator: validator),
        ],
      ),
    );
  }
}
