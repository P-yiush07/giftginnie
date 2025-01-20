import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:giftginnie_ui/constants/colors.dart';
import 'package:giftginnie_ui/constants/fonts.dart';
import 'package:giftginnie_ui/constants/icons.dart';
import 'package:flutter/services.dart';

class SearchScreen extends StatefulWidget {
  final bool showCancelButton;
  final bool autoFocus;
  
  const SearchScreen({
    super.key, 
    this.showCancelButton = true,
    this.autoFocus = false,
  });

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  bool _allowKeyboardShow = true;
  final List<String> _searchHistory = [
    'Restaurant Near me',
    'Thai Rise',
    'Chhole Kulche',
    'Pav bhaji'
  ];

  @override
  void initState() {
    super.initState();
    _allowKeyboardShow = true;
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

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: AppColors.white,
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
                    padding: const EdgeInsets.fromLTRB(16.0, 5.0, 16.0, 16.0),
                    child: Row(
                      children: [
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
                              textInputAction: TextInputAction.done,
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
                                  left: 16,
                                  right: 16,
                                ),
                                prefixIcon: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16.0,
                                    vertical: 12.0,
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
                              },
                            ),
                          ),
                        ),
                        if (widget.showCancelButton) ...[
                          const SizedBox(width: 12),
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text(
                              'Cancel',
                              style: AppFonts.paragraph.copyWith(
                                color: AppColors.textGrey,
                                fontSize: 16,
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
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'Categories',
                      style: AppFonts.paragraph.copyWith(
                        fontSize: 16,
                        color: AppColors.black
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 100,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      children: [
                        _buildCategoryItem(emoji: '🏅', label: 'Prizes'),
                        _buildCategoryItem(emoji: '🎂', label: 'Birthday'),
                        _buildCategoryItem(emoji: '💑', label: 'Anniversary'),
                        _buildCategoryItem(emoji: '🐱', label: 'Pet Gifts'),
                        _buildCategoryItem(emoji: '👔', label: 'Corporate'),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16.0, 24.0, 16.0, 8.0),
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
                          onPressed: () {
                            setState(() {
                              _searchHistory.clear();
                            });
                          },
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
                  Expanded(
                    child: ListView.builder(
                      itemCount: _searchHistory.length,
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      itemBuilder: (context, index) {
                        return _buildHistoryItem(_searchHistory[index]);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
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
            },
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchFocusNode.dispose();
    _searchController.dispose();
    super.dispose();
  }
}