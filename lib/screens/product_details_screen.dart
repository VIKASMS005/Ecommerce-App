import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopping_app/screens/manage_screens/address_screen/place_list.dart';

// import 'package:shopping_app/screens/cart_screen.dart';
import '../providers/products_provider.dart';
import 'package:intl/intl.dart';
import '../providers/cart.dart';

class ProductDetailsScreen extends StatelessWidget {
  const ProductDetailsScreen({super.key});
  static const routeName = '/product-details';

  @override
  Widget build(BuildContext context) {
    final mediaquery = MediaQuery.of(context);
    final productId = ModalRoute.of(context)!.settings.arguments as String;
    final loadedProduct = Provider.of<ProductsProvider>(
      context,
      listen: false,
    ).findById(productId);
    final cart = Provider.of<Cart>(context);
    Widget buildTextButton(String text, Function onPressed) {
      return TextButton(
        onPressed: () {
          onPressed();
        },
        child: Container(
          width: mediaquery.size.width * 0.55,
          //height: 30,
          decoration: BoxDecoration(
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(20),
            color: Theme.of(context).colorScheme.secondary,
          ),
          child: Center(
            child: Text(text, style: Theme.of(context).textTheme.titleMedium),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          loadedProduct.title,
          softWrap: false,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: double.infinity,
              height: mediaquery.size.height * 0.5,
              padding: EdgeInsets.all(20),
              child: Hero(
                tag: loadedProduct.id,
                child: Image.network(
                  loadedProduct.imageUrl,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            SizedBox(height: 10),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                children: [
                  Text('MRP : '),
                  Text(
                    NumberFormat.simpleCurrency(
                      locale: 'hi-IN',
                      decimalDigits: 2,
                    ).format(loadedProduct.price),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
            ),
            SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                loadedProduct.description,
                style: Theme.of(context).textTheme.displaySmall,
                softWrap: true,
              ),
            ),
            SizedBox(height: 20),
            buildTextButton('Add to Cart', () {
              cart.addItem(
                loadedProduct.id,
                loadedProduct.title,
                loadedProduct.price,
                loadedProduct.imageUrl,
              );
              // Navigator.of(context).pushNamed(CartScreen.routeName);
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Item Added  to Cart'),
                  duration: Duration(seconds: 3),
                  action: SnackBarAction(
                    label: 'UNDO',
                    onPressed: () {
                      cart.removeSingleItem(productId);
                    },
                  ),
                ),
              );
            }),
            buildTextButton('Buy Now', () {
              cart.addItem(
                loadedProduct.id,
                loadedProduct.title,
                loadedProduct.price,
                loadedProduct.imageUrl,
              );

              Navigator.of(context).pushNamed(PlaceList.routeName);
            }),
          ],
        ),
      ),
    );
  }
}
