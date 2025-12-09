// import 'package:yarima_wallet_pro/app/modules/profile/components/backup.dart';
// import 'package:yarima_wallet_pro/app/modules/tabview/dailytab.dart';
// import 'package:yarima_wallet_pro/app/modules/tabview/monthlytab.dart';
// import 'package:yarima_wallet_pro/app/modules/widgets/custom_confirmation.dart';
// import 'package:yarima_wallet_pro/app/modules/widgets/custom_toast.dart';
// import 'package:flutter/material.dart';

// class BackupScreen extends StatelessWidget {
//   const BackupScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final double width = MediaQuery.of(context).size.width;

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Backup & Restore'),
//       ),
//       body: SafeArea(
//         child: SingleChildScrollView(
//           child: Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 const Text(
//                   'Backup, Restore & Delete',
//                   style: TextStyle(
//                     fontSize: 24,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 const SizedBox(height: 16),
//                 Text(
//                   'You can backup your transaction data locally or to Google Drive. '
//                   'You can also restore data from a previous backup or delete all stored transaction details.',
//                   style: Theme.of(context).textTheme.bodyLarge,
//                 ),
//                 const SizedBox(height: 24),
//                 _buildActionCard(
//                   context,
//                   width,
//                   icon: Icons.backup,
//                   title: 'Local Backup',
//                   description: 'Create a local backup of your current data',
//                   onPressed: () =>
//                       _performAction(context, BackupAction.localBackup),
//                 ),
//                 const SizedBox(height: 16),
//                 _buildActionCard(
//                   context,
//                   width,
//                   icon: Icons.cloud_upload,
//                   title: 'Google Drive Backup',
//                   description: 'Backup your data to Google Drive',
//                   onPressed: () =>
//                       _performAction(context, BackupAction.driveBackup),
//                 ),
//                 const SizedBox(height: 16),
//                 _buildActionCard(
//                   context,
//                   width,
//                   icon: Icons.restore,
//                   title: 'Local Restore',
//                   description: 'Restore data from a local backup',
//                   onPressed: () =>
//                       _performAction(context, BackupAction.localRestore),
//                 ),
//                 const SizedBox(height: 16),
//                 _buildActionCard(
//                   context,
//                   width,
//                   icon: Icons.cloud_download,
//                   title: 'Google Drive Restore',
//                   description: 'Restore data from Google Drive',
//                   onPressed: () =>
//                       _performAction(context, BackupAction.driveRestore),
//                 ),
//                 const SizedBox(height: 16),
//                 _buildActionCard(
//                   context,
//                   width,
//                   icon: Icons.delete_forever,
//                   title: 'Delete Data',
//                   description: 'Permanently delete all stored data',
//                   onPressed: () => _performAction(context, BackupAction.delete),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildActionCard(
//     BuildContext context,
//     double width, {
//     required IconData icon,
//     required String title,
//     required String description,
//     required VoidCallback onPressed,
//   }) {
//     return Card(
//       elevation: 2,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       child: InkWell(
//         onTap: onPressed,
//         borderRadius: BorderRadius.circular(12),
//         child: Padding(
//           padding: const EdgeInsets.all(16),
//           child: Row(
//             children: [
//               Icon(icon, size: 48, color: Theme.of(context).primaryColor),
//               const SizedBox(width: 16),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(title, style: Theme.of(context).textTheme.titleLarge),
//                     const SizedBox(height: 4),
//                     Text(description,
//                         style: Theme.of(context).textTheme.bodyMedium),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   void _performAction(BuildContext context, BackupAction action) {
//     final actionDetails = _getActionDetails(action);
//     _showConfirmationDialog(
//       context,
//       actionDetails.confirmationMessage,
//       actionDetails.confirmationTitle,
//       () => _executeAction(context, action),
//     );
//   }

//   void _executeAction(BuildContext context, BackupAction action) async {
//     Navigator.of(context).pop(); // Close the confirmation dialog
//     try {
//       switch (action) {
//         case BackupAction.localBackup:
//           await BackupRestoreService().createBackup(context);
//           break;
//         case BackupAction.driveBackup:
//           await BackupRestoreService().createGDriveBackup(context);
//           break;
//         case BackupAction.localRestore:
//           await BackupRestoreService().restoreFromBackup(context);
//           _refreshData(context);
//         //   break;
//         case BackupAction.driveRestore:
//           await BackupRestoreService().restoreFromGDrive(context);
//           _refreshData(context);
//           break;
//         case BackupAction.delete:
//           await BackupRestoreService().deleteAllData(context);
//           _refreshData(context);
//           break;
//       }
//       _showToast(
//           context, '${action.name.capitalize()} completed successfully.');
//     } catch (e) {
//       _showToast(context, 'Error: ${e.toString()}');
//     }
//   }

//   void _refreshData(BuildContext context) {
//     dailyTabKey.currentState?.loadTransactions();
//     monthlyTabKey.currentState?.loadTransactionsFromHive();
//   }

//   void _showConfirmationDialog(
//     BuildContext context,
//     String content,
//     String title,
//     VoidCallback onConfirm,
//   ) {
//     showDialog(
//       context: context,
//       builder: (context) => ConfirmationDialog(
//         content: content,
//         title: title,
//         onCancel: () => Navigator.of(context).pop(),
//         onConfirm: onConfirm,
//         confirmButtonText: 'Confirm',
//         cancelButtonText: 'Cancel',
//       ),
//     );
//   }

//   void _showToast(BuildContext context, String message) {
//     CustomToast(message: message).showToast(context);
//   }
// }

// enum BackupAction {
//   localBackup,
//   driveBackup,
//   localRestore,
//   driveRestore,
//   delete
// }

// extension on String {
//   String capitalize() {
//     return "${this[0].toUpperCase()}${substring(1)}";
//   }
// }

// class ActionDetails {
//   final String confirmationTitle;
//   final String confirmationMessage;

//   ActionDetails(this.confirmationTitle, this.confirmationMessage);
// }

// ActionDetails _getActionDetails(BackupAction action) {
//   switch (action) {
//     case BackupAction.localBackup:
//       return ActionDetails('Confirm Local Backup',
//           'Are you sure you want to create a local backup of your data?');
//     case BackupAction.driveBackup:
//       return ActionDetails('Confirm Google Drive Backup',
//           'Are you sure you want to backup your data to Google Drive?');
//     case BackupAction.localRestore:
//       return ActionDetails('Confirm Local Restore',
//           'Are you sure you want to restore your data from a local backup? This will overwrite your current data.');
//     case BackupAction.driveRestore:
//       return ActionDetails('Confirm Google Drive Restore',
//           'Are you sure you want to restore your data from Google Drive? This will overwrite your current data.');
//     case BackupAction.delete:
//       return ActionDetails('Confirm Delete',
//           'Are you sure you want to delete all your data? This action cannot be undone.');
//   }
// }