import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:giftginnie_ui/constants/colors.dart';
import 'package:giftginnie_ui/constants/fonts.dart';
import 'package:giftginnie_ui/constants/icons.dart';
import 'package:flutter/services.dart';
import 'package:giftginnie_ui/models/product_model.dart';
import 'package:giftginnie_ui/services/image_service.dart';
import 'package:giftginnie_ui/widgets/favourite_button.dart';
import 'package:giftginnie_ui/widgets/product_detail_bottom_sheet.dart';
import 'package:provider/provider.dart';
import 'package:giftginnie_ui/controllers/main/home_controller.dart';
import 'package:giftginnie_ui/services/product_service.dart';
import 'dart:async';
import 'package:giftginnie_ui/services/cache_service.dart';

class SearchScreen extends StatefulWidget {
  final bool showSearchButton;
  final bool autoFocus;
  final bool isFromBottomTab;
  
  const SearchScreen({
    super.key, 
    this.showSearchButton = true,
    this.autoFocus = false,
    this.isFromBottomTab = false,
  });

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  bool _allowKeyboardShow = true;
  final List<String> _searchHistory = [];
  final ProductService _productService = ProductService();
  List<Product> _searchResults = [];
  bool _isLoading = false;
  Timer? _debounceTimer;
  final CacheService _cacheService = CacheService();

  @override
  void initState() {
    super.initState();
    _allowKeyboardShow = true;
    // Load search history asynchronously
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadSearchHistory();
    });
  }

  Future<void> _loadSearchHistory() async {
    final List<String>? savedHistory = await _cacheService.getStringList(CacheService.searchHistoryKey);
    
    if (savedHistory != null && mounted) {
      setState(() {
        _searchHistory.clear();
        _searchHistory.addAll(savedHistory);
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (widget.autoFocus && _allowKeyboardShow) {
      _searchFocusNode.requestFocus();
    }
  }

  @override
  void didUpdateWidget(SearchScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.autoFocus && !oldWidget.autoFocus) {
      setState(() {
        _allowKeyboardShow = true;
      });
      _searchFocusNode.requestFocus();
    } else if (!widget.autoFocus && oldWidget.autoFocus) {
      _searchFocusNode.unfocus();
    }
  }

  // Add WillPopScope to handle back button
  Future<bool> _onWillPop() async {
    if (_searchFocusNode.hasFocus || _searchController.text.isNotEmpty) {
      _searchFocusNode.unfocus();
      _searchController.clear();
      setState(() {
        _allowKeyboardShow = false;
        _searchResults = [];
      });
      return false;
    }
    if (widget.isFromBottomTab) {
      // If from bottom tab, switch to home tab
      Provider.of<HomeController>(context, listen: false).setCurrentIndex(0);
      return false;
    }
    return true;
  }

  void _performSearch(String query) {
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();
    
    _debounceTimer = Timer(const Duration(seconds: 1), () async {
      if (query.isEmpty) {
        setState(() {
          _searchResults = [];
          _isLoading = false;
        });
        return;
      }

      setState(() {
        _isLoading = true;
      });

      try {
        final results = await _productService.searchProducts(query);
        setState(() {
          _searchResults = results;
          _isLoading = false;
        });
        // Add to search history when search is successful
        _addToSearchHistory(query);
      } catch (e) {
        debugPrint('Error performing search: $e');
        setState(() {
          _searchResults = [];
          _isLoading = false;
        });
      }
    });
  }

  void _addToSearchHistory(String query) {
    if (query.isEmpty) return;
    
    setState(() {
      // Remove if already exists
      _searchHistory.remove(query);
      // Add to the beginning of the list
      _searchHistory.insert(0, query);
      // Keep only last 10 searches
      if (_searchHistory.length > 10) {
        _searchHistory.removeLast();
      }
    });

    // Save to cache
    _cacheService.saveStringList(CacheService.searchHistoryKey, _searchHistory);
  }

  void _clearSearchHistory() {
    setState(() {
      _searchHistory.clear();
    });
    
    // Clear from cache
    _cacheService.remove(CacheService.searchHistoryKey);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark.copyWith(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          systemNavigationBarColor: Colors.transparent,
          statusBarBrightness: Brightness.light,
        ),
        child: Scaffold(
          backgroundColor: const Color(0xFFF9F9F9),
          body: Column(
            children: [
              Container(
                color: Colors.white,
                child: Column(
                  children: [
                    Container(
                      color: Colors.white,
                      height: MediaQuery.of(context).padding.top,
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0.0, 12.0, 16.0, 5.0),
                      child: Row(
                        children: [
                          // Back Button
                          if (widget.showSearchButton) ...[
                            IconButton(
                              icon: const Icon(Icons.arrow_back, color: Colors.black),
                              onPressed: () {
                                if (_searchFocusNode.hasFocus || _searchController.text.isNotEmpty) {
                                  _searchFocusNode.unfocus();
                                  _searchController.clear();
                                  setState(() {
                                    _allowKeyboardShow = false;
                                    _searchResults = [];
                                  });
                                } else if (widget.isFromBottomTab) {
                                  // If from bottom tab, switch to home tab
                                  Provider.of<HomeController>(context, listen: false).setCurrentIndex(0);
                                } else {
                                  Navigator.pop(context);
                                }
                              },
                              padding: const EdgeInsets.only(left: 8.0),
                              constraints: const BoxConstraints(),
                            ),
                            const SizedBox(width: 4),
                          ],
                          // Search TextField
                          Expanded(
                            child: Container(
                              height: 52,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(26),
                              ),
                              child: TextField(
                                controller: _searchController,
                                focusNode: _searchFocusNode,
                                autofocus: widget.autoFocus && _allowKeyboardShow,
                                textInputAction: TextInputAction.search,
                                onSubmitted: (_) {
                                  _searchFocusNode.unfocus();
                                  setState(() {
                                    _allowKeyboardShow = false;
                                  });
                                },
                                onTap: () {
                                  setState(() {
                                    _allowKeyboardShow = true;
                                  });
                                },
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                ),
                                decoration: InputDecoration(
                                  hintText: 'Search Gift Store',
                                  hintStyle: AppFonts.paragraph.copyWith(
                                    color: AppColors.textGrey,
                                  ),
                                  isDense: true,
                                  contentPadding: const EdgeInsets.only(
                                    top: 24,
                                    bottom: 16,
                                    left: 0,
                                    right: 16,
                                  ),
                                  prefixIcon: Padding(
                                    padding: const EdgeInsets.only(
                                      left: 2.0,
                                      right: 8.0,
                                      top: 12.0,
                                      bottom: 12.0,
                                    ),
                                    child: SvgPicture.asset(
                                      AppIcons.svg_searchTabIcon,
                                      colorFilter: ColorFilter.mode(
                                        AppColors.textGrey,
                                        BlendMode.srcIn,
                                      ),
                                    ),
                                  ),
                                  suffixIcon: _searchController.text.isNotEmpty
                                      ? IconButton(
                                          icon: const Icon(Icons.close, size: 20),
                                          onPressed: () {
                                            _searchController.clear();
                                            setState(() {});
                                          },
                                        )
                                      : null,
                                  border: InputBorder.none,
                                ),
                                onChanged: (value) {
                                  setState(() {});
                                  _performSearch(value);
                                },
                              ),
                            ),
                          ),
                          // Search Button instead of Cancel
                          if (widget.showSearchButton) ...[
                            const SizedBox(width: 12),
                            TextButton(
                              onPressed: () {
                                if (_searchController.text.isNotEmpty) {
                                  _searchFocusNode.unfocus();
                                  _performSearch(_searchController.text);
                                }
                              },
                              child: Text(
                                'Search',
                                style: AppFonts.paragraph.copyWith(
                                  color: AppColors.primaryRed,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_searchController.text.isEmpty && _searchHistory.isNotEmpty) ...[
                      // Search History Header - Only show when there's history
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Search History',
                              style: AppFonts.paragraph.copyWith(
                                fontSize: 16,
                                color: AppColors.black
                              ),
                            ),
                            TextButton(
                              onPressed: _clearSearchHistory,
                              child: Text(
                                'Clear all',
                                style: AppFonts.paragraph.copyWith(
                                  color: AppColors.primaryRed,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Search History List
                      Expanded(
                        child: ListView.builder(
                          itemCount: _searchHistory.length,
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          itemBuilder: (context, index) {
                            return InkWell(
                              onTap: () {
                                _searchController.text = _searchHistory[index];
                                _performSearch(_searchHistory[index]);
                              },
                              child: _buildHistoryItem(_searchHistory[index]),
                            );
                          },
                        ),
                      ),
                    ] else if (_searchController.text.isEmpty) ...[
                      // Empty State - When no history
                      Expanded(
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SvgPicture.asset(
                                AppIcons.svg_searchTabIcon,
                                width: 64,
                                height: 64,
                                colorFilter: ColorFilter.mode(
                                  Colors.grey[300]!,
                                  BlendMode.srcIn,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No history available',
                                style: AppFonts.paragraph.copyWith(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                    if (_searchController.text.isNotEmpty) ...[
                      // Search Results
                      Expanded(
                        child: _isLoading
                            ? const Center(child: CircularProgressIndicator())
                            : _buildSearchResults(),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryItem({required String emoji, required String label}) {
    return Padding(
      padding: const EdgeInsets.only(right: 16.0),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.grey100,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                emoji,
                style: const TextStyle(fontSize: 32),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: AppFonts.paragraph.copyWith(
              fontSize: 12,
              color: AppColors.labelGrey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        children: [
        SvgPicture.asset(
          AppIcons.svg_searchTabIcon,
          width: 20,
          height: 20,
          colorFilter: const ColorFilter.mode(
            Colors.grey,
            BlendMode.srcIn,
          ),
        ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: AppFonts.paragraph.copyWith(
                fontSize: 14,
                color: AppColors.labelGrey,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.close,
              size: 20,
              color: Colors.grey,
            ),
            onPressed: () {
              setState(() {
                _searchHistory.remove(text);
              });
              // Save updated history to cache
              final CacheService cacheService = CacheService();
              cacheService.saveStringList(CacheService.searchHistoryKey, _searchHistory);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    if (_searchResults.isEmpty) {
      return Center(
        child: Text(
          'No products found',
          style: AppFonts.paragraph.copyWith(
            color: AppColors.textGrey,
          ),
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16.0,
        mainAxisSpacing: 16.0,
        childAspectRatio: 0.53,
      ),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final product = _searchResults[index];
        return GestureDetector(
          onTap: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (context) => ProductDetailBottomSheet(
                product: product,
                onProductUpdated: (updatedProduct) {
                  setState(() {
                    _searchResults[index] = updatedProduct;
                  });
                },
              ),
            );
          },
          child: _buildProductCard(product),
        );
      },
    );
  }

  Widget _buildProductCard(Product product) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
          child: Stack(
            children: [
              ImageService.getNetworkImage(
                key: ValueKey('search_product_${product.id}'),
                imageUrl: product.images.isNotEmpty ? product.images[0] : 'assets/images/placeholder.png',
                width: MediaQuery.of(context).size.width / 2 - 24,
                height: 200,
                fit: BoxFit.cover,
                errorWidget: Image.asset(
                  'assets/images/placeholder.png',
                  width: MediaQuery.of(context).size.width / 2 - 24,
                  height: 200,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: FavoriteButton(
                  productId: product.id,
                  isLiked: product.isLiked,
                  onProductUpdated: (updatedProduct) {
                    setState(() {
                      final index = _searchResults.indexWhere((p) => p.id == updatedProduct.id);
                      if (index != -1) {
                        _searchResults[index] = updatedProduct;
                      }
                    });
                  },
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                product.name,
                style: AppFonts.paragraph.copyWith(
                  fontSize: 14,
                  color: Colors.black,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                product.brand,
                style: AppFonts.paragraph.copyWith(
                  fontSize: 12,
                  color: AppColors.textGrey,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Text(
                    '\$${product.sellingPrice.toStringAsFixed(2)}',
                    style: AppFonts.paragraph.copyWith(
                      fontSize: 16,
                      color: AppColors.primaryRed,
                    ),
                  ),
                  const Spacer(),
                  const Icon(
                    Icons.star,
                    color: Colors.amber,
                    size: 16,
                  ),
                  Text(
                    product.rating.toStringAsFixed(1),
                    style: AppFonts.paragraph.copyWith(
                      fontSize: 12,
                      color: AppColors.textGrey,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _searchFocusNode.dispose();
    _searchController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }
}