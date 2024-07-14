import 'package:epos_application/components/buttons.dart';
import 'package:epos_application/components/common_widgets.dart';
import 'package:epos_application/components/data.dart';
import 'package:epos_application/components/size_config.dart';
import 'package:epos_application/providers/auth_provider.dart';
import 'package:epos_application/providers/info_provider.dart';
import 'package:epos_application/providers/upload_provider.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:provider/provider.dart';

class ImageUpload extends StatefulWidget {
  const ImageUpload({super.key});
  static const routeName = "imageUpload";

  @override
  State<ImageUpload> createState() => _ImageUploadState();
}

class _ImageUploadState extends State<ImageUpload> {
  final ImagePicker picker = ImagePicker();
// Pick an image.
  bool init = true;
  late double height;
  late double width;
  bool imageSelected = false;
  late XFile? image;

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
    return LoaderOverlay(
      useDefaultLoading: false,
      overlayWidgetBuilder: (_) {
        //ignored progress for the moment
        return Center(
          child: onLoading(width: width, context: context),
        );
      },
      child: Scaffold(
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
                              color: Colors.black
                                  .withOpacity(0.25), // Shadow color
                              spreadRadius: 0, // How much the shadow spreads
                              blurRadius: 4, // How much the shadow blurs
                              offset: const Offset(
                                  0, 5), // The offset of the shadow
                            ),
                          ],
                        ),
                        child: imageSelected
                            ? buildImage(image!.path, height, width,
                                fileImage: true)
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
                                  buttonColor: Provider.of<InfoProvider>(
                                          context,
                                          listen: true)
                                      .systemInfo
                                      .primaryColor,
                                  onTap: () async {
                                    image = await picker.pickImage(
                                        source: ImageSource.camera);
                                    if (image != null) {
                                      setState(() {
                                        imageSelected = true;
                                      });
                                    }
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
                                  buttonColor: Provider.of<InfoProvider>(
                                          context,
                                          listen: true)
                                      .systemInfo
                                      .primaryColor,
                                  onTap: () async {
                                    image = await picker.pickImage(
                                        source: ImageSource.gallery);
                                    if (image != null) {
                                      setState(() {
                                        imageSelected = true;
                                      });
                                    }
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
                  final loaderOverlay = context.loaderOverlay;
                  final overlayContext = Overlay.of(context);
                  loaderOverlay.show();
                  await Provider.of<UploadProvider>(context, listen: false)
                      .uploadImage(
                    user:
                        Provider.of<AuthProvider>(context, listen: false).user,
                    incomingFilePath: image!.path,
                    context: context,
                    isUserDP: true,
                  );
                  loaderOverlay.hide();
                },
                context,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
