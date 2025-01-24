import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:giftginnie_ui/constants/colors.dart';

class ImageService {
  static Widget getNetworkImage({
    required String imageUrl,
    required double width,
    required double height,
    BoxFit fit = BoxFit.cover,
    Widget? placeholder,
    Widget? errorWidget,
    Key? key,
  }) {
    if (imageUrl.isEmpty) {
      return errorWidget ?? Container(
        color: AppColors.grey300,
        child: Icon(Icons.error, color: AppColors.textGrey),
      );
    }

    return CachedNetworkImage(
      key: key,
      imageUrl: imageUrl,
      width: width,
      height: height,
      fit: fit,
      fadeInDuration: const Duration(milliseconds: 300),
      fadeOutDuration: const Duration(milliseconds: 300),
      placeholder: (context, url) => placeholder ?? Container(
        color: AppColors.grey300,
        child: Center(
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: AppColors.primaryRed,
          ),
        ),
      ),
      errorWidget: (context, url, error) => errorWidget ?? Container(
        color: AppColors.grey300,
        child: Icon(Icons.error, color: AppColors.textGrey),
      ),
    );
  }
}