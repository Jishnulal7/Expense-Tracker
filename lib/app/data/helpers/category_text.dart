import 'package:yarima_wallet_pro/app/models/transaction_model.dart';

String getCategoryText(TransactionModel transaction) {
  final mainCategory = transaction.generalCategory?.isNotEmpty == true
      ? transaction.generalCategory!
      : transaction.categoryName ?? '';
  if (transaction.subCategory == null || transaction.subCategory!.isEmpty) {
    return mainCategory;
  }
  return '$mainCategory • ${transaction.subCategory}';
}

String getAccountText(TransactionModel transaction) {
  final fromSubAccount = transaction.fromSubAccount;

  if (fromSubAccount == null || fromSubAccount.trim().isEmpty) {
    return transaction.fromAccount;
  }

  return '${transaction.fromAccount} • $fromSubAccount';
}
