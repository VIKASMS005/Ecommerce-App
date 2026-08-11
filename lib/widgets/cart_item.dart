import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/cart.dart';

class CartItems extends StatelessWidget {
  final String id;
  final String productId;
  final double price;
  final int quantity;
  final String title;
  final String imageUrl;

  const CartItems({
    super.key,
    required this.id,
    required this.productId,
    required this.price,
    required this.quantity,
    required this.title,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(id),
      background: Container(
        padding: EdgeInsets.only(right: 20),
        margin: EdgeInsets.symmetric(horizontal: 15, vertical: 4),
        alignment: Alignment.centerRight,
        child: Icon(Icons.delete, size: 35, color: Colors.redAccent),
      ),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) {
        return showDialog(
          context: context,
          builder: (ctx) {
            return AlertDialog(
              title: Text('Are you sure??'),
              content: Text(
                "Do you really want to delete the item from cart??",
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(ctx).pop(false);
                  },
                  child: Text('No'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(ctx).pop(true);
                  },
                  child: Text('Yes'),
                ),
              ],
            );
          },
        );
      },
      onDismissed: (direction) {
        Provider.of<Cart>(context, listen: false).removeItem(productId);
      },
      child: Card(
        margin: EdgeInsets.symmetric(horizontal: 15, vertical: 4),
        child: Padding(
          padding: EdgeInsets.all(8),
          child: ListTile(
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
                width: 50,
                height: 50,
              ),
            ),
            title: Text(title),
            subtitle: Text(
              NumberFormat.simpleCurrency(
                locale: 'hi-IN',
                decimalDigits: 2,
              ).format(price * quantity),
            ),

            trailing: SizedBox(
              width: 115,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade400),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    IconButton(
                      iconSize: 18,
                      onPressed: () {
                        Provider.of<Cart>(
                          context,
                          listen: false,
                        ).decreaseQuantity(productId);
                      },
                      icon: Icon(Icons.remove),
                    ),
                    Text(
                      '$quantity',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      iconSize: 18,
                      onPressed: () {
                        Provider.of<Cart>(
                          context,
                          listen: false,
                        ).increaseQuantity(productId);
                      },
                      icon: Icon(Icons.add),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
