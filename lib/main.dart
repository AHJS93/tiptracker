import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'pages/today_page.dart';
import 'pages/history_page.dart';
import 'pages/stats_page.dart';
import 'models/entry.dart';
import 'providers/entry_provider.dart';
import 'providers/theme_provider.dart';
import 'pages/settings_page.dart';
import 'package:flutter_svg/flutter_svg.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  Hive.registerAdapter(EntryAdapter());
  await Hive.openBox<Entry>('entries');
  await Hive.openBox('app_settings');

  final entryProvider = EntryProvider();
  await entryProvider.init();

  final themeProvider = ThemeProvider();
  await themeProvider.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => entryProvider),
        ChangeNotifierProvider(create: (_) => themeProvider),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int _index = 0;

  final pages = const [TodayPage(), HistoryPage(), StatsPage()];

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: themeProvider.themeMode,

      // 🌞 LIGHT THEME
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color.fromARGB(255, 0, 150, 52),
        brightness: Brightness.light,
        scaffoldBackgroundColor: Colors.white,
        cardTheme: CardThemeData(
          color: Color.fromARGB(255, 236, 236, 236)
        ) // 👈 REQUIRED
      ),

      // 🌙 DARK THEME
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 0, 255, 26),
          brightness: Brightness.dark,
        ),

        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: const Color.fromARGB(255, 20, 20, 20),
          indicatorColor: const Color.fromARGB(255, 35, 176, 28),
          iconTheme: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return const IconThemeData(color: Colors.black);
            }
            return const IconThemeData(color: Colors.grey);
          }),
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return const TextStyle(color: Color.fromARGB(255, 35, 176, 28));
            }
            return const TextStyle(color: Colors.grey);
          }),
        ),

        cardTheme: CardThemeData(
          color: Color.fromARGB(255, 30, 30, 30)
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color.fromARGB(255, 20, 20, 20),
        ),

        scaffoldBackgroundColor: const Color(0xFF0F0F0F), // 👈 DARK BACKGROUND
      ),

      home: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Row(
            children: [
              SvgPicture.asset("assets/tipperLogo.svg", height: 24),
              const Spacer(),
              Builder(
                builder: (context) {
                  return IconButton(
                    icon: const Icon(
                      Icons.settings,
                      color: Color.fromARGB(255, 35, 176, 28),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const SettingsPage()),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),

        body: pages[_index],

        bottomNavigationBar: NavigationBar(
          selectedIndex: _index,
          onDestinationSelected: (i) => setState(() => _index = i),
          destinations: const [
            NavigationDestination(icon: Icon(Icons.today), label: "Today"),
            NavigationDestination(icon: Icon(Icons.list), label: "History"),
            NavigationDestination(icon: Icon(Icons.bar_chart), label: "Stats"),
          ],
        ),
      ),
    );
  }
}

