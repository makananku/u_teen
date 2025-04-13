import 'package:flutter/material.dart';
import 'package:u_teen/widgets/food_list.dart';
import '../data/food_data.dart';
import '../data/search_data.dart';

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
          _buildOrderAgainSection(context),
        ],
      ],
    );
  }

  Widget _buildSearchBar(BuildContext context) {
  return TextField(
    controller: widget.searchController,
    focusNode: widget.focusNode,
    decoration: InputDecoration(
      hintText: "Search",
      prefixIcon: IconButton(
        icon: const Icon(Icons.search),
        onPressed: () {
          final query = widget.searchController.text.trim();
          if (query.isNotEmpty) {
            widget.onSearchSubmitted(query);
            SearchData.addRecentSearch(query);
            setState(() {
              searchQuery = query;
            });
          }
        },
      ),
      suffixIcon: widget.searchController.text.isNotEmpty
          ? IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                widget.searchController.clear();
                setState(() {
                  searchQuery = '';
                });
                widget.focusNode.requestFocus(); // Tetap fokus ke search bar
              },
            )
          : null,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: BorderSide.none,
      ),
      filled: true,
      fillColor: Colors.grey.shade200,
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
      // Tetap pertahankan fokus
      widget.focusNode.requestFocus();
    },
  );
}

  Widget _buildRecentSearches(List<String> recentSearches) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        "Recent Searches",
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 10),
      if (recentSearches.isEmpty) const Text("No recent searches"),
      if (recentSearches.isNotEmpty)
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: recentSearches.map((search) {
            return InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () {
                widget.searchController.text = search;
                setState(() {
                  searchQuery = search;
                });
                // Tidak memanggil onSearchSubmitted di sini
                // Biarkan TextField yang menangani submit
              },
              child: Chip(
                label: Text(search),
                deleteIcon: const Icon(Icons.clear, size: 18),
                onDeleted: () {
                  widget.onRemoveRecentSearch(search);
                  setState(() {});
                },
                backgroundColor: Colors.white,
                side: BorderSide(color: Colors.grey.shade300),
              ),
            );
          }).toList(),
        ),
    ],
  );
}

Widget _buildSearchResults(List<Map<String, String>> searchResults) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const SizedBox(height: 20),
      const Text(
        "Search Results",
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 10),
      if (searchResults.isEmpty) 
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 20.0),
          child: Center(
            child: Text(
              "No menu matches your search",
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 16,
              ),
            ),
          ),
        ),
      if (searchResults.isNotEmpty)
        ...searchResults.map((food) {
          return ListTile(
            leading: Image.asset(
              food["imgUrl"]!,
              width: 50,
              height: 50,
              fit: BoxFit.cover,
            ),
            title: Text(food["title"]!),
            subtitle: Text(food["subtitle"]!),
            trailing: Text("\Rp${food["price"]}"),
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
        }).toList(),
    ],
  );
}

  Widget _buildPopularCuisines(List<String> popularCuisines) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Popular Cuisines",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children:
              popularCuisines.map((cuisine) {
                return GestureDetector(
                  onTap: () {
                    widget.onFillSearchBar(cuisine);
                    setState(() {
                      searchQuery = cuisine;
                    });
                  },
                  child: Chip(
                    label: Text(cuisine),
                    backgroundColor: Colors.white,
                    side: BorderSide(color: Colors.grey.shade300),
                  ),
                );
              }).toList(),
        ),
      ],
    );
  }

  Widget _buildRecommendedSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: Text(
            "Recommended for you",
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
        const SizedBox(height: 16),
        FoodList(selectedCategory: 'All', onFoodItemTap: widget.onFoodItemTap),
      ],
    );
  }

  Widget _buildOrderAgainSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: Text(
            "Order Again",
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
        const SizedBox(height: 16),
        FoodList(selectedCategory: 'All', onFoodItemTap: widget.onFoodItemTap),
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
