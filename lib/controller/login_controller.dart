import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:watchman/constant/extension_data.dart';
import 'package:watchman/constant/show_toast_dialog.dart';
import 'package:watchman/ui/dashboard_screen.dart';
import 'package:watchman/utils/fire_store_utils.dart';
import 'package:watchman/utils/notification_service.dart';

class LoginController extends GetxController {
  Rx<TextEditingController> emailController = TextEditingController().obs;
  Rx<TextEditingController> passwordController = TextEditingController().obs;
  Rx<TextEditingController> countryCode = TextEditingController(text: "+1").obs;

  Rx<GlobalKey<FormState>> formKey = GlobalKey<FormState>().obs;

  signInWithEmailAndPassword() async {
    ShowToastDialog.showLoader("please_wait".tr);
    try {
      FirebaseAuth.instance.signInWithEmailAndPassword(email: emailController.value.text, password: passwordController.value.text).then((value) async {
        String watchmanId = value.user?.uid ?? '';
        if (watchmanId != '') {
          FireStoreUtils.getWatchMen(watchmanId).then((value) async {
            if (value != null) {
              if (value.isActive == true) {
                String ftoken = await NotificationService.getToken();
                value.fcmToken = ftoken;
                await FireStoreUtils.updateWatchmen(value);
                ShowToastDialog.closeLoader();
                Get.offAll(const DashBoardScreen());
              } else {
                ShowToastDialog.closeLoader();
                await FirebaseAuth.instance.signOut();
                ShowToastDialog.showToast("This user is disable please contact administrator".tr);
              }
            } else {
              ShowToastDialog.closeLoader();
              await FirebaseAuth.instance.signOut();
              ShowToastDialog.showToast("This user is disable please contact administrator".tr);
            }
          });
        }
      }).catchError((error) {
        var errorCode = error.code;
        var errorMessage = error.message;
        ShowToastDialog.closeLoader();
        if (errorCode == "user-not-found") {
          ShowToastDialog.showToast("Invalid email and password");
        } else if (errorCode == "wrong-password") {
          ShowToastDialog.showToast("Wrong password");
        } else {
          ShowToastDialog.showToast(errorMessage);
        }
      });
    } catch (e) {
      debugPrint("catchError--->$e");
      ShowToastDialog.closeLoader();
      ShowToastDialog.showToast(e.toString());
    }
  }

  checkValidation() {
    if (!isEmail(emailController.value.text)) {
      return "Please Enter Valid Email address";
    } else if (passwordController.value.text.isEmpty) {
      return "Please Enter Password";
    } else {
      return null;
    }
  }
}
