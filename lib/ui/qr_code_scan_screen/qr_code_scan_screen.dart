import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import 'package:watchman/constant/collection_name.dart';
import 'package:watchman/constant/constant.dart';
import 'package:watchman/constant/show_toast_dialog.dart';
import 'package:watchman/model/order_model.dart';
import 'package:watchman/themes/common_ui.dart';
import 'package:watchman/ui/after_scanned/after_scanned_screen.dart';
import 'package:watchman/ui/after_scanned/early_arrive_screen.dart';
import 'package:watchman/utils/dark_theme_provider.dart';
import 'package:watchman/utils/fire_store_utils.dart';

class QrCodeScanScreen extends StatelessWidget {
  final String? orderId;

  const QrCodeScanScreen({super.key, this.orderId});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return Scaffold(
      appBar: UiInterface().customAppBar(
        context,
        themeChange,
        'Scan QR code'.tr,
      ),
      body: MobileScanner(
        // fit: BoxFit.contain,
        onDetect: (capture) async {
          final List<Barcode> barcodes = capture.barcodes;
          final Uint8List? image = capture.image;
          for (final barcode in barcodes) {
            Get.back();
            if (orderId == null) {
              ShowToastDialog.showLoader("Please wait".tr);
              await FireStoreUtils.fireStore.collection(CollectionName.bookedParkingOrder).doc(barcode.rawValue).get().then((value) async {
                OrderModel orderModel = OrderModel.fromJson(value.data()!);
                log("Scan :: ${orderModel.toJson()}");
                ShowToastDialog.closeLoader();
                await FireStoreUtils.getWatchMen(FirebaseAuth.instance.currentUser!.uid).then((user) async {
                  if (orderModel.parkingDetails!.id != user?.parkingId) {
                    ShowToastDialog.showToast("Invalid QR code".tr);
                  } else if (orderModel.status == Constant.completed) {
                    ShowToastDialog.showToast("This booking already completed".tr);
                  } else if (orderModel.status == Constant.onGoing) {
                    ShowToastDialog.showToast("This Order already scanned".tr);
                  } else if (DateTime.now().isBefore(orderModel.bookingStartTime!.toDate())) {
                    Get.to(() => const EarlyArriveScreen(), arguments: {"orderModel": orderModel});
                  } else {
                    Get.to(() => const AfterScannedScreen(), arguments: {"orderModel": orderModel});
                  }
                });
              });
              debugPrint('Barcode found! ${barcode.rawValue}'.tr);
            } else {
              if (orderId == barcode.rawValue) {
                await FireStoreUtils.fireStore.collection(CollectionName.bookedParkingOrder).doc(barcode.rawValue).get().then((value) async {
                  OrderModel orderModel = OrderModel.fromJson(value.data()!);
                  log("Scan :: ${orderModel.toJson()}");
                  ShowToastDialog.closeLoader();
                  await FireStoreUtils.getWatchMen(FirebaseAuth.instance.currentUser!.uid).then((user) async {
                    if (orderModel.parkingDetails!.id != user?.parkingId) {
                      ShowToastDialog.showToast("Invalid QR code".tr);
                    } else if (orderModel.status == Constant.completed) {
                      ShowToastDialog.showToast("This booking already completed".tr);
                    } else if (orderModel.status == Constant.onGoing) {
                      ShowToastDialog.showToast("This Order already scanned".tr);
                    } else if (DateTime.now().isBefore(orderModel.bookingStartTime!.toDate())) {
                      Get.to(() => const EarlyArriveScreen(), arguments: {"orderModel": orderModel});
                    } else {
                      Get.to(() => const AfterScannedScreen(), arguments: {"orderModel": orderModel});
                    }
                  });
                });
              } else {
                ShowToastDialog.showToast("Invalid QR code".tr);
              }
            }
          }
        },
      ),
    );
  }
}
