import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:watchman/constant/show_toast_dialog.dart';
import 'package:watchman/controller/login_controller.dart';
import 'package:watchman/themes/app_them_data.dart';
import 'package:watchman/themes/responsive.dart';
import 'package:watchman/themes/round_button_gradiant.dart';
import 'package:watchman/themes/text_field_widget.dart';
import 'package:watchman/ui/terms_and_condition/terms_and_condition_screen.dart';
import 'package:watchman/utils/dark_theme_provider.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return GetX<LoginController>(
      init: LoginController(),
      builder: (controller) {
        return Scaffold(
          body: Center(
            child: SingleChildScrollView(
              child: Form(
                key: controller.formKey.value,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 120),
                      SvgPicture.asset("assets/images/login_logo.svg"),
                      const SizedBox(height: 40),
                      Text(
                        "Log in".tr,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: themeChange.getThem() ? AppThemData.grey01 : AppThemData.grey10,
                          fontSize: 24,
                          fontFamily: AppThemData.semiBold,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      SizedBox(
                        height: Responsive.height(5, context),
                      ),
                      TextFieldWidget(
                        title: "Email Address".tr,
                        controller: controller.emailController.value,
                        hintText: "Enter Email Address".tr,
                        onPress: () {},
                      ),
                      const SizedBox(height: 5),
                      TextFieldWidget(title: "Password".tr, controller: controller.passwordController.value, onPress: () {}, hintText: 'Enter Password'.tr),
                      const SizedBox(height: 40),
                      RoundedButtonGradiant(
                        title: "Continue".tr,
                        onPress: () {
                          if (controller.checkValidation() != null) {
                            ShowToastDialog.showToast(controller.checkValidation().toString());
                          } else {
                            if (controller.formKey.value.currentState!.validate()) {
                              controller.signInWithEmailAndPassword();
                            }
                          }
                        },
                      ),
                      const SizedBox(
                        height: 44,
                      ),
                      const SizedBox(height: 44),
                    ],
                  ),
                ),
              ),
            ),
          ),
          bottomNavigationBar: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              child: Text.rich(
                textAlign: TextAlign.center,
                TextSpan(
                  text: "${'tapping_next_agree'.tr} ",
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                    fontFamily: AppThemData.regular,
                    color: themeChange.getThem() ? AppThemData.grey01 : AppThemData.grey08,
                  ),
                  children: <TextSpan>[
                    TextSpan(
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          Get.to(
                            const TermsAndConditionScreen(
                              type: "terms",
                            ),
                          );
                        },
                      text: 'terms_and_conditions'.tr,
                      style: TextStyle(
                        color: themeChange.getThem() ? AppThemData.blueLight : AppThemData.blueLight,
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                        fontFamily: AppThemData.regular,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                    TextSpan(
                      text: " ${"and".tr} ",
                      style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16, color: themeChange.getThem() ? AppThemData.grey01 : AppThemData.grey08),
                    ),
                    TextSpan(
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          Get.to(
                            const TermsAndConditionScreen(
                              type: "privacy",
                            ),
                          );
                        },
                      text: 'privacy_policy'.tr,
                      style: TextStyle(
                        color: themeChange.getThem() ? AppThemData.blueLight : AppThemData.blueLight,
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                        fontFamily: AppThemData.regular,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ],
                ),
              )),
        );
      },
    );
  }
}
