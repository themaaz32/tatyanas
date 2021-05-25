import 'dart:async';
import 'dart:io';
import 'package:cool_alert/cool_alert.dart';
import 'package:flutter/foundation.dart' show kDebugMode;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_crop/image_crop.dart';
import 'package:image_picker/image_picker.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tatyanas_app/globals/consts/consts.dart';
import 'package:tatyanas_app/globals/routes/routes.dart';
import 'package:tatyanas_app/model/icon_model.dart';
import 'package:tatyanas_app/model/image_model.dart';
import 'package:tatyanas_app/repo/cached_repository.dart';
import 'package:tatyanas_app/screens/crop/crop_image.dart';

import '../globals/consts/consts.dart';
import '../model/icon_model.dart';

enum ImageSourceSelection {
  camera,
  gallery,
}

class AppState extends ChangeNotifier {
  Future initialize() async {
    initializeDefaultLandingRoute();
  }


  AppState() {
    initialize();

    initializeInAppPurchases();
  }

  List<ProductDetails> productDetails = [];
  List<PurchaseDetails> purchaseDetails = [];
  String _productId = "pro_version";

  // String _productId = "android.test.canceled";
  final _iap = InAppPurchaseConnection.instance;

  void upgradeToProVersion() {
    if (productDetails.isEmpty) {
      Fluttertoast.showToast(msg: "Sorry no pro version found");
      return;
    }

    ProductDetails proProduct = productDetails.first;

    // Fluttertoast.showToast(msg: "${proProduct.title} is found");

    if (hasPurchased(proProduct.id) != null) {
      Fluttertoast.showToast(msg: "You already have upgraded to Pro version");
    } else {
      buyInAppProduct(proProduct);
    }
  }

  bool pastPurchasesFetched = false;
  bool isAvailable = false;

  void setPastPurchasesFetched() {
    pastPurchasesFetched = true;
    notifyListeners();
  }

  void setIsAvailable(bool value) {
    /*Fluttertoast.showToast(
      msg: "Availablity : $isAvailable -> $value",
    );*/
    isAvailable = value;
    notifyListeners();
  }

  Future initializeInAppPurchases() async {
    try {
      isAvailable = await _iap.isAvailable();
      setIsAvailable(isAvailable);

      initializePurchaseDetails();
      if (!isAvailable) {
       /* Fluttertoast.showToast(
          msg: "Not available store",
        );*/
        return;
      } else {
        /*Fluttertoast.showToast(
          msg: "Store Available",
        );*/
      }

      await _getProProduct();
      await _getPastPurchases();
    } on Exception catch (e) {
      Fluttertoast.showToast(
        msg: e.toString(),
      );
    }
  }

  void buyInAppProduct(ProductDetails productDetails) {
    /*Fluttertoast.showToast(
      msg: "Buying product",
    );*/
    final PurchaseParam purchaseParam =
        PurchaseParam(productDetails: productDetails);
    _iap.buyNonConsumable(purchaseParam: purchaseParam);
  }

  PurchaseDetails hasPurchased(String productId) {
    /*Fluttertoast.showToast(
      msg: "has purchased?",
    );*/
    return purchaseDetails.firstWhere(
        (purchase) => purchase.productID == productId,
        orElse: () => null);
  }

  bool isPro = false;

  void verifyPurchase(String productId) {
    final purchase = hasPurchased(productId);

    if (purchase != null && purchase.status == PurchaseStatus.purchased) {
      enableProVersion();
    }else{
      Fluttertoast.showToast(
        msg: "Error : Not verified purchase",
      );
    }
  }

  enableProVersion() {
    isPro = true;
    print("pro version enabled");
    CoolAlert.show(
      context: context,
      type: CoolAlertType.success,
      text: "You have enabled the pro version",
    );
    notifyListeners();
  }

  Future _getProProduct() async {
    ///[_productID] = "pro_version"
    const Set<String> _kIds = <String>{'pro_version'};
    /*Fluttertoast.showToast(
      msg: "Getting Products",
    );*/
    ProductDetailsResponse response = await _iap.queryProductDetails(_kIds);
    /*Fluttertoast.showToast(
      msg: "Error :${response.error?.message}",
    );
    Fluttertoast.showToast(
      msg: "Ids not found ${response.notFoundIDs.toString()}",
    );
*/
    productDetails = response.productDetails;

    notifyListeners();
  }

  Future _getPastPurchases() async {
    print("gettting past purchases");

    QueryPurchaseDetailsResponse response = await _iap.queryPastPurchases();
    purchaseDetails = response.pastPurchases;


    for (PurchaseDetails purchase in response.pastPurchases) {
      if (purchase.productID.compareTo(_productId) == 0) {
        verifyPurchase(purchase.productID);
      }
    }
    setPastPurchasesFetched();
    print(purchaseDetails.toString());
    notifyListeners();
  }

  StreamSubscription<List<PurchaseDetails>> _subscription;

  void initializePurchaseDetails() {
    print("initialzing purchases");
    final Stream purchaseUpdated = _iap.purchaseUpdatedStream;

    _subscription = purchaseUpdated.listen((purchaseDetailsList) {
      print("Got purchase");
      purchaseDetails.addAll(purchaseDetailsList);
      for (PurchaseDetails purchase in purchaseDetails) {
        if (purchase.productID.compareTo(_productId) == 0) {
          verifyPurchase(purchase.productID);
        }
      }
    }, onDone: () {
      _subscription.cancel();
    }, onError: (error) {
      Fluttertoast.showToast(
        msg: "Error : $error",
      );
    });
  }

  GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  GlobalKey<CropState> cropKey = GlobalKey<CropState>();

  ImagePicker _imagePicker = ImagePicker();
  PickedFile _file;
  CachedImagesRepository _cachedImagesRepository = CachedImagesRepository();

  List<IconModel> imageGroups = [];

  void _loadDefaultImagesData() {
    imageGroups = [
      IconModel(
        iconLink: "assets/images/icon1.jpeg",
        source: "asset",
        images: [],
      ),
      IconModel(
        iconLink: "assets/images/icon2.png",
        source: "asset",
        images: [],
      ),
      IconModel(
        iconLink: "assets/images/icon3.jpeg",
        source: "asset",
        images: [],
      ),
    ];
    notifyListeners();
  }

  void setImagesData(List<IconModel> images) {
    imageGroups = images;
    notifyListeners();
  }

  Future loadImagesDataFromCache() async {
    final bool isDataAvailable =
        await _cachedImagesRepository.isDataAvailable();

    if (!isDataAvailable) {
      _loadDefaultImagesData();
    } else {
      final String jsonImagesData =
          await _cachedImagesRepository.getImagesDataFromCache();

      final List<IconModel> images = iconModelFromJson(jsonImagesData);
      setImagesData(images);
    }
  }

  Future pickImageFromGallery() async {
    _file = null;
    try {
      _file = await _imagePicker.getImage(
          source: ImageSource.gallery,
          imageQuality: 50,
          preferredCameraDevice: CameraDevice.rear);
    } on Exception catch (e) {
      print(e);
    }
  }

  Future pickImageFromCamera() async {
    _file = null;
    try {
      _file = await _imagePicker.getImage(
          source: ImageSource.camera,
          imageQuality: 50,
          preferredCameraDevice: CameraDevice.rear);
    } on Exception catch (e) {
      print(e);
    }
  }

  Future<String> savedPickedImageInDocumentDirectory(String filePath) async {
    final documentDirectory = await getApplicationDocumentsDirectory();
    File _pickedFile = File(filePath);
    File _savedFile = await _pickedFile.copy(
        "${documentDirectory.path}/${DateTime.now().toString().replaceAll(RegExp(r'(?:_|[^\w\s]| )+'), '')}.jpg");
    return _savedFile.path;
  }

  Future<String> savedRecordedAudioInDocumentDirectory(String filePath) async {
    final documentDirectory = await getApplicationDocumentsDirectory();
    File _recordedAudio = File(filePath);
    File _savedFile = await _recordedAudio.copy(
        "${documentDirectory.path}/${DateTime.now().toString().replaceAll(RegExp(r'(?:_|[^\w\s]| )+'), '')}.mp3");
    return _savedFile.path;
  }

  Future<ImageSourceSelection> showPickImageDialog() async {
    return await showModalBottomSheet<ImageSourceSelection>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return ListView(
          shrinkWrap: true,
          children: [
            ListTile(
              title: Text("Camera"),
              onTap: () async {
                Navigator.pop(ctx, ImageSourceSelection.camera);
              },
            ),
            ListTile(
              title: Text("Gallery"),
              onTap: () async {
                Navigator.pop(ctx, ImageSourceSelection.gallery);
              },
            ),
          ],
        );
      },
    );
  }

  Future<String> handleRecordingAudio() async {
    final audioFilePath =
        await navigatorKey.currentState.pushNamed(AppRoutes.recording);
    return audioFilePath;
  }

  Future _updateCachedImagesDataOnModification() async {
    final String jsonImagesData = iconModelToJson(imageGroups);
    await _cachedImagesRepository.updateImagesDataInCache(jsonImagesData);
  }

  void addIcon(String iconFilePath) {
    final IconModel iconModel = IconModel(
      iconLink: iconFilePath,
      source: "file",
      images: [],
    );
    imageGroups.add(iconModel);
    _updateCachedImagesDataOnModification();
    notifyListeners();
  }

  bool validTry(){
    if(isPro){
      // Fluttertoast.showToast(
      //   msg: "valid try : isPro = true",
      // );
      return true;
    }
    int count = 0;
    imageGroups.forEach((group) {
      count += group.images.length;
    });
    // Fluttertoast.showToast(
    //   msg: "valid try : count = $count",
    // );
    return count < 20;
    // return count < 1;
  }

  void addImageToGroup(
    int groupIndex,
    String imageFilePath,
    String audioLink,
  ) {


    final ImageModel imageModel = ImageModel(
      imageLink: imageFilePath,
      audioLink: audioLink,
    );
    imageGroups[groupIndex].addImageEntry(imageModel);
    _updateCachedImagesDataOnModification();
    notifyListeners();
  }

  void deleteImage(int groupId, int imageIndex) {
    imageGroups[groupId].removeImageEntry(imageIndex);
    _updateCachedImagesDataOnModification();
    notifyListeners();
  }

  void deleteImageGroup(
    int groupId,
  ) {
    imageGroups.removeAt(groupId);
    _updateCachedImagesDataOnModification();
    notifyListeners();
  }

  Future handleAddIcon() async {
    final imageSourceSelection = await showPickImageDialog();

    if (imageSourceSelection != null) {
      if (imageSourceSelection == ImageSourceSelection.camera) {
        await pickImageFromCamera();
      } else {
        await pickImageFromGallery();
      }

      if (_file == null) return;

      final croppedFile = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CropImageScreen(_file.path),
        ),
      );

      final imagePath =
          await savedPickedImageInDocumentDirectory(croppedFile.path);
      addIcon(imagePath);
    }
  }

  Future handleAddImageToAGroup(int groupIndex) async {


    if(!validTry()){
      CoolAlert.show(
        context: context,
        type: CoolAlertType.error,
        text: "Sorry you can't more images, upgrade to pro version!",
      );
      return;
    }

    final imageSourceSelection = await showPickImageDialog();

    if (imageSourceSelection != null) {
      if (imageSourceSelection == ImageSourceSelection.camera) {
        await pickImageFromCamera();
      } else {
        await pickImageFromGallery();
      }

      if (_file == null) return;

      final croppedFile = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CropImageScreen(_file.path),
        ),
      );

      final imagePath =
          await savedPickedImageInDocumentDirectory(croppedFile.path);
      print("image is saved in $imagePath");
      final audioPathLocal = await handleRecordingAudio();
      /*final audioPath =
          await savedRecordedAudioInDocumentDirectory(audioPathLocal);*/
      print("audio saved in $audioPathLocal");
      addImageToGroup(groupIndex, imagePath, audioPathLocal);
    }
  }

  BuildContext get context => navigatorKey.currentState.context;

  SharedPreferences _sharedPreferences;

  Size get appSize => MediaQuery.of(context).size;

  Future initializeDefaultLandingRoute() async {
    _sharedPreferences = await SharedPreferences.getInstance();
    final isUserFirstTime =
        _sharedPreferences.getBool(AppConstants.isUserFirstTimeKey) ?? true;
    _sharedPreferences.setBool(AppConstants.isUserFirstTimeKey, false);

    if (isUserFirstTime) showWelcomeDialog();
  }

  void showWelcomeDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Welcome to Tatyanas app"),
        content: Text(
            "survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged."),
        actions: [
          FlatButton(
            onPressed: () {
              navigatorKey.currentState.pop();
            },
            child: Text("Get Started"),
          ),
        ],
      ),
    );
  }
}
