import 'package:yarima_wallet_pro/app/data/constants/colors.dart';
import 'package:yarima_wallet_pro/app/data/helpers/color_helper.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:yarima_wallet_pro/app/data/provider/currency_provider.dart';

class DateNavigationCard extends StatelessWidget {
  final DateTime selectDailyDate;
  final double balance;
  final Function(DateTime) selectDate;

  const DateNavigationCard({
    super.key,
    required this.selectDailyDate,
    required this.balance,
    required this.selectDate,
  });

  @override
  Widget build(BuildContext context) {
    final isToday = DateTime.now().day == selectDailyDate.day;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              _buildNavigationButton(context, Icons.arrow_back_ios, -1),
              const SizedBox(
                width: 2,
              ),
              Expanded(child: _buildDateSection(context, isToday)),
              const SizedBox(width: 8),
              _buildBalanceSection(context),
              const SizedBox(
                width: 2,
              ),
              _buildNavigationButton(context, Icons.arrow_forward_ios, 1),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDateSection(BuildContext context, bool isToday) {
    return GestureDetector(
      onTap: () => _selectDate(context),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isToday
                  ? AppColor.kRed.withOpacity(0.1)
                  : Colors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              selectDailyDate.day.toString(),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 24,
                color: isToday
                    ? AppColor.kRed
                    : Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  DateFormat('MMMM y').format(selectDailyDate),
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w500),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  DateFormat('EEEE').format(selectDailyDate),
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceSection(BuildContext context) {
    final currencySymbol =
        Provider.of<CurrencyNotifier>(context).currencySymbol;
    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          constraints: BoxConstraints(maxWidth: constraints.maxWidth * 0.5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Balance',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  "$currencySymbol ${NumberFormat('#,##0.0').format(balance)}",
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildNavigationButton(
      BuildContext context, IconData icon, int offset) {
    return IconButton(
      color: ColorHelper().darkorWhite(context),
      onPressed: () {
        selectDate(selectDailyDate.add(Duration(days: offset)));
      },
      icon: Icon(icon),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? newDate = await showDatePicker(
      context: context,
      initialDate: selectDailyDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (newDate != null) {
      selectDate(newDate);
    }
  }
}
