import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/material.dart';
import 'package:giftginnie_ui/constants/colors.dart';
import 'package:giftginnie_ui/models/CarouselItem_model.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeCarousel extends StatefulWidget {
  final List<CarouselItem> items;
  
  const HomeCarousel({
    Key? key,
    required this.items,
  }) : super(key: key);

  @override
  State<HomeCarousel> createState() => _HomeCarouselState();
}

class _HomeCarouselState extends State<HomeCarousel> {
  late PageController _pageController;
  Timer? _carouselTimer;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _startCarouselTimer();
  }

  void _startCarouselTimer() {
    _carouselTimer?.cancel();
    _carouselTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (_currentPage < widget.items.length - 1) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }
      if (_pageController.hasClients) {
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeIn,
        );
      }
    });
  }

  @override
  void dispose() {
    _carouselTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 210,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (int page) {
              setState(() {
                _currentPage = page;
              });
            },
            itemCount: widget.items.length,
            itemBuilder: (context, index) {
              final item = widget.items[index];
              return GestureDetector(
                onTap: () {
                  if (item.link != null && item.link!.isNotEmpty) {
                    launchUrl(Uri.parse(item.link!));
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: CachedNetworkImage(
                      imageUrl: item.image,
                      width: double.infinity,
                      height: 210,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Shimmer.fromColors(
                        baseColor: AppColors.grey300,
                        highlightColor: AppColors.grey100,
                        child: Container(
                          width: double.infinity,
                          height: 210,
                          decoration: BoxDecoration(
                            color: AppColors.grey100,
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      errorWidget: (context, url, error) {
                        return Container(
                          // ... (keep existing error widget code)
                        );
                      },
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        Center(
          child: DotsIndicator(
            dotsCount: widget.items.length,
            position: _currentPage,
            decorator: DotsDecorator(
              color: AppColors.grey500.withOpacity(0.5),
              activeColor: AppColors.primaryRed,
              size: const Size(8, 8),
              activeSize: const Size(8, 8),
              spacing: const EdgeInsets.all(4),
            ),
          ),
        ),
      ],
    );
  }
}