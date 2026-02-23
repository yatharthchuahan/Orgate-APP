import 'package:flutter/material.dart';
import 'package:orangtre/Screens/accounts.dart';
import 'package:orangtre/Screens/homeScreen.dart';
import 'package:orangtre/Screens/inventoryScreen.dart';
import 'package:orangtre/Screens/manageStocks.dart';
import 'package:orangtre/Screens/profileScreen.dart';
import 'package:orangtre/Screens/salesScreen.dart';
import 'package:orangtre/StoredData/LoginData.dart';
import 'package:orangtre/Widgets/customLoader.dart';
import 'package:orangtre/utils/auth_handler.dart';
import 'Screens/ForgotPassScreen.dart';
import 'Screens/loginScreen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const OrangtreApp());
}

class OrangtreApp extends StatelessWidget {
  const OrangtreApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      home: const AuthCheck(),
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primaryColor: const Color(0xFF2C3E50)),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const HomeScreen(),
        '/manageStock': (context) => const Managestocks(),
        '/inventory': (context) => const Inventoryscreen(),
        '/sales': (context) => const SalesScreen(),
        '/account': (context) => const Accounts(),
        '/profile': (context) => const Profilescreen(),
        '/reset' : (context) => const ForgotPassScreen()
      },
    );
  }
}

class AuthCheck extends StatefulWidget {
  const AuthCheck({super.key});

  @override
  State<AuthCheck> createState() => _AuthCheckState();
}

class _AuthCheckState extends State<AuthCheck> {
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    try {
      // Check if user is already logged in
      final loginResponse = await LoginStorage.getLoginResponse();

      if (!mounted) return;

      if (loginResponse != null && loginResponse.token.isNotEmpty) {
        // User is logged in, navigate to home
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        // User is not logged in, navigate to login screen
        Navigator.pushReplacementNamed(context, '/login');
      }
    } catch (e) {
      // If any error occurs, navigate to login screen
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF2C3E50),
      body: Center(
        child: LoaderOverlay()
      ),
    );
  }
}
