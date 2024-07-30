import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/chat_provider.dart';
import 'providers/class_provider.dart';
import 'providers/goal_provider.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/home_screen.dart';
import 'screens/forgot_password_screen.dart';
import 'providers/qr_code_provider.dart';
import 'services/api_service.dart';
import 'providers/attendance_provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AuthProvider()),
        ChangeNotifierProvider(create: (context) => ChatProvider()),
        ChangeNotifierProvider(create: (context) => QRCodeProvider()),
        ChangeNotifierProvider(create: (context) => GoalProvider()),
        Provider<ApiService>(create: (context) => ApiService()),
        ChangeNotifierProvider(create: (context) => ClassProvider()),
        ChangeNotifierProvider(create: (_) => AttendanceProvider(ApiService())),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chickie',
      theme: ThemeData(
        visualDensity: VisualDensity.adaptivePlatformDensity,
        primaryColor: const Color(0xFFF5D500),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFF5D500),
          primary: const Color(0xFFF5D500),
        ),
        fontFamily: 'Montserrat',
        textTheme: const TextTheme(
          bodyLarge: TextStyle(fontSize: 14.0),
          bodyMedium: TextStyle(fontSize: 14.0),
          labelLarge: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold),
        ).apply(
          bodyColor: Colors.black87,
          displayColor: Colors.black87,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.black87,
            backgroundColor: const Color(0xFFF5D500),
            textStyle: const TextStyle(
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.bold,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30.0),
            ),
            padding:
                const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
          ),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFF5D500),
          foregroundColor: Colors.black87,
          titleTextStyle: TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ),
      home: Consumer<AuthProvider>(
        builder: (ctx, auth, _) =>
            auth.isLoggedIn ? HomeScreen() : LoginScreen(),
      ),
      routes: {
        '/login': (ctx) => LoginScreen(),
        '/register': (ctx) => const RegisterScreen(),
        '/home': (ctx) => HomeScreen(),
        '/forgot_password': (ctx) => ForgotPasswordScreen(),
      },
    );
  }
}
