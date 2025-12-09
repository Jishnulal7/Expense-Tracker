import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';

class DateSelectionRow extends StatelessWidget {
  final DateTime selectMonth;
  final VoidCallback onPreviousMonth;
  final VoidCallback onNextMonth;
  final VoidCallback onSelectMonthYear;

  const DateSelectionRow({
    super.key,
    required this.selectMonth,
    required this.onPreviousMonth,
    required this.onNextMonth,
    required this.onSelectMonthYear,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16.5),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
                onPressed: onPreviousMonth,
                icon: const Icon(Icons.arrow_back_ios)),
            _buildMonthYearSelector(context),
            IconButton(
                onPressed: onNextMonth,
                icon: const Icon(Icons.arrow_forward_ios))
          ],
        ),
      ),
    );
  }

  Widget _buildMonthYearSelector(BuildContext context) {
    DateTime now = DateTime.now();
    int currentMonth = now.month;
    int currentYear = now.year;

    // Compare the selected month and year with the current month and year
    bool isCurrentMonth = (selectMonth.month == currentMonth) &&
        (selectMonth.year == currentYear);

    return GestureDetector(
      onTap: onSelectMonthYear,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isCurrentMonth
              ? Theme.of(context).primaryColor
              : Colors.grey[300],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              DateFormat('MMMM y').format(selectMonth),
              style: GoogleFonts.lato(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: isCurrentMonth ? Colors.white : Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
