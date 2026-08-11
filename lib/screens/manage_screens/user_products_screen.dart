import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/products_provider.dart';
import '../../widgets/user_product_item.dart';
import 'edit_products_screen.dart';

class UserProductsScreen extends StatelessWidget {
  const UserProductsScreen({super.key});

  static const routeName = '/userproductscreen';

  Future<void> _refreshProducts(BuildContext context) async {
    await Provider.of<ProductsProvider>(
      context,
      listen: false,
    ).fetchProducts(true);
  }

  @override
  Widget build(BuildContext context) {
    //final productData = Provider.of<ProductsProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Products'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.of(context).pushNamed(EditProductsScreen.routeName);
            },
          ),
        ],
      ),
      body: FutureBuilder(
        future: _refreshProducts(context),
        builder:
            (context, snapshot) =>
                snapshot.connectionState == ConnectionState.waiting
                    ? Center(child: CircularProgressIndicator())
                    : RefreshIndicator(
                      onRefresh: () => _refreshProducts(context),
                      child: Consumer<ProductsProvider>(
                        builder:
                            (context, productData, child) => Padding(
                              padding: EdgeInsets.all(8),
                              child: ListView.builder(
                                itemCount: productData.userItems.length,
                                itemBuilder: (_, i) {
                                  return Column(
                                    children: [
                                      UserProductItem(
                                        productData.userItems[i].id,
                                        productData.userItems[i].title,
                                        productData.userItems[i].imageUrl,
                                        productData.userItems[i].price,
                                      ),
                                      Divider(color: Colors.black12),
                                    ],
                                  );
                                },
                              ),
                            ),
                      ),
                    ),
      ),
    );
  }
}
