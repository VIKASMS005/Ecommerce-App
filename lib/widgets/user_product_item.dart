import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../screens/manage_screens/edit_products_screen.dart';
import 'package:provider/provider.dart';
import '../providers/products_provider.dart';

class UserProductItem extends StatelessWidget {
  final String id;
  final String title;
  final String imageUrl;
  final double price;
  const UserProductItem(
    this.id,
    this.title,
    this.imageUrl,
    this.price, {
    super.key,
  });
  @override
  Widget build(BuildContext context) {
    final scaffold = ScaffoldMessenger.of(context);
    return ListTile(
      title: Text(title),
      leading: CircleAvatar(backgroundImage: NetworkImage(imageUrl)),
      subtitle: Text(
        NumberFormat.simpleCurrency(
          locale: 'hi-IN',
          decimalDigits: 2,
        ).format(price),
      ),
      trailing: SizedBox(
        width: MediaQuery.of(context).size.width * 0.24,
        child: Row(
          children: [
            IconButton(
              onPressed: () {
                Navigator.of(
                  context,
                ).pushNamed(EditProductsScreen.routeName, arguments: id);
              },
              icon: Icon(
                Icons.edit,
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
            IconButton(
              onPressed: () async {
                try {
                  await Provider.of<ProductsProvider>(
                    context,
                    listen: false,
                  ).deleteProduct(id);
                } catch (error) {
                  scaffold.showSnackBar(
                    SnackBar(content: Text('Deletion Failed!!')),
                  );
                }
              },
              icon: Icon(
                Icons.delete,
                color: Theme.of(context).colorScheme.error,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
