import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:giftginnie_ui/constants/colors.dart';
import 'package:shimmer/shimmer.dart';

class ImageService {
  static Widget getNetworkImage({
    required String imageUrl,
    required double width,
    required double height,
    BoxFit fit = BoxFit.cover,
    Widget? errorWidget,
  }) {
    return CachedNetworkImage(
      imageUrl: imageUrl,
      width: width,
      height: height,
      fit: fit,
      memCacheWidth: width.toInt(),
      memCacheHeight: height.toInt(),
      cacheKey: imageUrl,
      maxWidthDiskCache: width.toInt() * 2, // For higher resolution devices
      useOldImageOnUrlChange: true,
      placeholder: (context, url) => Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Container(
          width: width,
          height: height,
          color: Colors.white,
        ),
      ),
      errorWidget: (context, url, error) => errorWidget ?? Container(
        color: AppColors.grey300,
        child: Icon(Icons.error, color: AppColors.textGrey),
      ),
    );
  }
}