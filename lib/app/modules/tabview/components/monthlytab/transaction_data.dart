import 'package:yarima_wallet_pro/app/models/transaction_model.dart';
import 'package:yarima_wallet_pro/app/modules/tabview/components/monthlytab/custom_transaction.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:yarima_wallet_pro/app/data/provider/currency_provider.dart';

class TransactionData extends StatelessWidget {
  final List<String> sortedDates;
  final Map<String, List<TransactionModel>> filteredTransactionsByMonth;
  final Function(DateTime) getReceiptsForDay;
  final Function(DateTime) getPaymentsForDay;
  final Function(DateTime) getTransfersForDay;
  final double Function(DateTime) calculateBalanceForDay;
  final void Function(DateTime) changeToDailyTab;
  final bool isSelectionModeActive;
  final void Function(String) onSelectItem;
  final void Function(String) onLongPressItem;

  const TransactionData({
    super.key,
    required this.sortedDates,
    required this.filteredTransactionsByMonth,
    required this.getReceiptsForDay,
    required this.getPaymentsForDay,
    required this.getTransfersForDay,
    required this.calculateBalanceForDay,
    required this.changeToDailyTab,
    required this.isSelectionModeActive,
    required this.onSelectItem,
    required this.onLongPressItem,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      physics: const BouncingScrollPhysics(),
      itemCount: sortedDates.length,
      shrinkWrap: true,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final dayKey = sortedDates[index];
        final day = DateTime.parse(dayKey);
        final transactionsForDay = filteredTransactionsByMonth[dayKey] ?? [];
        if (transactionsForDay.isEmpty) return const SizedBox.shrink();

        return _buildDayCard(context, day, transactionsForDay, dayKey);
      },
    );
  }

  Widget _buildDayCard(BuildContext context, DateTime day,
      List<TransactionModel> transactionsForDay, String dayKey) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 14),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onLongPress: () => onLongPressItem(dayKey),
        onTap: () {
          if (isSelectionModeActive) {
            onSelectItem(dayKey);
          } else {
            changeToDailyTab(day);
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDateHeader(context, day),
              const SizedBox(height: 12),
              _buildTransactionSummary(day),
              const SizedBox(height: 8),
              _buildBalanceRow(context, day),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateHeader(BuildContext context, DateTime day) {
    final textTheme = Theme.of(context).textTheme;
    return Row(
      children: [
        Text(
          DateFormat('dd').format(day),
          style:
              textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              DateFormat('MMMM y').format(day),
              style: textTheme.titleMedium,
            ),
            Text(
              DateFormat('EEEE').format(day),
              style: textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTransactionSummary(DateTime day) {
    return DaySummaryWidget(
      transfersForDay: getTransfersForDay(day),
      receiptsForDay: getReceiptsForDay(day),
      paymentsForDay: getPaymentsForDay(day),
      day: day,
    );
  }

  Widget _buildBalanceRow(BuildContext context, DateTime day) {
    final currencySymbol =
        Provider.of<CurrencyNotifier>(context).currencySymbol;
    final balance = calculateBalanceForDay(day);
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          'Balance: ',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        Text(
          '$currencySymbol ${balance.toStringAsFixed(1)}',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: balance >= 0 ? Colors.green : Colors.red,
              ),
        ),
      ],
    );
  }
}
