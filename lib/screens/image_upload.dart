import 'dart:io' as io;
import 'dart:io';

import 'package:epos_application/components/buttons.dart';
import 'package:epos_application/components/common_widgets.dart';
import 'package:epos_application/components/data.dart';
import 'package:epos_application/components/models.dart';
import 'package:epos_application/components/size_config.dart';
import 'package:epos_application/providers/auth_provider.dart';
import 'package:epos_application/providers/info_provider.dart';
import 'package:epos_application/providers/menu_provider.dart';
import 'package:epos_application/providers/upload_provider.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

// ignore: must_be_immutable
class ImageUpload extends StatefulWidget {
  ImageUpload({
    super.key,
    this.isChangeDP = false,
    this.isChangeRestaurantImage = false,
    this.isChangeRestaurantLogo = false,
    this.isSpecialsImage = false,
    this.isCategoryImage = false,
    this.isItemImage = false,
    this.specials,
    this.category,
    this.menuItems,
    this.index,
  });
  static const routeName = "imageUpload";
  bool isChangeDP;
  bool isChangeRestaurantImage;
  bool isChangeRestaurantLogo;
  bool isSpecialsImage;
  bool isCategoryImage;
  bool isItemImage;
  Specials? specials;
  Category? category;
  MenuItems? menuItems;
  int? index;

  @override
  State<ImageUpload> createState() => _ImageUploadState();
}

class _ImageUploadState extends State<ImageUpload> {
  bool isLoading = false;
  final ImagePicker picker = ImagePicker();
// Pick an image.
  bool init = true;
  late double height;
  late double width;
  bool imageSelected = false;

  ///removing late keyword initialized variable to null
  XFile? originalImage;
  late File? compressedImage;

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
    imageSelected = false;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        mainBody(context),
      ],
    );
  }

  Scaffold mainBody(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            topSection(
                context: context,
                text: "Image Upload",
                height: height,
                width: width),
            SizedBox(height: height * 2),
            Center(
              child: SizedBox(
                width: width * 40,
                height: height * 70,
                child: Stack(
                  children: [
                    Container(
                      width: width * 40,
                      height: height * 70,
                      margin: EdgeInsets.only(bottom: height * 5),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Data.lightGreyBodyColor50,
                        boxShadow: [
                          BoxShadow(
                            color:
                                Colors.black.withOpacity(0.25), // Shadow color
                            spreadRadius: 0, // How much the shadow spreads
                            blurRadius: 4, // How much the shadow blurs
                            offset:
                                const Offset(0, 5), // The offset of the shadow
                          ),
                        ],
                      ),
                      child: imageSelected
                          ? buildImage(
                              originalImage!.path,
                              height,
                              width,
                              isFileImage: true,
                              context: context,
                            )
                          : Padding(
                              padding: EdgeInsets.only(bottom: height * 8),
                              child: Center(
                                child: Icon(
                                  Icons.no_photography_outlined,
                                  color: Provider.of<InfoProvider>(context,
                                          listen: true)
                                      .systemInfo
                                      .iconsColor,
                                  size: width * 20,
                                ),
                              ),
                            ),
                    ),
                    imageSelected
                        ? Align(
                            alignment: Alignment.topRight,
                            child: InkWell(
                              onTap: () {
                                setState(() {
                                  imageSelected = false;
                                });
                              },
                              child: Icon(
                                Icons.close,
                                color: Provider.of<InfoProvider>(context,
                                        listen: true)
                                    .systemInfo
                                    .iconsColor,
                                size: width * 5,
                              ),
                            ),
                          )
                        : const SizedBox(),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Padding(
                        padding: EdgeInsets.only(bottom: height * 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            customTextButton(
                                text: "Camera",
                                height: height,
                                width: width,
                                buttonWidth: width * 15,
                                textColor: Provider.of<InfoProvider>(context,
                                        listen: true)
                                    .systemInfo
                                    .primaryColor,
                                buttonColor: Provider.of<InfoProvider>(context,
                                        listen: true)
                                    .systemInfo
                                    .primaryColor,
                                onTap: () async {
                                  setState(() {
                                    isLoading = true;
                                  });
                                  originalImage = await picker.pickImage(
                                      source: ImageSource.camera);

                                  if (originalImage != null) {
                                    // Resize image to 700x700
                                    compressedImage = await compressFile(
                                        File(originalImage!.path));
                                    if (compressedImage != null) {
                                      setState(() {
                                        originalImage =
                                            XFile(compressedImage!.path);
                                        imageSelected = true;
                                      });
                                    }
                                  }
                                  setState(() {
                                    isLoading = false;
                                  });
                                }),
                            SizedBox(
                              width: width * 2,
                            ),
                            customTextButton(
                                text: "Gallery",
                                height: height,
                                width: width,
                                buttonWidth: width * 15,
                                textColor: Provider.of<InfoProvider>(context,
                                        listen: true)
                                    .systemInfo
                                    .primaryColor,
                                buttonColor: Provider.of<InfoProvider>(context,
                                        listen: true)
                                    .systemInfo
                                    .primaryColor,
                                onTap: () async {
                                  setState(() {
                                    isLoading = true;
                                  });
                                  originalImage = await picker.pickImage(
                                      source: ImageSource.gallery);
                                  if (originalImage != null) {
                                    // Resize image to 700x700
                                    compressedImage = await compressFile(
                                        File(originalImage!.path));
                                    if (compressedImage != null) {
                                      setState(() {
                                        originalImage =
                                            XFile(compressedImage!.path);
                                        imageSelected = true;
                                      });
                                    }
                                  }
                                  setState(() {
                                    isLoading = false;
                                  });
                                }),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            buildButton(
              Icons.cloud_upload,
              "Upload Image",
              height,
              width,
              () async {
                if (originalImage == null) {
                  showTopSnackBar(
                    Overlay.of(context),
                    const CustomSnackBar.error(
                      message: "Please select an image to upload",
                    ),
                  );
                  return;
                }
                final overlayContext = Overlay.of(context);
                setState(() {
                  isLoading = true;
                });
                String? imageUrl =
                    await Provider.of<UploadProvider>(context, listen: false)
                        .uploadImage(
                  user: Provider.of<AuthProvider>(context, listen: false).user,
                  incomingFilePath: compressedImage!.path,
                  context: context,
                  isChangeDP: widget.isChangeDP,
                  isChangeRestaurantImage: widget.isChangeRestaurantImage,
                  isChangeRestaurantLogo: widget.isChangeRestaurantLogo,
                  isSpecialsImage: widget.isSpecialsImage,
                  isCategoryImage: widget.isCategoryImage,
                  isItemImage: widget.isItemImage,
                  specials: widget.specials,
                  category: widget.category,
                  menuItems: widget.menuItems,
                  index: widget.index,
                );
                setState(() {
                  isLoading = false;
                });
                if (imageUrl == "too big") {
                  showTopSnackBar(
                    overlayContext,
                    const CustomSnackBar.error(
                      message:
                          "Image Size is too big. Please upload a smaller image",
                    ),
                  );
                } else if (imageUrl != null) {
                  showTopSnackBar(
                    overlayContext,
                    const CustomSnackBar.success(
                      message: "Image Successfully Uploaded",
                    ),
                  );
                  if (context.mounted) {
                    if (widget.isChangeDP) {
                      Provider.of<AuthProvider>(context, listen: false)
                          .updateUserProfilePictureLocally(imageUrl: imageUrl);
                    } else if (widget.isChangeRestaurantImage) {
                      Provider.of<InfoProvider>(context, listen: false)
                          .updateRestaurantImageLocally(imageUrl: imageUrl);
                    } else if (widget.isChangeRestaurantLogo) {
                      Provider.of<InfoProvider>(context, listen: false)
                          .updateRestaurantLogoLocally(logoUrl: imageUrl);
                    } else if (widget.isSpecialsImage) {
                      Provider.of<MenuProvider>(context, listen: false)
                          .updateSpecialsImageLocally(
                              index: widget.index!, imageUrl: imageUrl);
                    } else if (widget.isCategoryImage) {
                      Provider.of<MenuProvider>(context, listen: false)
                          .updateCategoryImageLocally(
                              index: widget.index!, imageUrl: imageUrl);
                    } else if (widget.isItemImage) {}

                    Navigator.pop(context);
                  }
                } else {
                  showTopSnackBar(
                    overlayContext,
                    const CustomSnackBar.error(
                      message: "Image Upload failed",
                    ),
                  );
                }
              },
              context,
            ),
          ],
        ),
      ),
    );
  }

  // Function to compress the image
  Future<File?> compressFile(File file) async {
    img.Image? image = img.decodeImage(await file.readAsBytes());
    img.Image resizedImage = img.copyResize(image!, width: 700, height: 700);
    return File(
        '${(io.Directory.systemTemp).path}/${file.path.split('/').last}')
      ..writeAsBytesSync(img.encodeJpg(resizedImage, quality: 85));
  }
}
