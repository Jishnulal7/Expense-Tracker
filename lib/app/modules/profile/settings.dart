import 'package:yarima_wallet_pro/app/modules/profile/components/exports.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({
    super.key,
  });

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  TextEditingController nameController = TextEditingController();

  int activeFieldIndex = -1;

  @override
  dispose() {
    super.dispose();
    nameController.dispose();
  }

  void setActiveFieldIndex(int index) {
    setState(() {
      activeFieldIndex = index;
    });
  }

  Widget buildEditableField({
    required String label,
    required TextEditingController controller,
    required int fieldIndex,
    required TextInputType keyboardType,
  }) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 18),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: controller,
            keyboardType: keyboardType,
            readOnly: activeFieldIndex != fieldIndex,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderSide: BorderSide(color: Theme.of(context).primaryColor),
              ),
              suffixIcon: activeFieldIndex == fieldIndex
                  ? Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextButton(
                          onPressed: () {},
                          child: Text(
                            'Save',
                            style: Theme.of(context)
                                .textTheme
                                .displayMedium!
                                .copyWith(fontSize: 14),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            setActiveFieldIndex(-1);
                          },
                          child: Text(
                            'Cancel',
                            style: Theme.of(context)
                                .textTheme
                                .displayMedium!
                                .copyWith(fontSize: 14),
                          ),
                        ),
                      ],
                    )
                  : TextButton(
                      child: Text(
                        'Edit',
                        style: Theme.of(context)
                            .textTheme
                            .displayMedium!
                            .copyWith(fontSize: 14),
                      ),
                      onPressed: () {
                        setActiveFieldIndex(fieldIndex);
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              children: [
                buildEditableField(
                  label: 'Name',
                  controller: nameController,
                  fieldIndex: 0,
                  keyboardType: TextInputType.name,
                ),
              ],
            ),
            const SizedBox(height: 10),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 5),
              child: PrimaryButton(
                text: 'Delete Account',
                onTap: () {},
                textColor: AppColor.kWhite,
                bgColor: AppColor.kPrimary,
                width: double.maxFinite,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
