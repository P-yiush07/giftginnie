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
    Key? key,
  }) {
    // Check if the imageUrl is a network URL
    final bool isNetworkImage = imageUrl.startsWith('http');
    
    if (!isNetworkImage) {
      return Image.asset(
        imageUrl,
        width: width,
        height: height,
        fit: fit,
        key: key,
      );
    }

    // Only set cache dimensions if they are finite
    final int? cacheWidth = width.isFinite ? width.toInt() : null;
    final int? cacheHeight = height.isFinite ? height.toInt() : null;

    return CachedNetworkImage(
      key: key,
      imageUrl: imageUrl,
      width: width,
      height: height,
      fit: fit,
      memCacheWidth: cacheWidth,
      memCacheHeight: cacheHeight,
      cacheKey: imageUrl,
      maxWidthDiskCache: cacheWidth != null ? cacheWidth * 2 : null,
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