// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:angkutin/common/utils.dart';
import 'package:angkutin/database/storage_service.dart';
import 'package:angkutin/provider/auth/auth_provider.dart';
import 'package:angkutin/provider/complain/complain_provider.dart';
import 'package:angkutin/provider/driver/driver_daily_provider.dart';
import 'package:angkutin/provider/driver/driver_ongoing_service.dart';
import 'package:angkutin/provider/driver/driver_service_provider.dart';
import 'package:angkutin/provider/monitor_provider.dart';
import 'package:angkutin/provider/upload_provider.dart';
import 'package:angkutin/provider/user/user_daily_provider.dart';
import 'package:angkutin/provider/user/user_request_provider.dart';
import 'package:angkutin/screen/auth/fill_user_data_screen.dart';
import 'package:angkutin/screen/complain/complain_screen.dart';
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
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'screen/driver/driver_gome_screen.dart';
import 'screen/driver/driver_report_waste_screen.dart';
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

  // onboarding state
  bool isOnboarding = await authProvider.getOnBoardingState();
  bool isLoggedIn = await authProvider.getLoginState();
  String userRole = await authProvider.getRoleState();

  Widget getInitialScreen(AuthenticationProvider authProvider) {
    if (isOnboarding) {
      if (isLoggedIn) {
        if (userRole == "Masyarakat" || userRole == "masyarakat") {
          return const UserHomeScreen();
        } else if (userRole == "Petugas" || userRole == "petugas") {
          return const DriverHomeScreen();
        } else {
          return const LoginScreen();
        }
      } else {
        return const LoginScreen();
      }
    } else {
      return const OnBoardingScreen();
    }
  }

  Widget initialScreen = getInitialScreen(authProvider);

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
        ChangeNotifierProvider(create: (_) => ComplainProvider()),
      ],
      child: MaterialApp(
          home: initialScreen,
          navigatorObservers: [routeObserver],
          onUnknownRoute: (settings) {
            return MaterialPageRoute(builder: (_) {
              return const Scaffold(
                body: Center(
                  child: Text('Page not found :('),
                ),
              );
            });
          },
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
                final String userId = settings.arguments as String;
                return MaterialPageRoute(
                    builder: (_) => UserHistoryScreen(
                          userId: userId,
                        ));

              case UserProfileScreen.ROUTE_NAME:
                return MaterialPageRoute(
                    builder: (_) => const UserProfileScreen());

              case RequestAcceptedScreen.ROUTE_NAME:
                return MaterialPageRoute(
                    builder: (_) => const RequestAcceptedScreen());

              case UserMonitorRequestScreen.ROUTE_NAME:
                final List<dynamic> arguments =
                    settings.arguments as List<dynamic>;
                return MaterialPageRoute(
                    builder: (_) => UserMonitorRequestScreen(
                          type: arguments[0],
                          requestId: arguments[1],
                        ));

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
                final String driverId = settings.arguments as String;
                return MaterialPageRoute(
                    builder: (_) => DriverHistoryScreen(
                          driverId: driverId,
                        ));

              case DriverMonitorScreen.ROUTE_NAME:
                final List<dynamic> arguments =
                    settings.arguments as List<dynamic>;
                return MaterialPageRoute(
                    builder: (_) => DriverMonitorScreen(
                          type: arguments[0],
                          requestId: arguments[1],
                          userLocation: arguments[2],
                        ));

              case DriverRequestWasteScreen.ROUTE_NAME:
                final dataDriver = settings.arguments as userModel.User;
                return MaterialPageRoute(
                    builder: (_) => DriverRequestWasteScreen(
                          dataDriver: dataDriver,
                        ));

              case DriverReportWasteScreen.ROUTE_NAME:
                final dataDriver = settings.arguments as userModel.User;
                return MaterialPageRoute(
                    builder: (_) => DriverReportWasteScreen(
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

              // Complain
              case ComplainScreen.ROUTE_NAME:
                final userModel.User user =
                    settings.arguments as userModel.User;

                return MaterialPageRoute(
                    builder: (_) => ComplainScreen(
                          userData: user,
                        ));

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
