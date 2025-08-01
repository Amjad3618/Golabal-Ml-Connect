import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:excel/excel.dart' hide Border;
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import 'dart:io';

// Add this import for file picker (you'll need to add file_picker to pubspec.yaml)
import 'package:file_picker/file_picker.dart';

import '../../controllers/kyc_controller.dart';
import '../../widgets/cnic_formater.dart';

class KycScreen extends StatelessWidget {
  const KycScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final KycController controller = Get.put(KycController());

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: SingleChildScrollView(
        child: Center(
          child: Container(
            width: 700, // Increased width for better layout
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 12,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Bulk KYC CNIC Verification',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.purple,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Enter multiple CNICs and verify them all at once',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 24),

                // Enhanced Multiple CNIC Input Options
                Row(
                  children: [
                    Expanded(
                      child: _buildSingleCnicInput(controller),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildBulkCnicInput(controller),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),

                // File Upload Option
                _buildFileUploadOption(controller),
                
                const SizedBox(height: 16),

                // Added CNICs Display
                Obx(() {
                  if (controller.cnicList.isNotEmpty) {
                    return _buildCnicListDisplay(controller);
                  }
                  return const SizedBox.shrink();
                }),

                const SizedBox(height: 20),

                // Control Buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: controller.cnicList.isEmpty 
                            ? null 
                            : controller.clearAllCnics,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.shade400,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        icon: const Icon(Icons.clear_all),
                        label: const Text('Clear All'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: Obx(
                        () => ElevatedButton.icon(
                          onPressed: controller.isLoading.value || controller.cnicList.isEmpty
                              ? null
                              : controller.verifyAllCnics,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.purple,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          icon: controller.isLoading.value
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                              : const Icon(Icons.verified_user, color: Colors.white),
                          label: Text(
                            controller.isLoading.value
                                ? 'Verifying ${controller.currentVerificationIndex.value + 1}/${controller.cnicList.length}...'
                                : 'Verify All CNICs (${controller.cnicList.length})',
                            style: const TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Progress Indicator
                Obx(() {
                  if (controller.isLoading.value && controller.cnicList.isNotEmpty) {
                    return Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.purple.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.purple.shade200),
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Verification Progress',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.purple.shade700,
                                    ),
                                  ),
                                  Text(
                                    '${controller.currentVerificationIndex.value + 1}/${controller.cnicList.length}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.purple.shade600,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              LinearProgressIndicator(
                                value: controller.currentVerificationIndex.value / controller.cnicList.length,
                                backgroundColor: Colors.purple.shade100,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.purple),
                                minHeight: 8,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Processing CNIC verification requests...',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.purple.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    );
                  }
                  return const SizedBox.shrink();
                }),

                // Results Display
                Obx(() {
                  if (controller.verifiedUsersData.isNotEmpty) {
                    return _buildVerificationResults(controller);
                  } else if (controller.errorMessage.value.isNotEmpty) {
                    return Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.error_outline,
                            color: Colors.red.shade600,
                            size: 24,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Verification Error',
                            style: TextStyle(
                              color: Colors.red.shade700,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            controller.errorMessage.value,
                            style: TextStyle(
                              color: Colors.red.shade600,
                              fontSize: 14,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSingleCnicInput(KycController controller) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.credit_card, color: Colors.blue.shade600, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Single CNIC Entry',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.blue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: controller.cnicController,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(13),
              CnicInputFormatter(),
            ],
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Enter CNIC',
              hintText: '12345-1234567-1',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              prefixIcon: const Icon(Icons.person, size: 20),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            onSubmitted: (value) => controller.addSingleCnic(),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: controller.addSingleCnic,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Add CNIC', style: TextStyle(fontSize: 14)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBulkCnicInput(KycController controller) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.list_alt, color: Colors.orange.shade600, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Bulk CNIC Entry',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.orange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Enter multiple CNICs (one per line)',
            style: TextStyle(
              fontSize: 12,
              color: Colors.orange.shade600,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: controller.bulkCnicController,
            maxLines: 5,
            decoration: InputDecoration(
              labelText: 'Enter Multiple CNICs',
              hintText: '12345-1234567-1\n54321-7654321-2\n98765-9876543-3\n...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              prefixIcon: const Padding(
                padding: EdgeInsets.only(bottom: 80),
                child: Icon(Icons.format_list_numbered, size: 20),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: controller.addBulkCnics,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              icon: const Icon(Icons.playlist_add, size: 18),
              label: const Text('Add All CNICs', style: TextStyle(fontSize: 14)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFileUploadOption(KycController controller) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.upload_file, color: Colors.green.shade600, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Upload CNIC File',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Upload a text file with CNICs (one per line) or Excel file',
            style: TextStyle(
              fontSize: 12,
              color: Colors.green.shade600,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _uploadCnicFile(controller),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              icon: const Icon(Icons.file_upload, size: 18),
              label: const Text('Choose File', style: TextStyle(fontSize: 14)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCnicListDisplay(KycController controller) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.list, color: Colors.grey.shade600, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'CNICs Ready for Verification (${controller.cnicList.length})',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              TextButton.icon(
                onPressed: controller.clearAllCnics,
                icon: const Icon(Icons.clear_all, size: 16),
                label: const Text('Clear All', style: TextStyle(fontSize: 12)),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            constraints: const BoxConstraints(maxHeight: 200),
            child: SingleChildScrollView(
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: controller.cnicList.asMap().entries.map((entry) {
                  int index = entry.key;
                  String cnic = entry.value;
                  return Chip(
                    label: Text(
                      cnic,
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                    ),
                    deleteIcon: const Icon(Icons.close, size: 16),
                    onDeleted: () => controller.removeCnic(index),
                    backgroundColor: Colors.white,
                    side: BorderSide(color: Colors.grey.shade400),
                    elevation: 1,
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // File upload functionality
  Future<void> _uploadCnicFile(KycController controller) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['txt', 'csv', 'xlsx'],
      );

      if (result != null) {
        File file = File(result.files.single.path!);
        String fileName = result.files.single.name.toLowerCase();
        
        List<String> cnics = [];
        
        if (fileName.endsWith('.txt') || fileName.endsWith('.csv')) {
          // Read text/CSV file
          String content = await file.readAsString();
          cnics = content
              .split('\n')
              .map((line) => line.trim())
              .where((line) => line.isNotEmpty)
              .toList();
        } else if (fileName.endsWith('.xlsx')) {
          // Read Excel file (you'll need to implement this based on your Excel package)
          Get.snackbar(
            'Info',
            'Excel file support coming soon. Please use .txt or .csv files.',
            backgroundColor: Colors.orange,
            colorText: Colors.white,
          );
          return;
        }
        
        // Validate and add CNICs
        int validCount = 0;
        for (String cnic in cnics) {
          // Basic CNIC validation
          String cleanCnic = cnic.replaceAll(RegExp(r'[^0-9]'), '');
          if (cleanCnic.length == 13) {
            // Format CNIC
            String formattedCnic = '${cleanCnic.substring(0, 5)}-${cleanCnic.substring(5, 12)}-${cleanCnic.substring(12, 13)}';
            if (!controller.cnicList.contains(formattedCnic)) {
              controller.cnicList.add(formattedCnic);
              validCount++;
            }
          }
        }
        
        Get.snackbar(
          'Success',
          'Added $validCount valid CNICs from file',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          icon: const Icon(Icons.check_circle, color: Colors.white),
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to read file: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        icon: const Icon(Icons.error, color: Colors.white),
      );
    }
  }

  Widget _buildVerificationResults(KycController controller) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.verified, color: Colors.green.shade600, size: 24),
                  const SizedBox(width: 8),
                  Text(
                    'Verification Results (${controller.verifiedUsersData.length})',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
              _buildBulkDownloadButtons(controller.verifiedUsersData),
            ],
          ),
          const SizedBox(height: 16),
          
          // Summary Stats
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatCard('Total Requested', controller.cnicList.length.toString(), Colors.blue),
                _buildStatCard('Successfully Verified', controller.verifiedUsersData.length.toString(), Colors.green),
                _buildStatCard('Failed/Not Found', (controller.cnicList.length - controller.verifiedUsersData.length).toString(), Colors.red),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Results List
          Container(
            constraints: const BoxConstraints(maxHeight: 450),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: controller.verifiedUsersData.length,
              itemBuilder: (context, index) {
                final user = controller.verifiedUsersData[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  elevation: 2,
                  child: ExpansionTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.green.shade100,
                      child: Text(
                        '${index + 1}',
                        style: TextStyle(
                          color: Colors.green.shade700,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(
                      user.name ?? 'Unknown',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text('CNIC: ${user.cnic ?? 'N/A'}'),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            _buildInfoRow('Father Name', user.fatherName ?? 'N/A'),
                            _buildInfoRow('Date of Birth', _formatDateOfBirth(user.dob)),
                            _buildInfoRow('City', user.city ?? 'N/A'),
                            _buildInfoRow('State', user.state ?? 'N/A'),
                            _buildInfoRow('Address', user.address ?? 'N/A'),
                            _buildInfoRow('Criminal Record', user.criminalRecord ?? 'N/A'),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildBulkDownloadButtons(List<dynamic> usersData) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ElevatedButton.icon(
          onPressed: () => _downloadBulkPDF(usersData),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red.shade600,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          icon: const Icon(Icons.picture_as_pdf, size: 16),
          label: const Text('PDF', style: TextStyle(fontSize: 12)),
        ),
        const SizedBox(width: 8),
        ElevatedButton.icon(
          onPressed: () => _downloadBulkExcel(usersData),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green.shade600,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          icon: const Icon(Icons.table_chart, size: 16),
          label: const Text('Excel', style: TextStyle(fontSize: 12)),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.black54),
            ),
          ),
        ],
      ),
    );
  }

  // Method to get Downloads directory across different platforms
  Future<Directory> _getDownloadsDirectory() async {
    Directory? directory;
    
    if (Platform.isWindows) {
      String? userProfile = Platform.environment['USERPROFILE'];
      if (userProfile != null) {
        directory = Directory('$userProfile\\Downloads');
      }
    } else if (Platform.isMacOS) {
      try {
        directory = await getDownloadsDirectory();
      } catch (e) {
        String? home = Platform.environment['HOME'];
        if (home != null) {
          directory = Directory('$home/Downloads');
        }
      }
    } else if (Platform.isLinux) {
      String? home = Platform.environment['HOME'];
      if (home != null) {
        directory = Directory('$home/Downloads');
      }
    }
    
    directory ??= await getApplicationDocumentsDirectory();
    
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }
    
    return directory;
  }

  Future<String?> _pickSaveLocation(String fileName) async {
    try {
      String? outputFile = await FilePicker.platform.saveFile(
        dialogTitle: 'Please select where to save the file:',
        fileName: fileName,
      );
      return outputFile;
    } catch (e) {
      print('Error picking save location: $e');
      return null;
    }
  }

  Future<void> _downloadBulkPDF(List<dynamic> usersData) async {
    try {
      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      final pdf = pw.Document();
      
      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return [
              pw.Header(
                level: 0,
                child: pw.Text(
                  'Bulk KYC CNIC Verification Report',
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.SizedBox(height: 20),
              pw.Text(
                'Generated on: ${DateFormat('dd MMMM yyyy, hh:mm a').format(DateTime.now())}',
                style: const pw.TextStyle(fontSize: 12),
              ),
              pw.Text(
                'Total Records: ${usersData.length}',
                style: const pw.TextStyle(fontSize: 12),
              ),
              pw.SizedBox(height: 20),
              
              // Summary Table
              pw.Table(
                border: pw.TableBorder.all(),
                children: [
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(color: PdfColors.grey300),
                    children: [
                      pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('Name', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                      pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('CNIC', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                      pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('Father Name', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                      pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('City', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                    ],
                  ),
                  ...usersData.map((user) => pw.TableRow(
                    children: [
                      pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text(user.name ?? 'N/A')),
                      pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text(user.cnic?.toString() ?? 'N/A')),
                      pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text(user.fatherName ?? 'N/A')),
                      pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text(user.city ?? 'N/A')),
                    ],
                  )).toList(),
                ],
              ),
              
              pw.SizedBox(height: 30),
              
              // Detailed Information
              pw.Text(
                'Detailed Information',
                style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 10),
              
              ...usersData.asMap().entries.map((entry) {
                int index = entry.key;
                dynamic user = entry.value;
                return pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      '${index + 1}. ${user.name ?? 'Unknown'}',
                      style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
                    ),
                    pw.SizedBox(height: 8),
                    pw.Table(
                      border: pw.TableBorder.all(),
                      children: [
                        _buildPdfTableRow('Name', user.name ?? 'N/A'),
                        _buildPdfTableRow('Father Name', user.fatherName ?? 'N/A'),
                        _buildPdfTableRow('CNIC', user.cnic?.toString() ?? 'N/A'),
                        _buildPdfTableRow('Date of Birth', _formatDateOfBirth(user.dob)),
                        _buildPdfTableRow('City', user.city ?? 'N/A'),
                        _buildPdfTableRow('State', user.state ?? 'N/A'),
                        _buildPdfTableRow('Address', user.address ?? 'N/A'),
                        _buildPdfTableRow('Criminal Record', user.criminalRecord ?? 'N/A'),
                      ],
                    ),
                    pw.SizedBox(height: 20),
                  ],
                );
              }).toList(),
            ];
          },
        ),
      );

      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final fileName = 'Bulk_KYC_Report_$timestamp.pdf';

      try {
        final directory = await _getDownloadsDirectory();
        final file = File('${directory.path}${Platform.pathSeparator}$fileName');
        await file.writeAsBytes(await pdf.save());
        
        Get.back();
        
        Get.snackbar(
          'Success',
          'Bulk PDF saved successfully to: ${file.path}',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          icon: const Icon(Icons.check_circle, color: Colors.white),
          duration: const Duration(seconds: 4),
        );
        
        _showOpenLocationDialog(file.path);
        
      } catch (e) {
        Get.back();
        
        final savedPath = await _pickSaveLocation(fileName);
        if (savedPath != null) {
          final file = File(savedPath);
          await file.writeAsBytes(await pdf.save());
          
          Get.snackbar(
            'Success',
            'Bulk PDF saved successfully to: $savedPath',
            backgroundColor: Colors.green,
            colorText: Colors.white,
            icon: const Icon(Icons.check_circle, color: Colors.white),
            duration: const Duration(seconds: 4),
          );
        }
      }
    } catch (e) {
      Get.back();
      Get.snackbar(
        'Error',
        'Failed to download bulk PDF: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        icon: const Icon(Icons.error, color: Colors.white),
      );
    }
  }

  pw.TableRow _buildPdfTableRow(String label, String value) {
    return pw.TableRow(
      children: [
        pw.Padding(
          padding: const pw.EdgeInsets.all(8),
          child: pw.Text(
            label,
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          ),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.all(8),
          child: pw.Text(value),
        ),
      ],
    );
  }

  Future<void> _downloadBulkExcel(List<dynamic> usersData) async {
    try {
      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      var excel = Excel.createExcel();
      Sheet sheetObject = excel['Bulk KYC Report'];

      // Add headers
      final headers = ['Sr.', 'Name', 'Father Name', 'CNIC', 'Date of Birth', 'City', 'State', 'Address', 'Criminal Record'];
      for (int i = 0; i < headers.length; i++) {
        sheetObject.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0)).value = TextCellValue(headers[i]);
        sheetObject.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0)).cellStyle = CellStyle(bold: true);
      }

      // Add data
      for (int i = 0; i < usersData.length; i++) {
        final user = usersData[i];
        final rowData = [
          (i + 1).toString(),
          user.name ?? 'N/A',
          user.fatherName ?? 'N/A',
          user.cnic?.toString() ?? 'N/A',
          _formatDateOfBirth(user.dob),
          user.city ?? 'N/A',
          user.state ?? 'N/A',
          user.address ?? 'N/A',
          user.criminalRecord ?? 'N/A',
        ];

        for (int j = 0; j < rowData.length; j++) {
          sheetObject.cell(CellIndex.indexByColumnRow(columnIndex: j, rowIndex: i + 1)).value = TextCellValue(rowData[j]);
        }
      }

      // Add summary sheet
      Sheet summarySheet = excel['Summary'];
      summarySheet.cell(CellIndex.indexByString("A1")).value = TextCellValue('Bulk KYC Verification Summary');
      summarySheet.cell(CellIndex.indexByString("A1")).cellStyle = CellStyle(bold: true);
      summarySheet.cell(CellIndex.indexByString("A3")).value = TextCellValue('Total Records Verified');
      summarySheet.cell(CellIndex.indexByString("B3")).value = TextCellValue(usersData.length.toString());
      summarySheet.cell(CellIndex.indexByString("A4")).value = TextCellValue('Generated On');
      summarySheet.cell(CellIndex.indexByString("B4")).value = TextCellValue(DateFormat('dd MMMM yyyy, hh:mm a').format(DateTime.now()));

      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final fileName = 'Bulk_KYC_Report_$timestamp.xlsx';

      try {
        final directory = await _getDownloadsDirectory();
        final file = File('${directory.path}${Platform.pathSeparator}$fileName');
        await file.writeAsBytes(excel.encode()!);
        
        Get.back();
        
        Get.snackbar(
          'Success',
          'Bulk Excel file saved successfully to: ${file.path}',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          icon: const Icon(Icons.check_circle, color: Colors.white),
          duration: const Duration(seconds: 4),
        );
        
        _showOpenLocationDialog(file.path);
        
      } catch (e) {
        Get.back();
        
        final savedPath = await _pickSaveLocation(fileName);
        if (savedPath != null) {
          final file = File(savedPath);
          await file.writeAsBytes(excel.encode()!);
          
          Get.snackbar(
            'Success',
            'Bulk Excel file saved successfully to: $savedPath',
            backgroundColor: Colors.green,
            colorText: Colors.white,
            icon: const Icon(Icons.check_circle, color: Colors.white),
            duration: const Duration(seconds: 4),
          );
        }
      }
    } catch (e) {
      Get.back();
      Get.snackbar(
        'Error',
        'Failed to download bulk Excel: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        icon: const Icon(Icons.error, color: Colors.white),
      );
    }
  }

  void _showOpenLocationDialog(String filePath) {
    Get.dialog(
      AlertDialog(
        title: const Text('File Saved Successfully'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Your file has been saved to:'),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(4),
              ),
              child: SelectableText(
                filePath,
                style: const TextStyle(fontSize: 12),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('OK'),
          ),
          if (Platform.isWindows || Platform.isMacOS || Platform.isLinux)
            ElevatedButton(
              onPressed: () {
                // Open file location - you might want to implement this
                Get.back();
              },
              child: const Text('Open Location'),
            ),
        ],
      ),
    );
  }

  String _formatDateOfBirth(dynamic dob) {
    if (dob == null) return 'N/A';
    
    try {
      if (dob is String) {
        // Try to parse different date formats
        DateTime? dateTime;
        
        // Try common formats
        List<String> formats = [
          'yyyy-MM-dd',
          'dd/MM/yyyy',
          'MM/dd/yyyy',
          'dd-MM-yyyy',
          'yyyy/MM/dd',
        ];
        
        for (String format in formats) {
          try {
            dateTime = DateFormat(format).parse(dob);
            break;
          } catch (e) {
            continue;
          }
        }
        
        if (dateTime != null) {
          return DateFormat('dd MMM yyyy').format(dateTime);
        }
        
        return dob; // Return original if can't parse
      } else if (dob is DateTime) {
        return DateFormat('dd MMM yyyy').format(dob);
      }
      
      return dob.toString();
    } catch (e) {
      return dob.toString();
    }
  }
}