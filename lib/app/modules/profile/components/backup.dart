// import 'dart:convert';
// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:google_sign_in/google_sign_in.dart';
// import 'package:hive/hive.dart';
// import 'package:get_storage/get_storage.dart';
// import 'package:file_picker/file_picker.dart';
// import 'package:yarima_wallet_pro/app/models/attendance_model.dart';
// import 'package:yarima_wallet_pro/app/modules/tabview/dailytab.dart';
// import 'package:yarima_wallet_pro/app/modules/tabview/monthlytab.dart';
// import 'package:googleapis/drive/v3.dart' as drive;
// import 'package:http/http.dart' as http;
// import '../../../models/transaction_model.dart';

// class BackupRestoreService {
//   static const String transactionsBoxName = 'transactions';
//   static const String attendanceBoxName = 'attendanceBox';
//   static const String backupFileName = 'Wallet_backup.json';

//   // Callback for data restoration
//   static void Function()? onDataRestored;
//   static void Function()? onDataDeleted;

//   final GoogleSignIn _googleSignIn = GoogleSignIn.standard(scopes: [
//     drive.DriveApi.driveFileScope,
//     drive.DriveApi.driveAppdataScope,
//   ]);
//   Future<String?> createGDriveBackup(BuildContext context) async {
//     try {
//       // Sign in to Google
//       final GoogleSignInAccount? account = await _googleSignIn.signIn();
//       if (account == null) return null;

//       final headers = await account.authHeaders;
//       final client = http.Client();
//       final authenticatedClient = GoogleAuthClient(headers, client);
//       final driveApi = drive.DriveApi(authenticatedClient);

//       // Prepare backup data (reuse existing logic)
//       final backupData = {
//         'transactions': Hive.box<TransactionModel>(transactionsBoxName)
//             .values
//             .map((e) => e.toJson())
//             .toList(),
//         'attendanceBox': Hive.box<AttendanceModel>(attendanceBoxName)
//             .values
//             .map((e) => e.toJson())
//             .toList(),
//         'categories': {
//           'payment_categories': GetStorage().read('payment_categories'),
//           'receipt_categories': GetStorage().read('receipt_categories'),
//           'general_categories': GetStorage().read('generalCategories'),
//           'attendance_categories': GetStorage().read('attendance_categories'),
//         },
//         'accounts': await _getAccountsData(),
//         'timestamp': DateTime.now().toIso8601String(),
//       };

//       // Generate unique backup filename with timestamp
//       final timestamp = DateTime.now().millisecondsSinceEpoch;
//       final uniqueBackupFileName = 'wallet_backup_$timestamp.json';

//       // Create file metadata
//       final fileMetadata = drive.File()
//         ..name = uniqueBackupFileName
//         ..mimeType = 'application/json'
//         ..parents = ['appDataFolder']; // Store in app-specific folder

//       // Convert backup data to stream
//       final stream = Stream.fromIterable([utf8.encode(jsonEncode(backupData))]);
//       final media = drive.Media(stream, jsonEncode(backupData).length);

//       // Upload file to Drive
//       final driveFile =
//           await driveApi.files.create(fileMetadata, uploadMedia: media);

//       debugPrint('Backup created on Google Drive with ID: ${driveFile.id}');
//       return driveFile.id;
//     } catch (e) {
//       debugPrint('Error creating Google Drive backup: $e');
//       rethrow;
//     }
//   }

//   // Restore from Google Drive
//   Future<void> restoreFromGDrive(BuildContext context) async {
//     try {
//       debugPrint('Starting Google Drive restoration process...');

//       // Sign in to Google
//       final GoogleSignInAccount? account = await _googleSignIn.signIn();
//       if (account == null) return;

//       final headers = await account.authHeaders;
//       final client = http.Client();
//       final authenticatedClient = GoogleAuthClient(headers, client);
//       final driveApi = drive.DriveApi(authenticatedClient);

//       // List backup files in app folder
//       final fileList = await driveApi.files.list(
//         spaces: 'appDataFolder',
//         orderBy: 'modifiedTime desc',
//         q: "name contains 'wallet_backup_' and mimeType='application/json'",
//       );

//       if (fileList.files == null || fileList.files!.isEmpty) {
//         throw Exception('No backup files found on Google Drive');
//       }

//       // Get the most recent backup file
//       final mostRecentBackup = fileList.files!.first;
//       final media = await driveApi.files.get(mostRecentBackup.id!,
//           downloadOptions: drive.DownloadOptions.fullMedia) as drive.Media;

//       // Read the backup data
//       final List<int> dataBytes = [];
//       await for (final chunk in media.stream) {
//         dataBytes.addAll(chunk);
//       }

//       final jsonString = utf8.decode(dataBytes);
//       final backupData = jsonDecode(jsonString) as Map<String, dynamic>;

//       // Restore data using existing restoration logic
//       await _restoreData(backupData);

//       // Refresh UI
//       debugPrint('Refreshing UI...');
//       await _refreshUI();

//       if (onDataRestored != null) {
//         debugPrint('Calling onDataRestored callback...');
//         onDataRestored!.call();
//       }

//       debugPrint('Google Drive restoration completed successfully.');
//     } catch (e) {
//       debugPrint('Error restoring from Google Drive: $e');
//       rethrow;
//     }
//   }

//   Future<void> _restoreData(Map<String, dynamic> backupData) async {
//     // Restore transactions
//     if (backupData['transactions'] != null) {
//       final transactionsBox = Hive.box<TransactionModel>(transactionsBoxName);
//       final transactions = (backupData['transactions'] as List)
//           .map((json) => TransactionModel.fromJson(json))
//           .toList();
//       await transactionsBox.putAll(
//         Map.fromEntries(
//           transactions.asMap().entries.map(
//                 (entry) => MapEntry(entry.key, entry.value),
//               ),
//         ),
//       );
//     }

//     // Restore attendance
//     if (backupData['attendanceBox'] != null) {
//       final attendanceBox = Hive.box<AttendanceModel>(attendanceBoxName);
//       final attendance = (backupData['attendanceBox'] as List)
//           .map((json) => AttendanceModel.fromJson(json))
//           .toList();
//       await attendanceBox.putAll(
//         Map.fromEntries(
//           attendance.asMap().entries.map(
//                 (entry) => MapEntry(entry.key, entry.value),
//               ),
//         ),
//       );
//     }

//     // Restore categories
//     final categories = backupData['categories'] as Map<String, dynamic>?;
//     if (categories != null) {
//       final getStorage = GetStorage();
//       for (final entry in categories.entries) {
//         if (entry.value != null) {
//           await getStorage.write(entry.key, entry.value);
//         }
//       }
//     }

//     // Restore accounts
//     if (backupData['accounts'] != null) {
//       await _restoreAccountsData(
//           backupData['accounts'] as Map<String, dynamic>);
//     }
//   }

//   Future<String?> createBackup(BuildContext context) async {
//     try {
//       // Get directory path from user using FilePicker
//       final String? directoryPath = await FilePicker.platform.getDirectoryPath(
//         dialogTitle: 'Select backup location',
//       );

//       if (directoryPath == null) {
//         return null;
//       }

//       // Get the boxes
//       final transactionsBox = Hive.box<TransactionModel>(transactionsBoxName);
//       final attendanceBox = Hive.box<AttendanceModel>(attendanceBoxName);
//       final getStorage = GetStorage();

//       // Prepare backup data
//       final backupData = {
//         'transactions': transactionsBox.values.map((e) => e.toJson()).toList(),
//         'attendanceBox': attendanceBox.values.map((e) => e.toJson()).toList(),
//         'categories': {
//           'payment_categories': getStorage.read('payment_categories'),
//           'receipt_categories': getStorage.read('receipt_categories'),
//           'general_categories': getStorage.read('generalCategories'),
//           'attendance_categories': getStorage.read('attendance_categories'),
//         },
//         'accounts': await _getAccountsData(),
//         'timestamp': DateTime.now().toIso8601String(),
//       };

//       // Generate unique backup filename with timestamp
//       final timestamp = DateTime.now().millisecondsSinceEpoch;
//       final uniqueBackupFileName = 'wallet_backup_$timestamp.json';

//       // Create backup file
//       final file = File('$directoryPath/$uniqueBackupFileName');
//       await file.writeAsString(jsonEncode(backupData));

//       return file.path;
//     } catch (e) {
//       debugPrint('Error creating backup: $e');
//       rethrow;
//     }
//   }

//   Future<void> restoreFromBackup(BuildContext context) async {
//     try {
//       debugPrint('Starting restoration process...');

//       final result = await FilePicker.platform.pickFiles(
//         type: FileType.custom,
//         allowedExtensions: ['json'],
//         dialogTitle: 'Select backup file to restore',
//       );

//       if (result == null || result.files.isEmpty) {
//         debugPrint('No backup file selected.');
//         return;
//       }

//       final file = File(result.files.first.path!);
//       if (!await file.exists()) {
//         throw Exception('Backup file not found');
//       }

//       debugPrint('Backup file selected: ${file.path}');
//       final jsonString = await file.readAsString();
//       final backupData = jsonDecode(jsonString) as Map<String, dynamic>;

//       // Clear and restore transactions
//       final transactionsBox = Hive.box<TransactionModel>(transactionsBoxName);
//       if (backupData['transactions'] != null) {
//         debugPrint('Clearing existing transactions...');
//         // await transactionsBox.clear();

//         final transactions = (backupData['transactions'] as List)
//             .map((json) => TransactionModel.fromJson(json))
//             .toList();
//         debugPrint('Restoring ${transactions.length} transactions...');
//         await transactionsBox.putAll(
//           Map.fromEntries(
//             transactions.asMap().entries.map(
//                   (entry) => MapEntry(entry.key, entry.value),
//                 ),
//           ),
//         );
//         debugPrint('Transactions restored successfully.');
//       } else {
//         debugPrint('No transactions data found in backup.');
//       }

//       // Clear and restore attendance
//       final attendanceBox = Hive.box<AttendanceModel>(attendanceBoxName);
//       if (backupData['attendanceBox'] != null) {
//         debugPrint('Clearing existing attendance records...');
//         // await attendanceBox.clear();

//         final attendance = (backupData['attendanceBox'] as List)
//             .map((json) => AttendanceModel.fromJson(json))
//             .toList();
//         debugPrint('Restoring ${attendance.length} attendance records...');
//         await attendanceBox.putAll(
//           Map.fromEntries(
//             attendance.asMap().entries.map(
//                   (entry) => MapEntry(entry.key, entry.value),
//                 ),
//           ),
//         );
//         debugPrint('Attendance records restored successfully.');
//       } else {
//         debugPrint('No attendance data found in backup.');
//       }

//       // Clear and restore categories
//       final categories = backupData['categories'] as Map<String, dynamic>?;
//       if (categories != null) {
//         final getStorage = GetStorage();

//         debugPrint('Clearing existing categories...');
//         await getStorage.remove('payment_categories');
//         await getStorage.remove('receipt_categories');
//         await getStorage.remove('generalCategories');
//         await getStorage.remove('attendance_categories');

//         if (categories['payment_categories'] != null) {
//           debugPrint('Restoring payment categories...');
//           await getStorage.write(
//               'payment_categories', categories['payment_categories']);
//         }

//         if (categories['receipt_categories'] != null) {
//           debugPrint('Restoring receipt categories...');
//           await getStorage.write(
//               'receipt_categories', categories['receipt_categories']);
//         }

//         if (categories['general_categories'] != null) {
//           debugPrint('Restoring general categories...');
//           await getStorage.write(
//               'generalCategories', categories['general_categories']);
//         }

//         if (categories['attendance_categories'] != null) {
//           debugPrint('Restoring attendance categories...');
//           await getStorage.write(
//               'attendance_categories', categories['attendance_categories']);
//         }
//         debugPrint('Categories restored successfully.');
//       }

//       // Clear and restore accounts
//       if (backupData['accounts'] != null) {
//         debugPrint('Restoring accounts...');
//         await _restoreAccountsData(
//             backupData['accounts'] as Map<String, dynamic>);
//         debugPrint('Accounts restored successfully.');
//       }

//       // Refresh UI
//       debugPrint('Refreshing UI...');
//       await _refreshUI();
//       debugPrint('UI refreshed successfully.');

//       if (onDataRestored != null) {
//         debugPrint('Calling onDataRestored callback...');
//         onDataRestored!.call();
//       }

//       debugPrint('Restoration process completed successfully.');
//     } catch (e) {
//       debugPrint('Error restoring backup: $e');
//       rethrow;
//     }
//   }

//   Future<void> _restoreAccountsData(Map<String, dynamic> accountsData) async {
//     final accountsStorage = GetStorage('accounts');
//     await accountsStorage.erase(); // Clear existing accounts
//     accountsData.forEach((key, value) {
//       if (value != null) {
//         accountsStorage.write(key, value);
//       }
//     });
//   }

//   Future<void> _refreshUI() async {
//     try {
//       if (dailyTabKey.currentState != null) {
//         await dailyTabKey.currentState!.restoreData();
//       }
//       if (monthlyTabKey.currentState != null) {
//         await monthlyTabKey.currentState!.restoreData();
//       }
//     } catch (e) {
//       debugPrint('Error refreshing UI: $e');
//     }
//   }

//   Future<Map<String, dynamic>> _getAccountsData() async {
//     final accountsStorage = GetStorage('accounts');
//     final Map<String, dynamic> accounts = {};

//     final keys = accountsStorage.getKeys();
//     for (var key in keys) {
//       accounts[key.toString()] = accountsStorage.read(key);
//     }

//     return accounts;
//   }

//   Future<void> deleteAllData(BuildContext context,
//       {bool includeGDriveBackups = false}) async {
//     try {
//       // Show confirmation dialog
//       final bool? confirmed = await showDialog<bool>(
//         context: context,
//         barrierDismissible: false,
//         builder: (BuildContext context) {
//           return AlertDialog(
//             title: const Text('Delete All Data'),
//             content: Text(
//                 'This will permanently delete all your data${includeGDriveBackups ? ' and Google Drive backups' : ''}. '
//                 'This action cannot be undone. Are you sure you want to continue?'),
//             actions: <Widget>[
//               TextButton(
//                 child: const Text('Cancel'),
//                 onPressed: () => Navigator.of(context).pop(false),
//               ),
//               TextButton(
//                 style: TextButton.styleFrom(
//                   foregroundColor: Colors.red,
//                 ),
//                 child: const Text('Delete'),
//                 onPressed: () => Navigator.of(context).pop(true),
//               ),
//             ],
//           );
//         },
//       );

//       if (confirmed != true) {
//         debugPrint('Data deletion cancelled by user');
//         return;
//       }

//       debugPrint('Starting data deletion process...');

//       // 1. Delete local data
//       await _deleteLocalData();

//       // 2. Delete Google Drive backups if requested
//       if (includeGDriveBackups) {
//         await _deleteGDriveBackups();
//       }

//       // 3. Refresh UI
//       await _refreshUI();

//       // 4. Call deletion callback if exists
//       if (onDataDeleted != null) {
//         onDataDeleted!.call();
//       }

//       debugPrint('Data deletion completed successfully');
//     } catch (e) {
//       debugPrint('Error deleting data: $e');
//       rethrow;
//     }
//   }

//   // Delete only local data
//   Future<void> _deleteLocalData() async {
//     try {
//       debugPrint('Deleting local data...');

//       // 1. Clear Hive boxes
//       final transactionsBox = Hive.box<TransactionModel>(transactionsBoxName);
//       final attendanceBox = Hive.box<AttendanceModel>(attendanceBoxName);

//       await transactionsBox.clear();
//       await attendanceBox.clear();

//       // 2. Clear GetStorage data
//       final getStorage = GetStorage();
//       await getStorage.remove('payment_categories');
//       await getStorage.remove('receipt_categories');
//       await getStorage.remove('generalCategories');
//       await getStorage.remove('attendance_categories');

//       // 3. Clear accounts data
//       final accountsStorage = GetStorage('accounts');
//       await accountsStorage.erase();

//       debugPrint('Local data deleted successfully');
//     } catch (e) {
//       debugPrint('Error deleting local data: $e');
//       rethrow;
//     }
//   }

//   // Delete Google Drive backups
//   Future<void> _deleteGDriveBackups() async {
//     try {
//       debugPrint('Deleting Google Drive backups...');

//       // Sign in to Google
//       final GoogleSignInAccount? account = await _googleSignIn.signIn();
//       if (account == null) {
//         debugPrint('Google Sign In cancelled');
//         return;
//       }

//       final headers = await account.authHeaders;
//       final client = http.Client();
//       final authenticatedClient = GoogleAuthClient(headers, client);
//       final driveApi = drive.DriveApi(authenticatedClient);

//       // List all backup files in app folder
//       final fileList = await driveApi.files.list(
//         spaces: 'appDataFolder',
//         q: "name contains 'wallet_backup_' and mimeType='application/json'",
//       );

//       if (fileList.files == null || fileList.files!.isEmpty) {
//         debugPrint('No backup files found on Google Drive');
//         return;
//       }

//       // Delete each backup file
//       for (final file in fileList.files!) {
//         await driveApi.files.delete(file.id!);
//         debugPrint('Deleted Google Drive backup: ${file.name}');
//       }

//       debugPrint('Google Drive backups deleted successfully');
//     } catch (e) {
//       debugPrint('Error deleting Google Drive backups: $e');
//       rethrow;
//     } finally {
//       await _googleSignIn.signOut();
//     }
//   }

//   // Helper method to check if any data exists
//   Future<bool> hasExistingData() async {
//     final transactionsBox = Hive.box<TransactionModel>(transactionsBoxName);
//     final attendanceBox = Hive.box<AttendanceModel>(attendanceBoxName);
//     final getStorage = GetStorage();
//     final accountsStorage = GetStorage('accounts');

//     return transactionsBox.length > 0 ||
//         attendanceBox.length > 0 ||
//         getStorage.hasData('payment_categories') ||
//         getStorage.hasData('receipt_categories') ||
//         getStorage.hasData('generalCategories') ||
//         getStorage.hasData('attendance_categories') ||
//         accountsStorage.getKeys().isNotEmpty;
//   }

//   // Add a method to check for Google Drive backups
//   Future<bool> hasGDriveBackups() async {
//     try {
//       final GoogleSignInAccount? account = await _googleSignIn.signIn();
//       if (account == null) return false;

//       final headers = await account.authHeaders;
//       final client = http.Client();
//       final authenticatedClient = GoogleAuthClient(headers, client);
//       final driveApi = drive.DriveApi(authenticatedClient);

//       final fileList = await driveApi.files.list(
//         spaces: 'appDataFolder',
//         q: "name contains 'wallet_backup_' and mimeType='application/json'",
//       );

//       return fileList.files != null && fileList.files!.isNotEmpty;
//     } catch (e) {
//       debugPrint('Error checking Google Drive backups: $e');
//       return false;
//     } finally {
//       await _googleSignIn.signOut();
//     }
//   }
// }

// class GoogleAuthClient extends http.BaseClient {
//   final Map<String, String> _headers;
//   final http.Client _client;

//   GoogleAuthClient(this._headers, this._client);

//   @override
//   Future<http.StreamedResponse> send(http.BaseRequest request) {
//     request.headers.addAll(_headers);
//     return _client.send(request);
//   }
// }
