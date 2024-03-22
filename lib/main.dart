// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:angkutin/provider/auth/auth_provider.dart';
import 'package:angkutin/screen/home_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'package:angkutin/firebase_options.dart';
import 'package:angkutin/screen/auth/login_screen.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  // init firebase
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
// auth provider
  AuthenticationProvider authProvider = AuthenticationProvider();

// initial screen
  print("Current User : ${FirebaseAuth.instance.currentUser}");
  Widget initialScreen = authProvider.isLoggedIn()
      ? ChangeNotifierProvider.value(value: authProvider, child: const HomeScreen())
      : const LoginScreen();

  runApp(
    ChangeNotifierProvider(
      create: (_) => authProvider,
      child: MaterialApp(
        home: MainApp(
          initialScreen: initialScreen,
          // Use JustDestinationScreen for logged-in state
        ),
      ),
    ),
  );
}

class MainApp extends StatelessWidget {
  final Widget initialScreen;
  const MainApp({
    Key? key,
    required this.initialScreen,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AuthenticationProvider()),
        ],
        child: MaterialApp(
          home: initialScreen,
        ));
  }
}
