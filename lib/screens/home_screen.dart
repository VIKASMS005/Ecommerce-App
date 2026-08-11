import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import './products_screen.dart';
import '../providers/products_provider.dart';
//import '../providers/cart.dart';
//import './cart_screen.dart';
import '/widgets/search_bar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  static const routeName = '/home';
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

enum FilterOptions { favorites, all }

class _HomeScreenState extends State<HomeScreen> {
  var isInit = true;
  var _showOnlyFavorites = false;
  var _isLoading = false;
  @override
  void initState() {
    // Provider.of<ProductsProvider>(context, listen: false).fetchProducts();
    // Future.delayed(Duration.zero).then((_) {
    //   Provider.of<ProductsProvider>(context).fetchProducts();
    // });
    super.initState();
  }

  @override
  void didChangeDependencies() {
    if (isInit) {
      setState(() {
        _isLoading = true;
      });
      Provider.of<ProductsProvider>(context, listen: false)
          .fetchProducts()
          .then((_) {
            setState(() {
              _isLoading = false;
            });
          })
          .catchError((error) {
            setState(() {
              _isLoading = false;
            });
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Failed to load products')),
              );
            }
          });
      isInit = false;
      super.didChangeDependencies();
    }
  }

  @override
  Widget build(BuildContext context) {
    debugPrint(
      'accessibleNavigation = ${MediaQuery.of(context).accessibleNavigation}',
    );
    //final favProducts = Provider.of<ProductsProvider>(context);
    return Scaffold(
      appBar: AppBar(
        actions: [
          SeacrchBarWidget(),
          PopupMenuButton(
            icon: Icon(Icons.more_vert, color: Colors.white),
            onSelected: (FilterOptions selectedValue) {
              setState(() {
                if (selectedValue == FilterOptions.favorites) {
                  //favProducts.showFavorites();
                  _showOnlyFavorites = true;
                } else {
                  //favProducts.showAll();
                  _showOnlyFavorites = false;
                }
              });
            },
            itemBuilder:
                (_) => [
                  PopupMenuItem(
                    value: FilterOptions.favorites,
                    child: Text("Wishlist"),
                  ),
                  PopupMenuItem(value: FilterOptions.all, child: Text("All")),
                ],
          ),
        ],
      ),
      body:
          _isLoading
              ? Center(child: CircularProgressIndicator())
              : Column(
                children: [Expanded(child: Products(_showOnlyFavorites))],
              ),
    );
  }
}
