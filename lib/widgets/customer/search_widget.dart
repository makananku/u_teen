import 'package:flutter/material.dart';
import 'package:u_teen/widgets/food_list.dart';
import '../../data/food_data.dart';
import '../../data/search_data.dart';

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
  final List<Map<String, dynamic>> orderAgainItems;

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

  @override
  void initState() {
    super.initState();
    _loadRecentSearches();
  }

  Future<void> _loadRecentSearches() async {
    await SearchData.loadRecentSearches();
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final searchResults = _searchFoodItems(searchQuery);
    final recentSearches = SearchData.getRecentSearches();
    final popularCuisines = SearchData.getPopularCuisines();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSearchBar(context),

        if (!widget.isSearchActive) ...[
          const SizedBox(height: 20),
          widget.categorySelector,
        ],

        if (widget.isSearchActive)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (searchQuery.isNotEmpty) _buildSearchResults(searchResults),
              if (searchQuery.isEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    _buildRecentSearches(recentSearches),
                    const SizedBox(height: 20),
                    _buildPopularCuisines(popularCuisines),
                  ],
                ),
            ],
          ),

        if (widget.showFoodLists) ...[
          const SizedBox(height: 20),
          _buildRecommendedSection(context),
          const SizedBox(height: 24),
          if (widget.orderAgainItems.isNotEmpty) _buildOrderAgainSection(context),
        ],
      ],
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.4),
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
          hintStyle: TextStyle(color: Colors.grey.shade400),
          prefixIcon: Icon(Icons.search, color: Colors.grey.shade500),
          suffixIcon: widget.searchController.text.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.clear, color: Colors.grey.shade500),
                  onPressed: () {
                    widget.searchController.clear();
                    setState(() {
                      searchQuery = '';
                    });
                    widget.focusNode.requestFocus();
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.grey.shade50,
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
        ),
        onChanged: (value) {
          setState(() {
            searchQuery = value;
          });
        },
        onSubmitted: (value) {
          if (value.isNotEmpty) {
            widget.onSearchSubmitted(value);
            SearchData.addRecentSearch(value);
          }
          widget.focusNode.requestFocus();
        },
      ),
    );
  }

  Widget _buildRecentSearches(List<String> recentSearches) {
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
              color: Colors.grey.shade800,
            ),
          ),
        ),
        const SizedBox(height: 12),
        if (recentSearches.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              "No recent searches",
              style: TextStyle(color: Colors.grey.shade600),
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
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          search,
                          style: TextStyle(
                            color: Colors.grey.shade800,
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () {
                            widget.onRemoveRecentSearch(search);
                            setState(() {});
                          },
                          child: Icon(
                            Icons.close,
                            size: 16,
                            color: Colors.grey.shade600,
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

  Widget _buildSearchResults(List<Map<String, String>> searchResults) {
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
              color: Colors.grey.shade800,
            ),
          ),
        ),
        if (searchResults.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Center(
              child: Column(
                children: [
                  Icon(
                    Icons.search_off,
                    size: 48,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "No results found",
                    style: TextStyle(
                      color: Colors.grey.shade600,
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
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final food = searchResults[index];
              return ListTile(
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    food["imgUrl"]!,
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  ),
                ),
                title: Text(
                  food["title"]!,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                subtitle: Text(
                  food["subtitle"]!,
                  style: TextStyle(color: Colors.grey.shade600),
                ),
                trailing: Text(
                  "\Rp${food["price"]}",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF3A86FF),
                  ),
                ),
                onTap: () {
                  FocusScope.of(context).unfocus();
                  widget.onFoodItemTap(
                    food["title"]!,
                    food["price"]!,
                    food["imgUrl"]!,
                    food["subtitle"]!,
                    food["sellerEmail"] ?? '',
                  );
                  SearchData.addRecentSearch(food["title"]!);
                },
              );
            },
          ),
      ],
    );
  }

  Widget _buildPopularCuisines(List<String> popularCuisines) {
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
              color: Colors.grey.shade800,
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
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF3A86FF).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFF3A86FF).withOpacity(0.3),
                    ),
                  ),
                  child: Text(
                    cuisine,
                    style: const TextStyle(
                      color: Color(0xFF3A86FF),
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
  }

  Widget _buildRecommendedSection(BuildContext context) {
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
                  color: Colors.black,
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "Delicious meals just for you",
                style: TextStyle(
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        FoodList(
          selectedCategory: 'All',
          onFoodItemTap: widget.onFoodItemTap,
        ),
      ],
    );
  }

  Widget _buildOrderAgainSection(BuildContext context) {
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
                  color: Colors.black,
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "Your favorite meals",
                style: TextStyle(
                  color: Colors.grey.shade600,
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
                  imgUrl: food["imgUrl"]!,
                  price: food["price"]!,
                  sellerEmail: food["sellerEmail"] ?? '',
                  onTap: () => widget.onFoodItemTap(
                    food["title"]!,
                    food["price"]!,
                    food["imgUrl"]!,
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

  List<Map<String, String>> _searchFoodItems(String query) {
    final allFoodItems = FoodData.getFoodItems('All');
    if (query.isEmpty) return [];
    return allFoodItems.where((food) {
      final titleMatch = food["title"]!.toLowerCase().contains(
        query.toLowerCase(),
      );
      final subtitleMatch = food["subtitle"]!.toLowerCase().contains(
        query.toLowerCase(),
      );
      return titleMatch || subtitleMatch;
    }).toList();
  }
}