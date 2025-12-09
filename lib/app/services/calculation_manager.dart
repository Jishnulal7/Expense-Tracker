import 'package:yarima_wallet_pro/app/services/exports.dart';
import 'package:intl/intl.dart';

class CalculationManager {
  Map<String, List<TransactionModel>> groupTransactionsByMonth(
      Map<String, List<TransactionModel>> transactionsByDate) {
    try {
      Map<String, List<TransactionModel>> transactionsByMonth = {};

      transactionsByDate.forEach((dateKey, transactions) {
        final monthYear = DateFormat('yyyy-MM')
            .format(DateFormat('yyyy-MM-dd').parse(dateKey));

        transactionsByMonth.putIfAbsent(monthYear, () => []);
        transactionsByMonth[monthYear]!.addAll(transactions);
      });
      return transactionsByMonth;
    } catch (e) {
      debugPrint('Error grouping transactions by month: $e');
      return {};
    }
  }

  Map<String, List<TransactionModel>> groupTransactionsByDate(
      List<TransactionModel> transactions) {
    try {
      Map<String, List<TransactionModel>> transactionsByDate = {};

      for (final transaction in transactions) {
        final dateKey = DateFormat('yyyy-MM-dd').format(transaction.date);
        transactionsByDate.putIfAbsent(dateKey, () => []);
        transactionsByDate[dateKey]!.add(transaction);
      }

      return transactionsByDate;
    } catch (e) {
      debugPrint('Error grouping transactions by date: $e');
      return {};
    }
  }

  double calculateBalanceForDay(DateTime selectedDate, double openingBalance,
      Box<TransactionModel> transactionBox) {
    try {
      double balance = openingBalance;

      final truncatedSelectedDate =
          DateTime(selectedDate.year, selectedDate.month, selectedDate.day);

      final filteredTransactions = transactionBox.values.where((transaction) {
        final truncatedTransactionDate = DateTime(transaction.date.year,
            transaction.date.month, transaction.date.day);

        bool isBeforeOrSameDate = truncatedTransactionDate
                .isBefore(truncatedSelectedDate.add(const Duration(days: 1))) ||
            truncatedTransactionDate.isAtSameMomentAs(truncatedSelectedDate);

        return isBeforeOrSameDate;
      });

      for (final transaction in filteredTransactions) {
        // Exclude transfers from balance calculation
        if (transaction.transactionType == TransactionType.receipt ||
            transaction.transactionType == TransactionType.payment) {
          if (transaction.transactionType == TransactionType.receipt) {
            balance += transaction.amount;
          } else {
            balance -= transaction.amount;
          }
        }
      }

      return balance;
    } catch (e) {
      debugPrint('Error calculating balance for date: $e');
      return openingBalance;
    }
  }

  double calculateBalanceForMonth(DateTime month, double openingBalance,
      Box<TransactionModel> transactionBox) {
    try {
      double balance = openingBalance;
      DateTime lastDayOfMonth = DateTime(month.year, month.month + 1, 0);

      for (int day = 1; day <= lastDayOfMonth.day; day++) {
        DateTime date = DateTime(month.year, month.month, day);
        balance = calculateBalanceForDay(date, openingBalance, transactionBox);
      }

      return balance;
    } catch (e) {
      debugPrint('Error calculating balance for month: $e');
      return openingBalance;
    }
  }

  double calculatePreviousMonthBalance(DateTime month, double openingBalance,
      Box<TransactionModel> transactionBox) {
    try {
      DateTime startDate = DateTime(month.year, month.month, 1);
      DateTime previousMonthStartDate = DateTime(
        startDate.year,
        startDate.month - 1,
        1,
      );
      DateTime previousMonthEndDate = DateTime(
        startDate.year,
        startDate.month,
        0,
      );

      double previousMonthBalance = 0.0;
      for (DateTime date = previousMonthStartDate;
          date.isBefore(previousMonthEndDate) || date == previousMonthEndDate;
          date = date.add(const Duration(days: 1))) {
        previousMonthBalance =
            calculateBalanceForDay(date, openingBalance, transactionBox);
      }

      return previousMonthBalance;
    } catch (e) {
      debugPrint('Error calculating previous month balance: $e');
      return openingBalance;
    }
  }

  Map<String, Map<String, double>> calculateYearlyData(
      Map<String, List<TransactionModel>> transactionsByMonth,
      double openingBalance,
      Box<TransactionModel> transactionBox) {
    try {
      Map<String, Map<String, double>> yearlyData = {};

      for (var monthData in transactionsByMonth.entries) {
        if (monthData.value.isNotEmpty) {
          String month =
              DateFormat('MMMM yyyy').format(monthData.value[0].date);
          double totalReceiptsForMonth = calculateTotalReceiptAmountForMonth(
              monthData.value[0].date, transactionBox);
          double totalPaymentsForMonth = calculateTotalPaymentAmountForMonth(
              monthData.value[0].date, transactionBox);
          double totalTransfersForMonth = calculateTotalTransferAmountForMonth(
              monthData.value[0].date, transactionBox);
          double balanceForMonth = calculateBalanceForMonth(
              monthData.value[0].date, openingBalance, transactionBox);
          double closingBalance = calculatePreviousMonthBalance(
              monthData.value[0].date, openingBalance, transactionBox);
          yearlyData[month] = {
            'totalReceipts': totalReceiptsForMonth,
            'totalPayments': totalPaymentsForMonth,
            'totalTransfers': totalTransfersForMonth,
            'balance': balanceForMonth,
            'closingBalance': closingBalance
          };
        }
      }

      return yearlyData;
    } catch (e) {
      debugPrint('Error calculating and saving yearly data: $e');
      return {};
    }
  }

  double calculateTotalTransferAmountForMonth(
      DateTime selectedMonth, Box<TransactionModel> transactionBox) {
    try {
      return transactionBox.values
              .where((transaction) =>
                  transaction.date.month == selectedMonth.month &&
                  transaction.date.year == selectedMonth.year &&
                  transaction.transactionType == TransactionType.transfer)
              .fold(0.0, (total, transaction) => total! + transaction.amount) ??
          0.0;
    } catch (e) {
      debugPrint('Error calculating total transfer amount for month: $e');
      return 0.0;
    }
  }

  double calculateTotalPaymentAmount(
      DateTime selectedDailyDate, Box<TransactionModel> transactionBox) {
    try {
      return transactionBox.values
          .where((transaction) =>
              DateFormat('yyyy-MM-dd').format(transaction.date) ==
              DateFormat('yyyy-MM-dd').format(selectedDailyDate))
          .where((transaction) =>
              transaction.transactionType == TransactionType.payment)
          .fold(0.0, (total, transaction) => total + transaction.amount);
    } catch (e) {
      debugPrint('Error calculating total payment amount: $e');
      return 0.0;
    }
  }

  double calculateTotalReceiptAmount(
      DateTime selectedDailyDate, Box<TransactionModel> transactionBox) {
    try {
      return transactionBox.values
          .where((transaction) =>
              DateFormat('yyyy-MM-dd').format(transaction.date) ==
              DateFormat('yyyy-MM-dd').format(selectedDailyDate))
          .where((transaction) =>
              transaction.transactionType == TransactionType.receipt)
          .fold(0.0, (total, transaction) => total + transaction.amount);
    } catch (e) {
      debugPrint('Error calculating total receipt amount: $e');
      return 0.0;
    }
  }

  double calculateTotalPaymentAmountForMonth(
      DateTime selectedMonth, Box<TransactionModel> transactionBox) {
    try {
      return transactionBox.values
              .where((transaction) =>
                  transaction.date.month == selectedMonth.month &&
                  transaction.date.year == selectedMonth.year &&
                  transaction.transactionType == TransactionType.payment)
              .fold(0.0, (total, transaction) => total! + transaction.amount) ??
          0.0;
    } catch (e) {
      debugPrint('Error calculating total payment amount for month: $e');
      return 0.0;
    }
  }

  double calculateTotalReceiptAmountForMonth(
      DateTime selectedMonth, Box<TransactionModel> transactionBox) {
    try {
      return transactionBox.values
              .where((transaction) =>
                  transaction.date.month == selectedMonth.month &&
                  transaction.date.year == selectedMonth.year &&
                  transaction.transactionType == TransactionType.receipt)
              .fold(0.0, (total, transaction) => total! + transaction.amount) ??
          0.0;
    } catch (e) {
      debugPrint('Error calculating total receipt amount for month: $e');
      return 0.0;
    }
  }

  List<Payment> getPaymentsForMonth(
      DateTime selectedMonth, Box<TransactionModel> transactionBox) {
    try {
      final payments = <Payment>[];

      for (final transaction in transactionBox.values) {
        if (transaction.transactionType == TransactionType.payment &&
            transaction.date.year == selectedMonth.year &&
            transaction.date.month == selectedMonth.month) {
          payments.add(Payment(
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
            fromSubAccount: transaction.fromSubAccount,
            generalCategory: transaction.generalCategory,
            generalSubCategory: transaction.generalSubCategory,
            subCategory: transaction.subCategory,
            toSubAccount: transaction.toSubAccount,
          ));
        }
      }
      return payments;
    } catch (e) {
      debugPrint('Error getting payments for month: $e');
      return [];
    }
  }

  List<Payment> getPaymentsForYear(
      DateTime selectedMonth, Box<TransactionModel> transactionBox) {
    try {
      final payments = <Payment>[];

      for (final transaction in transactionBox.values) {
        if (transaction.transactionType == TransactionType.payment &&
            transaction.date.year == selectedMonth.year) {
          payments.add(Payment(
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
            fromSubAccount: transaction.fromSubAccount,
            generalCategory: transaction.generalCategory,
            generalSubCategory: transaction.generalSubCategory,
            subCategory: transaction.subCategory,
            toSubAccount: transaction.toSubAccount,
          ));
        }
      }
      return payments;
    } catch (e) {
      debugPrint('Error getting payments for year: $e');
      return [];
    }
  }

  List<Receipt> getReceiptsForMonth(
      DateTime selectedMonth, Box<TransactionModel> transactionBox) {
    try {
      final receipts = <Receipt>[];

      for (final transaction in transactionBox.values) {
        if (transaction.transactionType == TransactionType.receipt &&
            transaction.date.year == selectedMonth.year &&
            transaction.date.month == selectedMonth.month) {
          receipts.add(Receipt(
            id: transaction.id,
            amount: transaction.amount,
            description: transaction.description,
            categoryName: transaction.categoryName,
            date: transaction.date,
            transactionType: TransactionType.receipt,
            categoryPath: transaction.categoryPath,
            fromAccount: transaction.fromAccount,
            toAccount: transaction.toAccount,
            fromAccountImagePath: transaction.fromAccountImagePath,
            toAccountImagePath: transaction.toAccountImagePath,
            fromSubAccount: transaction.fromSubAccount,
            generalCategory: transaction.generalCategory,
            generalSubCategory: transaction.generalSubCategory,
            subCategory: transaction.subCategory,
            toSubAccount: transaction.toSubAccount,
          ));
        }
      }

      return receipts;
    } catch (e) {
      debugPrint('Error getting receipts for month: $e');
      return [];
    }
  }

  List<Receipt> getReceiptsForYear(
      DateTime selectedMonth, Box<TransactionModel> transactionBox) {
    try {
      final receipts = <Receipt>[];

      for (final transaction in transactionBox.values) {
        if (transaction.transactionType == TransactionType.receipt &&
            transaction.date.year == selectedMonth.year) {
          receipts.add(Receipt(
            id: transaction.id,
            amount: transaction.amount,
            description: transaction.description,
            categoryName: transaction.categoryName,
            date: transaction.date,
            transactionType: TransactionType.receipt,
            categoryPath: transaction.categoryPath,
            fromAccount: transaction.fromAccount,
            toAccount: transaction.toAccount,
            fromAccountImagePath: transaction.fromAccountImagePath,
            toAccountImagePath: transaction.toAccountImagePath,
            fromSubAccount: transaction.fromSubAccount,
            generalCategory: transaction.generalCategory,
            generalSubCategory: transaction.generalSubCategory,
            subCategory: transaction.subCategory,
            toSubAccount: transaction.toSubAccount,
          ));
        }
      }

      return receipts;
    } catch (e) {
      debugPrint('Error getting receipts for year: $e');
      return [];
    }
  }

  List<Receipt> getReceiptsFromHive(
      Box<dynamic> monthlyTransactionBox, DateTime selectedDate) {
    try {
      final receipts = <Receipt>[];

      for (final transaction in monthlyTransactionBox.values) {
        if (transaction is TransactionModel &&
            transaction.transactionType == TransactionType.receipt &&
            transaction.date.year == selectedDate.year &&
            transaction.date.month == selectedDate.month &&
            transaction.date.day == selectedDate.day) {
          receipts.add(Receipt(
            id: transaction.id,
            amount: transaction.amount,
            description: transaction.description,
            categoryName: transaction.categoryName,
            date: transaction.date,
            transactionType: TransactionType.receipt,
            categoryPath: transaction.categoryPath,
            fromAccount: transaction.fromAccount,
            toAccount: transaction.toAccount,
            fromAccountImagePath: transaction.fromAccountImagePath,
            toAccountImagePath: transaction.toAccountImagePath,
            fromSubAccount: transaction.fromSubAccount,
            generalCategory: transaction.generalCategory,
            generalSubCategory: transaction.generalSubCategory,
            subCategory: transaction.subCategory,
            toSubAccount: transaction.toSubAccount,
          ));
        }
      }

      return receipts;
    } catch (e) {
      debugPrint('Error getting receipts from Hive: $e');
      return [];
    }
  }

  List<Transfer> getTransfersFromHive(
      Box<dynamic> monthlyTransactionBox, DateTime selectedDate) {
    try {
      final transfers = <Transfer>[];

      for (final transaction in monthlyTransactionBox.values) {
        if (transaction is TransactionModel &&
            transaction.transactionType == TransactionType.transfer &&
            transaction.date.year == selectedDate.year &&
            transaction.date.month == selectedDate.month &&
            transaction.date.day == selectedDate.day) {
          transfers.add(Transfer(
            id: transaction.id,
            amount: transaction.amount,
            description: transaction.description,
            categoryName: transaction.categoryName,
            date: transaction.date,
            transactionType: TransactionType.transfer,
            categoryPath: transaction.categoryPath,
            fromAccount: transaction.fromAccount,
            toAccount: transaction.toAccount,
            fromAccountImagePath: transaction.fromAccountImagePath,
            toAccountImagePath: transaction.toAccountImagePath,
            fromSubAccount: transaction.fromSubAccount,
            generalCategory: transaction.generalCategory,
            generalSubCategory: transaction.generalSubCategory,
            subCategory: transaction.subCategory,
            toSubAccount: transaction.toSubAccount,
          ));
        }
      }
      return transfers;
    } catch (e) {
      debugPrint('Error getting transfers from Hive: $e');
      return [];
    }
  }

  List<Transfer> getTransfersForMonth(
      Box<dynamic> monthlyTransactionBox, DateTime selectedDate) {
    try {
      final transfers = <Transfer>[];

      for (final transaction in monthlyTransactionBox.values) {
        if (transaction is TransactionModel &&
            transaction.transactionType == TransactionType.transfer &&
            transaction.date.year == selectedDate.year &&
            transaction.date.month == selectedDate.month) {
          transfers.add(Transfer(
            id: transaction.id,
            amount: transaction.amount,
            description: transaction.description,
            categoryName: transaction.categoryName,
            date: transaction.date,
            transactionType: TransactionType.transfer,
            categoryPath: transaction.categoryPath,
            fromAccount: transaction.fromAccount,
            toAccount: transaction.toAccount,
            fromAccountImagePath: transaction.fromAccountImagePath,
            toAccountImagePath: transaction.toAccountImagePath,
            fromSubAccount: transaction.fromSubAccount,
            generalCategory: transaction.generalCategory,
            generalSubCategory: transaction.generalSubCategory,
            subCategory: transaction.subCategory,
            toSubAccount: transaction.toSubAccount,
          ));
        }
      }
      return transfers;
    } catch (e) {
      debugPrint('Error getting transfers from Hive: $e');
      return [];
    }
  }

  List<Transfer> getTransfersForYear(
      Box<dynamic> monthlyTransactionBox, DateTime selectedDate) {
    try {
      final transfers = <Transfer>[];

      for (final transaction in monthlyTransactionBox.values) {
        if (transaction is TransactionModel &&
            transaction.transactionType == TransactionType.transfer &&
            transaction.date.year == selectedDate.year) {
          transfers.add(Transfer(
            id: transaction.id,
            amount: transaction.amount,
            description: transaction.description,
            categoryName: transaction.categoryName,
            date: transaction.date,
            transactionType: TransactionType.transfer,
            categoryPath: transaction.categoryPath,
            fromAccount: transaction.fromAccount,
            toAccount: transaction.toAccount,
            fromAccountImagePath: transaction.fromAccountImagePath,
            toAccountImagePath: transaction.toAccountImagePath,
            fromSubAccount: transaction.fromSubAccount,
            generalCategory: transaction.generalCategory,
            generalSubCategory: transaction.generalSubCategory,
            subCategory: transaction.subCategory,
            toSubAccount: transaction.toSubAccount,
          ));
        }
      }
      return transfers;
    } catch (e) {
      debugPrint('Error getting transfers from Hive: $e');
      return [];
    }
  }

  List<Payment> getPaymentsFromHive(
      Box<dynamic> monthlyTransactionBox, DateTime selectedDate) {
    try {
      final payments = <Payment>[];

      for (final transaction in monthlyTransactionBox.values) {
        if (transaction is TransactionModel &&
            transaction.transactionType == TransactionType.payment &&
            transaction.date.year == selectedDate.year &&
            transaction.date.month == selectedDate.month &&
            transaction.date.day == selectedDate.day) {
          payments.add(Payment(
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
            fromSubAccount: transaction.fromSubAccount,
            generalCategory: transaction.generalCategory,
            generalSubCategory: transaction.generalSubCategory,
            subCategory: transaction.subCategory,
            toSubAccount: transaction.toSubAccount,
          ));
        }
      }

      return payments;
    } catch (e) {
      debugPrint('Error getting payments from Hive: $e');
      return [];
    }
  }
}
