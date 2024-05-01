// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:angkutin/common/utils.dart';
import 'package:angkutin/provider/auth/auth_provider.dart';
import 'package:angkutin/screen/auth/fill_user_data_screen.dart';
import 'package:angkutin/screen/onboarding_screen.dart';
import 'package:angkutin/screen/user/user_home_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'package:angkutin/firebase_options.dart';
import 'package:angkutin/screen/auth/login_screen.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../../data/model/UserModel.dart' as user_model;

Future<void> main() async {
  // env
  await dotenv.load(fileName: ".env");

  // init firebase
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

// auth provider
  AuthenticationProvider authProvider = AuthenticationProvider();

// initial screen
  await authProvider.readUserDataLocally();
  bool isLoggedIn = authProvider.currentUser != null;

  Widget initialScreen = isLoggedIn
      ? ChangeNotifierProvider.value(
          value: authProvider, child: const UserHomeScreen())
      : const LoginScreen();

  runApp(
    ChangeNotifierProvider(
      create: (_) => authProvider,
      child: MaterialApp(
        home: MainApp(
          initialScreen: OnBoardingScreen(),
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
          navigatorObservers: [routeObserver],
          onGenerateRoute: (RouteSettings settings) {
            switch (settings.name) {
              // onboarding
              case OnBoardingScreen.ROUTE_NAME:
                return MaterialPageRoute(
                    builder: (_) => const OnBoardingScreen());

              // login
              case LoginScreen.ROUTE_NAME:
                return MaterialPageRoute(builder: (_) => const LoginScreen());

              case FillUserDataScreen.ROUTE_NAME:
                return MaterialPageRoute(
                    builder: (_) => const FillUserDataScreen());

              // user
              case UserHomeScreen.ROUTE_NAME:
                return MaterialPageRoute(
                    builder: (_) => const UserHomeScreen());

              //  case AbsensiScreen.ROUTE_NAME:
              // final List<String> arguments = settings.arguments as List<String>;
              // final screenTitle = arguments[0];
              // final token = arguments[1];
              // return MaterialPageRoute(
              //     builder: (_) => AbsensiScreen(
              //           screenTitle: screenTitle,
              //           token: token,
              //         ));

              default:
                return MaterialPageRoute(builder: (_) {
                  return const Scaffold(
                    body: Center(
                      child: Text('Page not found :('),
                    ),
                  );
                });
            }
          }),
    );
  }
}
