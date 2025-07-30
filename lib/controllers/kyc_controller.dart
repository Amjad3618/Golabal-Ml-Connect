import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../models/kyc_model.dart';

class KycController extends GetxController {
  final TextEditingController cnicController = TextEditingController();
  
  final RxBool isLoading = false.obs;
  final Rx<Data?> userData = Rx<Data?>(null);
  final RxString errorMessage = ''.obs;

  static const String apiBaseUrl = 'https://global-ml-connect-backend.vercel.app/api/person';

  @override
  void onClose() {
    cnicController.dispose();
    super.onClose();
  }

  void clearData() {
    userData.value = null;
    errorMessage.value = '';
  }

  Future<void> verifyCnic() async {
    final cnic = cnicController.text.replaceAll('-', ''); // Remove dashes
    
    if (cnic.length != 13) {
      Get.snackbar(
        'Invalid CNIC',
        'Please enter a valid 13-digit CNIC number',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    try {
      isLoading.value = true;
      clearData();

      final response = await GetConnect().get(apiBaseUrl);

      if (response.statusCode == 200) {
        final kycModel = KYCModel.fromJson(response.body);
        
        if (kycModel.success == true && kycModel.data != null) {
          // Find user with matching CNIC
          final matchedUser = kycModel.data!.firstWhereOrNull(
            (user) => user.cnic.toString() == cnic,
          );

          if (matchedUser != null) {
            userData.value = matchedUser;
            Get.snackbar(
              'Success',
              'User data found successfully!',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.green,
              colorText: Colors.white,
            );
          } else {
            errorMessage.value = 'No user found with this CNIC number';
            Get.snackbar(
              'Not Found',
              'No user found with this CNIC number',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.orange,
              colorText: Colors.white,
            );
          }
        } else {
          errorMessage.value = 'Failed to fetch data from server';
        }
      } else {
        errorMessage.value = 'Server error: ${response.statusCode}';
      }
    } catch (e) {
      errorMessage.value = 'Network error: ${e.toString()}';
      Get.snackbar(
        'Error',
        'Network error occurred. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }
}