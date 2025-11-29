import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import 'screens/home_screen.dart';
import 'providers/todo_provider.dart';
import 'providers/meal_provider.dart';
import 'providers/calendar_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const WallApp());
}

class WallApp extends StatelessWidget {
  const WallApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TodoProvider()),
        ChangeNotifierProvider(create: (_) => MealProvider()),
        ChangeNotifierProvider(create: (_) => CalendarProvider()),
      ],
      child: MaterialApp(
        title: 'Wallapp - Fridge Assistant',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.teal,
            brightness: Brightness.light,
          ),
          textTheme: GoogleFonts.poppinsTextTheme(),
          useMaterial3: true,
          cardTheme: CardTheme(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
        home: const HomeScreen(),
      ),
    );
  }
}
