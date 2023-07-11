import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grocerytrip/Utils/grocerylist_model.dart';
import 'package:grocerytrip/Utils/store_notifier.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Pages/homepage.dart';

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final darkMode = prefs.getBool('dark_mode') ?? false;
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp(darkMode: darkMode));
}

class MyApp extends StatefulWidget {
  final bool darkMode;
  const MyApp({super.key, required this.darkMode});
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _darkMode = false;
  IconData _icon = Icons.light_mode_outlined;

  @override
  void initState() {
    super.initState();

    _darkMode = widget.darkMode;
    _icon =
        widget.darkMode ? Icons.dark_mode_outlined : Icons.light_mode_outlined;
  }

  // This widget is the root of your application.
  void toggleDarkMode() async {
    final prefs = await SharedPreferences.getInstance();
    _darkMode = !_darkMode;
    _icon = _darkMode ? Icons.dark_mode_outlined : Icons.light_mode_outlined;
    prefs.setBool('dark_mode', _darkMode);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final primaryTextColor = _darkMode
        ? const Color.fromARGB(255, 243, 243, 243)
        : const Color.fromARGB(255, 71, 94, 110);
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<GroceryListModel>(
          create: (_) => GroceryListModel(),
        ),
        ChangeNotifierProvider<StoreNotifier>(
          create: (_) => StoreNotifier(),
        ),
      ],
      child: MaterialApp(
        title: 'GroceryTrip',
        theme: _buildTheme(_darkMode, primaryTextColor),
        home: MyHomePage(
          title: 'GroceryTrip',
          toggleDarkMode: toggleDarkMode,
          icon: _icon,
        ),
      ),
    );
  }

  ThemeData _buildTheme(bool darkMode, Color primaryTextColor) {
    var baseTheme = ThemeData(
      colorSchemeSeed: const Color.fromARGB(255, 100, 235, 171),
      useMaterial3: true,
      brightness: darkMode ? Brightness.dark : Brightness.light,
      appBarTheme: AppBarTheme(
        foregroundColor: primaryTextColor,
        elevation: 2,
        centerTitle: true,
      ),
    );

    return baseTheme.copyWith(
      textTheme: GoogleFonts.robotoTextTheme(
        baseTheme.textTheme.apply(
          bodyColor: primaryTextColor,
          displayColor: primaryTextColor,
        ),
      ),
    );
  }
}
