import 'package:flutter/material.dart';
import 'package:giftginnie_ui/constants/colors.dart';
import 'package:giftginnie_ui/constants/fonts.dart';
import 'package:giftginnie_ui/models/product_model.dart';
import 'package:giftginnie_ui/services/image_service.dart';
import 'package:giftginnie_ui/services/Product/product_service.dart';
import 'package:giftginnie_ui/widgets/Item/favourite_button.dart';
import 'package:giftginnie_ui/widgets/shimmer/product_detail_shimmer.dart';
import 'package:giftginnie_ui/services/Cart/cart_service.dart';

class ProductDetailBottomSheet extends StatefulWidget {
  final Product product;
  final Function(Product)? onProductUpdated;

  const ProductDetailBottomSheet({
    super.key,
    required this.product,
    this.onProductUpdated,
  });

  @override
  State<ProductDetailBottomSheet> createState() => _ProductDetailBottomSheetState();
}

class _ProductDetailBottomSheetState extends State<ProductDetailBottomSheet> {
  final PageController _imageController = PageController();
  int _currentImageIndex = 0;
  late Product _product;
  bool _isAddingToCart = false;
  bool _isDescriptionExpanded = false;
  static const int _descriptionMaxLines = 2;
  int _selectedVariantIndex = 0;

  @override
  void initState() {
    super.initState();
    _product = widget.product;
    // Initialize with the first variant if available
    if (_product.variants.isNotEmpty) {
      debugPrint('Product has ${_product.variants.length} variants');
      _product.selectVariant(0);
      final variant = _product.selectedVariant;
      if (variant != null) {
        debugPrint('Selected variant: ${variant.color}, Price: ${variant.price}');
      }
    } else {
      debugPrint('Product has no variants');
    }
  }

  @override
  void dispose() {
    _imageController.dispose();
    super.dispose();
  }

  void _updateProduct(Product updatedProduct) {
    setState(() {
      _product = updatedProduct;
    });
    if (widget.onProductUpdated != null) {
      widget.onProductUpdated!(updatedProduct);
    }
  }
  
  void _selectVariant(int index) {
    if (index >= 0 && index < _product.variants.length) {
      setState(() {
        _product.selectVariant(index);
        _selectedVariantIndex = index;
        // Reset image index when variant changes
        _currentImageIndex = 0;
        _imageController.jumpToPage(0);
        
        // Debug variant selection
        final variant = _product.selectedVariant;
        if (variant != null) {
          debugPrint('Changed to variant: ${variant.color}, Price: ${variant.price}');
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Expanded(
                child: CustomScrollView(
                  controller: scrollController,
                  slivers: [
                    SliverToBoxAdapter(
                      child: Stack(
                        children: [
                          // Image slider
                          ClipRRect(
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                            child: Container(
                              height: 400,
                              color: Colors.grey[200],
                              child: PageView.builder(
                                controller: _imageController,
                                onPageChanged: (index) {
                                  setState(() {
                                    _currentImageIndex = index;
                                  });
                                },
                                itemCount: _product.selectedVariant != null && _product.selectedVariant!.images.isNotEmpty
                                    ? _product.selectedVariant!.images.length
                                    : _product.images.length,
                                itemBuilder: (context, index) {
                                  // Use variant images if available, otherwise use product images
                                  final imageUrl = _product.selectedVariant != null && _product.selectedVariant!.images.isNotEmpty
                                      ? _product.selectedVariant!.images[index]
                                      : _product.images[index];
                                  
                                  return ImageService.getNetworkImage(
                                    imageUrl: imageUrl,
                                    fit: BoxFit.cover,
                                    errorWidget: Image.asset(
                                      'assets/images/placeholder.png',
                                      width: double.infinity,
                                      height: 300,
                                      fit: BoxFit.cover,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          // Close button and heart icon
                          Positioned(
                            top: 16,
                            right: 16,
                            child: Row(
                              children: [
                                FavoriteButton(
                                  productId: _product.id,
                                  isLiked: _product.isLiked,
                                  onProductUpdated: _updateProduct,
                                ),
                                const SizedBox(width: 8),
                                Container(
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
                                  child: IconButton(
                                    icon: const Icon(
                                      Icons.close,
                                      color: Colors.black,
                                      size: 20,
                                    ),
                                    onPressed: () => Navigator.pop(context),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Image indicator dots
                          Positioned(
                            bottom: 16,
                            left: 0,
                            right: 0,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(
                                _product.selectedVariant != null && _product.selectedVariant!.images.isNotEmpty
                                    ? _product.selectedVariant!.images.length
                                    : _product.images.length,
                                (index) => Container(
                                  width: 8,
                                  height: 8,
                                  margin: const EdgeInsets.symmetric(horizontal: 4),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: _currentImageIndex == index
                                        ? AppColors.primaryRed
                                        : Colors.white.withOpacity(0.5),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Product Details
                    SliverPadding(
                      padding: const EdgeInsets.all(24),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate([
                          Text(
                            _product.name,
                            style: AppFonts.heading1.copyWith(
                              fontSize: 24,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Builder(
                                builder: (context) {
                                  // Calculate the prices
                                  double displayPrice;
                                  
                                  if (_product.selectedVariant != null) {
                                    displayPrice = _product.selectedVariant!.price;
                                    debugPrint('Using variant price: $displayPrice');
                                  } else {
                                    displayPrice = _product.sellingPrice;
                                    debugPrint('Using product price: $displayPrice');
                                  }
                                  
                                  return Text(
                                    '₹${displayPrice.toStringAsFixed(2)}',
                                    style: AppFonts.heading1.copyWith(
                                      fontSize: 20,
                                      color: AppColors.primaryRed,
                                    ),
                                  );
                                }
                              ),
                              // We're not showing a strikethrough price anymore since we don't have discounted prices
                            ],
                          ),
                          const SizedBox(height: 24),
                          
                          // Always display the variant information
                          if (_product.variants.isNotEmpty)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      _product.variants.length > 1 ? 'Available Colors' : 'Selected Variant',
                                      style: AppFonts.heading1.copyWith(
                                        fontSize: 18,
                                        color: Colors.black,
                                      ),
                                    ),
                                    if (_product.selectedVariant != null && _product.selectedVariant!.isGift)
                                      Container(
                                        margin: const EdgeInsets.only(left: 10),
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Colors.amber.shade100,
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          'Gift',
                                          style: AppFonts.paragraph.copyWith(
                                            color: Colors.amber.shade800,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                if (_product.variants.length > 1)
                                  // Multiple variants - show selector
                                  SizedBox(
                                    height: 44,
                                    child: ListView.builder(
                                      scrollDirection: Axis.horizontal,
                                      itemCount: _product.variants.length,
                                      itemBuilder: (context, index) {
                                        final variant = _product.variants[index];
                                        final isSelected = index == _selectedVariantIndex;
                                        
                                        return GestureDetector(
                                          onTap: () => _selectVariant(index),
                                          child: Container(
                                            margin: const EdgeInsets.only(right: 10),
                                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                            decoration: BoxDecoration(
                                              color: isSelected ? AppColors.primaryRed : Colors.white,
                                              borderRadius: BorderRadius.circular(8),
                                              border: Border.all(
                                                color: isSelected ? AppColors.primaryRed : Colors.grey.shade300,
                                              ),
                                            ),
                                            child: Text(
                                              variant.color,
                                              style: AppFonts.paragraph.copyWith(
                                                color: isSelected ? Colors.white : Colors.black87,
                                                fontSize: 14,
                                                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  )
                                else if (_product.selectedVariant != null)
                                  // Single variant - show chip
                                  Wrap(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                        decoration: BoxDecoration(
                                          color: Colors.grey.shade100,
                                          borderRadius: BorderRadius.circular(8),
                                          border: Border.all(
                                            color: Colors.grey.shade300,
                                          ),
                                        ),
                                        child: Text(
                                          _product.selectedVariant!.color,
                                          style: AppFonts.paragraph.copyWith(
                                            color: Colors.black87,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                const SizedBox(height: 24),
                              ],
                            ),
                          
                          // Description Section
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF5F5),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Product Description',
                                  style: AppFonts.heading1.copyWith(
                                    fontSize: 18,
                                    color: Colors.black,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    LayoutBuilder(
                                      builder: (context, constraints) {
                                        // Get the primary description text
                                        String primaryDescription = _product.selectedVariant?.description ?? _product.description;
                                        
                                        // Get the secondary description if available
                                        String? secondaryDescription = _product.selectedVariant?.descriptionSecond;
                                        
                                        // Format the secondary description to display bullet points properly
                                        if (secondaryDescription != null) {
                                          // Replace tab characters with spaces
                                          secondaryDescription = secondaryDescription.replaceAll(r'\t', '  ');
                                          
                                          // Replace bullet points with proper line breaks
                                          secondaryDescription = secondaryDescription.replaceAll('•', '\n•');
                                          
                                          // Ensure the first bullet point doesn't have a leading newline if it's at the start
                                          if (secondaryDescription.startsWith('\n')) {
                                            secondaryDescription = secondaryDescription.substring(1);
                                          }
                                        }
                                        
                                        return Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              primaryDescription,
                                              maxLines: _isDescriptionExpanded ? null : _descriptionMaxLines,
                                              overflow: _isDescriptionExpanded ? null : TextOverflow.ellipsis,
                                              style: AppFonts.paragraph.copyWith(
                                                color: AppColors.textGrey,
                                                height: 1.5,
                                              ),
                                            ),
                                            
                                            if (_isDescriptionExpanded && 
                                                secondaryDescription != null && 
                                                secondaryDescription.isNotEmpty)
                                              Padding(
                                                padding: const EdgeInsets.only(top: 16.0),
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    const Divider(height: 1),
                                                    const SizedBox(height: 16),
                                                    Text(
                                                      'Additional Details:',
                                                      style: AppFonts.heading1.copyWith(
                                                        fontSize: 16,
                                                        color: Colors.black87,
                                                        fontWeight: FontWeight.w600,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 8),
                                                    Text(
                                                      secondaryDescription,
                                                      style: AppFonts.paragraph.copyWith(
                                                        color: AppColors.textGrey,
                                                        height: 1.8,
                                                        fontSize: 14,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                          ],
                                        );
                                      }
                                    ),
                                    const SizedBox(height: 12),
                                    GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          _isDescriptionExpanded = !_isDescriptionExpanded;
                                        });
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(vertical: 6),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              _isDescriptionExpanded ? 'Read Less' : 'Read More',
                                              style: AppFonts.paragraph.copyWith(
                                                color: AppColors.primaryRed,
                                                fontWeight: FontWeight.w600,
                                                fontSize: 13,
                                              ),
                                            ),
                                            const SizedBox(width: 4),
                                            Icon(
                                              _isDescriptionExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                                              size: 16,
                                              color: AppColors.primaryRed,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          // Add stock indicator if using variant
                          if (_product.selectedVariant != null)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 16.0),
                              child: Row(
                                children: [
                                  Container(
                                    width: 10,
                                    height: 10,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: _product.selectedVariant!.inStock ? Colors.green : Colors.red,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    _product.selectedVariant!.inStock 
                                        ? 'In Stock (${_product.selectedVariant!.stock} available)' 
                                        : 'Out of Stock',
                                    style: AppFonts.paragraph.copyWith(
                                      color: _product.selectedVariant!.inStock ? Colors.green : Colors.red,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            
                          // Add to Cart Button
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: (_product.selectedVariant?.inStock ?? _product.inStock)
                              ? ElevatedButton(
                                  onPressed: _isAddingToCart ? null : () async {
                                    setState(() {
                                      _isAddingToCart = true;
                                    });
                                    
                                    try {
                                      final cartService = CartService();
                                      
                                      // Get variant ID if available
                                      String? variantId;
                                      if (_product.selectedVariant != null) {
                                        variantId = _product.selectedVariant!.id;
                                        debugPrint('Selected variant ID: $variantId');
                                      } else {
                                        debugPrint('No variant selected');
                                      }
                                      
                                      // Check if we have a valid variant ID
                                      if (variantId == null || variantId.isEmpty) {
                                        throw Exception('No variant selected or invalid variant');
                                      }
                                      
                                      await cartService.addToCart(_product.id, variantId, 1);
                                      
                                      if (mounted) {
                                        setState(() {
                                          _isAddingToCart = false;
                                        });
                                        
                                        if (context.mounted) {
                                          final overlay = Overlay.of(context);
                                          final overlayEntry = OverlayEntry(
                                            builder: (context) => Positioned(
                                              bottom: MediaQuery.of(context).viewInsets.bottom + 100,
                                              left: 16,
                                              right: 16,
                                              child: Material(
                                                color: Colors.transparent,
                                                child: Container(
                                                  padding: const EdgeInsets.symmetric(
                                                    horizontal: 24,
                                                    vertical: 16,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: Colors.green,
                                                    borderRadius: BorderRadius.circular(12),
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: Colors.black.withOpacity(0.1),
                                                        blurRadius: 8,
                                                        offset: const Offset(0, 4),
                                                      ),
                                                    ],
                                                  ),
                                                  child: Row(
                                                    children: [
                                                      const Icon(
                                                        Icons.check_circle_outline,
                                                        color: Colors.white,
                                                      ),
                                                      const SizedBox(width: 12),
                                                      Text(
                                                        'Item added to cart successfully',
                                                        style: AppFonts.paragraph.copyWith(
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          );

                                          overlay.insert(overlayEntry);
                                          await Future.delayed(const Duration(seconds: 2));
                                          overlayEntry.remove();
                                        }
                                      }
                                    } catch (e) {
                                      if (mounted) {
                                        setState(() {
                                          _isAddingToCart = false;
                                        });
                                        
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                'Failed to add item to cart',
                                                style: AppFonts.paragraph.copyWith(
                                                  color: Colors.white,
                                                ),
                                              ),
                                              backgroundColor: Colors.red,
                                            ),
                                          );
                                        }
                                      }
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primaryRed,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(28),
                                    ),
                                  ),
                                  child: _isAddingToCart
                                    ? const SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : Text(
                                        'Add to Cart',
                                        style: AppFonts.heading1.copyWith(
                                          color: Colors.white,
                                          fontSize: 16,
                                        ),
                                      ),
                                )
                              : ElevatedButton(
                                  onPressed: null,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFE0E0E0),
                                    disabledBackgroundColor: const Color(0xFFE0E0E0),
                                    disabledForegroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(28),
                                    ),
                                  ),
                                  child: Text(
                                    'Out of Stock',
                                    style: AppFonts.heading1.copyWith(
                                      color: const Color(0xFF757575),
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                          ),
                          const SizedBox(height: 50),
                          // Ratings Header
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  "What's other think\nabout the product",
                                  style: AppFonts.heading1.copyWith(
                                    fontSize: 18,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 16,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFF9E7),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(
                                          Icons.star,
                                          color: Colors.amber,
                                          size: 28,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          _product.rating.toStringAsFixed(1),
                                          style: AppFonts.heading1.copyWith(
                                            fontSize: 28,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Avg. Customer Ratings',
                                      style: AppFonts.paragraph.copyWith(
                                        fontSize: 12,
                                        color: Colors.black54,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 50),
                          // Rating Bars
                          _buildRatingBar(5, 120, 0.9),
                          _buildRatingBar(4, 84, 0.7),
                          _buildRatingBar(3, 68, 0.5),
                          _buildRatingBar(2, 42, 0.3),
                          _buildRatingBar(1, 15, 0.1),
                          const SizedBox(height: 52),
                          // Illustration
                          Center(
                            child: Image.asset(
                              'assets/images/shopping_bags.webp',
                              width: 300,
                              height: 300,
                              fit: BoxFit.contain,
                            ),
                          ),
                          const SizedBox(height: 32),
                        ]),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }



  Widget _buildRatingBar(int rating, int count, double percentage) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            '$rating',
            style: AppFonts.paragraph.copyWith(
              color: Colors.black54,
              fontSize: 14,
            ),
          ),
          const SizedBox(width: 8),
          Icon(Icons.star, size: 16, color: Colors.amber),
          const SizedBox(width: 8),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: percentage,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(Colors.amber),
                minHeight: 8,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '$count',
            style: AppFonts.paragraph.copyWith(
              color: Colors.black54,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}