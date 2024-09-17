import 'dart:async';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:watchman/constant/collection_name.dart';
import 'package:watchman/constant/constant.dart';
import 'package:watchman/model/admin_commission.dart';
import 'package:watchman/model/faq_model.dart';
import 'package:watchman/model/language_model.dart';
import 'package:watchman/model/on_boarding_model.dart';
import 'package:watchman/model/order_model.dart';
import 'package:watchman/model/parking_model.dart';
import 'package:watchman/model/review_model.dart';
import 'package:watchman/model/user_model.dart';

class FireStoreUtils {
  static FirebaseFirestore fireStore = FirebaseFirestore.instance;

  static String getCurrentUid() {
    return FirebaseAuth.instance.currentUser!.uid;
  }

  static Future<bool> isLogin() async {
    bool isLogin = false;
    if (FirebaseAuth.instance.currentUser != null) {
      isLogin = await userExistOrNot(FirebaseAuth.instance.currentUser!.uid);
    } else {
      isLogin = false;
    }
    return isLogin;
  }

  static Future<bool> userExistOrNot(String uid) async {
    bool isExist = false;

    await fireStore.collection(CollectionName.users).doc(uid).get().then(
      (value) {
        if (value.exists) {
          isExist = true;
        } else {
          isExist = false;
        }
      },
    ).catchError((error) {
      log("Failed to check user exist: $error");
      isExist = false;
    });
    return isExist;
  }

  static Future<List<OnBoardingModel>> getOnBoardingList() async {
    List<OnBoardingModel> onBoardingModel = [];
    await fireStore.collection(CollectionName.onBoarding).get().then((value) {
      for (var element in value.docs) {
        OnBoardingModel documentModel = OnBoardingModel.fromJson(element.data());
        onBoardingModel.add(documentModel);
      }
    }).catchError((error) {
      log(error.toString());
    });
    return onBoardingModel;
  }

  static Future<bool> updateWatchmen(UserModel watchModel) async {
    bool isUpdate = false;
    await fireStore.collection(CollectionName.users).doc(watchModel.id).set(watchModel.toJson()).whenComplete(() {
      isUpdate = true;
    }).catchError((error) {
      log("Failed to update user: $error");
      isUpdate = false;
    });
    return isUpdate;
  }

  static Future<UserModel?> getUserProfile(String uuid) async {
    UserModel? userModel;
    await fireStore.collection(CollectionName.users).doc(uuid).get().then((value) {
      if (value.exists) {
        userModel = UserModel.fromJson(value.data()!);
      }
    }).catchError((error) {
      log("Failed to update user: $error");
      userModel = null;
    });
    return userModel;
  }

  static Future<UserModel?> getOwnerProfile(String uuid) async {
    UserModel? userModel;
    await fireStore.collection(CollectionName.users).doc(uuid).get().then((value) {
      if (value.exists) {
        userModel = UserModel.fromJson(value.data()!);
      }
    }).catchError((error) {
      log("Failed to update user: $error");
      userModel = null;
    });
    return userModel;
  }

  static Future<UserModel?> getWatchMen(String uuid) async {
    UserModel? userModel;
    await fireStore.collection(CollectionName.users).doc(uuid).get().then((value) {
      if (value.exists) {
        userModel = UserModel.fromJson(value.data()!);
      }
    }).catchError((error) {
      log("Failed to update user: $error");
      userModel = null;
    });
    return userModel;
  }

  static Future<List<LanguageModel>?> getLanguage() async {
    List<LanguageModel> languageList = [];

    await fireStore.collection(CollectionName.languages).get().then((value) {
      for (var element in value.docs) {
        LanguageModel taxModel = LanguageModel.fromJson(element.data());
        languageList.add(taxModel);
      }
    }).catchError((error) {
      log(error.toString());
    });
    return languageList;
  }

  static Future<bool?> deleteUser() async {
    bool? isDelete;
    try {
      await fireStore.collection(CollectionName.users).doc(FireStoreUtils.getCurrentUid()).delete();

      // delete user  from firebase auth
      await FirebaseAuth.instance.currentUser!.delete().then((value) {
        isDelete = true;
      });
    } catch (e, s) {
      log('FireStoreUtils.firebaseCreateNewUser $e $s');
      return false;
    }
    return isDelete;
  }

  getSettings() async {
    fireStore.collection(CollectionName.settings).doc("globalKey").snapshots().listen((event) {
      if (event.exists) {
        Constant.mapAPIKey = event.data()!["googleMapKey"];
        Constant.radius = event.data()!["radius"];
        Constant.distanceType = event.data()!["distanceType"];
      }
    });

    await fireStore.collection(CollectionName.settings).doc("notification_setting").get().then((value) {
      if (value.exists) {
        Constant.senderId = value.data()!['senderId'].toString();
        Constant.jsonNotificationFileURL = value.data()!['serviceJson'].toString();
      }
    });


    await fireStore.collection(CollectionName.settings).doc("global").get().then((value) {
      if (value.exists) {
        Constant.termsAndConditions = value.data()!["termsAndConditions"];
        Constant.privacyPolicy = value.data()!["privacyPolicy"];
        Constant.minimumAmountToDeposit = value.data()!["minimumAmountToDeposit"];
        Constant.minimumAmountToWithdrawal = value.data()!["minimumAmountToWithdrawal"];
        Constant.mapType = value.data()!["mapType"];
      }
    });

    await fireStore.collection(CollectionName.settings).doc("referral").get().then((value) {
      if (value.exists) {
        Constant.referralAmount = value.data()!["referralAmount"];
      }
    });

    await fireStore.collection(CollectionName.settings).doc("contact_us").get().then((value) {
      if (value.exists) {
        Constant.supportURL = value.data()!["supportURL"];
      }
    });

    await fireStore.collection(CollectionName.settings).doc("adminCommission").get().then((value) {
      Constant.adminCommission = AdminCommission.fromJson(value.data()!);
    });
  }

  static Future<OrderModel?> getSingleOrder(String orderId) async {
    OrderModel? orderModel;
    await fireStore.collection(CollectionName.bookedParkingOrder).doc(orderId).get().then((value) {
      if (value.exists) {
        orderModel = OrderModel.fromJson(value.data()!);
      }
    }).catchError((error) {
      log("Failed to update user: $error");
      orderModel = null;
    });
    return orderModel;
  }

  static Future<ParkingModel?> getMyParking({parkingId}) async {
    ParkingModel? parkingModel;
    await fireStore.collection(CollectionName.parking).doc(parkingId).get().then((value) async {
      parkingModel = ParkingModel.fromJson(value.data()!);
    });
    return parkingModel;
  }

  static Future<bool?> setOrder(OrderModel orderModel) async {
    bool isAdded = false;
    await fireStore.collection(CollectionName.bookedParkingOrder).doc(orderModel.id).set(orderModel.toJson()).then((value) {
      isAdded = true;
    }).catchError((error) {
      log("Failed to update user: $error");
      isAdded = false;
    });
    return isAdded;
  }

  static Future<List<FaqModel>> getFaq() async {
    List<FaqModel> faqModel = [];
    await fireStore.collection(CollectionName.faq).where('enable', isEqualTo: true).get().then((value) {
      for (var element in value.docs) {
        FaqModel documentModel = FaqModel.fromJson(element.data());
        faqModel.add(documentModel);
      }
    }).catchError((error) {
      log(error.toString());
    });
    return faqModel;
  }

  static Future<ReviewModel?> getReview(String orderId) async {
    ReviewModel? reviewModel;
    await fireStore.collection(CollectionName.review).doc(orderId).get().then((value) {
      if (value.data() != null) {
        reviewModel = ReviewModel.fromJson(value.data()!);
      }
    });
    return reviewModel;
  }
}
