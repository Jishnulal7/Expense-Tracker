import 'package:yarima_wallet_pro/app/modules/account/components/exports.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:yarima_wallet_pro/app/data/provider/currency_provider.dart';

class TransferSection extends StatelessWidget {
  final List<TransactionModel> transactions;
  final String title;
  final Function(TransactionModel) editTransactions;
  final Function(TransactionModel) deleteTransactions;
  final Function(TransactionModel, DateTime) copyTransaction;

  const TransferSection({
    super.key,
    required this.transactions,
    required this.title,
    required this.editTransactions,
    required this.deleteTransactions,
    required this.copyTransaction,
  });

  @override
  Widget build(BuildContext context) {
    final transfers = transactions
        .where((t) => t.transactionType == TransactionType.transfer)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(context),
        if (transfers.isEmpty)
          _buildEmptySection()
        else
          ...transfers.map((transfer) => _buildTransferTile(context, transfer)),
      ],
    );
  }

  Widget _buildSectionHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(
        title,
        style: const TextStyle(fontSize: 16),
      ),
    );
  }

  Widget _buildTransferTile(BuildContext context, TransactionModel transfer) {
    final currencySymbol =
        Provider.of<CurrencyNotifier>(context).currencySymbol;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onLongPress: () => _showOptions(context, transfer),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: _buildAccountInfo(context, transfer.fromAccount,
                        isFrom: true),
                  ),
                  const Icon(Icons.arrow_forward, color: Colors.grey),
                  Expanded(
                    child: _buildAccountInfo(context, transfer.toAccount,
                        isFrom: false),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    DateFormat('MMM d, yyyy').format(transfer.date),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  Text(
                    '$currencySymbol ${transfer.amount.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColor.kPrimary,
                        ),
                  ),
                ],
              ),
              if (transfer.description.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    transfer.description,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAccountInfo(BuildContext context, String account,
      {required bool isFrom}) {
    return Row(
      mainAxisAlignment:
          isFrom ? MainAxisAlignment.start : MainAxisAlignment.end,
      children: [
        if (!isFrom) Expanded(child: Container()),
        Image.asset(
          CustomIcons().getImagePathForAccounts(account),
          width: 24,
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            account,
            style: Theme.of(context).textTheme.titleMedium,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (isFrom) Expanded(child: Container()),
      ],
    );
  }

  Widget _buildEmptySection() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.swap_horiz, size: 48, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No transfers',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap + to add a new transfer',
              style: TextStyle(fontSize: 14, color: Colors.grey[400]),
            ),
          ],
        ),
      ),
    );
  }

  void _showOptions(BuildContext context, TransactionModel transaction) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => _buildOptionsMenu(context, transaction),
    );
  }

  Widget _buildOptionsMenu(BuildContext context, TransactionModel transaction) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Edit'),
              onTap: () {
                Navigator.pop(context);
                editTransactions(transaction);
              },
            ),
            ListTile(
              leading: const Icon(Icons.content_copy),
              title: const Text('Copy'),
              onTap: () {
                Navigator.pop(context);
                copyTransaction(transaction, DateTime.now());
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Delete', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                _showDeleteConfirmationDialog(context, transaction);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmationDialog(
      BuildContext context, TransactionModel transaction) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Transfer'),
          content: const Text('Are you sure you want to delete this transfer?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
              onPressed: () {
                Navigator.of(context).pop();
                deleteTransactions(transaction);
              },
            ),
          ],
        );
      },
    );
  }
}
