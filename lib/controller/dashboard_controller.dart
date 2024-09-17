import 'package:get/get.dart';
// import 'package:watchman/ui/home/home_screen.dart';
// import 'package:watchman/ui/my_booking/my_booking_screen.dart';
import 'package:watchman/ui/parking/my_parking_booking_screen.dart';

import 'package:watchman/ui/profile/profile_screen.dart';

class DashboardScreenController extends GetxController {
  RxInt selectedIndex = 0.obs;

  RxList pageList = [
    const MyParkingBooingScreen(isBack: false),
    const ProfileScreen(),
  ].obs;
}
