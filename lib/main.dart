// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:angkutin/common/utils.dart';
import 'package:angkutin/provider/auth/auth_provider.dart';
import 'package:angkutin/provider/upload_provider.dart';
import 'package:angkutin/screen/auth/fill_user_data_screen.dart';
import 'package:angkutin/screen/auth/map_screen.dart';
import 'package:angkutin/screen/onboarding_screen.dart';
import 'package:angkutin/screen/user/user_history_screen.dart';
import 'package:angkutin/screen/user/user_home_screen.dart';
import 'package:angkutin/screen/user/user_monitor_request_screen.dart';
import 'package:angkutin/screen/user/user_profile_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'package:angkutin/firebase_options.dart';
import 'package:angkutin/screen/auth/login_screen.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'screen/user/request_accepted_screen.dart';
import 'screen/user/request_service_screen.dart';

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

  // onboarding state
  bool isOnboarding = await authProvider.getOnBoardingState();
  bool isLoggedIn = await authProvider.getLoginState();
  // Future<bool> isFillData = authProvider.getFillDataState();

  print('onboarding : $isOnboarding || isLogin : $isLoggedIn');
  Widget initialScreen = isOnboarding
      ? isLoggedIn
          ? ChangeNotifierProvider.value(
              value: authProvider, child: const UserHomeScreen())
          : const LoginScreen()
      : const OnBoardingScreen();

  runApp(
    ChangeNotifierProvider(
      create: (_) => authProvider,
      child: MaterialApp(
        home: MainApp(
          initialScreen: UserHomeScreen(),
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
        ChangeNotifierProvider(create: (_) => UploadProvider()),
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

              case UserHistoryScreen.ROUTE_NAME:
                return MaterialPageRoute(
                    builder: (_) => const UserHistoryScreen());

              case UserProfileScreen.ROUTE_NAME:
                return MaterialPageRoute(
                    builder: (_) => const UserProfileScreen());

              case UserMonitorRequestScreen.ROUTE_NAME:
                return MaterialPageRoute(
                    builder: (_) => const UserMonitorRequestScreen());

              case RequestServiceScreen.ROUTE_NAME:
                final titleScreen = settings.arguments as String;
                return MaterialPageRoute(
                    builder: (_) => RequestServiceScreen(
                          titleScreen: titleScreen,
                        ));
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
