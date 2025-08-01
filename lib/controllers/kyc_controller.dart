import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../models/kyc_model.dart';

class KycController extends GetxController {
  // Text Controllers
  final TextEditingController cnicController = TextEditingController();
  final TextEditingController bulkCnicController = TextEditingController();
  
  // Single CNIC verification (existing)
  final RxBool isLoading = false.obs;
  final Rx<Data?> userData = Rx<Data?>(null);
  final RxString errorMessage = ''.obs;

  // Bulk CNIC verification (new)
  final RxList<String> cnicList = <String>[].obs;
  final RxList<Data> verifiedUsersData = <Data>[].obs;
  final RxInt currentVerificationIndex = 0.obs;
  final RxBool isBulkLoading = false.obs;

  static const String apiBaseUrl = 'https://global-ml-connect-backend.vercel.app/api/person';

  // Cache to store API data and avoid repeated calls
  List<Data>? _cachedApiData;
  DateTime? _lastApiCall;
  static const Duration cacheValidityDuration = Duration(minutes: 5);

  @override
  void onClose() {
    cnicController.dispose();
    bulkCnicController.dispose();
    super.onClose();
  }

  void clearData() {
    userData.value = null;
    errorMessage.value = '';
  }

  void clearAllCnics() {
    cnicList.clear();
    verifiedUsersData.clear();
    errorMessage.value = '';
    currentVerificationIndex.value = 0;
  }

  // Original single CNIC verification method (unchanged)
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

  // Add single CNIC to bulk list
  void addSingleCnic() {
    String cnic = cnicController.text.trim();
    
    if (cnic.isEmpty) {
      _showError('Please enter a CNIC number');
      return;
    }

    // Validate CNIC format
    if (!_isValidCnic(cnic)) {
      _showError('Please enter a valid CNIC format (e.g., 12345-1234567-1)');
      return;
    }

    // Check for duplicates
    if (cnicList.contains(cnic)) {
      _showError('This CNIC is already in the list');
      return;
    }

    // Add to list
    cnicList.add(cnic);
    cnicController.clear();
    
    Get.snackbar(
      'Success',
      'CNIC added successfully',
      backgroundColor: Colors.green,
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
    );
  }

  // Add bulk CNICs
  void addBulkCnics() {
    String bulkText = bulkCnicController.text.trim();
    
    if (bulkText.isEmpty) {
      _showError('Please enter CNICs in the bulk input field');
      return;
    }

    List<String> lines = bulkText.split('\n');
    List<String> validCnics = [];
    List<String> invalidCnics = [];

    for (String line in lines) {
      String cnic = line.trim();
      if (cnic.isNotEmpty) {
        if (_isValidCnic(cnic)) {
          if (!cnicList.contains(cnic)) {
            validCnics.add(cnic);
          }
        } else {
          // Try to auto-format if it's just numbers
          String cleanCnic = cnic.replaceAll(RegExp(r'[^0-9]'), '');
          if (cleanCnic.length == 13) {
            String formattedCnic = '${cleanCnic.substring(0, 5)}-${cleanCnic.substring(5, 12)}-${cleanCnic.substring(12, 13)}';
            if (!cnicList.contains(formattedCnic)) {
              validCnics.add(formattedCnic);
            }
          } else {
            invalidCnics.add(cnic);
          }
        }
      }
    }

    // Add valid CNICs
    cnicList.addAll(validCnics);
    bulkCnicController.clear();

    // Show result
    if (validCnics.isNotEmpty) {
      Get.snackbar(
        'Success',
        'Added ${validCnics.length} valid CNICs',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
    }

    if (invalidCnics.isNotEmpty) {
      Get.snackbar(
        'Warning',
        '${invalidCnics.length} CNICs were invalid and skipped',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    }

    if (validCnics.isEmpty && invalidCnics.isEmpty) {
      _showError('No valid CNICs found');
    }
  }

  // Remove CNIC from list
  void removeCnic(int index) {
    if (index >= 0 && index < cnicList.length) {
      cnicList.removeAt(index);
    }
  }

  // Verify all CNICs in bulk
  Future<void> verifyAllCnics() async {
    if (cnicList.isEmpty) {
      _showError('Please add CNICs to verify');
      return;
    }

    isBulkLoading.value = true;
    isLoading.value = true; // For compatibility with existing UI
    errorMessage.value = '';
    verifiedUsersData.clear();
    currentVerificationIndex.value = 0;

    try {
      // Get fresh data from API or use cached data
      List<Data>? apiData = await _getApiData();
      
      if (apiData == null || apiData.isEmpty) {
        _showError('Failed to fetch data from server');
        return;
      }

      // Verify each CNIC
      for (int i = 0; i < cnicList.length; i++) {
        currentVerificationIndex.value = i;
        
        String cnicToFind = cnicList[i].replaceAll('-', ''); // Remove dashes for comparison
        
        // Find matching user in API data
        final matchedUser = apiData.firstWhereOrNull(
          (user) => user.cnic.toString() == cnicToFind,
        );

        if (matchedUser != null) {
          verifiedUsersData.add(matchedUser);
        }
        
        // Small delay to show progress
        if (i < cnicList.length - 1) {
          await Future.delayed(const Duration(milliseconds: 100));
        }
      }

      // Show results
      if (verifiedUsersData.isNotEmpty) {
        Get.snackbar(
          'Verification Complete',
          'Successfully verified ${verifiedUsersData.length} out of ${cnicList.length} CNICs',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 4),
        );
      } else {
        _showError('No matching records found for the provided CNICs');
      }

    } catch (e) {
      _showError('Verification failed: ${e.toString()}');
    } finally {
      isBulkLoading.value = false;
      isLoading.value = false;
    }
  }

  // Get API data with caching
  Future<List<Data>?> _getApiData() async {
    // Check if we have valid cached data
    if (_cachedApiData != null && 
        _lastApiCall != null && 
        DateTime.now().difference(_lastApiCall!) < cacheValidityDuration) {
      return _cachedApiData;
    }

    try {
      final response = await GetConnect().get(apiBaseUrl);

      if (response.statusCode == 200) {
        final kycModel = KYCModel.fromJson(response.body);
        
        if (kycModel.success == true && kycModel.data != null) {
          _cachedApiData = kycModel.data;
          _lastApiCall = DateTime.now();
          return _cachedApiData;
        }
      }
      
      return null;
    } catch (e) {
      print('API Error: $e');
      return null;
    }
  }

  // Validate CNIC format
  bool _isValidCnic(String cnic) {
    // Check if CNIC matches the format: 12345-1234567-1
    RegExp cnicRegex = RegExp(r'^\d{5}-\d{7}-\d{1}$');
    return cnicRegex.hasMatch(cnic);
  }

  // Show error message
  void _showError(String message) {
    errorMessage.value = message;
    Get.snackbar(
      'Error',
      message,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
    );
  }

  // Clear cache (call this if you want to force refresh)
  void clearCache() {
    _cachedApiData = null;
    _lastApiCall = null;
  }
}