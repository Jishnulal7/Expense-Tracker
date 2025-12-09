import 'package:yarima_wallet_pro/app/data/constants/colors.dart';
import 'package:yarima_wallet_pro/app/models/transaction_model.dart';
import 'package:yarima_wallet_pro/app/models/transfer_model.dart';
import 'package:yarima_wallet_pro/app/modules/tabview/components/monthlytab/simple_transaction_list.dart';
import 'package:yarima_wallet_pro/app/modules/tabview/components/monthlytab/simple_transfer_list.dart';
import 'package:flutter/material.dart';

class DaySummaryWidget extends StatelessWidget {
  final List<Transfer> transfersForDay;
  final List<TransactionModel> receiptsForDay;
  final List<TransactionModel> paymentsForDay;
  final DateTime day;

  const DaySummaryWidget({
    super.key,
    required this.transfersForDay,
    required this.receiptsForDay,
    required this.paymentsForDay,
    required this.day,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSection(
            items: transfersForDay,
            itemBuilder: (transfer) => SimpleTransferList(
              toAccount: transfer.toAccount,
              amount: transfer.amount,
              fromAccount: transfer.fromAccount,
            ),
          ),
          _buildSection(
            items: receiptsForDay,
            itemBuilder: (receipt) => SimpleTransactionListItem(
              category: receipt.categoryName,
              amount: receipt.amount,
              color: AppColor.kGreen,
              categoryPath: receipt.categoryPath,
            ),
          ),
          _buildSection(
            items: paymentsForDay,
            itemBuilder: (payment) => SimpleTransactionListItem(
              category: payment.categoryName,
              amount: payment.amount,
              color: AppColor.kRed,
              categoryPath: payment.categoryPath,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required List<dynamic> items,
    required Widget Function(dynamic) itemBuilder,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var item in items) itemBuilder(item),
        if (items.isNotEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 15),
            // child: Divider(),
          ),
      ],
    );
  }
}
