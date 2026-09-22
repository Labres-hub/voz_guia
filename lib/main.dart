import 'package:flutter/material.dart';
import 'screens/main_navigation_screen.dart';
import 'screens/search_screen.dart';
import 'screens/navigation_screen.dart';

void main() {
  runApp(const VozGuiaApp());
}

class VozGuiaApp extends StatelessWidget {
  const VozGuiaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VozGuia',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(fontSize: 22),
          bodyMedium: TextStyle(fontSize: 20),
          titleLarge: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 72),
            textStyle: const TextStyle(fontSize: 22),
          ),
        ),
      ),
      // A tela inicial agora é o wrapper com a barra de navegação,
      // não mais a HomeScreen diretamente.
      initialRoute: '/',
      routes: {
        '/': (context) => const MainNavigationScreen(),
        '/search': (context) => const SearchScreen(),
        '/navigation': (context) => const NavigationScreen(),
      },
    );
  }
}