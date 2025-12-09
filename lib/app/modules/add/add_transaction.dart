import 'package:yarima_wallet_pro/app/modules/account/components/account_helper.dart';
import 'package:yarima_wallet_pro/app/modules/add/exports.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddTransactionScreen extends StatefulWidget {
  final DateTime selectedDate;
  final Function(TransactionModel) onAddTransaction;
  final Box<TransactionModel> transactionBox;
  const AddTransactionScreen({
    super.key,
    required this.selectedDate,
    required this.onAddTransaction,
    required this.transactionBox,
  });

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  int toggleIndex = 1; // Set default to Payment
  double amount = 0.0;
  double? enteredAmount;
  int secondToggle = 1;
  String description = '';
  String? selectedCategory = '';
  String? selectedCategoryName;
  String? selectedFirstAccountName;
  String? selectedSecondAccountName;
  String id = const Uuid().v1();

  bool isReceipt = false;
  bool isPayment = true; // Set default to true
  bool isTransfer = false;
  bool isAmountValid = true;
  bool isAttendanceEnabled = false;
  AccountHelper accountModel = AccountHelper();
  TextEditingController amountController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  final _key = GlobalKey<FormState>();

  String paymentPath = 'assets/categories/payment.png';
  String receiptPath = 'assets/categories/receipt.png';
  String defaultWalletPath = 'assets/categories/wallet.png';
  String? selectedCategoryIcon;
  String? selectedFirstAccountIcon;
  String? selectedSecondAccountIcon;

  late DateTime selectedDate;

  @override
  void initState() {
    super.initState();
    selectedDate = widget.selectedDate;
    _initializeCategory();
    _loadLastSelections();
    _loadAttendanceState();
  }

  void _initializeCategory() {
    setState(() {
      selectedCategory = isReceipt
          ? CategoryHelper().receiptCategories[0]['name']
          : CategoryHelper().paymentCategories[0]['name'];
    });
  }

  Future<void> _loadAttendanceState() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isAttendanceEnabled = prefs.getBool('isAttendance') ?? false;
    });
  }

  void _resetSelections() {
    setState(() {
      selectedCategoryName = null;
      selectedCategoryIcon = null;
    });
  }

  Future<void> _loadLastSelections() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      toggleIndex = prefs.getInt('lastToggleIndex') ?? 1; // Default to Payment
      isReceipt = toggleIndex == 0;
      isPayment = toggleIndex == 1;
      isTransfer = toggleIndex == 2;
      selectedFirstAccountName = 'Cash';
      selectedFirstAccountIcon = 'assets/categories/cash-bill-dollar.png';
    });
  }

  Future<void> _saveToggleIndex(int index) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('lastToggleIndex', index);
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // ThemeData currentTheme = Theme.of(context);
    // Color textColor = currentTheme.brightness == Brightness.dark
    //     ? AppColor.kPurple
    //     : AppColor.kPurple;

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Form(
          key: _key,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              _buildDateAndAttendance(),
              _buildToggleSwitch(),
              _buildAccountAndCategorySelection(),
              _buildAmountAndDescriptionFields(),
              const SizedBox(height: 10),
              _buildAddButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateAndAttendance() {
    String date = DateFormat('dd MMMM y').format(selectedDate);
    return Row(
      mainAxisAlignment: isAttendanceEnabled
          ? MainAxisAlignment.spaceBetween
          : MainAxisAlignment.end,
      children: [
        TextButton(
          onPressed: () => _selectDate(context),
          child: Text(date),
        ),
      ],
    );
  }

  Widget _buildToggleSwitch() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ToggleSwitch(
        activeBgColors: [
          [AppColor.kGreen],
          [AppColor.kRed],
          [AppColor.kPrimary]
        ],
        minWidth: 100,
        initialLabelIndex: toggleIndex,
        labels: const ['Income', 'Expense', 'Transfer'],
        onToggle: (index) {
          setState(() {
            toggleIndex = index!;
            isReceipt = toggleIndex == 0;
            isPayment = toggleIndex == 1;
            isTransfer = toggleIndex == 2;
            _resetSelections();
            _saveToggleIndex(toggleIndex);
          });
        },
      ),
    );
  }

  Widget _buildAccountAndCategorySelection() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: toggleIndex == 2
          ? _buildTransferAccountSelection()
          : _buildPaymentOrReceiptSelection(),
    );
  }

  Widget _buildTransferAccountSelection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildAccountButton(
            1, selectedFirstAccountName, selectedFirstAccountIcon),
        const SizedBox(width: 16),
        _buildAccountButton(
            2, selectedSecondAccountName, selectedSecondAccountIcon),
      ],
    );
  }

  Widget _buildPaymentOrReceiptSelection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildAccountButton(
            1, selectedFirstAccountName, selectedFirstAccountIcon),
        const SizedBox(width: 16),
        _buildCategoryButton(),
      ],
    );
  }

  Widget _buildAccountButton(
      int accountIndex, String? accountName, String? accountIcon) {
    return Expanded(
      child: OutlinedButton.icon(
        onPressed: () => _accountSelection(accountIndex),
        label: Text(
          accountName ?? 'Account',
          overflow: TextOverflow.ellipsis,
        ),
        icon: accountIcon != null
            ? Image.asset(
                accountIcon,
                width: 24,
              )
            : Image.asset(defaultWalletPath, width: 24),
      ),
    );
  }

  Widget _buildCategoryButton() {
    return Expanded(
      child: OutlinedButton.icon(
        onPressed: () => categorySelection(
          isPayment
              ? CategoryHelper().paymentCategories
              : CategoryHelper().receiptCategories,
        ),
        label: Text(
          selectedCategoryName ?? 'Category',
          overflow: TextOverflow.ellipsis,
        ),
        icon: selectedCategoryIcon != null
            ? Image.asset(
                selectedCategoryIcon!,
                width: 24,
              )
            : isPayment
                ? Image.asset(
                    paymentPath,
                    width: 24,
                  )
                : Image.asset(
                    receiptPath,
                    width: 24,
                  ),
      ),
    );
  }

  Widget _buildAmountAndDescriptionFields() {
    return Row(
      children: [
        Expanded(
          child: _buildAmountField(),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildDescriptionField(),
        ),
      ],
    );
  }

  Widget _buildAmountField() {
    ThemeData currentTheme = Theme.of(context);

    Color color = currentTheme.brightness == Brightness.dark
        ? AppColor.kWhite
        : AppColor.kGrayscale100;
    return TextFormField(
      maxLength: 8,
      controller: amountController,
      decoration: InputDecoration(
        counterText: '',
        labelText: 'Amount',
        errorText: isAmountValid ? null : 'Enter a valid number',
        prefixIcon: const Icon(
          Icons.currency_rupee,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25),
          borderSide: BorderSide(
            color: AppColor.kRed,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25),
          borderSide: BorderSide(
            color: color,
          ),
        ),
      ),
      keyboardType: TextInputType.number,
      onChanged: (value) {
        setState(() {
          enteredAmount = double.tryParse(value);
          isAmountValid = enteredAmount != null && enteredAmount! >= 0;
          amount = enteredAmount ?? 0.0;
        });
      },
    );
  }

  Widget _buildDescriptionField() {
    ThemeData currentTheme = Theme.of(context);

    Color color = currentTheme.brightness == Brightness.dark
        ? AppColor.kWhite
        : AppColor.kGrayscale100;
    return TextFormField(
      controller: descriptionController,
      decoration: InputDecoration(
        labelText: 'Description',
        prefixIcon: const Icon(
          Icons.edit_note,
        ),
        labelStyle: const TextStyle(),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25),
          borderSide: BorderSide(
            color: AppColor.kRed,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25),
          borderSide: BorderSide(color: color),
        ),
      ),
      onChanged: (value) {
        setState(() {
          description = value;
        });
      },
    );
  }

  Widget _buildAddButton() {
    return CustomOutlineButton(
      height: 40,
      width: 130,
      borderRadius: 20,
      onTap: _onAddButtonPressed,
      text: 'Save',
    );
  }

  void _onAddButtonPressed() {
    if (_key.currentState?.validate() ?? false) {
      _saveTransaction();
    }
  }

  void _saveTransaction() {
    try {
      if (_isFormValid()) {
        TransactionModel newTransaction = _createTransaction();
        widget.onAddTransaction(newTransaction);
        Navigator.pop(context);
      } else {
        _showErrorMessage();
      }
    } catch (e) {
      debugPrint('Error saving transaction: $e');
    }
  }

  bool _isFormValid() {
    return enteredAmount != null &&
        ((toggleIndex != 2 &&
                selectedCategoryName != null &&
                selectedFirstAccountName != null) ||
            (toggleIndex == 2 &&
                selectedFirstAccountName != null &&
                selectedSecondAccountName != null &&
                selectedFirstAccountName != selectedSecondAccountName));
  }

  TransactionModel _createTransaction() {
    if (toggleIndex == 0 || toggleIndex == 1) {
      return TransactionModel(
        date: selectedDate,
        amount: amount,
        description: description,
        categoryName: selectedCategoryName ?? '',
        id: id,
        transactionType: toggleIndex == 1
            ? TransactionType.payment
            : TransactionType.receipt,
        categoryPath: (selectedCategoryIcon),
        fromAccount: selectedFirstAccountName.toString(),
        toAccount: selectedSecondAccountName.toString(),
        fromAccountImagePath: selectedFirstAccountIcon ?? '',
        toAccountImagePath: (selectedSecondAccountIcon),
        fromSubAccount: '',
        toSubAccount: '',
        generalCategory: '',
        generalSubCategory: '',
        subCategory: '',
      );
    } else {
      return Transfer(
        date: selectedDate,
        amount: amount,
        description: description,
        categoryName: selectedCategoryName ?? 'Category',
        id: id,
        transactionType: TransactionType.transfer,
        categoryPath: (selectedCategoryIcon),
        fromAccount: selectedFirstAccountName.toString(),
        toAccount: selectedSecondAccountName.toString(),
        fromAccountImagePath: selectedFirstAccountIcon ?? '',
        toAccountImagePath: (selectedSecondAccountIcon),
        fromSubAccount: '',
        toSubAccount: '',
      );
    }
  }

  void _showErrorMessage() {
    String errorMessage = '';

    if (toggleIndex == 0 || toggleIndex == 1) {
      if (selectedFirstAccountName == null) {
        errorMessage = 'Select the account';
      } else if (selectedCategoryName == null) {
        errorMessage = 'Select the category';
      } else if (amountController.text.isEmpty) {
        errorMessage = 'Please enter amount';
      }
    } else if (toggleIndex == 2 &&
        (selectedFirstAccountName == null ||
            selectedSecondAccountName == null)) {
      errorMessage = 'Select both accounts';
    } else if (toggleIndex == 2 &&
        selectedFirstAccountName == selectedSecondAccountName) {
      errorMessage = 'Select different accounts';
    } else if (toggleIndex == 2 && amountController.text.isEmpty) {
      errorMessage = 'Please enter amount';
    }

    CustomToast(message: errorMessage).showTopToast(context);
  }

  Future<void> _accountSelection(int accountIndex) async {
    final result = await showModalBottomSheet<Map<String, String>>(
      isScrollControlled: true,
      context: context,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.9,
          minChildSize: 0.5,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return AccountSelection(
              accounts: accountModel.accountCategories,
              selectedDate: widget.selectedDate,
              onCategorySelected: (String selectedAccount, String imagePath) {
                setState(() {
                  if (accountIndex == 1) {
                    selectedFirstAccountName = selectedAccount;
                    selectedFirstAccountIcon = imagePath;
                  } else {
                    selectedSecondAccountName = selectedAccount;
                    selectedSecondAccountIcon = imagePath;
                  }
                });
              },
            );
          },
        );
      },
    );

    if (result != null) {
      setState(() {
        if (accountIndex == 1) {
          selectedFirstAccountName = result['name'];
          selectedFirstAccountIcon = result['imagePath'];
        } else {
          selectedSecondAccountName = result['name'];
          selectedSecondAccountIcon = result['imagePath'];
        }
      });
    }
  }

  void addCategory(String name, String icon, TransactionType type) {
    setState(() {
      CategoryHelper().addCategory(name, icon, type);
      selectedCategory = name;
    });
  }

  void categorySelection(List<Map<String, dynamic>> categories) async {
    var transactionType =
        isPayment ? TransactionType.payment : TransactionType.receipt;
    var result = await showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.9,
          minChildSize: 0.5,
          maxChildSize: 0.9,
          expand: false,
          builder: (_, controller) {
            return CategorySelection(
              categories: categories,
              transactionType: transactionType,
              onCategoryCreated: (String newCategoryName, String selectedIcon) {
                setState(() {
                  addCategory(
                    newCategoryName,
                    selectedIcon,
                    transactionType,
                  );
                });
              },
              onCategorySelected: (
                String categoryName,
                String? icon,
              ) {
                setState(() {
                  selectedCategoryName = categoryName;
                  selectedCategoryIcon = icon;

                  // Preserve the transaction type here
                  transactionType = isReceipt
                      ? TransactionType.receipt
                      : TransactionType.payment;
                });
              },
              previouslySelectedCategory: selectedCategoryName,
              selectedDailyDate: widget.selectedDate,
              transactionBox: widget.transactionBox,
            );
          },
        );
      },
    );
    if (result != null) {
      setState(() {
        selectedCategoryName = result['name'];
        selectedCategoryIcon = result['imagePath'];
      });
    }
  }

  @override
  void dispose() {
    descriptionController.dispose();
    amountController.dispose();
    super.dispose();
  }
}
