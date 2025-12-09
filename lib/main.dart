import 'package:yarima_wallet_pro/app/data/constants/themes.dart';
import 'package:yarima_wallet_pro/app/data/provider/currency_provider.dart';
import 'package:yarima_wallet_pro/app/data/provider/theme_notifer.dart';
import 'package:yarima_wallet_pro/app/models/attendance_model.dart';
import 'package:yarima_wallet_pro/app/models/budget_model.dart';
import 'package:yarima_wallet_pro/app/models/hive_color.dart';
import 'package:yarima_wallet_pro/app/models/theme_mode_adapetar.g.dart';
import 'package:yarima_wallet_pro/app/modules/account/components/exports.dart';
import 'package:yarima_wallet_pro/app/modules/auth/fingerprint_auth.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yarima_wallet_pro/app/modules/pdf/components/exports.dart';
import 'app/models/task_model.dart';

void main() async {
  await Hive.initFlutter();
  await GetStorage.init();

  // Initialize GetStorage instances for specific data
  GetStorage.init('receipt_categories');
  GetStorage.init('payment_categories');
  GetStorage.init('accounts');
  GetStorage.init('biometric_enabled');

  Hive.registerAdapter<TransactionModel>(TransactionModelAdapter());
  Hive.registerAdapter(TransactionTypeAdapter());
  Hive.registerAdapter(AttendanceModelAdapter());
  Hive.registerAdapter(TaskModelAdapter());
  Hive.registerAdapter(ThemeModeAdapter());
  Hive.registerAdapter(BudgetModelAdapter());
  Hive.registerAdapter(BudgetPeriodAdapter());
  Hive.registerAdapter(HiveColorAdapter());

  final appDocumentDirectory =
      await path_provider.getApplicationDocumentsDirectory();
  Hive.init(appDocumentDirectory.path);

  await Hive.openBox<TransactionModel>('transactions');
  await Hive.openBox<TaskModel>('tasks');
  await Hive.openBox('themeSettings');
  await Hive.openBox('themeMode');
  await Hive.openBox('themeColor');
  await Hive.openBox<BudgetModel>('budgets');
  await Hive.openBox<AttendanceModel>('attendanceBox');
  await SharedPreferences.getInstance();

  runApp(
    const MyAppWrapper(),
  );
}

class MyAppWrapper extends StatelessWidget {
  const MyAppWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    // Provide both ThemeNotifier and CurrencyNotifier globally
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CurrencyNotifier()),
        ChangeNotifierProvider(create: (_) => ThemeNotifier()),
      ],
      child: const MyApp(),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    return Consumer<ThemeNotifier>(
      builder: (context, themeNotifier, _) {
        return MaterialApp(
          themeMode: themeNotifier.themeMode,
          theme: themes(ThemeMode.light, themeNotifier.primaryColor),
          darkTheme: themes(ThemeMode.dark, themeNotifier.primaryColor),
          title: 'Yarima Wallet Pro',
          debugShowCheckedModeBanner: false,
          locale: const Locale('en_US'),
          // home: const FingerprintAuthPage(),
        );
      },
    );
  }
}
