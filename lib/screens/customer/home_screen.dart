import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:provider/provider.dart';
import '../../auth/auth_provider.dart';
import '../../providers/favorite_provider.dart';
import '../../providers/notification_provider.dart';
import '../../providers/order_provider.dart';
import '../../widgets/customer/custom_bottom_navigation.dart';
import '../../utils/app_theme.dart';
import '../../providers/theme_notifier.dart';
import 'favorite_screen.dart';
import 'notification_screen.dart';
import '../../data/search_data.dart';
import '../../widgets/customer/search_widget.dart';
import '../../widgets/customer/category_selector.dart';
import '../../widgets/customer/food_list.dart';
import '../../widgets/customer/detail_box.dart';

class HomeScreen extends StatefulWidget {
  final String? initialFoodItem;
  final String? initialFoodPrice;
  final String? initialFoodImgBase64;
  final String? initialFoodSubtitle;
  final String? initialSellerEmail;

  const HomeScreen({
    super.key,
    this.initialFoodItem,
    this.initialFoodPrice,
    this.initialFoodImgBase64,
    this.initialFoodSubtitle,
    this.initialSellerEmail,
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
  String selectedFoodImgBase64 = '';
  String selectedFoodSubtitle = '';
  String selectedSellerEmail = '';
  late AnimationController _boxController;
  late AnimationController _navController;
  final TextEditingController _searchController = TextEditingController();

  bool isKeyboardVisible = false;
  bool isSearchActive = false;
  String searchQuery = '';

  final FocusNode _searchFocusNode = FocusNode();
  DateTime? _lastBackPressTime;

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
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (authProvider.isLoggedIn && authProvider.user != null) {
        Provider.of<FavoriteProvider>(context, listen: false)
            .initialize(context)
            .then((_) {
          debugPrint('HomeScreen: FavoriteProvider initialized');
        }).catchError((e) {
          debugPrint('HomeScreen: Error initializing FavoriteProvider: $e');
        });
      }
      if (widget.initialFoodItem != null &&
          widget.initialFoodPrice != null &&
          widget.initialFoodImgBase64 != null) {
        setState(() {
          selectedFoodItem = widget.initialFoodItem!;
          selectedFoodPrice = widget.initialFoodPrice!;
          selectedFoodImgBase64 = widget.initialFoodImgBase64!;
          selectedFoodSubtitle = widget.initialFoodSubtitle ?? '';
          selectedSellerEmail = widget.initialSellerEmail ?? '';
          isDetailVisible = true;
          _boxController.forward();
          _navController.reverse();
          debugPrint('HomeScreen: Initialized with imgBase64 length: ${selectedFoodImgBase64.length}');
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

    final currentTime = DateTime.now();
    final backPressDuration = _lastBackPressTime == null
        ? Duration.zero
        : currentTime.difference(_lastBackPressTime!);

    if (backPressDuration >= const Duration(seconds: 2)) {
      _lastBackPressTime = currentTime;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Press back again to exit', style: TextStyle(color: AppTheme.getPrimaryText(true))),
          duration: const Duration(seconds: 2),
          backgroundColor: AppTheme.getSnackBarInfo(false),
        ),
      );
      return false;
    } else {
      _lastBackPressTime = null;
      return true;
    }
  }

  Future<void> _refreshData() async {
    await Future.delayed(const Duration(seconds: 2));
    setState(() {});
  }

  Future<void> _loadRecentSearches() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final customerName = authProvider.user?.name ?? '';
    await SearchData.loadRecentSearches(customerName);
    setState(() {});
  }

  void _handleSearch(String query) {
    setState(() {
      searchQuery = query;
    });
  }

  void _removeRecentSearch(String query) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final customerName = authProvider.user?.name ?? '';
    SearchData.removeRecentSearch(customerName, query);
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
    String imgBase64,
    String subtitle,
    String sellerEmail,
  ) {
    setState(() {
      selectedFoodItem = title;
      selectedFoodPrice = price;
      selectedFoodImgBase64 = imgBase64;
      selectedFoodSubtitle = subtitle;
      selectedSellerEmail = sellerEmail;
      isDetailVisible = true;
      _boxController.forward();
      _navController.reverse();
      debugPrint('HomeScreen: Food item tapped, imgBase64 length: ${imgBase64.length}, sellerEmail: $sellerEmail');
    });
  }

  Widget _buildMainContent(ThemeData theme, bool isDarkMode) {
    final orderProvider = Provider.of<OrderProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final customerName = authProvider.user?.name ?? '';
    final orderAgainItems = orderProvider.getOrderAgainItemsForCustomer(customerName);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Recommended for you",
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: AppTheme.getPrimaryText(isDarkMode),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Delicious meals just for you",
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppTheme.getSecondaryText(isDarkMode),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        FoodList(
          selectedCategory: selectedCategory,
          onFoodItemTap: (title, price, imgBase64, subtitle, sellerEmail) {
            _handleFoodItemTap(title, price, imgBase64, subtitle, sellerEmail);
          },
        ),
        const SizedBox(height: 24),
        if (orderAgainItems.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Order Again",
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.getPrimaryText(isDarkMode),
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Your favorite meals",
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppTheme.getSecondaryText(isDarkMode),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 240,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: orderAgainItems.length,
              itemBuilder: (context, index) {
                final food = orderAgainItems[index];
                return Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: FoodCard(
                    title: food["title"]!,
                    subtitle: food["subtitle"]!,
                    time: food["time"]!,
                    imgBase64: food["imgBase64"]!,
                    price: food["price"]!,
                    sellerEmail: food["sellerEmail"] ?? '',
                    onTap: () => _handleFoodItemTap(
                      food["title"]!,
                      food["price"]!,
                      food["imgBase64"]!,
                      food["subtitle"]!,
                      food["sellerEmail"] ?? '',
                    ),
                  ),
                );
              },
            ),
          ),
        ],
        const SizedBox(height: 100),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final favoriteProvider = Provider.of<FavoriteProvider>(context);
    final notificationProvider = Provider.of<NotificationProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final customerName = authProvider.user?.name ?? '';
    final unreadNotificationCount =
        notificationProvider.getUnreadCountForCustomer(customerName);
    final theme = Theme.of(context);
    final orderProvider = Provider.of<OrderProvider>(context);
    final orderAgainItems = orderProvider.getOrderAgainItemsForCustomer(customerName);
    final isDarkMode = Provider.of<ThemeNotifier>(context).isDarkMode;

    return WillPopScope(
      onWillPop: _onWillPop,
      child: KeyboardVisibilityProvider(
        child: Scaffold(
          backgroundColor: AppTheme.getCard(isDarkMode),
          appBar: AppBar(
            title: Text(
              'Home',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: AppTheme.getPrimaryText(isDarkMode),
              ),
            ),
            centerTitle: true,
            leading: IconButton(
              icon: Stack(
                children: [
                  Icon(Icons.favorite_border, color: AppTheme.getPrimaryText(isDarkMode)),
                  if (favoriteProvider.favoriteItems.isNotEmpty)
                    Positioned(
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: AppTheme.getBadge(isDarkMode),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 12,
                          minHeight: 12,
                        ),
                        child: Text(
                          '${favoriteProvider.favoriteItems.length}',
                          style: TextStyle(
                            color: AppTheme.getPrimaryText(!isDarkMode),
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
                    Icon(Icons.notifications_outlined, color: AppTheme.getPrimaryText(isDarkMode)),
                    if (unreadNotificationCount > 0)
                      Positioned(
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: AppTheme.getBadge(isDarkMode),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 12,
                            minHeight: 12,
                          ),
                          child: Text(
                            '$unreadNotificationCount',
                            style: TextStyle(
                              color: AppTheme.getPrimaryText(!isDarkMode),
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
            backgroundColor: AppTheme.getCard(isDarkMode),
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
                                      imgBase64,
                                      subtitle,
                                      sellerEmail,
                                    ) {
                                      _handleFoodItemTap(
                                        title,
                                        price,
                                        imgBase64,
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
                                    orderAgainItems: orderAgainItems,
                                  ),
                                ),
                                if (!isSearchActive && !isKeyboardVisible)
                                  _buildMainContent(theme, isDarkMode),
                              ],
                            ),
                          ),
                        ),
                        if (isDetailVisible)
                          Positioned.fill(
                            child: GestureDetector(
                              onTap: _closeDetailBox,
                              child: Container(
                                color: AppTheme.getPrimaryText(isDarkMode).withOpacity(0.4),
                              ),
                            ),
                          ),
                        if (isDetailVisible)
                          DetailBox(
                            selectedFoodItem: selectedFoodItem,
                            selectedFoodPrice: selectedFoodPrice,
                            selectedFoodImgBase64: selectedFoodImgBase64,
                            selectedFoodSubtitle: selectedFoodSubtitle,
                            sellerEmail: selectedSellerEmail,
                            onClose: _closeDetailBox,
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