import 'package:flutter/material.dart';
import 'package:giftginnie_ui/constants/colors.dart';
import 'package:giftginnie_ui/controllers/main/home_controller.dart';
import 'package:giftginnie_ui/controllers/main/tabs/cart_tab_controller.dart';
import 'package:giftginnie_ui/utils/global.dart';
import 'package:provider/provider.dart';

class FloatingCartWidget extends StatelessWidget {

  final CartTabController? cartController;

  const FloatingCartWidget({super.key, this.cartController});

  void _navigateToCart(BuildContext context) {

    Navigator.of(context).popUntil((route) => route.isFirst);

    context.read<HomeController>().setCurrentIndex(1);
  }

  @override
  Widget build(BuildContext context) {

    final controller = cartController ?? context.watch<CartTabController>();

    debugPrint("Items Number on the floating Cart: ${controller.cartData?.items.length.toString()}");
    
    return Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).padding.bottom + 20, // safe spacing
                  left: 16,
                  right: 16,
                ),
                child: GestureDetector(
                    onTap: () {
                      debugPrint("Cart button Clicked");
                      _navigateToCart(context);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 20),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 6,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Cart (${controller.cartData?.items.length ?? 0} items)",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold),
                          ),
                          Icon(Icons.shopping_cart, color: Colors.white),
                        ],
                      ),
                    ))),
          );
  }
}