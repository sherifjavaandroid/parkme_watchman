import 'package:clipboard/clipboard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:watchman/constant/constant.dart';
import 'package:watchman/constant/show_toast_dialog.dart';
import 'package:watchman/controller/my_summary_controller.dart';
import 'package:watchman/model/tax_model.dart';
import 'package:watchman/themes/app_them_data.dart';
import 'package:watchman/themes/common_ui.dart';
import 'package:watchman/themes/responsive.dart';
import 'package:watchman/utils/dark_theme_provider.dart';
import 'package:watchman/utils/network_image_widget.dart';

class MySummaryScreen extends StatelessWidget {
  const MySummaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return GetX(
        init: MySummaryController(),
        builder: (controller) {
          return Scaffold(
            appBar: UiInterface().customAppBar(context, themeChange, "My Review summary".tr),
            body: controller.isLoading.value
                ? Constant.loader()
                : SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          color: themeChange.getThem() ? AppThemData.grey09 : AppThemData.grey10,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Parking ID'.tr,
                                        style: const TextStyle(
                                          color: AppThemData.grey07,
                                          fontSize: 14,
                                          fontFamily: AppThemData.regular,
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 6,
                                      ),
                                      Text(
                                        '#${controller.orderModel.value.id}'.tr,
                                        style: const TextStyle(
                                          color: AppThemData.grey02,
                                          fontSize: 14,
                                          fontFamily: AppThemData.medium,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                InkWell(
                                  onTap: () {
                                    FlutterClipboard.copy(controller.orderModel.value.id.toString()).then((value) {
                                      ShowToastDialog.showToast("Parking ID copied".tr);
                                    });
                                  },
                                  child: SvgPicture.asset(
                                    "assets/icon/ic_content_copy.svg",
                                    height: 24,
                                    width: 24,
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Column(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  color: themeChange.getThem() ? AppThemData.grey10 : AppThemData.white,
                                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Parking Info'.tr,
                                        style: const TextStyle(
                                          color: AppThemData.grey07,
                                          fontSize: 16,
                                          fontFamily: AppThemData.medium,
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                        decoration: ShapeDecoration(
                                          color: controller.orderModel.value.paymentCompleted == true ? AppThemData.success02 : AppThemData.error02,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(200),
                                          ),
                                        ),
                                        child: Text(
                                          controller.orderModel.value.paymentCompleted == true ? "Payment completed".tr : 'Payment Incomplete'.tr,
                                          style: TextStyle(
                                            color: controller.orderModel.value.paymentCompleted == true ? AppThemData.success08 : AppThemData.error08,
                                            fontSize: 12,
                                            fontFamily: 'Golos Text',
                                          ),
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 24,
                                      ),
                                      Text(
                                        controller.orderModel.value.parkingDetails!.name.toString(),
                                        style: TextStyle(
                                          color: themeChange.getThem() ? AppThemData.grey06 : AppThemData.grey09,
                                          fontSize: 18,
                                          fontFamily: AppThemData.semiBold,
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Icon(
                                            Icons.location_on_outlined,
                                            color: AppThemData.grey07,
                                          ),
                                          const SizedBox(
                                            width: 5,
                                          ),
                                          Expanded(
                                            child: Text(
                                              controller.orderModel.value.parkingDetails!.address.toString(),
                                              style: const TextStyle(
                                                color: AppThemData.grey07,
                                                fontSize: 14,
                                                fontFamily: AppThemData.regular,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Row(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                const Icon(Icons.calendar_today, color: AppThemData.grey07, size: 20),
                                                const SizedBox(
                                                  width: 10,
                                                ),
                                                Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      Constant.timestampToDate(controller.orderModel.value.bookingDate!),
                                                      style: TextStyle(
                                                        color: themeChange.getThem() ? AppThemData.grey06 : AppThemData.grey09,
                                                        fontSize: 16,
                                                        fontFamily: AppThemData.medium,
                                                      ),
                                                    ),
                                                    const SizedBox(
                                                      height: 5,
                                                    ),
                                                    Text(
                                                      "${Constant.timestampToTime(controller.orderModel.value.bookingStartTime!)} - ${Constant.timestampToTime(controller.orderModel.value.bookingEndTime!)}",
                                                      style: const TextStyle(
                                                        color: AppThemData.grey07,
                                                        fontSize: 12,
                                                        fontFamily: AppThemData.regular,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                          Expanded(
                                            child: Row(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                const Icon(Icons.local_parking, color: AppThemData.grey07, size: 20),
                                                const SizedBox(
                                                  width: 10,
                                                ),
                                                Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      controller.orderModel.value.parkingSlotId.toString(),
                                                      style: TextStyle(
                                                        color: themeChange.getThem() ? AppThemData.grey06 : AppThemData.grey09,
                                                        fontSize: 16,
                                                        fontFamily: AppThemData.medium,
                                                      ),
                                                    ),
                                                    const SizedBox(
                                                      height: 5,
                                                    ),
                                                    Text(
                                                      "Parking Slot".tr,
                                                      style: const TextStyle(
                                                        color: AppThemData.grey07,
                                                        fontSize: 12,
                                                        fontFamily: AppThemData.regular,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          )
                                        ],
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Row(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                SvgPicture.asset("assets/icon/ic_car_image.svg", height: 24, width: 24),
                                                const SizedBox(
                                                  width: 10,
                                                ),
                                                Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      controller.orderModel.value.userVehicle!.vehicleModel!.name.toString(),
                                                      style: TextStyle(
                                                        color: themeChange.getThem() ? AppThemData.grey06 : AppThemData.grey09,
                                                        fontSize: 16,
                                                        fontFamily: AppThemData.medium,
                                                      ),
                                                    ),
                                                    const SizedBox(
                                                      height: 5,
                                                    ),
                                                    Text(
                                                      "vehicle Detail".tr,
                                                      style: const TextStyle(
                                                        color: AppThemData.grey07,
                                                        fontSize: 12,
                                                        fontFamily: AppThemData.regular,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                          Expanded(
                                            child: Row(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                const Icon(Icons.access_time_rounded, color: AppThemData.grey07, size: 20),
                                                const SizedBox(
                                                  width: 10,
                                                ),
                                                Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      "${controller.orderModel.value.duration.toString()} hours".tr,
                                                      style: TextStyle(
                                                        color: themeChange.getThem() ? AppThemData.grey06 : AppThemData.grey09,
                                                        fontSize: 16,
                                                        fontFamily: AppThemData.medium,
                                                      ),
                                                    ),
                                                    const SizedBox(
                                                      height: 5,
                                                    ),
                                                    Text(
                                                      "Time Durations".tr,
                                                      style: const TextStyle(
                                                        color: AppThemData.grey07,
                                                        fontSize: 12,
                                                        fontFamily: AppThemData.regular,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          )
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  color: themeChange.getThem() ? AppThemData.grey10 : AppThemData.white,
                                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 5),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                'Sub Total'.tr,
                                                style: TextStyle(
                                                  color: themeChange.getThem() ? AppThemData.grey03 : AppThemData.grey07,
                                                  fontSize: 16,
                                                  fontFamily: AppThemData.medium,
                                                ),
                                              ),
                                            ),
                                            Text(
                                              Constant.amountShow(amount: controller.orderModel.value.subTotal.toString()),
                                              style: TextStyle(
                                                color: themeChange.getThem() ? AppThemData.grey03 : AppThemData.grey07,
                                                fontSize: 16,
                                                fontFamily: AppThemData.semiBold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 5),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                'Coupon Applied'.tr,
                                                style: TextStyle(
                                                  color: themeChange.getThem() ? AppThemData.grey03 : AppThemData.grey07,
                                                  fontSize: 16,
                                                  fontFamily: AppThemData.medium,
                                                ),
                                              ),
                                            ),
                                            Text(
                                              Constant.amountShow(amount: controller.couponAmount.toString()),
                                              style: TextStyle(
                                                color: themeChange.getThem() ? AppThemData.grey03 : AppThemData.grey07,
                                                fontSize: 16,
                                                fontFamily: AppThemData.semiBold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      controller.orderModel.value.taxList == null
                                          ? const SizedBox()
                                          : ListView.builder(
                                              itemCount: controller.orderModel.value.taxList!.length,
                                              shrinkWrap: true,
                                              padding: EdgeInsets.zero,
                                              itemBuilder: (context, index) {
                                                TaxModel taxModel = controller.orderModel.value.taxList![index];
                                                return Padding(
                                                  padding: const EdgeInsets.symmetric(vertical: 5),
                                                  child: Row(
                                                    children: [
                                                      Expanded(
                                                        child: Text(
                                                          "${taxModel.title.toString()} (${taxModel.type == "fix" ? Constant.amountShow(amount: taxModel.tax) : "${taxModel.tax}%"})",
                                                          style: TextStyle(
                                                            color: themeChange.getThem() ? AppThemData.grey03 : AppThemData.grey07,
                                                            fontSize: 16,
                                                            fontFamily: AppThemData.medium,
                                                          ),
                                                        ),
                                                      ),
                                                      Text(
                                                        "${Constant.amountShow(amount: Constant().calculateTax(amount: (double.parse(controller.orderModel.value.subTotal.toString()) - double.parse(controller.couponAmount.value.toString())).toString(), taxModel: taxModel).toStringAsFixed(Constant.currencyModel!.decimalDigits!).toString())} ",
                                                        style: TextStyle(
                                                          color: themeChange.getThem() ? AppThemData.grey03 : AppThemData.grey07,
                                                          fontSize: 16,
                                                          fontFamily: AppThemData.semiBold,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              }),
                                      Divider(
                                        thickness: 1,
                                        color: themeChange.getThem() ? AppThemData.grey09 : AppThemData.grey03,
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 5),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                'Total'.tr,
                                                style: TextStyle(
                                                  color: themeChange.getThem() ? AppThemData.grey03 : AppThemData.grey07,
                                                  fontSize: 16,
                                                  fontFamily: AppThemData.medium,
                                                ),
                                              ),
                                            ),
                                            Text(
                                              Constant.amountShow(amount: controller.calculateAmount().toString()),
                                              style: TextStyle(
                                                color: themeChange.getThem() ? AppThemData.grey03 : AppThemData.grey07,
                                                fontSize: 16,
                                                fontFamily: AppThemData.semiBold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        controller.reviewModel.value.id == null
                            ? Container()
                            : Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 10),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 10),
                                      child: Text(
                                        "Review".tr,
                                        style: const TextStyle(
                                          color: AppThemData.grey07,
                                          fontSize: 14,
                                          fontFamily: AppThemData.medium,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    Container(
                                      decoration: BoxDecoration(
                                        color: themeChange.getThem() ? AppThemData.grey10 : AppThemData.white,
                                        borderRadius: const BorderRadius.all(Radius.circular(10)),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Row(
                                          children: [
                                            ClipRRect(
                                              borderRadius: BorderRadius.circular(60),
                                              child: NetworkImageWidget(
                                                imageUrl: controller.otherUserModel.value.profilePic.toString(),
                                                height: Responsive.width(10, context),
                                                width: Responsive.width(10, context),
                                              ),
                                            ),
                                            const SizedBox(
                                              width: 10,
                                            ),
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  controller.otherUserModel.value.fullName.toString(),
                                                  style: TextStyle(
                                                    color: themeChange.getThem() ? AppThemData.grey06 : AppThemData.grey09,
                                                    fontSize: 14,
                                                    fontFamily: AppThemData.semiBold,
                                                  ),
                                                ),
                                                RatingBar.builder(
                                                  initialRating: double.parse(controller.reviewModel.value.rating.toString()),
                                                  minRating: 0,
                                                  direction: Axis.horizontal,
                                                  allowHalfRating: true,
                                                  itemCount: 5,
                                                  itemSize: 16,
                                                  itemBuilder: (context, _) => const Icon(
                                                    Icons.star,
                                                    color: Colors.amber,
                                                  ),
                                                  onRatingUpdate: (rating) {},
                                                ),
                                                Text(
                                                  controller.reviewModel.value.comment.toString(),
                                                  style: const TextStyle(
                                                    color: AppThemData.grey07,
                                                    fontSize: 14,
                                                    fontFamily: AppThemData.semiBold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                        const SizedBox(
                          height: 10,
                        ),
                        // Padding(
                        //   padding: const EdgeInsets.symmetric(horizontal: 10),
                        //   child: Container(
                        //     decoration: BoxDecoration(
                        //       color: themeChange.getThem() ? AppThemData.grey10 : AppThemData.white,
                        //       borderRadius: const BorderRadius.all(Radius.circular(10)),
                        //     ),
                        //     child: Padding(
                        //       padding: const EdgeInsets.all(8.0),
                        //       child: Column(
                        //         crossAxisAlignment: CrossAxisAlignment.start,
                        //         children: [
                        //           Row(
                        //             children: [
                        //               Expanded(
                        //                 child: Text(
                        //                   "Admin commission".tr,
                        //                   style: const TextStyle(fontFamily: AppThemData.medium),
                        //                 ),
                        //               ),
                        //               Text(
                        //                 "(-${Constant.amountShow(amount: Constant.calculateAdminCommission(amount: (double.parse(controller.orderModel.value.subTotal.toString()) - double.parse(controller.couponAmount.value.toString())).toString(), adminCommission: controller.orderModel.value.adminCommission).toString())})",
                        //                 style: const TextStyle(fontFamily: AppThemData.medium, color: AppThemData.error07),
                        //               ),
                        //             ],
                        //           ),
                        //           const SizedBox(
                        //             height: 10,
                        //           ),
                        //           Text(
                        //             "Note : Admin commission will be debited from your wallet balance. \nAdmin commission will apply on sub total minus Discount(if applicable)."
                        //                 .tr,
                        //             style: const TextStyle(fontFamily: AppThemData.medium, color: AppThemData.error07),
                        //           )
                        //         ],
                        //       ),
                        //     ),
                        //   ),
                        // ),
                        // const SizedBox(
                        //   height: 10,
                        // ),
                      ],
                    ),
                  ),
          );
        });
  }
}
