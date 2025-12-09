// ignore_for_file: depend_on_referenced_packages
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get_storage/get_storage.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:rxdart/rxdart.dart';
import 'package:provider/provider.dart';
import 'package:yarima_wallet_pro/app/data/provider/currency_provider.dart';
import 'package:yarima_wallet_pro/app/models/transaction_model.dart';
import 'package:yarima_wallet_pro/app/modules/account/components/account_helper.dart';
import 'package:yarima_wallet_pro/app/modules/account/components/account_info.dart';
import 'package:yarima_wallet_pro/app/modules/account/components/bottom_sheet_header.dart';
import 'package:yarima_wallet_pro/app/modules/account/components/transaction_list.dart';
import 'package:yarima_wallet_pro/app/modules/tabview/dailytab.dart';
import 'package:yarima_wallet_pro/app/modules/widgets/custom_confirmation.dart';
import 'package:yarima_wallet_pro/app/modules/widgets/no_records.dart';

class AccountListTile extends StatefulWidget {
  const AccountListTile({
    required this.accountData,
    required this.balance,
    required this.isDefaultAccount,
    required this.transactionBox,
    required this.color,
    required this.selectedMonth,
    super.key,
    this.onAccountAdded,
  });

  final VoidCallback? onAccountAdded;
  final Map<String, dynamic> accountData;
  final double balance;
  final bool isDefaultAccount;
  final Box<TransactionModel> transactionBox;
  final Color color;
  final DateTime selectedMonth;

  @override
  State<AccountListTile> createState() => _AccountListTileState();
}

class _AccountListTileState extends State<AccountListTile> {
  String boxName = 'accounts';
  final accountsBox = GetStorage('accounts');
  late List<String> subAccounts;
  late Stream<void> _combinedStream;
  late ValueNotifier<Set<TransactionModel>> _transactionsNotifier;
  late TextEditingController _editingController;

  @override
  void initState() {
    super.initState();
    _editingController = TextEditingController();
    _transactionsNotifier = ValueNotifier<Set<TransactionModel>>({});
    _setupStreams();
  }

  void _setupStreams() {
    _combinedStream = Rx.merge([
      widget.transactionBox.watch().map((_) => _updateTransactions()),
    ]);

    _combinedStream.listen((_) {
      if (mounted) {
        setState(() {});
      }
    });

    // Initial load
    _updateTransactions();
  }

  void _updateTransactions() {
    if (!mounted) return;

    final transactions = _getAllTransactions(
      widget.transactionBox,
      widget.accountData['name'],
      widget.accountData['name'],
    );

    _transactionsNotifier.value = transactions;
  }

  // @override
  // void dispose() {
  //   _transactionsNotifier.dispose();
  //   _attendanceNotifier.dispose();
  //   super.dispose();
  // }

  @override
  Widget build(BuildContext context) {
    final currencySymbol =
        Provider.of<CurrencyNotifier>(context).currencySymbol;
    return StatefulBuilder(
      builder: (context, setState) {
        double calculatedBalance = _calculateTotalBalance(
          _transactionsNotifier.value,
        );
        return Slidable(
          endActionPane: ActionPane(
            motion: const ScrollMotion(),
            children: [
              SlidableAction(
                onPressed: (_) =>
                    _editAccount(widget.accountData['name'], context),
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                icon: Icons.edit,
                label: 'Edit',
              ),
              SlidableAction(
                onPressed: (_) => _deleteAccount(widget.accountData['name']),
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                icon: Icons.delete,
                label: 'Delete',
              ),
            ],
          ),
          child: ListTile(
            onTap: () {
              _accountTransactions(
                context,
                widget.accountData,
                widget.transactionBox,
                widget.accountData['name'],
                widget.accountData['name'],
                widget.color,
              );
            },
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  widget.accountData['name'],
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 15),
                ),
                Text(
                  'Balance : $currencySymbol${calculatedBalance.toStringAsFixed(1)}',
                  style: const TextStyle(fontSize: 13),
                )
              ],
            ),
            leading: Image.asset(
              widget.accountData['imagePath'],
              width: 25,
            ),
          ),
        );
      },
    );
  }

  double _calculateTotalBalance(Set<TransactionModel> transactions) {
    return AccountHelper().calculateAccountBalance(
      transactions,
      widget.accountData['name'],
      widget.accountData['name'],
      widget.accountData,
    );
  }

  void _accountTransactions(
    BuildContext context,
    Map<String, dynamic> category,
    Box<TransactionModel> monthlyTransactionBox,
    String fromAccount,
    String toAccount,
    Color color,
  ) {
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (BuildContext context) {
        return ValueListenableBuilder<Set<TransactionModel>>(
          valueListenable: _transactionsNotifier,
          builder: (context, transactions, _) {
            return _buildBottomSheetContent(
              context,
              category,
              transactions,
              fromAccount,
              toAccount,
              color,
            );
          },
        );
      },
    );
  }

  Widget _buildBottomSheetContent(
    BuildContext context,
    Map<String, dynamic> category,
    Set<TransactionModel> allTransactions,
    String fromAccount,
    String toAccount,
    Color color,
  ) {
    final List<String> sortedMonths = _getSortedMonths(allTransactions);

    double balance = AccountHelper().calculateAccountBalance(
      allTransactions,
      fromAccount,
      toAccount,
      category,
    );

    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BottomSheetHeader(
              context: context,
              category: category,
              color: color,
            ),
            const SizedBox(height: 10),
            AccountInfo(
              context: context,
              account: category,
              color: color,
              balance: balance,
              transactionBox: widget.transactionBox,
              selectedMonth: widget.selectedMonth,
            ),
            const SizedBox(height: 10),
            allTransactions.isEmpty
                ? const NoRecordsWidget()
                : TransactionList(
                    sortedMonths: sortedMonths,
                    allTransactions: allTransactions,
                    fromAccount: fromAccount,
                    toAccount: toAccount,
                    color: color,
                    selectedMonth: widget.selectedMonth,
                    transactionBox: widget.transactionBox,
                  ),
          ],
        ),
      ),
    );
  }

  Set<TransactionModel> _getAllTransactions(
    Box<TransactionModel> monthlyTransactionBox,
    String fromAccount,
    String toAccount,
  ) {
    final Set<TransactionModel> allTransactions = {};

    for (var transaction in monthlyTransactionBox.values) {
      if (transaction.fromAccount == fromAccount ||
          transaction.toAccount == fromAccount) {
        allTransactions.add(transaction);
      }
    }

    return allTransactions;
  }

  List<String> _getSortedMonths(Set<TransactionModel> allTransactions) {
    final List<String> uniqueMonths = allTransactions
        .map((transaction) => DateFormat('MMMM yyyy').format(transaction.date))
        .toSet()
        .toList();

    final List<DateTime> dateTimeMonths = uniqueMonths
        .map((month) => DateFormat('MMMM yyyy').parse(month))
        .toList();

    dateTimeMonths.sort((a, b) => b.compareTo(a)); // Sort in descending order

    return dateTimeMonths
        .map((dateTime) => DateFormat('MMMM yyyy').format(dateTime))
        .toList();
  }

  void _deleteAccount(String accountName) {
    try {
      showDialog(
        context: context,
        builder: (context) => ConfirmationDialog(
          title: 'Confirm Deletion',
          content: 'Are you sure you want to delete this Account?',
          onCancel: () {
            Navigator.of(context).pop();
          },
          onConfirm: () {
            _removeAccountFromStorage(accountName);
            widget.onAccountAdded?.call();
            setState(() {});
            dailyTabKey.currentState
                ?.removeTransactionsWithRemovedAccount(accountName);
            Navigator.of(context).pop();
          },
          confirmButtonText: 'Yes',
          cancelButtonText: 'No',
        ),
      );
    } catch (e) {
      debugPrint('Error deleting Account: $e');
    }
  }

  void _removeAccountFromStorage(String accountName) {
    try {
      // Remove transactions associated with the account
      final transactionBox = Hive.box<TransactionModel>('transactions');
      final transactions = transactionBox.values.where((transaction) =>
          transaction.fromAccount == accountName ||
          transaction.toAccount == accountName);
      for (final transaction in transactions) {
        transactionBox.delete(transaction.key);
      }

      // Remove the account from GetStorage
      accountsBox.remove(accountName);

      // Trigger UI update
      setState(() {});
      widget.onAccountAdded?.call();

      debugPrint('Account removed: $accountName');
    } catch (e) {
      debugPrint('Error removing account: $e');
    }
  }

  void _editAccount(String accountName, BuildContext context) {
    // Set the initial text in the controller
    _editingController.text = accountName;
    double newInitialAmount =
        widget.accountData['initialAmount'] as double? ?? 0.0;

    try {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Edit Account'),
          content: StatefulBuilder(builder: (context, setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _editingController,
                  decoration: const InputDecoration(
                    labelText: 'Account Name',
                  ),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  initialValue: newInitialAmount.toString(),
                  keyboardType: TextInputType.number,
                  onChanged: (newValue) {
                    newInitialAmount =
                        double.tryParse(newValue) ?? newInitialAmount;
                  },
                  decoration: const InputDecoration(
                    labelText: 'Opening Balance',
                  ),
                ),
              ],
            );
          }),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final newAccountName = _editingController.text;
                if (newAccountName.isNotEmpty) {
                  _updateAccountNameAndAmount(
                      accountName, newAccountName, newInitialAmount);
                  widget.onAccountAdded?.call();
                  dailyTabKey.currentState
                      ?.updateTransactionsWithUpdatedAccountName(
                          accountName, newAccountName);
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Save'),
            ),
          ],
        ),
      );
    } catch (e) {
      debugPrint('Error while editing account: $e');
    }
  }

  void _updateAccountNameAndAmount(
      String oldName, String newName, double newAmount) {
    try {
      final accountData = accountsBox.read(oldName);
      if (accountData != null) {
        final String imagePath = accountData['imagePath'];

        // First, update the account data in storage
        final Map<String, dynamic> updatedAccountData = {
          'imagePath': imagePath,
          'initialAmount': newAmount,
        };

        // If we're only adding/modifying sub-accounts and not changing the account name,
        // update the existing account
        if (oldName == newName) {
          accountsBox.write(oldName, updatedAccountData);
        } else {
          // If account name is changing, remove old and add new
          accountsBox.remove(oldName);
          accountsBox.write(newName, updatedAccountData);
        }

        // Update transactions
        final accountBox = Hive.box<TransactionModel>('transactions');
        final transactions = accountBox.values
            .where((transaction) =>
                transaction.fromAccount == oldName ||
                transaction.toAccount == oldName)
            .toList();

        // Batch update transactions
        for (var transaction in transactions) {
          final updatedTransaction = TransactionModel(
            id: transaction.id,
            amount: transaction.amount,
            categoryName: transaction.categoryName,
            date: transaction.date,
            description: transaction.description,
            fromAccount: transaction.fromAccount == oldName
                ? newName
                : transaction.fromAccount,
            fromAccountImagePath: transaction.fromAccount == oldName
                ? imagePath
                : transaction.fromAccountImagePath,
            toAccount: transaction.toAccount == oldName
                ? newName
                : transaction.toAccount,
            toAccountImagePath: transaction.toAccount == oldName
                ? imagePath
                : transaction.toAccountImagePath,
            transactionType: transaction.transactionType,
            categoryPath: transaction.categoryPath,
            subCategory: transaction.subCategory,
            generalCategory: transaction.generalSubCategory,
            generalSubCategory: transaction.generalSubCategory,
            // Preserve existing sub-account information
            fromSubAccount: transaction.fromSubAccount,
            toSubAccount: transaction.toSubAccount,
          );

          // Use the transaction's key to update it
          accountBox.put(transaction.key, updatedTransaction);
        }

        // Update widget state
        setState(() {
          if (oldName != newName) {
            widget.accountData['name'] = newName;
          }
          widget.accountData['initialAmount'] = newAmount;
        });

        // Force refresh transactions
        _updateTransactions();

        // Notify parent widget of changes
        if (widget.onAccountAdded != null) {
          widget.onAccountAdded!();
        }

        // Update daily tab if account name changed
        if (oldName != newName) {
          dailyTabKey.currentState
              ?.updateTransactionsWithUpdatedAccountName(oldName, newName);
        }
      } else {
        debugPrint('No data found for account: $oldName');
      }
    } catch (e) {
      debugPrint('Error updating account: $e');
    }
  }
}
