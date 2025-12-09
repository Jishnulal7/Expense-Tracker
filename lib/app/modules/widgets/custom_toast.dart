import 'package:yarima_wallet_pro/app/modules/widgets/exports.dart';

class CustomToast extends StatelessWidget {
  final String message;
  final String? image;
  final Color backgroundColor;
  final Color iconColor;
  final Duration duration;

  const CustomToast({
    super.key,
    required this.message,
    this.image,
    this.backgroundColor = Colors.black54,
    this.iconColor = Colors.white,
    this.duration = const Duration(seconds: 2),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25.0),
        color: AppColor.kGrayscaleDark100,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            image!,
            width: 25,
          ),
          const SizedBox(
            width: 12.0,
          ),
          Flexible(
            child: Align(
              alignment: Alignment.center,
              child: Text(
                message,
                style: TextStyle(
                  color: AppColor.kWhite,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void showToast(BuildContext context) {
    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (BuildContext context) {
        return Positioned(
          bottom: 100.0,
          left: MediaQuery.of(context).size.width * 0.2,
          right: MediaQuery.of(context).size.width * 0.2,
          child: Material(
            color: Colors.transparent,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: CustomToast(
                message: message,
                image: 'assets/images/Logo.png',
                backgroundColor: backgroundColor,
                iconColor: iconColor,
                duration: duration,
              ),
            ),
          ),
        );
      },
    );
    overlay.insert(overlayEntry);
    Future.delayed(duration, () {
      overlayEntry.remove();
    });
  }

  void showTopToast(BuildContext context) {
    final double height = MediaQuery.of(context).size.height;
    final double width = MediaQuery.of(context).size.width;
    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (BuildContext context) {
        return Positioned(
          top: height / 3.5,
          left: width * .2,
          right: width * .2,
          child: Material(
            color: Colors.transparent,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: CustomToast(
                message: message,
                image: 'assets/images/Logo.png',
                backgroundColor: backgroundColor,
                iconColor: iconColor,
                duration: duration,
              ),
            ),
          ),
        );
      },
    );
    overlay.insert(overlayEntry);
    Future.delayed(duration, () {
      overlayEntry.remove();
    });
  }
}
