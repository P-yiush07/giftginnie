import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:giftginnie_ui/controllers/authHome_controller.dart';
import 'package:giftginnie_ui/controllers/main/address_controller.dart';
import 'package:giftginnie_ui/controllers/main/product_controller.dart';
import 'package:giftginnie_ui/widgets/Splash%20Screen/splash_screen.dart';
import 'constants/colors.dart';
import 'utils/global.dart';
import 'package:provider/provider.dart';
import 'services/Cache/cache_service.dart';
import 'controllers/main/user_controller.dart';
import 'services/connectivity_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  await dotenv.load(fileName: ".env");
  try {
    WidgetsFlutterBinding.ensureInitialized();
    
    // Initialize CacheService first
    await CacheService().init();
    
    // Then initialize API client
    // final apiClient = ApiClient();
    // await apiClient.testConnection(); 

    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarDividerColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.dark,
    ));

    await SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.edgeToEdge,
      overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom],
    );

    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ConnectivityService()),
          ChangeNotifierProvider(create: (_) => AuthController()),
          ChangeNotifierProvider(create: (_) => UserController()),
          ChangeNotifierProvider(create: (_) => AddressController()),
          ChangeNotifierProvider(create: (_) => ProductController()),
          // Add other global providers
          // ChangeNotifierProvider(create: (_) => CartController()),
          // ChangeNotifierProvider(create: (_) => UserController()),
        ],
        child: const MyApp(),
      ),
    );
  } catch (e) {
    debugPrint('Initialization Error: $e');
    // run the app even if initialization fails
    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ConnectivityService()),
          ChangeNotifierProvider(create: (_) => AuthController()),
          ChangeNotifierProvider(create: (_) => UserController()),
          ChangeNotifierProvider(create: (_) => AddressController()),
          ChangeNotifierProvider(create: (_) => ProductController()),
          // Add other global providers
          // ChangeNotifierProvider(create: (_) => CartController()),
          // ChangeNotifierProvider(create: (_) => UserController()),
        ],
        child: const MyApp(),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ConnectivityService()),
        ChangeNotifierProvider(create: (_) => AuthController()),
        ChangeNotifierProvider(create: (_) => UserController()),
        ChangeNotifierProvider(create: (_) => AddressController()),
        ChangeNotifierProvider(create: (_) => ProductController()),
        // Add other global providers
        // ChangeNotifierProvider(create: (_) => CartController()),
        // ChangeNotifierProvider(create: (_) => UserController()),
      ],
      child: MaterialApp(
        navigatorKey: navigatorKey,
        title: 'Gift App',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppColors.primary,
            brightness: Brightness.light,
          ),
          scaffoldBackgroundColor: Colors.transparent,
        ),
        darkTheme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppColors.primary,
            brightness: Brightness.dark,
          ),
          scaffoldBackgroundColor: Colors.transparent,
        ),
        home: const SplashScreen(),
      ),
    );
  }
}
