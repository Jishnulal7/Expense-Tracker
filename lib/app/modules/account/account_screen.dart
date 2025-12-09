import 'package:yarima_wallet_pro/app/modules/account/components/account_helper.dart';
import 'package:yarima_wallet_pro/app/modules/account/components/account_section.dart';
import 'package:yarima_wallet_pro/app/modules/account/components/exports.dart';
import 'package:yarima_wallet_pro/app/modules/tabview/components/exports.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({
    super.key,
    this.onAccountAdded,
    required this.selectedDailyDate,
  });

  final VoidCallback? onAccountAdded;
  final DateTime selectedDailyDate;

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  AccountHelper accountModel = AccountHelper();
  String newAccountName = '';
  final boxName = 'accounts';
  final Box<TransactionModel> transactionBox =
      Hive.box<TransactionModel>('transactions');
  double initialAmount = 0;
  String selectedIcon = '';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: SpeedDial(
        label: const Text('Add Account'),
        onPress: () {
          _addAccount();
        },
        child: const Icon(Icons.account_balance_wallet_outlined),
      ),
      appBar: AppBar(
        title: const Text('Accounts'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              AccountSection(
                transactionBox: transactionBox,
                selectedMonth: widget.selectedDailyDate,
                onAccountAdded: () {
                  setState(() {});
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _addAccount() {
    final categoryFormKey = GlobalKey<FormState>();
    selectedIcon = '';

    final List<String> accountIcons = [
      'assets/categories/wallet.png',
      'assets/categories/piggy-bank.png',
      'assets/categories/bank.png',
      'assets/categories/dollar-coin.png',
      'assets/categories/rent.png',
      'assets/categories/investment.png',
      'assets/categories/cash-bill-dollar.png',
    ];
    selectedIcon = accountIcons[0];
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, StateSetter setState) {
          return SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 20,
                right: 20,
                top: 20,
              ),
              child: Form(
                key: categoryFormKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Create New Account',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Enter an Account name';
                        }
                        return null;
                      },
                      decoration:
                          const InputDecoration(labelText: 'Account Name'),
                      onChanged: (value) {
                        newAccountName = value;
                      },
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      maxLength: 9,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Opening Balance',
                        counterText: '',
                      ),
                      onChanged: (value) {
                        initialAmount = double.tryParse(value) ?? 0;
                      },
                    ),
                    const SizedBox(height: 20),
                    const Text('Select an icon for your account:'),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 100,
                      child: GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 7,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                        ),
                        itemCount: accountIcons.length,
                        itemBuilder: (context, index) {
                          return InkWell(
                            onTap: () {
                              setState(() {
                                selectedIcon = accountIcons[index];
                              });
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: selectedIcon == accountIcons[index]
                                      ? AppColor.kPurple
                                      : Colors.transparent,
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Image.asset(
                                accountIcons[index],
                                width: 12,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text('Cancel'),
                        ),
                        OutlinedButton(
                          onPressed: () {
                            if (categoryFormKey.currentState?.validate() ??
                                false) {
                              _saveAccount(
                                newAccountName,
                                initialAmount,
                                selectedIcon,
                              );
                              Navigator.of(context).pop();
                              setState(() {});
                              widget.onAccountAdded?.call();
                            }
                          },
                          child: const Text('Save'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          );
        });
      },
    );
  }

  void _saveAccount(
    String accountName,
    double initialAmount,
    String icon,
  ) {
    final box = GetStorage(boxName);
    final key = accountName;

    box.write(key, {
      'name': accountName,
      'imagePath': icon,
      'initialAmount': initialAmount,
    });

    debugPrint('Account saved: $accountName,');
    debugPrint('Icon saved: $icon');
    debugPrint('All keys in $boxName box: ${box.getKeys().toString()}');
    setState(() {});
  }
}
