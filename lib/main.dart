import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:giftginnie_ui/controllers/authHome_controller.dart';
import 'views/onboarding_screen.dart';
import 'constants/colors.dart';
import 'utils/global.dart';
import 'package:provider/provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark, // For Android (dark icons)
    statusBarBrightness: Brightness.light, // For iOS (dark icons)
  ));
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthController()),
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
        ),
        darkTheme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppColors.primary,
            brightness: Brightness.dark,
          ),
        ),
        home: const OnboardingScreen(),
      ),
    );
  }
}
