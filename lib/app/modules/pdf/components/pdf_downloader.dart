import 'package:yarima_wallet_pro/app/modules/profile/components/exports.dart';
import 'dart:typed_data';
import 'package:yarima_wallet_pro/app/modules/widgets/custom_toast.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class PdfDownloader {
  Future<void> downloadPdf(
      BuildContext context, Uint8List pdfBytes, String name) async {
    try {
      final String? folderPath = await pickFolderToSaveFile(context);
      if (folderPath == null) return;

      final file = File('$folderPath/$name-transactions.pdf');
      await file.writeAsBytes(pdfBytes);

      CustomToast(
        message: 'PDF saved successfully to ${file.path}',
      ).showToast(context);
    } catch (e) {
      debugPrint('Error downloading PDF: $e');
      CustomToast(
        message: 'Error saving PDF: $e',
      ).showToast(context);
    }
  }

  static Future<String?> pickFolderToSaveFile(BuildContext context) async {
    String? directoryPath = await FilePicker.platform.getDirectoryPath();

    if (directoryPath == null) {
      debugPrint("Directory selection canceled.");
      const CustomToast(message: 'Directory selection canceled.')
          .showToast(context);
      return null;
    }
    debugPrint("Selected directory: $directoryPath");
    return directoryPath;
  }

  Future<void> sharePdf(Uint8List pdfBytes, String name) async {
    try {
      final directory = await getTemporaryDirectory();
      final file = File('${directory.path}/$name-transactions.pdf');
      await file.writeAsBytes(pdfBytes);
      await Share.shareXFiles([XFile(file.path)], text: '$name Transactions');
    } catch (e) {
      // Handle any errors, perhaps show an error message to the user
      debugPrint('Error sharing PDF: $e');
    }
  }
}
