import 'package:flutter/material.dart';
import 'package:giftginnie_ui/constants/icons.dart';
import 'package:giftginnie_ui/controllers/main/tabs/home_tab_controller.dart';
import 'package:giftginnie_ui/services/connectivity_service.dart';
import 'package:giftginnie_ui/views/tabs/cart_tab_new.dart';
import 'package:giftginnie_ui/views/tabs/order_tab.dart';
import 'package:giftginnie_ui/views/tabs/profile_tab.dart';
import 'package:giftginnie_ui/widgets/Internet/connectivity_wrapper.dart';
import 'package:provider/provider.dart';
import '../../constants/colors.dart';
import '../../controllers/main/home_controller.dart';
import 'tabs/home_tab.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/services.dart';
import 'package:giftginnie_ui/views/Product%20Screen/search_screen.dart';
import 'package:flutter/services.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DateTime? _lastBackPressTime;

  Future<bool> _onWillPop() async {
    final homeController = Provider.of<HomeController>(context, listen: false);
    if (homeController.currentIndex != 0) {
      homeController.setCurrentIndex(0);
      return false;
    }
    
    if (_lastBackPressTime == null || 
        DateTime.now().difference(_lastBackPressTime!) > const Duration(seconds: 2)) {
      _lastBackPressTime = DateTime.now();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Press back again to exit'),
          duration: Duration(seconds: 2),
        ),
      );
      return false;
    }
    
    await SystemNavigator.pop(animated: true);
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: const HomeView(),
    );
  }
}

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  // Getter for tab item widget
  Widget _buildTabItem({
    required String icon,
    required String label,
    required bool isActive,
  }) {
    final color = isActive ? AppColors.primary : Colors.grey;
    
    return Material(
      type: MaterialType.transparency,
      child: SizedBox(
        width: 70,
        height: 50,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 6), 
            SvgPicture.asset(
              icon,
              colorFilter: ColorFilter.mode(
                color,
                BlendMode.srcIn,
              ),
              height: 28,
              width: 28,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Getter for bottom navigation items
  List<BottomNavigationBarItem> get _navigationItems => [
    BottomNavigationBarItem(
      icon: _buildTabItem(
        icon: AppIcons.svg_homeTabIcon,
        label: 'Home',
        isActive: false,
      ),
      activeIcon: _buildTabItem(
        icon: AppIcons.svg_homeTabIcon,
        label: 'Home',
        isActive: true,
      ),
      label: '',
    ),
    BottomNavigationBarItem(
      icon: _buildTabItem(
        icon: AppIcons.svg_cartTabIcon,
        label: 'Cart',
        isActive: false,
      ),
      activeIcon: _buildTabItem(
        icon: AppIcons.svg_cartTabIcon,
        label: 'Cart',
        isActive: true,
      ),
      label: '',
    ),
    BottomNavigationBarItem(
      icon: _buildTabItem(
        icon: AppIcons.svg_searchTabIcon,
        label: 'Search',
        isActive: false,
      ),
      activeIcon: _buildTabItem(
        icon: AppIcons.svg_searchTabIcon,
        label: 'Search',
        isActive: true,
      ),
      label: '',
    ),
    BottomNavigationBarItem(
      icon: _buildTabItem(
        icon: AppIcons.svg_orderTabIcon,
        label: 'Orders',
        isActive: false,
      ),
      activeIcon: _buildTabItem(
        icon: AppIcons.svg_orderTabIcon,
        label: 'Orders',
        isActive: true,
      ),
      label: '',
    ),
    BottomNavigationBarItem(
      icon: _buildTabItem(
        icon: AppIcons.svg_profileTabIcon,
        label: 'Profile',
        isActive: false,
      ),
      activeIcon: _buildTabItem(
        icon: AppIcons.svg_profileTabIcon,
        label: 'Profile',
        isActive: true,
      ),
      label: '',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeController>(
      builder: (context, controller, _) {
        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle.light.copyWith(
            systemNavigationBarColor: Colors.transparent,
            systemNavigationBarIconBrightness: Brightness.dark,
          ),
          child: Scaffold(
            body: IndexedStack(
              index: controller.currentIndex,
              children: [
                HomeTab(),
                CartTab(),
                Consumer<HomeController>(
                  builder: (context, controller, _) => SearchScreen(
                    showSearchButton: true,
                    autoFocus: controller.currentIndex == 2,
                    isFromBottomTab: true,
                  ),
                ),
                ChangeNotifierProvider.value(
                  value: controller.ordersController,
                  child: const OrdersTab(),
                ),
                const ProfileTab(),
              ],
            ),
            bottomNavigationBar: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, -3),
                  ),
                ],
              ),
              child: Theme(
                data: ThemeData(
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                ),
                child: BottomNavigationBar(
                  elevation: 0,
                  currentIndex: controller.currentIndex,
                  onTap: controller.setCurrentIndex,
                  type: BottomNavigationBarType.fixed,
                  backgroundColor: Colors.white,
                  selectedItemColor: AppColors.primary,
                  unselectedItemColor: Colors.grey,
                  selectedFontSize: 0,
                  unselectedFontSize: 0,
                  showSelectedLabels: false,
                  showUnselectedLabels: false,
                  enableFeedback: false,
                  items: _navigationItems,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        SystemNavigator.pop(); // This will close the app
        return false;
      },
      child: ConnectivityWrapper(
        onRetry: () {
          if (context.read<ConnectivityService>().isConnected) {
            context.read<HomeTabController>().refreshData();
          }
        },
        child: AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle.dark.copyWith(
            statusBarColor: Colors.transparent,
            systemNavigationBarColor: Colors.transparent,
            systemNavigationBarIconBrightness: Brightness.dark,
          ),
          child: ChangeNotifierProvider(
            create: (_) => HomeTabController(),
            child: const HomeTabView(),
          ),
        ),
      ),
    );
  }
}