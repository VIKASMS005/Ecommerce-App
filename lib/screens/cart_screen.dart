import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../providers/cart.dart';
import '../widgets/cart_item.dart';
import '../screens/manage_screens/address_screen/place_list.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});
  static const routeName = '/cart';
  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<Cart>(context);
    return Scaffold(
      appBar: AppBar(title: Text('Your Cart')),
      body: Column(
        children: [
          Card(
            margin: EdgeInsets.all(15),
            child: Padding(
              padding: EdgeInsets.all(8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total : ',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Chip(
                    label: Text(
                      NumberFormat.simpleCurrency(
                        locale: 'hi-IN',
                        decimalDigits: 2,
                      ).format(cart.totalAmount),
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    backgroundColor: Theme.of(context).primaryColor,
                  ),
                  Spacer(),
                  AddressButton(),
                ],
              ),
            ),
          ),
          SizedBox(height: 10),
          Expanded(
            child:
                cart.itemCount == 0
                    ? const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.shopping_cart_outlined,
                            size: 80,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Your cart is empty',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Add some products to place an order.',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    )
                    : ListView.builder(
                      itemCount: cart.itemCount,
                      itemBuilder:
                          (ctx, i) => CartItems(
                            id: cart.items.values.toList()[i].id,
                            productId: cart.items.keys.toList()[i],
                            price: cart.items.values.toList()[i].price,
                            title: cart.items.values.toList()[i].title,
                            quantity: cart.items.values.toList()[i].quantity,
                            imageUrl: cart.items.values.toList()[i].imageUrl,
                          ),
                    ),
          ),
        ],
      ),
    );
  }
}

class AddressButton extends StatefulWidget {
  const AddressButton({super.key});

  @override
  State<AddressButton> createState() => _AddressButtonState();
}

class _AddressButtonState extends State<AddressButton> {
  var isLoading = false;

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<Cart>(context);
    return TextButton(
      onPressed:
          cart.itemCount == 0
              ? null
              : () async {
                setState(() {
                  isLoading = true;
                });

                await Navigator.of(context).pushNamed(PlaceList.routeName);

                setState(() {
                  isLoading = false;
                });
              },
      child:
          isLoading
              ? CircularProgressIndicator()
              : Text('ORDER NOW', style: TextStyle(fontSize: 18)),
    );
  }
}
