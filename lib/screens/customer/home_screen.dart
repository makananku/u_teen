import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:provider/provider.dart';
import '../../data/food_data.dart';
import '../../providers/cart_provider.dart';
import '../../providers/favorite_provider.dart';
import '../../providers/order_provider.dart';
import '../../widgets/customer/custom_bottom_navigation.dart';
import '../../models/cart_item.dart';
import '../../models/favorite_item.dart';
import 'favorite_screen.dart';
import 'notification_screen.dart';
import '../../data/search_data.dart';
import '../../widgets/customer/search_widget.dart';
import '../../widgets/customer/category_selector.dart';
import '../../widgets/food_list.dart';
import '../../widgets/customer/detail_box.dart';
import '../../auth/auth_provider.dart';

class HomeScreen extends StatefulWidget {
  final String? initialFoodItem;
  final String? initialFoodPrice;
  final String? initialFoodImgUrl;
  final String? initialFoodSubtitle;

  const HomeScreen({
    super.key,
    this.initialFoodItem,
    this.initialFoodPrice,
    this.initialFoodImgUrl,
    this.initialFoodSubtitle,
  });

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  int selectedIndex = 0;
  String selectedCategory = 'All';
  bool isDetailVisible = false;
  String selectedFoodItem = '';
  String selectedFoodPrice = '';
  String selectedFoodImgUrl = '';
  String selectedFoodSubtitle = '';
  late AnimationController _boxController;
  late AnimationController _navController;
  final TextEditingController _searchController = TextEditingController();

  bool isKeyboardVisible = false;
  bool isSearchActive = false;
  String searchQuery = '';

  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _boxController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _navController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _loadRecentSearches();

    _searchFocusNode.addListener(() {
      setState(() {
        isSearchActive = _searchFocusNode.hasFocus;
      });
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.initialFoodItem != null &&
          widget.initialFoodPrice != null &&
          widget.initialFoodImgUrl != null) {
        setState(() {
          selectedFoodItem = widget.initialFoodItem!;
          selectedFoodPrice = widget.initialFoodPrice!;
          selectedFoodImgUrl = widget.initialFoodImgUrl!;
          selectedFoodSubtitle = widget.initialFoodSubtitle ?? '';
          isDetailVisible = true;
          _boxController.forward();
          _navController.reverse();
        });
      }
    });
  }

  @override
  void dispose() {
    _boxController.dispose();
    _navController.dispose();
    _searchFocusNode.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<bool> _onWillPop() async {
    if (isDetailVisible) {
      _closeDetailBox();
      return false;
    }
    if (isSearchActive) {
      if (isKeyboardVisible) {
        FocusScope.of(context).unfocus();
        return false;
      } else {
        setState(() {
          isSearchActive = false;
          _searchFocusNode.unfocus();
        });
        return false;
      }
    }
    return true;
  }

  Future<void> _refreshData() async {
    await Future.delayed(const Duration(seconds: 2));
    setState(() {});
  }

  Future<void> _loadRecentSearches() async {
    await SearchData.loadRecentSearches();
    setState(() {});
  }

  void _handleSearch(String query) {
    setState(() {
      searchQuery = query;
    });
  }

  void _removeRecentSearch(String query) {
    SearchData.removeRecentSearch(query);
    setState(() {});
  }

  void _fillSearchBar(String query) {
    setState(() {
      _searchController.text = query;
      searchQuery = query;
    });
  }

  void _onCategorySelected(String category) {
    setState(() {
      selectedCategory = category;
      if (isDetailVisible) {
        isDetailVisible = false;
      }
    });
  }

  void _closeDetailBox() {
    setState(() {
      isDetailVisible = false;
    });
    _boxController.reverse();
    _navController.forward();
  }

  void _handleFoodItemTap(
    String title,
    String price,
    String imgUrl,
    String subtitle,
    String sellerEmail,
  ) {
    setState(() {
      selectedFoodItem = title;
      selectedFoodPrice = price;
      selectedFoodImgUrl = imgUrl;
      selectedFoodSubtitle = subtitle;
      isDetailVisible = true;
      _boxController.forward();
      _navController.reverse();
    });
  }

  Widget _buildMainContent(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.only(left: 24.0),
          child: Text(
            "Recommended for you",
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
        const SizedBox(height: 16),
        FoodList(
          selectedCategory: selectedCategory,
          onFoodItemTap: (title, price, imgUrl, subtitle, sellerEmail) {
            _handleFoodItemTap(title, price, imgUrl, subtitle, sellerEmail);
          },
        ),
        const SizedBox(height: 24),
        Padding(
          padding: const EdgeInsets.only(left: 24.0),
          child: Text(
            "Order Again",
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
        const SizedBox(height: 16),
        FoodList(
          selectedCategory: selectedCategory,
          onFoodItemTap: _handleFoodItemTap,
        ),
        const SizedBox(height: 100),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final favoriteProvider = Provider.of<FavoriteProvider>(context);
    final orderProvider = Provider.of<OrderProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final customerName = authProvider.user?.name ?? '';
    final unreadNotificationCount = orderProvider.getUnreadNotificationCount(customerName);
    final theme = Theme.of(context);

    return WillPopScope(
      onWillPop: _onWillPop,
      child: KeyboardVisibilityProvider(
        child: Scaffold(
          backgroundColor: Colors.grey[50],
          appBar: AppBar(
            title: Text(
              'Home',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            centerTitle: true,
            leading: IconButton(
              icon: Stack(
                children: [
                  const Icon(Icons.favorite_border, color: Colors.black),
                  if (favoriteProvider.favoriteItems.isNotEmpty)
                    Positioned(
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 12,
                          minHeight: 12,
                        ),
                        child: Text(
                          '${favoriteProvider.favoriteItems.length}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 8,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const FavoritesScreen(),
                  ),
                );
              },
            ),
            actions: [
              IconButton(
                icon: Stack(
                  children: [
                    const Icon(Icons.notifications_outlined, color: Colors.black),
                    if (unreadNotificationCount > 0)
                      Positioned(
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 12,
                            minHeight: 12,
                          ),
                          child: Text(
                            '$unreadNotificationCount',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 8,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const NotificationScreen(),
                    ),
                  );
                },
              ),
            ],
            elevation: 0,
            backgroundColor: Colors.white,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
            ),
          ),
          body: LayoutBuilder(
            builder: (context, constraints) {
              return KeyboardVisibilityBuilder(
                builder: (context, isKeyboardVisible) {
                  this.isKeyboardVisible = isKeyboardVisible;

                  return GestureDetector(
                    onTap: () {
                      if (isDetailVisible) _closeDetailBox();
                      setState(() {
                        isSearchActive = false;
                        _searchFocusNode.unfocus();
                      });
                    },
                    child: Stack(
                      children: [
                        SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              minHeight: constraints.maxHeight,
                            ),
                            child: Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 16,
                                  ),
                                  child: SearchWidget(
                                    searchController: _searchController,
                                    onSearchSubmitted: _handleSearch,
                                    onFillSearchBar: _fillSearchBar,
                                    onRemoveRecentSearch: _removeRecentSearch,
                                    onFoodItemTap: (
                                      title,
                                      price,
                                      imgUrl,
                                      subtitle,
                                      sellerEmail,
                                    ) {
                                      _handleFoodItemTap(
                                        title,
                                        price,
                                        imgUrl,
                                        subtitle,
                                        sellerEmail,
                                      );
                                    },
                                    isSearchActive: isSearchActive,
                                    focusNode: _searchFocusNode,
                                    categorySelector: CategorySelector(
                                      selectedCategory: selectedCategory,
                                      onCategorySelected: _onCategorySelected,
                                    ),
                                    showFoodLists: isSearchActive,
                                  ),
                                ),
                                if (!isSearchActive && !isKeyboardVisible)
                                  _buildMainContent(theme),
                              ],
                            ),
                          ),
                        ),

                        // Semi-transparent overlay
                        if (isDetailVisible)
                          Positioned.fill(
                            child: GestureDetector(
                              onTap: _closeDetailBox,
                              child: Container(
                                color: Colors.black.withOpacity(0.4),
                              ),
                            ),
                          ),

                        // Improved DetailBox
                        if (isDetailVisible)
                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            child: DetailBox(
                              selectedFoodItem: selectedFoodItem,
                              selectedFoodPrice: selectedFoodPrice,
                              selectedFoodImgUrl: selectedFoodImgUrl,
                              selectedFoodSubtitle: selectedFoodSubtitle,
                              onAddToCart: () {
                                final cartProvider = Provider.of<CartProvider>(
                                  context,
                                  listen: false,
                                );

                                // Get the full food item to access sellerEmail
                                final foodItem = FoodData.getFoodItems(
                                  'All',
                                ).firstWhere(
                                  (item) =>
                                      item['title'] == selectedFoodItem &&
                                      item['imgUrl'] == selectedFoodImgUrl,
                                );

                                cartProvider.addToCart(
                                  CartItem(
                                    name: selectedFoodItem,
                                    price: int.parse(
                                      selectedFoodPrice.replaceAll(".", ""),
                                    ),
                                    image: selectedFoodImgUrl,
                                    subtitle: selectedFoodSubtitle,
                                    sellerEmail: foodItem['sellerEmail'] ?? '',
                                  ),
                                );
                                _closeDetailBox();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      "$selectedFoodItem added to cart!",
                                      style: const TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                    duration: const Duration(seconds: 2),
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    backgroundColor: Colors.blue[800],
                                  ),
                                );
                              },
                              onAddToFavorites: () {
                                final favoriteProvider =
                                    Provider.of<FavoriteProvider>(
                                      context,
                                      listen: false,
                                    );
                                if (favoriteProvider.favoriteItems.any(
                                  (item) =>
                                      item.name == selectedFoodItem &&
                                      item.image == selectedFoodImgUrl,
                                )) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        "$selectedFoodItem is already in your favorites",
                                        style: const TextStyle(
                                          color: Colors.white,
                                        ),
                                      ),
                                      duration: const Duration(seconds: 2),
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      backgroundColor: Colors.blue[800],
                                    ),
                                  );
                                } else {
                                  favoriteProvider.addToFavorites(
                                    FavoriteItem(
                                      name: selectedFoodItem,
                                      price: selectedFoodPrice,
                                      image: selectedFoodImgUrl,
                                      subtitle: selectedFoodSubtitle,
                                    ),
                                  );
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: const Text(
                                        "Added to favorites!",
                                        style: TextStyle(color: Colors.white),
                                      ),
                                      duration: const Duration(seconds: 2),
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      backgroundColor: Colors.blue[800],
                                    ),
                                  );
                                }
                              },
                              onClose: _closeDetailBox,
                            ),
                          ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerDocked,
          floatingActionButton: AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            bottom:
                isKeyboardVisible ? MediaQuery.of(context).viewInsets.bottom + 16 : 0,
            left: 0,
            right: 0,
            child: AnimatedOpacity(
              opacity: isDetailVisible ? 0 : 1,
              duration: const Duration(milliseconds: 300),
              child: IgnorePointer(
                ignoring: isDetailVisible,
                child: CustomBottomNavigation(
                  selectedIndex: 0,
                  context: context,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}