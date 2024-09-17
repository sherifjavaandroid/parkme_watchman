import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:date_picker_timeline/date_picker_timeline.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:watchman/constant/collection_name.dart';
import 'package:watchman/constant/constant.dart';
import 'package:watchman/constant/show_toast_dialog.dart';
import 'package:watchman/controller/my_parking_booking_controller.dart';
import 'package:watchman/model/order_model.dart';
import 'package:watchman/themes/app_them_data.dart';
import 'package:watchman/themes/common_ui.dart';
import 'package:watchman/themes/round_button_fill.dart';
import 'package:watchman/ui/parking/my_summery_screen.dart';
import 'package:watchman/ui/qr_code_scan_screen/qr_code_scan_screen.dart';
import 'package:watchman/utils/dark_theme_provider.dart';
import 'package:watchman/utils/fire_store_utils.dart';

class MyParkingBooingScreen extends StatelessWidget {
  final bool isBack;

  const MyParkingBooingScreen({required this.isBack, super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return GetX(
        init: MyParkingBookingController(),
        builder: (controller) {
          return Scaffold(
            appBar: UiInterface().customAppBar(
              isBack: isBack,
              context,
              themeChange,
              controller.selectedParkingModel.value.id != null ? controller.selectedParkingModel.value.name.toString().tr : "My Booking List".tr,
              actions: [
                InkWell(
                  onTap: () {
                    Get.to(const QrCodeScanScreen());
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: Icon(Icons.qr_code_scanner, color: themeChange.getThem() ? AppThemData.grey01 : AppThemData.grey08),
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
              ],
            ),
            body: controller.isLoading.value
                ? Constant.loader()
                : controller.selectedParkingModel.value.id == null
                    ? Constant.showEmptyView(message: "Parking not assign please contact to parking owner.")
                    : DefaultTabController(
                        length: 3,
                        child: Column(
                          children: [
                            Container(
                              color: themeChange.getThem() ? AppThemData.grey09 : AppThemData.white,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Text(
                                    //   "Your Parking : ${controller.selectedParkingModel.value.name.toString().tr}",
                                    //   textAlign: TextAlign.center,
                                    //   style: TextStyle(
                                    //     color: themeChange.getThem() ? AppThemData.grey01 : AppThemData.grey10,
                                    //     fontSize: 20,
                                    //     fontFamily: AppThemData.semiBold,
                                    //     fontWeight: FontWeight.w400,
                                    //   ),
                                    // ),
                                    // const SizedBox(
                                    //   height: 10,
                                    // ),
                                    DatePicker(
                                      DateTime.now(),
                                      height: 95,
                                      width: 76,
                                      initialSelectedDate: controller.selectedDateTime.value,
                                      selectionColor: AppThemData.primary07,
                                      selectedTextColor: AppThemData.primary11,
                                      onDateChange: (date) {
                                        controller.selectedDateTime.value = date;
                                      },
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    TabBar(
                                      onTap: (value) {
                                        controller.selectedTabIndex.value = value;
                                        controller.update();
                                      },
                                      labelStyle: const TextStyle(fontFamily: AppThemData.semiBold),
                                      labelColor: themeChange.getThem() ? AppThemData.primary06 : AppThemData.grey10,
                                      unselectedLabelStyle: const TextStyle(fontFamily: AppThemData.medium),
                                      unselectedLabelColor: themeChange.getThem() ? AppThemData.grey11 : AppThemData.grey06,
                                      indicatorColor: AppThemData.primary06,
                                      indicatorWeight: 1,
                                      tabs: [
                                        Tab(
                                          text: "ongoing".tr,
                                        ),
                                        Tab(
                                          text: "completed".tr,
                                        ),
                                        Tab(
                                          text: "canceled".tr,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Expanded(
                              child: TabBarView(
                                children: [
                                  StreamBuilder<QuerySnapshot>(
                                    stream: FirebaseFirestore.instance
                                        .collection(CollectionName.bookedParkingOrder)
                                        .where('status', whereIn: [Constant.placed, Constant.onGoing])
                                        .where('bookingDate', isEqualTo: Timestamp.fromDate(controller.selectedDateTime.value))
                                        .where('parkingId', isEqualTo: controller.selectedParkingModel.value.id)
                                        .orderBy('createdAt', descending: true)
                                        .snapshots(),
                                    builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                                      if (snapshot.hasError) {
                                        return Center(child: Text('Something went wrong'.tr));
                                      }
                                      if (snapshot.connectionState == ConnectionState.waiting) {
                                        return Constant.loader();
                                      }
                                      return snapshot.data!.docs.isEmpty
                                          ? Constant.showEmptyView(message: "No active rides found".tr)
                                          : ListView.builder(
                                              itemCount: snapshot.data!.docs.length,
                                              scrollDirection: Axis.vertical,
                                              shrinkWrap: true,
                                              itemBuilder: (context, index) {
                                                OrderModel orderModel = OrderModel.fromJson(snapshot.data!.docs[index].data() as Map<String, dynamic>);
                                                print(orderModel.bookingDate!.toDate());
                                                return Padding(
                                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                                  child: Container(
                                                    padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
                                                    decoration: BoxDecoration(
                                                      borderRadius: BorderRadius.circular(12),
                                                      color: themeChange.getThem() ? AppThemData.grey10 : AppThemData.white,
                                                    ),
                                                    child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Row(
                                                          children: [
                                                            Expanded(
                                                              child: Text(
                                                                "ID: ${orderModel.id}".tr,
                                                                style: TextStyle(
                                                                    fontSize: 14,
                                                                    fontFamily: AppThemData.semiBold,
                                                                    color: themeChange.getThem() ? AppThemData.grey01 : AppThemData.grey08),
                                                              ),
                                                            ),
                                                            Visibility(
                                                              visible: orderModel.status == Constant.placed,
                                                              child: InkWell(
                                                                onTap: () {
                                                                  Get.to(QrCodeScanScreen(
                                                                    orderId: orderModel.id,
                                                                  ));
                                                                },
                                                                child: Padding(
                                                                  padding: const EdgeInsets.only(right: 10),
                                                                  child: Icon(Icons.qr_code_scanner, color: themeChange.getThem() ? AppThemData.blueLight : AppThemData.blueLight),
                                                                ),
                                                              ),
                                                            )
                                                          ],
                                                        ),
                                                        const SizedBox(
                                                          height: 10,
                                                        ),
                                                        const Divider(thickness: 1, color: AppThemData.grey04),
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
                                                                        Constant.timestampToDate(orderModel.bookingDate!),
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
                                                                        "${Constant.timestampToTime(orderModel.bookingStartTime!)} - ${Constant.timestampToTime(orderModel.bookingEndTime!)}",
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
                                                                        orderModel.parkingSlotId.toString(),
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
                                                                        orderModel.userVehicle!.vehicleModel!.name.toString(),
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
                                                                        "${orderModel.duration.toString()} hours".tr,
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
                                                        ),
                                                        const SizedBox(
                                                          height: 12,
                                                        ),
                                                        Row(
                                                          children: [
                                                            Expanded(
                                                              child: RoundedButtonFill(
                                                                title: "Summary".tr,
                                                                color: AppThemData.primary06,
                                                                height: 5.5,
                                                                onPress: () {
                                                                  Get.to(() => const MySummaryScreen(), arguments: {"orderModel": orderModel});
                                                                },
                                                              ),
                                                            ),
                                                            const SizedBox(
                                                              width: 10,
                                                            ),
                                                            orderModel.status == Constant.onGoing
                                                                ? Expanded(
                                                                    child: RoundedButtonFill(
                                                                    title: "Mark as Completed".tr,
                                                                    color: themeChange.getThem() ? AppThemData.grey09 : AppThemData.grey03,
                                                                    height: 5.5,
                                                                    onPress: () async {
                                                                      ShowToastDialog.showLoader("Please wait".tr);
                                                                      orderModel.status = Constant.completed;
                                                                      await FireStoreUtils.setOrder(orderModel).then((value) {
                                                                        ShowToastDialog.closeLoader();
                                                                      });
                                                                    },
                                                                  ))
                                                                : Container()
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                );
                                              });
                                    },
                                  ),
                                  StreamBuilder<QuerySnapshot>(
                                    stream: FirebaseFirestore.instance
                                        .collection(CollectionName.bookedParkingOrder)
                                        .where('status', whereIn: [Constant.completed])
                                        .where('bookingDate', isEqualTo: Timestamp.fromDate(controller.selectedDateTime.value))
                                        .where('parkingId', isEqualTo: controller.selectedParkingModel.value.id.toString())
                                        .orderBy("createdAt", descending: true)
                                        .snapshots(),
                                    builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                                      if (snapshot.hasError) {
                                        return Center(child: Text('Something went wrong'.tr));
                                      }
                                      if (snapshot.connectionState == ConnectionState.waiting) {
                                        return Constant.loader();
                                      }
                                      return snapshot.data!.docs.isEmpty
                                          ? Constant.showEmptyView(message: "No Completed Booking Found")
                                          : ListView.builder(
                                              itemCount: snapshot.data!.docs.length,
                                              scrollDirection: Axis.vertical,
                                              shrinkWrap: true,
                                              padding: EdgeInsets.zero,
                                              itemBuilder: (context, index) {
                                                OrderModel orderModel = OrderModel.fromJson(snapshot.data!.docs[index].data() as Map<String, dynamic>);
                                                return Padding(
                                                  padding: const EdgeInsets.all(8.0),
                                                  child: Container(
                                                    padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
                                                    decoration: BoxDecoration(
                                                      borderRadius: BorderRadius.circular(12),
                                                      color: themeChange.getThem() ? AppThemData.grey10 : AppThemData.white,
                                                    ),
                                                    child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Row(
                                                          children: [
                                                            Expanded(
                                                              child: Text(
                                                                "ID: ${orderModel.id}".tr,
                                                                style: TextStyle(
                                                                    fontSize: 14,
                                                                    fontFamily: AppThemData.semiBold,
                                                                    color: themeChange.getThem() ? AppThemData.grey01 : AppThemData.grey08),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        const SizedBox(
                                                          height: 10,
                                                        ),
                                                        const Divider(thickness: 1, color: AppThemData.grey04),
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
                                                                    children: [
                                                                      Text(
                                                                        Constant.timestampToDate(orderModel.bookingDate!),
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
                                                                        "${Constant.timestampToTime(orderModel.bookingStartTime!)} - ${Constant.timestampToTime(orderModel.bookingEndTime!)}",
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
                                                                        orderModel.parkingSlotId.toString(),
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
                                                                        orderModel.userVehicle!.vehicleModel!.name.toString(),
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
                                                                        "${orderModel.duration.toString()} hours".tr,
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
                                                        ),
                                                        const SizedBox(
                                                          height: 20,
                                                        ),
                                                        RoundedButtonFill(
                                                          title: "Summary".tr,
                                                          color: AppThemData.primary06,
                                                          height: 5.5,
                                                          onPress: () {
                                                            Get.to(() => const MySummaryScreen(), arguments: {"orderModel": orderModel});
                                                          },
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                );
                                              });
                                    },
                                  ),
                                  StreamBuilder<QuerySnapshot>(
                                    stream: FirebaseFirestore.instance
                                        .collection(CollectionName.bookedParkingOrder)
                                        .where('status', whereIn: [Constant.canceled])
                                        .where('bookingDate', isEqualTo: Timestamp.fromDate(controller.selectedDateTime.value))
                                        .where('parkingId', isEqualTo: controller.selectedParkingModel.value.id.toString())
                                        .orderBy("createdAt", descending: true)
                                        .snapshots(),
                                    builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                                      if (snapshot.hasError) {
                                        return Center(child: Text('Something went wrong'.tr));
                                      }
                                      if (snapshot.connectionState == ConnectionState.waiting) {
                                        return Constant.loader();
                                      }
                                      return snapshot.data!.docs.isEmpty
                                          ? Constant.showEmptyView(message: "No Canceled Booking Found")
                                          : ListView.builder(
                                              itemCount: snapshot.data!.docs.length,
                                              scrollDirection: Axis.vertical,
                                              shrinkWrap: true,
                                              itemBuilder: (context, index) {
                                                OrderModel orderModel = OrderModel.fromJson(snapshot.data!.docs[index].data() as Map<String, dynamic>);
                                                return Padding(
                                                  padding: const EdgeInsets.all(8.0),
                                                  child: Container(
                                                    padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
                                                    decoration: BoxDecoration(
                                                      borderRadius: BorderRadius.circular(12),
                                                      color: themeChange.getThem() ? AppThemData.grey10 : AppThemData.white,
                                                    ),
                                                    child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Row(
                                                          children: [
                                                            Expanded(
                                                              child: Text(
                                                                "ID: ${orderModel.id}".tr,
                                                                style: TextStyle(
                                                                    fontSize: 14,
                                                                    fontFamily: AppThemData.semiBold,
                                                                    color: themeChange.getThem() ? AppThemData.grey01 : AppThemData.grey08),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        const SizedBox(
                                                          height: 10,
                                                        ),
                                                        const Divider(thickness: 1, color: AppThemData.grey04),
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
                                                                    children: [
                                                                      Text(
                                                                        Constant.timestampToDate(orderModel.bookingDate!),
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
                                                                        "${Constant.timestampToTime(orderModel.bookingStartTime!)} - ${Constant.timestampToTime(orderModel.bookingEndTime!)}",
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
                                                                        orderModel.parkingSlotId.toString(),
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
                                                                        orderModel.userVehicle!.vehicleModel!.name.toString(),
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
                                                                        "${orderModel.duration.toString()} hours".tr,
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
                                                );
                                              });
                                    },
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
          );
        });
  }
}
