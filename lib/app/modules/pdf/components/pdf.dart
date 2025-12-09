// ignore_for_file: use_build_context_synchronously
import 'package:yarima_wallet_pro/app/modules/add/exports.dart';
import 'package:yarima_wallet_pro/app/modules/pdf/components/exports.dart';
import 'package:yarima_wallet_pro/app/modules/profile/components/exports.dart';
import 'package:intl/intl.dart';

class PdfHelper {
  Future<void> savePdf(
    BuildContext context,
    String pdfPath,
    DateTime selectedMonth,
    int tabIndex,
    int subIndex,
  ) async {
    // Select directory using FilePicker
    String? directoryPath = await FilePicker.platform.getDirectoryPath();
    if (directoryPath == null) {
      // User canceled the picker
      debugPrint("Directory selection canceled.");
      const CustomToast(message: 'Directory selection canceled.')
          .showToast(context);
      return;
    }

    debugPrint("Selected directory: $directoryPath");

    // Generate file name based on tabIndex and subIndex
    String fileName = '';
    if (tabIndex == 0) {
      String year = DateFormat('yyyy').format(selectedMonth);
      String reportType = '';
      switch (subIndex) {
        case 1:
          reportType = 'Expense';
          break;
        case 2:
          reportType = 'Income';
          break;
        case 3:
          reportType = 'Transfers';
          break;
        default:
          reportType = 'Yearly';
          break;
      }
      fileName = '$reportType $year.pdf';
    } else if (tabIndex == 1) {
      String month = DateFormat('MMMM').format(selectedMonth);
      String year = DateFormat('y').format(selectedMonth);
      String reportType = '';
      switch (subIndex) {
        case 1:
          reportType = 'Expense';
          break;
        case 2:
          reportType = 'Income';
          break;
        case 3:
          reportType = 'Transfers';
          break;
        default:
          reportType = 'Monthly';
          break;
      }
      fileName = '$reportType $month $year.pdf';
    } else {
      fileName = 'yarima_wallet_pro.pdf';
    }

    // Complete file path
    String filePath = "$directoryPath/$fileName";
    debugPrint("File path: $filePath");

    // Write PDF file
    try {
      final File file = File(filePath);
      await file.writeAsBytes(await File(pdfPath).readAsBytes());
      debugPrint("PDF saved to: ${file.path}");

      const CustomToast(
        message: 'PDF saved to selected directory.',
      ).showToast(context);
    } catch (error) {
      debugPrint("Error saving PDF: $error");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving PDF: $error'),
        ),
      );
    }
  }

  Future<void> sharePdf(String pdfPath) async {
    try {
      final xFile = XFile(pdfPath);
      await Share.shareXFiles([xFile], text: 'Sharing PDF');
    } catch (error) {
      debugPrint("Error sharing PDF: $error");
    }
  }
}
