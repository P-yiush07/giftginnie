import 'package:flutter/material.dart';
import 'package:giftginnie_ui/constants/icons.dart';
import 'package:giftginnie_ui/views/tabs/cart_tab.dart';
import 'package:provider/provider.dart';
import '../../constants/colors.dart';
import '../../controllers/main/home_controller.dart';
import 'tabs/home_tab.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/services.dart';
import 'package:giftginnie_ui/views/search_screen.dart';
// import 'tabs/search_tab.dart';
// import 'tabs/orders_tab.dart';
// import 'tabs/profile_tab.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => HomeController(),
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
    
    return SizedBox(
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
                const SearchScreen(showCancelButton: false),
                const Center(child: Text('Orders')),
                const Center(child: Text('Profile')),
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
                items: _navigationItems,
              ),
            ),
          ),
        );
      },
    );
  }
}