// ignore_for_file: depend_on_referenced_packages
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:hive/hive.dart';
import 'package:yarima_wallet_pro/app/data/helpers/color_helper.dart';
import 'package:yarima_wallet_pro/app/data/helpers/icon_helper.dart';
import 'package:yarima_wallet_pro/app/models/transaction_model.dart';
import 'package:yarima_wallet_pro/app/modules/account/components/account_helper.dart';
import 'package:rxdart/rxdart.dart';
import 'package:yarima_wallet_pro/app/modules/account/components/account_listtile.dart';

class AccountSection extends StatefulWidget {
  const AccountSection({
    required this.transactionBox,
    required this.selectedMonth,
    super.key,
    this.onAccountAdded,
  });

  final Box<TransactionModel> transactionBox;
  final DateTime selectedMonth;
  final VoidCallback? onAccountAdded;

  @override
  State<AccountSection> createState() => _AccountSectionState();
}

class _AccountSectionState extends State<AccountSection> {
  final accountModel = AccountHelper();
  final StreamController<void> _accountChangesController =
      StreamController<void>.broadcast();
  late Stream<void> _combinedStream;
  @override
  void initState() {
    super.initState();
    accountModel.initializeDefaultAccounts();
    _combinedStream = Rx.merge([
      widget.transactionBox.watch().map((_) {}),
    ]);
  }

  @override
  void dispose() {
    _accountChangesController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<void>(
      stream: _combinedStream,
      builder: (context, snapshot) {
        return _buildAccountSection(
          'Accounts',
          widget.transactionBox,
          ColorHelper().darkorWhite(context),
          accountModel,
          AccountHelper().allTransactionTypes,
        );
      },
    );
  }

  Widget _buildAccountSection(
    String title,
    Box<TransactionModel> transactionBox,
    Color color,
    AccountHelper accountModel,
    List<TransactionType> allTransactionTypes,
  ) {
    return StreamBuilder<void>(
      stream: _accountChangesController.stream,
      builder: (context, snapshot) {
        final List<Map<String, dynamic>> accounts = [];

        final box = GetStorage('accounts');
        final keys = box.getKeys();
        for (final key in keys) {
          final data = box.read(key);

          accounts.add({
            'name': key,
            'imagePath':
                data['imagePath'] ?? CustomIcons().getImagePathForAccounts(key),
            'initialAmount': data['initialAmount'] ?? 0.0,
          });
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Column(
              children: accounts.map<Widget>(
                (accountData) {
                  try {
                    final List<TransactionModel> allTransactions = [];

                    for (int i = 0; i <= widget.selectedMonth.month; i++) {
                      final transactionsFromAccount =
                          AccountHelper().getTransactionsOfAccounts(
                        DateTime(widget.selectedMonth.year, i + 1),
                        transactionBox,
                        allTransactionTypes,
                        accountData['name'],
                        accountData['name'],
                      );

                      allTransactions.addAll(transactionsFromAccount);
                    }

                    double balance = AccountHelper().calculateAccountBalance(
                      allTransactions.toSet(),
                      accountData['name'],
                      accountData['name'],
                      accountData,
                    );

                    // Add initial amount to the balance
                    balance += (accountData['initialAmount'] ?? 0.0);

                    bool isDefaultAccount = accountModel.accountCategories.any(
                        (element) => element['name'] == accountData['name']);

                    return AccountListTile(
                      accountData: accountData,
                      balance: balance,
                      isDefaultAccount: isDefaultAccount,
                      transactionBox: transactionBox,
                      color: color,
                      selectedMonth: widget.selectedMonth,
                      onAccountAdded: widget.onAccountAdded,
                    );
                  } catch (e) {
                    debugPrint('Error while mapping account: $e');
                    return const SizedBox.shrink();
                  }
                },
              ).toList(),
            ),
          ],
        );
      },
    );
  }
}
