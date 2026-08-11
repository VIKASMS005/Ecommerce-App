import 'package:flutter/material.dart';
import '../screens/product_details_screen.dart';
import 'package:provider/provider.dart';
import '../providers/products.dart';
import '../providers/cart.dart';

class ProductItem extends StatelessWidget {
  const ProductItem({super.key});
  // final String id;
  // final String title;
  // final String imageUrl;

  // ProductItem(this.id, this.title, this.imageUrl);

  @override
  Widget build(BuildContext context) {
    final scaffold = ScaffoldMessenger.of(context);
    final product = Provider.of<Product>(context, listen: false);
    final cartProducts = Provider.of<Cart>(context, listen: false);
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: GridTile(
        footer: GridTileBar(
          leading: Consumer<Product>(
            builder:
                (ctx, product, _) => IconButton(
                  onPressed: () async {
                    try {
                      await product.toggleFavorite();
                    } catch (error) {
                      scaffold.showSnackBar(
                        SnackBar(content: Text('Something Went Wrong!!')),
                      );
                    }
                  },
                  icon:
                      product.isFavorite
                          ? Icon(Icons.favorite, color: Colors.redAccent)
                          : Icon(Icons.favorite_border),
                ),
          ),
          backgroundColor: Colors.black87,
          title: Text(
            product.title,
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          trailing: IconButton(
            onPressed: () {
              cartProducts.addItem(
                product.id,
                product.title,
                product.price,
                product.imageUrl,
              );
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
              final messenger = ScaffoldMessenger.of(context);

              messenger.clearSnackBars();

              final controller = messenger.showSnackBar(
                SnackBar(
                  content: const Text('Item added to cart'),
                  duration: const Duration(seconds: 2),
                  action: SnackBarAction(
                    label: 'UNDO',
                    onPressed: () {
                      cartProducts.removeSingleItem(product.id);
                    },
                  ),
                ),
              );

              controller.closed.then((_) {});

              Future.delayed(const Duration(seconds: 2), () {
                controller.close();
              });
            },
            icon: Icon(Icons.shopping_cart),
          ),
        ),
        child: GestureDetector(
          onTap: () {
            Navigator.of(
              context,
            ).pushNamed(ProductDetailsScreen.routeName, arguments: product.id);
          },
          child: Hero(
            tag: product.id,
            child: Image.network(product.imageUrl, fit: BoxFit.cover),
          ),
        ),
      ),
    );
  }
}
