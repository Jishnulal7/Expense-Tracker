import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yarima_wallet_pro/app/data/provider/theme_notifer.dart';


class ThemeSelectionPage extends StatefulWidget {
  const ThemeSelectionPage({super.key});

  @override
  ThemeSelectionPageState createState() => ThemeSelectionPageState();
}

class ThemeSelectionPageState extends State<ThemeSelectionPage> {
  // List of predefined color options
  final List<Color> _colorOptions = [
    Colors.blue,
    Colors.green,
    Colors.purple,
    Colors.orange,
    Colors.red,
    Colors.teal,
    Colors.indigo,
    Colors.pink,
    Colors.amber,
    Colors.deepPurple,
  ];

  @override
  Widget build(BuildContext context) {
    // Access ThemeNotifier using Provider
    final themeNotifier = Provider.of<ThemeNotifier>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Theme & Color Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Theme Mode Section
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              'Theme Mode',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Card(
            child: Column(
              children: [
                RadioListTile<ThemeMode>(
                  title: const Text('System Default'),
                  value: ThemeMode.system,
                  groupValue: themeNotifier.themeMode,
                  onChanged: (value) =>
                      _handleThemeChange(themeNotifier, value),
                ),
                RadioListTile<ThemeMode>(
                  title: const Text('Light Theme'),
                  value: ThemeMode.light,
                  groupValue: themeNotifier.themeMode,
                  onChanged: (value) =>
                      _handleThemeChange(themeNotifier, value),
                ),
                RadioListTile<ThemeMode>(
                  title: const Text('Dark Theme'),
                  value: ThemeMode.dark,
                  groupValue: themeNotifier.themeMode,
                  onChanged: (value) =>
                      _handleThemeChange(themeNotifier, value),
                ),
              ],
            ),
          ),

          // Color Customization Section
          const SizedBox(height: 20),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              'Color Palette',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Select Primary Color',
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 10),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _colorOptions.map((color) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                          child: GestureDetector(
                            onTap: () =>
                                _handleColorChange(themeNotifier, color),
                            child: Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: color,
                                shape: BoxShape.circle,
                                border: themeNotifier.primaryColor == color
                                    ? Border.all(
                                        color: Colors.white,
                                        width: 4,
                                      )
                                    : null,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    spreadRadius: 1,
                                    blurRadius: 3,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: themeNotifier.primaryColor == color
                                  ? const Icon(
                                      Icons.check,
                                      color: Colors.white,
                                    )
                                  : null,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleThemeChange(ThemeNotifier themeNotifier, ThemeMode? value) {
    if (value != null) {
      themeNotifier.setTheme(value);
    }
  }

  void _handleColorChange(ThemeNotifier themeNotifier, Color color) {
    // Update the primary color
    themeNotifier.setPrimaryColor(color);

    // Show a snackbar to confirm color change
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Primary color changed to ${color.toString()}'),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}