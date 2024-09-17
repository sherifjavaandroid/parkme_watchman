import 'package:get/get.dart';
import 'package:watchman/model/parking_model.dart';
import 'package:watchman/model/user_model.dart';
import 'package:watchman/utils/fire_store_utils.dart';

class MyParkingBookingController extends GetxController {
  RxBool isLoading = true.obs;

  Rx<ParkingModel> selectedParkingModel = ParkingModel().obs;
  Rx<DateTime> selectedDateTime = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day).obs;

  Rx<UserModel> userModel = UserModel().obs;

  @override
  void onInit() {
    // TODO: implement onInit
    getData();
    super.onInit();
  }

  RxInt selectedTabIndex = 0.obs;

  getData() async {
    await FireStoreUtils.getUserProfile(FireStoreUtils.getCurrentUid()).then((value) {
      if (value != null) {
        userModel.value = value;
      }
    });

    if (userModel.value.parkingId != null) {
      await FireStoreUtils.getMyParking(parkingId: userModel.value.parkingId).then((value) {
        if (value != null) {
          selectedParkingModel.value = value;
        }
      });
    }

    isLoading.value = false;
    update();
  }
}
