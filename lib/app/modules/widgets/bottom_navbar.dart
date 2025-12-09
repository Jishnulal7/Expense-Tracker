import 'package:yarima_wallet_pro/app/modules/widgets/exports.dart';

class BottomNavBar extends StatefulWidget {
  const BottomNavBar({
    super.key,
    required this.items,
    this.selectedIndex = 0,
  });

  final List<BottomNavItem> items;
  final int selectedIndex;

  @override
  State<BottomNavBar> createState() => _BottomState();
}

class _BottomState extends State<BottomNavBar> {
  late List<Widget> _widgetOptions;

  @override
  void initState() {
    super.initState();
    _widgetOptions = widget.items.map((item) => item.screen).toList();
  }

  void _onItemTapped(int index) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => _widgetOptions[index]),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      notchMargin: 7,
      shape: const CircularNotchedRectangle(),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(widget.items.length, (index) {
              return _buildNavBarItem(
                widget.items[index].icon,
                widget.items[index].label,
                index,
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildNavBarItem(IconData icon, String label, int index) {
    if (index == 2) {
      return InkWell(
        onTap: () {
          _onItemTapped(index + 1);
        },
        child: const SizedBox.shrink(),
      );
    }

    return InkWell(
      onTap: () {
        _onItemTapped(index);
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Icon(icon),
          const SizedBox(
            height: 5,
          ),
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold),
          )
        ],
      ),
    );
  }
}

class BottomNavItem {
  final IconData icon;
  final String label;
  final Widget screen;

  BottomNavItem({
    required this.icon,
    required this.label,
    required this.screen,
  });
}
