import 'package:yarima_wallet_pro/app/modules/widgets/exports.dart';

class CustomSwitch extends StatelessWidget {
  final bool isSwitchOn;
  final ValueChanged<bool> onToggle;

  const CustomSwitch({
    super.key,
    required this.isSwitchOn,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Switch(
      activeColor: isSwitchOn ? AppColor.kRed : AppColor.kWhite,
      value: isSwitchOn,
      onChanged: onToggle,
    );
  }
}
