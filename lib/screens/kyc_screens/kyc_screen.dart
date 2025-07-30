import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:excel/excel.dart' hide Border;
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import 'dart:io';

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
            width: 400,
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
                  'KYC CNIC Verification',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.purple,
                  ),
                ),
                const SizedBox(height: 20),

                // CNIC Input Field
                TextField(
                  controller: controller.cnicController,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(13),
                    CnicInputFormatter(),
                  ],
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Enter CNIC Number',
                    hintText: '12345-1234567-1',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: const Icon(Icons.credit_card),
                  ),
                ),
                const SizedBox(height: 20),

                // Verify Button
                Obx(
                  () => ElevatedButton.icon(
                    onPressed: controller.isLoading.value
                        ? null
                        : controller.verifyCnic,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    icon: controller.isLoading.value
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : const Icon(Icons.search, color: Colors.white),
                    label: Text(
                      controller.isLoading.value
                          ? 'Verifying...'
                          : 'Verify Now',
                      style: const TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // User Data Display
                Obx(() {
                  if (controller.userData.value != null) {
                    final user = controller.userData.value!;
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
                          const Text(
                            'User Information',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _buildInfoRow('Name', user.name ?? 'N/A'),
                          _buildInfoRow(
                            'Father Name',
                            user.fatherName ?? 'N/A',
                          ),
                          _buildInfoRow('CNIC', user.cnic?.toString() ?? 'N/A'),
                          _buildInfoRow('Date of Birth', _formatDateOfBirth(user.dob)),
                          _buildInfoRow('City', user.city ?? 'N/A'),
                          _buildInfoRow('State', user.state ?? 'N/A'),
                          _buildInfoRow('Address', user.address ?? 'N/A'),
                          _buildInfoRow(
                            'Criminal Record',
                            user.criminalRecord ?? 'N/A',
                          ),
                          const SizedBox(height: 16),
                          
                          // Professional Download Buttons
                          _buildDownloadButtons(user),
                        ],
                      ),
                    );
                  } else if (controller.errorMessage.value.isNotEmpty) {
                    return Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: Text(
                        controller.errorMessage.value,
                        style: TextStyle(
                          color: Colors.red.shade700,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
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

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(color: Colors.black54)),
          ),
        ],
      ),
    );
  }

  String _formatDateOfBirth(String? dob) {
    if (dob == null || dob.isEmpty || dob == 'N/A') {
      return 'N/A';
    }
    
    try {
      // Try different date formats
      DateTime date;
      if (dob.contains('-')) {
        date = DateTime.parse(dob);
      } else if (dob.contains('/')) {
        date = DateFormat('dd/MM/yyyy').parse(dob);
      } else {
        return dob; // Return original if format is unknown
      }
      
      return DateFormat('dd MMMM yyyy').format(date);
    } catch (e) {
      return dob; // Return original if parsing fails
    }
  }

  Widget _buildDownloadButtons(dynamic user) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Export Options',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _downloadPDF(user),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade600,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  icon: const Icon(Icons.picture_as_pdf, size: 18),
                  label: const Text(
                    'PDF',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _downloadExcel(user),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade600,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  icon: const Icon(Icons.table_chart, size: 18),
                  label: const Text(
                    'Excel',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _downloadPDF(dynamic user) async {
    try {
      // Create PDF document
      final pdf = pw.Document();
      
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Header(
                  level: 0,
                  child: pw.Text(
                    'KYC CNIC Verification Report',
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
                pw.SizedBox(height: 20),
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
              ],
            );
          },
        ),
      );

      // Get macOS Downloads directory
      Directory? directory;
      if (Platform.isMacOS) {
        directory = await getDownloadsDirectory();
        directory ??= Directory('${Platform.environment['HOME']}/Downloads');
      } else {
        directory = await getApplicationDocumentsDirectory();
      }

      // Ensure directory exists
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }

      // Save PDF file
      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final file = File('${directory.path}/KYC_Report_$timestamp.pdf');
      await file.writeAsBytes(await pdf.save());

      Get.snackbar(
        'Success',
        'PDF saved successfully to: ${file.path}',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        icon: const Icon(Icons.check_circle, color: Colors.white),
        duration: const Duration(seconds: 4),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to download PDF: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        icon: const Icon(Icons.error, color: Colors.white),
      );
    }
  }

  Future<void> _downloadExcel(dynamic user) async {
    try {
      // Create Excel workbook
      var excel = Excel.createExcel();
      Sheet sheetObject = excel['KYC Report'];

      // Add headers
      sheetObject.cell(CellIndex.indexByString("A1")).value = TextCellValue('Field');
      sheetObject.cell(CellIndex.indexByString("B1")).value = TextCellValue('Value');

      // Add data
      final data = [
        ['Name', user.name ?? 'N/A'],
        ['Father Name', user.fatherName ?? 'N/A'],
        ['CNIC', user.cnic?.toString() ?? 'N/A'],
        ['Date of Birth', _formatDateOfBirth(user.dob)],
        ['City', user.city ?? 'N/A'],
        ['State', user.state ?? 'N/A'],
        ['Address', user.address ?? 'N/A'],
        ['Criminal Record', user.criminalRecord ?? 'N/A'],
        ['Generated On', DateFormat('dd MMMM yyyy, hh:mm a').format(DateTime.now())],
      ];

      for (int i = 0; i < data.length; i++) {
        sheetObject.cell(CellIndex.indexByString("A${i + 2}")).value = TextCellValue(data[i][0]);
        sheetObject.cell(CellIndex.indexByString("B${i + 2}")).value = TextCellValue(data[i][1]);
      }

      // Style headers
      sheetObject.cell(CellIndex.indexByString("A1")).cellStyle = CellStyle(
        bold: true,
      );
      sheetObject.cell(CellIndex.indexByString("B1")).cellStyle = CellStyle(
        bold: true,
      );

      // Get macOS Downloads directory
      Directory? directory;
      if (Platform.isMacOS) {
        directory = await getDownloadsDirectory();
        directory ??= Directory('${Platform.environment['HOME']}/Downloads');
      } else {
        directory = await getApplicationDocumentsDirectory();
      }

      // Ensure directory exists
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }

      // Save Excel file
      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final file = File('${directory.path}/KYC_Report_$timestamp.xlsx');
      await file.writeAsBytes(excel.encode()!);

      Get.snackbar(
        'Success',
        'Excel file saved successfully to: ${file.path}',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        icon: const Icon(Icons.check_circle, color: Colors.white),
        duration: const Duration(seconds: 4),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to download Excel: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        icon: const Icon(Icons.error, color: Colors.white),
      );
    }
  }

  pw.TableRow _buildPdfTableRow(String field, String value) {
    return pw.TableRow(
      children: [
        pw.Padding(
          padding: const pw.EdgeInsets.all(8),
          child: pw.Text(
            field,
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
}