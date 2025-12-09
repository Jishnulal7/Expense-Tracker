import 'package:yarima_wallet_pro/app/modules/account/components/account_helper.dart';
import 'package:yarima_wallet_pro/app/modules/add/exports.dart';
import 'package:intl/intl.dart';

class EditScreen extends StatefulWidget {
  final TransactionModel? transaction;
  final DateTime selectedDailyDate;
  final Box<TransactionModel> transactionBox;
  const EditScreen({
    super.key,
    required this.transaction,
    required this.selectedDailyDate,
    required this.transactionBox,
  });

  @override
  _EditScreenState createState() => _EditScreenState();
}

class _EditScreenState extends State<EditScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _amountController;
  late TextEditingController _descriptionController;
  String selectedCategory = '';
  bool isPayment = true;
  bool isTransfer = false;
  late int toggleIndex;
  String? selectedCategoryName;
  String? selectedCategoryIcon;
  String? selectedFirstAccountName;
  String? selectedFirstAccountIcon;
  String? selectedSecondAccountName;
  String? selectedSecondAccountIcon;
  late DateTime selectedDate;
  TransactionType transactionType = TransactionType.payment;
  String paymentPath = 'assets/categories/payment.png';
  String receiptPath = 'assets/categories/receipt.png';
  String defaultWalletPath = 'assets/categories/wallet.png';

  @override
  void initState() {
    super.initState();
    initializeControllers();
    initializeSelections();
    selectedDate = widget.transaction?.date ?? widget.selectedDailyDate;
  }

  void initializeControllers() {
    _amountController = TextEditingController(
      text: widget.transaction?.amount.toString() ?? '',
    );
    _descriptionController = TextEditingController(
      text: widget.transaction?.description ?? '',
    );
  }

  void initializeSelections() {
    if (widget.transaction != null) {
      selectedCategory = widget.transaction!.categoryName ?? '';
      selectedCategoryName = widget.transaction!.categoryName;
      selectedFirstAccountName = widget.transaction!.fromAccount;
      selectedSecondAccountName = widget.transaction!.toAccount;
      isPayment =
          widget.transaction!.transactionType == TransactionType.payment;
      isTransfer =
          widget.transaction!.transactionType == TransactionType.transfer;
      toggleIndex = isTransfer ? 2 : (isPayment ? 1 : 0);
      initializeIcons();
    } else {
      toggleIndex = 0; // Default to Receipt
    }
  }

  void initializeIcons() {
    selectedCategoryIcon = widget.transaction?.categoryPath;
    selectedFirstAccountIcon = widget.transaction?.fromAccountImagePath;
    selectedSecondAccountIcon = widget.transaction?.toAccountImagePath;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(35.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              buildDateButton(),
              const SizedBox(height: 16),
              buildToggleSwitch(),
              const SizedBox(height: 16),
              isTransfer ? buildTransferRow() : buildPaymentReceiptRow(),
              const SizedBox(height: 16),
              buildAmountDescriptionRow(),
              const SizedBox(height: 16),
              buildSaveButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildDateButton() {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: _selectDate,
        child: Text(DateFormat('dd MMMM y').format(selectedDate)),
      ),
    );
  }

  Future<void> _selectDate() async {
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

  Widget buildToggleSwitch() {
    return ToggleSwitch(
      minWidth: 100,
      activeBgColors: [
        [AppColor.kGreen],
        [AppColor.kRed],
        [AppColor.kPrimary]
      ],
      initialLabelIndex: toggleIndex,
      labels: const ['Income', 'Expense', 'Transfer'],
      onToggle: (index) {
        setState(() {
          toggleIndex = index!;
          isPayment = index == 1;
          isTransfer = index == 2;
          resetAccountSelections();
        });
      },
    );
  }

  void resetAccountSelections() {
    selectedFirstAccountName = null;
    selectedFirstAccountIcon = null;
    selectedSecondAccountName = null;
    selectedSecondAccountIcon = null;
  }

  Widget buildTransferRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        buildAccountButton(
            1, selectedFirstAccountName, selectedFirstAccountIcon),
        const SizedBox(width: 5),
        buildAccountButton(
            2, selectedSecondAccountName, selectedSecondAccountIcon),
      ],
    );
  }

  Widget buildPaymentReceiptRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        buildAccountButton(
            1, selectedFirstAccountName, selectedFirstAccountIcon),
        const SizedBox(width: 5),
        buildCategoryButton(),
      ],
    );
  }

  Widget buildAccountButton(
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

  Widget buildCategoryButton() {
    return Expanded(
      child: OutlinedButton.icon(
        onPressed: () => _categorySelection(isPayment
            ? CategoryHelper().paymentCategories
            : CategoryHelper().receiptCategories),
        label: Text(
          selectedCategoryName ?? 'Category',
          overflow: TextOverflow.ellipsis,
        ),
        icon: selectedCategoryIcon != null
            ? Image.asset(
                selectedCategoryIcon!,
                width: 24,
              )
            : Image.asset(toggleIndex == 0 ? receiptPath : paymentPath,
                width: 24),
      ),
    );
  }

  Widget buildAmountDescriptionRow() {
    return Row(
      children: [
        Expanded(
          child: buildAmountField(),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: buildDescriptionField(),
        ),
      ],
    );
  }

  Widget buildAmountField() {
    ThemeData currentTheme = Theme.of(context);

    Color textColor = currentTheme.brightness == Brightness.dark
        ? AppColor.kWhite
        : AppColor.kGrayscale100;
    return TextFormField(
      maxLength: 8,
      validator: (value) =>
          value == null || value.isEmpty ? 'Please enter the amount' : null,
      controller: _amountController,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        counterText: '',
        border: const OutlineInputBorder(),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25),
          borderSide: BorderSide(color: AppColor.kRed),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25),
          borderSide: BorderSide(color: textColor),
        ),
        labelText: 'Amount',
        prefixIcon: Icon(Icons.currency_rupee, color: AppColor.kPurple),
      ),
    );
  }

  Widget buildDescriptionField() {
    ThemeData currentTheme = Theme.of(context);

    Color textColor = currentTheme.brightness == Brightness.dark
        ? AppColor.kWhite
        : AppColor.kGrayscale100;

    return TextFormField(
      controller: _descriptionController,
      decoration: InputDecoration(
        labelText: 'Description',
        border: const OutlineInputBorder(),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25),
          borderSide: BorderSide(color: AppColor.kRed),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25),
          borderSide: BorderSide(color: textColor),
        ),
        prefixIcon: Icon(Icons.edit_note, color: AppColor.kPurple),
      ),
    );
  }

  Widget buildSaveButton() {
    return OutlinedButton(
      onPressed: onEdit,
      child: const Text('Save'),
    );
  }

  void onEdit() {
    if (_formKey.currentState!.validate()) {
      try {
        final updatedTransaction = createUpdatedTransaction();
        var transactionsBox = Hive.box<TransactionModel>('transactions');
        transactionsBox.put(widget.transaction!.key, updatedTransaction);
        Navigator.of(context).pop(updatedTransaction);
      } catch (e) {
        debugPrint('An error occurred: $e');
      }
    } else {
      displayErrorMessage();
    }
  }

  TransactionModel createUpdatedTransaction() {
    final double updatedAmount = double.tryParse(_amountController.text) ?? 0.0;
    final TransactionType updatedType = getUpdatedTransactionType();

    return updatedType == TransactionType.transfer
        ? Transfer(
            amount: updatedAmount,
            description: _descriptionController.text,
            transactionType: updatedType,
            date: widget.transaction!.date,
            categoryName: '',
            id: widget.transaction!.id,
            categoryPath: '',
            fromAccount: selectedFirstAccountName.toString(),
            toAccount: selectedSecondAccountName.toString(),
            fromAccountImagePath: selectedFirstAccountIcon.toString(),
            toAccountImagePath: selectedSecondAccountIcon.toString(),
            fromSubAccount: '',
            generalCategory: '',
            generalSubCategory: '',
            toSubAccount: '',
            subCategory: '',
          )
        : TransactionModel(
            amount: updatedAmount,
            description: _descriptionController.text,
            transactionType: updatedType,
            date: widget.transaction!.date,
            categoryName: selectedCategory,
            id: widget.transaction!.id,
            categoryPath: selectedCategoryIcon.toString(),
            fromAccount: selectedFirstAccountName.toString(),
            toAccount: '',
            fromAccountImagePath: selectedFirstAccountIcon.toString(),
            toAccountImagePath: '',
            fromSubAccount: '',
            generalCategory: '',
            generalSubCategory: '',
            toSubAccount: '',
            subCategory: '',
          );
  }

  TransactionType getUpdatedTransactionType() {
    return isPayment
        ? TransactionType.payment
        : (isTransfer ? TransactionType.transfer : TransactionType.receipt);
  }

  void displayErrorMessage() {
    String errorMessage = '';

    if (toggleIndex == 0 || toggleIndex == 1) {
      errorMessage = getPaymentReceiptErrorMessage();
    } else if (toggleIndex == 2) {
      errorMessage = getTransferErrorMessage();
    }

    CustomToast(message: errorMessage).showToast(context);
  }

  String getPaymentReceiptErrorMessage() {
    if (selectedFirstAccountName == null) {
      return 'Select the account';
    } else if (selectedCategoryName == null) {
      return 'Select the category';
    } else if (_amountController.text.isEmpty) {
      return 'Please enter amount';
    } else {
      return 'Please enter description';
    }
  }

  String getTransferErrorMessage() {
    if (selectedFirstAccountName == null || selectedSecondAccountName == null) {
      return 'Select both accounts';
    } else if (selectedFirstAccountName == selectedSecondAccountName) {
      return 'Select different accounts';
    } else if (_amountController.text.isEmpty) {
      return 'Please enter amount';
    } else {
      return '';
    }
  }

  Future<void> _accountSelection(int accountIndex) async {
    AccountHelper accountModel = AccountHelper();
    var result = await showModalBottomSheet(
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
              selectedDate: widget.selectedDailyDate,
              onCategorySelected:
                  (String selectedFirstAccount, String imagePath) {
                setState(() {
                  if (accountIndex == 1) {
                    selectedFirstAccountName = selectedFirstAccount;
                    selectedFirstAccountIcon = imagePath;
                  } else {
                    selectedSecondAccountName = selectedFirstAccount;
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

  Future<void> _categorySelection(List<Map<String, dynamic>> categories) async {
    var result = await showModalBottomSheet<Map<String, dynamic>?>(
      isScrollControlled: true,
      context: context,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.9,
          minChildSize: 0.5,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return CategorySelection(
              categories: categories,
              transactionType:
                  isPayment ? TransactionType.payment : TransactionType.receipt,
              onCategoryCreated: (String newCategoryName, String selectedIcon) {
                addCategory(newCategoryName, selectedIcon);
              },
              onCategorySelected: (String categoryName, String? icon) {
                setSelectedCategory(categoryName, icon);
              },
              selectedDailyDate: widget.selectedDailyDate,
              transactionBox: widget.transactionBox,
            );
          },
        );
      },
    );

    if (result != null) {
      setSelectedCategory(
        result['name'] as String?,
        result['imagePath'] as String?,
      );
    }
  }

  void setSelectedCategory(String? categoryName, String? icon) {
    setState(() {
      selectedCategoryName = categoryName;
      selectedCategoryIcon = icon;
      selectedCategory = categoryName ?? '';
      toggleIndex = isPayment ? 0 : 1;
    });
  }

  void addCategory(String name, String icon) {
    setState(() {
      CategoryHelper().addCategory(name, icon, transactionType);
      selectedCategory = name;
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}
