import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme/theme_manager.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final themeManager = ThemeManager();
  await themeManager.loadTheme();
  runApp(MyApp(themeManager: themeManager));
}

class MyApp extends StatelessWidget {
  final ThemeManager themeManager;

  const MyApp({super.key, required this.themeManager});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: themeManager,
      child: Consumer<ThemeManager>(
        builder: (context, themeManager, child) {
          return MaterialApp(
            title: 'Task Notes Manager',
            debugShowCheckedModeBanner: false,
            theme: themeManager.currentTheme,
            home: const HomeScreen(),
          );
        },
      ),
    );
  }
}
