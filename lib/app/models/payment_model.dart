import 'package:hive_flutter/hive_flutter.dart';
import 'package:yarima_wallet_pro/app/models/transaction_model.dart';
part 'payment_model.g.dart';

@HiveType(typeId: 4)
class Payment extends TransactionModel {
  Payment({
    required super.id,
    required super.amount,
    required super.description,
    required super.categoryName,
    required super.date,
    required TransactionType transactionType,
    required super.fromAccount,
    required super.toAccount,
    required super.categoryPath,
    required super.fromAccountImagePath,
    required super.subCategory,
    required super.toAccountImagePath,
    required super.generalCategory,
    required super.generalSubCategory,
    required super.fromSubAccount,
    required super.toSubAccount,
  }) : super(
          transactionType: TransactionType.payment,
        );

  factory Payment.fromTransaction(TransactionModel transaction) {
    return Payment(
        generalCategory: transaction.generalCategory,
        generalSubCategory: transaction.generalSubCategory,
        id: transaction.id,
        amount: transaction.amount,
        description: transaction.description,
        categoryName: transaction.categoryName,
        date: transaction.date,
        transactionType: TransactionType.payment,
        categoryPath: transaction.categoryPath,
        fromAccount: transaction.fromAccount,
        toAccount: transaction.toAccount,
        fromAccountImagePath: transaction.fromAccountImagePath,
        toAccountImagePath: transaction.toAccountImagePath,
        subCategory: transaction.subCategory,
        fromSubAccount: transaction.fromSubAccount,
        toSubAccount: transaction.toSubAccount);
  }
}
