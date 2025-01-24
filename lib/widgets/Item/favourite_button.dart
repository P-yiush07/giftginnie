import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../constants/colors.dart';
import '../../services/Product/product_service.dart';
import '../../models/product_model.dart';
import '../../controllers/main/product_controller.dart';
import 'package:provider/provider.dart';

class FavoriteButton extends StatefulWidget {
  final String productId;
  final bool isLiked;
  final Function(Product)? onProductUpdated;

  const FavoriteButton({
    super.key,
    required this.productId,
    required this.isLiked,
    this.onProductUpdated,
  });

  @override
  State<FavoriteButton> createState() => _FavoriteButtonState();
}

class _FavoriteButtonState extends State<FavoriteButton> {
  bool _isLoading = false;
  late bool _isLiked;

  @override
  void initState() {
    super.initState();
    _isLiked = widget.isLiked;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProductController>(
      builder: (context, productController, _) {
        final isLiked = productController.isProductLiked(widget.productId);
        
        return Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: _isLoading
              ? Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: IconButton(
                    icon: Icon(
                      isLiked ? Icons.favorite : Icons.favorite_border,
                      color: isLiked ? AppColors.primaryRed : Colors.black,
                      size: 20,
                    ),
                    onPressed: null,
                  ),
                )
              : IconButton(
                  icon: Icon(
                    isLiked ? Icons.favorite : Icons.favorite_border,
                    color: isLiked ? AppColors.primaryRed : Colors.black,
                    size: 20,
                  ),
                  onPressed: () async {
                    setState(() {
                      _isLoading = true;
                    });
                    
                    try {
                      final updatedProduct = await productController.toggleProductLike(widget.productId);
                      if (widget.onProductUpdated != null) {
                        widget.onProductUpdated!(updatedProduct);
                      }
                    } finally {
                      if (mounted) {
                        setState(() {
                          _isLoading = false;
                        });
                      }
                    }
                  },
                ),
        );
      },
    );
  }
}