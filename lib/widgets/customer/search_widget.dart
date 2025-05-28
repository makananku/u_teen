import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import '../../providers/food_provider.dart';
import '../../data/search_data.dart';
import '../../utils/app_theme.dart';
import '../../providers/theme_notifier.dart';
import 'food_list.dart';
import '../../models/product_model.dart';
import 'dart:convert';

class SearchWidget extends StatefulWidget {
  final TextEditingController searchController;
  final Function(String) onSearchSubmitted;
  final Function(String) onFillSearchBar;
  final Function(String) onRemoveRecentSearch;
  final Function(String, String, String, String, String) onFoodItemTap;
  final bool isSearchActive;
  final FocusNode focusNode;
  final Widget categorySelector;
  final bool showFoodLists;
  final List<Map<String, String>> orderAgainItems;

  const SearchWidget({
    Key? key,
    required this.searchController,
    required this.onSearchSubmitted,
    required this.onFillSearchBar,
    required this.onRemoveRecentSearch,
    required this.onFoodItemTap,
    required this.isSearchActive,
    required this.focusNode,
    required this.categorySelector,
    required this.showFoodLists,
    required this.orderAgainItems,
  }) : super(key: key);

  @override
  _SearchWidgetState createState() => _SearchWidgetState();
}

class _SearchWidgetState extends State<SearchWidget> {
  String searchQuery = '';
  String? userEmail;

  @override
  void initState() {
    super.initState();
    debugPrint('Initializing SearchWidget');
    final user = fb.FirebaseAuth.instance.currentUser;
    userEmail = user?.email;
    if (userEmail != null) {
      SearchData.loadRecentSearches(userEmail!);
      debugPrint('Loaded recent searches for user: $userEmail');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Provider.of<ThemeNotifier>(context).isDarkMode;
    final foodProvider = Provider.of<FoodProvider>(context);
    final searchResults = _searchFoodItems(searchQuery, foodProvider.products);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSearchBar(context, isDarkMode),
        if (!widget.isSearchActive) ...[
          const SizedBox(height: 20),
          widget.categorySelector,
        ],
        if (widget.isSearchActive && userEmail != null)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (searchQuery.isNotEmpty)
                _buildSearchResults(searchResults, isDarkMode),
              if (searchQuery.isEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    _buildRecentSearches(isDarkMode),
                    const SizedBox(height: 20),
                    _buildPopularCuisines(isDarkMode),
                  ],
                ),
            ],
          ),
        if (widget.showFoodLists) ...[
          const SizedBox(height: 20),
          _buildRecommendedSection(context, isDarkMode, foodProvider.products),
          const SizedBox(height: 24),
          if (widget.orderAgainItems.isNotEmpty)
            _buildOrderAgainSection(context, isDarkMode),
        ],
      ],
    );
  }

  Widget _buildSearchBar(BuildContext context, bool isDarkMode) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.getCard(isDarkMode),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.getSecondaryText(isDarkMode).withOpacity(0.4),
            blurRadius: 10,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: widget.searchController,
        focusNode: widget.focusNode,
        decoration: InputDecoration(
          hintText: "Search for food...",
          hintStyle: TextStyle(color: AppTheme.getSecondaryText(isDarkMode)),
          prefixIcon:
              Icon(Icons.search, color: AppTheme.getSecondaryText(isDarkMode)),
          suffixIcon: widget.searchController.text.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.clear,
                      color: AppTheme.getSecondaryText(isDarkMode)),
                  onPressed: () {
                    widget.searchController.clear();
                    setState(() {
                      searchQuery = '';
                    });
                    widget.focusNode.requestFocus();
                    debugPrint('Cleared search query');
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: AppTheme.getDetailBackground(isDarkMode),
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
        ),
        style: TextStyle(color: AppTheme.getPrimaryText(isDarkMode)),
        onChanged: (value) {
          setState(() {
            searchQuery = value;
          });
          debugPrint('Search query changed to: $searchQuery');
        },
        onSubmitted: (value) {
          if (value.isNotEmpty && userEmail != null) {
            widget.onSearchSubmitted(value);
            SearchData.addRecentSearch(value, userEmail!);
            debugPrint('Search submitted: $value');
          }
          widget.focusNode.requestFocus();
        },
      ),
    );
  }

  Widget _buildRecentSearches(bool isDarkMode) {
    final recentSearches = SearchData.getRecentSearches();
    debugPrint('Building recent searches: ${recentSearches.length} items');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            "Recent Searches",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppTheme.getPrimaryText(isDarkMode),
            ),
          ),
        ),
        const SizedBox(height: 12),
        if (recentSearches.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              "No recent searches",
              style: TextStyle(color: AppTheme.getSecondaryText(isDarkMode)),
            ),
          ),
        if (recentSearches.isNotEmpty)
          SizedBox(
            height: 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              itemCount: recentSearches.length,
              separatorBuilder: (context, index) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final search = recentSearches[index];
                return GestureDetector(
                  onTap: () {
                    widget.searchController.text = search;
                    setState(() {
                      searchQuery = search;
                    });
                    debugPrint('Tapped recent search: $search');
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.getDivider(isDarkMode),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          search,
                          style: TextStyle(
                            color: AppTheme.getPrimaryText(isDarkMode),
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () {
                            if (userEmail != null) {
                              widget.onRemoveRecentSearch(search);
                              SearchData.removeRecentSearch(search, userEmail!);
                              setState(() {});
                              debugPrint('Removed recent search: $search');
                            }
                          },
                          child: Icon(
                            Icons.close,
                            size: 16,
                            color: AppTheme.getSecondaryText(isDarkMode),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildSearchResults(List<Product> searchResults, bool isDarkMode) {
    debugPrint('Building search results: ${searchResults.length} items');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Text(
            "Search Results",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppTheme.getPrimaryText(isDarkMode),
            ),
          ),
        ),
        if (searchResults.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.search_off,
                    size: 48,
                    color: AppTheme.getSecondaryText(isDarkMode),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "No results found",
                    style: TextStyle(
                      color: AppTheme.getSecondaryText(isDarkMode),
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
        if (searchResults.isNotEmpty)
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: searchResults.length,
            separatorBuilder: (context, index) => Divider(
              height: 1,
              color: AppTheme.getDivider(isDarkMode),
            ),
            itemBuilder: (context, index) {
              final food = searchResults[index];
              return ListTile(
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: food.imgBase64.isNotEmpty
                      ? Image.memory(
                          base64Decode(food.imgBase64),
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                        )
                      : Icon(
                          Icons.image,
                          color: AppTheme.getSecondaryText(isDarkMode),
                        ),
                ),
                title: Text(
                  food.title,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: AppTheme.getPrimaryText(isDarkMode),
                  ),
                ),
                subtitle: Text(
                  food.subtitle,
                  style: TextStyle(color: AppTheme.getSecondaryText(isDarkMode)),
                ),
                trailing: Text(
                  "Rp${food.price}",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.getAccentBlueInfo(isDarkMode),
                  ),
                ),
                onTap: () {
                  FocusScope.of(context).unfocus();
                  widget.onFoodItemTap(
                    food.title,
                    food.price,
                    food.imgBase64,
                    food.subtitle,
                    food.sellerEmail,
                  );
                  if (userEmail != null) {
                    SearchData.addRecentSearch(food.title, userEmail!);
                    debugPrint('Added to recent search: ${food.title}');
                  }
                },
              );
            },
          ),
      ],
    );
  }

  Widget _buildPopularCuisines(bool isDarkMode) {
    debugPrint('Building popular cuisines');
    return FutureBuilder<List<String>>(
      future: SearchData.getPopularCuisines(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final popularCuisines = snapshot.data ?? [];
        debugPrint('Fetched popular cuisines: ${popularCuisines.length} items');
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Text(
                "Popular Categories",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.getPrimaryText(isDarkMode),
                ),
              ),
            ),
            SizedBox(
              height: 40,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                itemCount: popularCuisines.length,
                separatorBuilder: (context, index) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final cuisine = popularCuisines[index];
                  return GestureDetector(
                    onTap: () {
                      widget.onFillSearchBar(cuisine);
                      setState(() {
                        searchQuery = cuisine;
                      });
                      debugPrint('Tapped popular cuisine: $cuisine');
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.getAccentBlueInfo(isDarkMode).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppTheme.getAccentBlueInfo(isDarkMode).withOpacity(0.3),
                        ),
                      ),
                      child: Text(
                        cuisine,
                        style: TextStyle(
                          color: AppTheme.getAccentBlueInfo(isDarkMode),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildRecommendedSection(BuildContext context, bool isDarkMode, List<Product> products) {
    debugPrint('Building recommended section');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Recommended",
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.getPrimaryText(isDarkMode),
                      fontSize: 20,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                "Delicious meals just for you",
                style: TextStyle(
                  color: AppTheme.getSecondaryText(isDarkMode),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        FoodList(
          selectedCategory: 'All',
          onFoodItemTap: widget.onFoodItemTap,
          products: products,
        ),
      ],
    );
  }

  Widget _buildOrderAgainSection(BuildContext context, bool isDarkMode) {
    debugPrint('Building order again section with ${widget.orderAgainItems.length} items');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Order Again",
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.getPrimaryText(isDarkMode),
                      fontSize: 20,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                "Your favorite meals",
                style: TextStyle(
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
            itemCount: widget.orderAgainItems.length,
            itemBuilder: (context, index) {
              final food = widget.orderAgainItems[index];
              return Padding(
                padding: const EdgeInsets.only(right: 16),
                child: FoodCard(
                  title: food["title"]!,
                  subtitle: food["subtitle"]!,
                  time: food["time"]!,
                  imgBase64: food["imgUrl"]!, // Asumsi imgUrl di sini sebenarnya imgBase64
                  price: food["price"]!,
                  sellerEmail: food["sellerEmail"] ?? '',
                  onTap: () => widget.onFoodItemTap(
                    food["title"]!,
                    food["price"]!,
                    food["imgUrl"]!, // Asumsi imgUrl di sini sebenarnya imgBase64
                    food["subtitle"]!,
                    food["sellerEmail"] ?? '',
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  List<Product> _searchFoodItems(String query, List<Product> products) {
    if (query.isEmpty) return [];
    final results = products.where((food) {
      final titleMatch = food.title.toLowerCase().contains(query.toLowerCase());
      final subtitleMatch = food.subtitle.toLowerCase().contains(query.toLowerCase());
      return titleMatch || subtitleMatch;
    }).toList();
    debugPrint('Search results for query "$query": ${results.length} items');
    return results;
  }
}