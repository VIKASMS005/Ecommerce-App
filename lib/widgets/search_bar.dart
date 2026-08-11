import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/products_provider.dart';
import '../providers/products.dart';
import '../screens/product_details_screen.dart';

class SeacrchBarWidget extends StatefulWidget {
  const SeacrchBarWidget({super.key});
  @override
  State<SeacrchBarWidget> createState() => _SeacrchBarWidgetState();
}

class _SeacrchBarWidgetState extends State<SeacrchBarWidget> {
  final SearchController _searchController = SearchController();

  List<Widget> _buildSuggestions(BuildContext context) {
    final query = _searchController.text.trim().toLowerCase();

    if (query.isEmpty) {
      return const [];
    }

    final queryWords = query.split(RegExp(r'\s+'));

    final products =
        Provider.of<ProductsProvider>(context, listen: false).items;

    final matches =
        products.where((product) {
          final title = product.title.toLowerCase();
          return queryWords.every((word) => title.contains(word));
        }).toList();

    if (matches.isEmpty) {
      return const [
        ListTile(
          title: Text('No products found'),
          leading: Icon(Icons.search_off),
        ),
      ];
    }

    return matches.map((Product product) {
      return ListTile(
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: Image.network(
            product.imageUrl,
            width: 40,
            height: 40,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => const Icon(Icons.image_not_supported),
          ),
        ),
        title: Text(
          product.title,
          style: const TextStyle(color: Colors.black87),
        ),
        subtitle: Text(
          '₹${product.price.toStringAsFixed(0)}',
          style: const TextStyle(color: Colors.black54),
        ),
        onTap: () {
          _searchController.closeView(product.title);
          Navigator.of(
            context,
          ).pushNamed(ProductDetailsScreen.routeName, arguments: product.id);
        },
      );
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mediaquery = MediaQuery.of(context);
    return Container(
      alignment: Alignment.centerLeft,
      width: mediaquery.size.width * 0.85,
      padding: const EdgeInsets.all(8.0),
      child: SearchAnchor(
        searchController: _searchController,
        dividerColor: Colors.indigo,
        viewBackgroundColor: Colors.white,
        viewLeading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () {
            _searchController.closeView(null);
          },
        ),
        viewHintText: 'Search products.....',
        headerHintStyle: const TextStyle(color: Colors.black38),
        headerTextStyle: const TextStyle(color: Colors.black87),
        builder: (context, controller) {
          return SearchBar(
            controller: controller,
            elevation: const WidgetStatePropertyAll(0),
            backgroundColor: const WidgetStatePropertyAll(Colors.white),
            shape: WidgetStatePropertyAll(
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            ),
            leading: const Icon(Icons.search, color: Colors.black26),
            hintText: 'Search products.....',
            hintStyle: const WidgetStatePropertyAll(
              TextStyle(color: Colors.black26),
            ),
            onTap: () {
              controller.openView();
            },
          );
        },
        suggestionsBuilder: (context, controller) {
          return _buildSuggestions(context);
        },
      ),
    );
  }
}
