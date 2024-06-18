// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:angkutin/common/utils.dart';
import 'package:angkutin/data/model/RequestModel.dart';
import 'package:angkutin/database/storage_service.dart';
import 'package:angkutin/provider/auth/auth_provider.dart';
import 'package:angkutin/provider/driver/driver_daily_provider.dart';
import 'package:angkutin/provider/driver/driver_ongoing_service.dart';
import 'package:angkutin/provider/driver/driver_service_provider.dart';
import 'package:angkutin/provider/monitor_provider.dart';
import 'package:angkutin/provider/upload_provider.dart';
import 'package:angkutin/provider/user/user_daily_provider.dart';
import 'package:angkutin/provider/user/user_request_provider.dart';
import 'package:angkutin/screen/auth/fill_user_data_screen.dart';
import 'package:angkutin/screen/auth/map_screen.dart';
import 'package:angkutin/screen/driver/driver_detail_service_screen.dart';
import 'package:angkutin/screen/driver/driver_history_screen.dart';
import 'package:angkutin/screen/driver/driver_monitor_screen.dart';
import 'package:angkutin/screen/driver/driver_request_waste.dart';
import 'package:angkutin/screen/onboarding_screen.dart';
import 'package:angkutin/screen/user/user_history_screen.dart';
import 'package:angkutin/screen/user/user_home_screen.dart';
import 'package:angkutin/screen/user/user_monitor_request_screen.dart';
import 'package:angkutin/screen/user/user_profile_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'package:angkutin/firebase_options.dart';
import 'package:angkutin/screen/auth/login_screen.dart';
import 'package:intl/find_locale.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'screen/driver/driver_gome_screen.dart';
import 'screen/user/request_accepted_screen.dart';
import 'screen/user/request_service_screen.dart';
import '../../data/model/UserModel.dart' as userModel;

Future<void> main() async {
  // env
  await dotenv.load(fileName: ".env");

  // local
  // await findSystemLocale();

  // init firebase
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

// auth provider
  AuthenticationProvider authProvider = AuthenticationProvider();

// initial screen
  await authProvider.readUserDataLocally();
  print("Data user local : ${authProvider.readUserDataLocally()}");

  // onboarding state
  bool isOnboarding = await authProvider.getOnBoardingState();
  bool isLoggedIn = await authProvider.getLoginState();
  String userRole = await authProvider.getRoleState();
  bool isMasyarakat = userRole == "Masyarakat";
  // Future<bool> isFillData = authProvider.getFillDataState();

  print('onboarding : $isOnboarding || isLogin : $isLoggedIn');
  Widget initialScreen = isOnboarding
      ? isMasyarakat
          ? isLoggedIn
              ? ChangeNotifierProvider.value(
                  value: authProvider, child: const UserHomeScreen())
              : const LoginScreen()
          : const DriverHomeScreen()
      : const OnBoardingScreen();

  runApp(
    ChangeNotifierProvider(
      create: (_) => authProvider,
      child: MaterialApp(
        home: MainApp(
          initialScreen: initialScreen,
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
    StorageService storageService = StorageService();

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthenticationProvider()),
        ChangeNotifierProvider(create: (_) => UploadProvider(storageService)),
        ChangeNotifierProvider(
            create: (_) => UserRequestProvider(storageService)),
        ChangeNotifierProvider(create: (_) => DriverDailyProvider()),
        ChangeNotifierProvider(create: (_) => DriverServiceProvider()),
        ChangeNotifierProvider(create: (_) => DriverOngoingService()),
        ChangeNotifierProvider(create: (_) => UserDailyProvider()),
        ChangeNotifierProvider(create: (_) => MonitorProvider()),
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
              final String userId =
                    settings.arguments as String;
                return MaterialPageRoute(
                    builder: (_) =>  UserHistoryScreen(userId: userId,));

              case UserProfileScreen.ROUTE_NAME:
                return MaterialPageRoute(
                    builder: (_) => const UserProfileScreen());

              case RequestAcceptedScreen.ROUTE_NAME:
                return MaterialPageRoute(
                    builder: (_) => const RequestAcceptedScreen());

              case UserMonitorRequestScreen.ROUTE_NAME:
                return MaterialPageRoute(
                    builder: (_) => const UserMonitorRequestScreen());

              case RequestServiceScreen.ROUTE_NAME:
                // final tipeAngkutan = settings.arguments as int;
                final List<dynamic> arguments =
                    settings.arguments as List<dynamic>;
                return MaterialPageRoute(
                    builder: (_) => RequestServiceScreen(
                          // titleScreen: titleScreen,
                          tipeAngkutan: arguments[0],
                          user: arguments[1],
                        ));

              // Driver
              case DriverHomeScreen.ROUTE_NAME:
                return MaterialPageRoute(
                    builder: (_) => const DriverHomeScreen());

              case DriverHistoryScreen.ROUTE_NAME:
              final String driverId =
                    settings.arguments as String;
                return MaterialPageRoute(
                    builder: (_) =>  DriverHistoryScreen(driverId: driverId,));

              case DriverMonitorScreen.ROUTE_NAME:
                final List<dynamic> arguments =
                    settings.arguments as List<dynamic>;
                return MaterialPageRoute(
                    builder: (_) => DriverMonitorScreen(
                          requestId: arguments[0],
                          userLocation: arguments[1],
                        ));

              case DriverRequestWasteScreen.ROUTE_NAME:
                final dataDriver = settings.arguments as userModel.User;
                return MaterialPageRoute(
                    builder: (_) => DriverRequestWasteScreen(
                          dataDriver: dataDriver,
                        ));

              case DriverDetailServiceScreen.ROUTE_NAME:
                final List<dynamic> arguments =
                    settings.arguments as List<dynamic>;

                // final serviceData = settings.arguments as RequestService;
                return MaterialPageRoute(
                    builder: (_) => DriverDetailServiceScreen(
                          serviceData: arguments[0],
                          driverLocation: arguments[1],
                        ));
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
