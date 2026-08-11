import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopping_app/models/place_model.dart';
import 'package:shopping_app/screens/order_success_screen.dart';
import '/screens/manage_screens/address_screen/add_place_screen.dart';
import '/providers/places.dart';
import 'package:shopping_app/providers/orders.dart';
import 'package:shopping_app/providers/cart.dart';

class PlaceList extends StatefulWidget {
  const PlaceList({super.key});
  static const routeName = '/placesList';

  @override
  State<PlaceList> createState() => _PlaceListState();
}

class _PlaceListState extends State<PlaceList> {
  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      if (!mounted) return;
      Provider.of<Places>(context, listen: false).loadAddress();
    });
  }

  IconData getAddressIcon(String addressType) {
    switch (addressType) {
      case 'Home':
        return Icons.home_outlined;
      case 'Work':
        return Icons.work_outline_outlined;
      case 'Hostel':
        return Icons.school_outlined;
    }
    return Icons.location_on_outlined;
  }

  Widget showPopupMenu(
    BuildContext context,
    String addressId,
    PlaceModel? address,
  ) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert),
      onSelected: (value) {
        if (value == 'delete') {
          showDialog(
            context: context,
            builder:
                (context) => AlertDialog(
                  title: const Text('Do you want to delete this address??'),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        Provider.of<Places>(
                          context,
                          listen: false,
                        ).deleteAddress(addressId);
                      },
                      child: const Text('Yes'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('No'),
                    ),
                  ],
                ),
          );
        } else if (value == 'edit') {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => AddPlaceScreen(address: address)),
          );
        }
      },
      itemBuilder:
          (context) => [
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [Icon(Icons.edit), SizedBox(width: 8), Text('Edit')],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Delete'),
                ],
              ),
            ),
          ],
    );
  }

  var isLoading = false;

  Future<OrderItems> placeOrder(PlaceModel selectedAddress) async {
    final cart = Provider.of<Cart>(context, listen: false);

    setState(() {
      isLoading = true;
    });

    try {
      final order = await Provider.of<Orders>(context, listen: false).addOrders(
        cart.items.values.toList(),
        cart.totalAmount,
        selectedAddress,
      );

      cart.clear();

      return order;
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  void onAddressTap(PlaceModel place) {
    final cart = Provider.of<Cart>(context, listen: false);

    if (cart.itemCount == 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Cart is empty')));
      return;
    }

    confirmPlaceOrder(place);
  }

  void confirmPlaceOrder(PlaceModel place) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Place Order'),
          content: const Text('Do you want to place your order?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();

                final navigator = Navigator.of(context);
                final scaffold = ScaffoldMessenger.of(context);

                try {
                  final order = await placeOrder(place);
                  navigator.pushReplacementNamed(
                    OrderSuccessScreen.routeName,
                    arguments: order,
                  );
                } catch (error) {
                  scaffold.showSnackBar(
                    const SnackBar(
                      content: Text('Failed to place order. Please try again.'),
                    ),
                  );
                }
              },
              child: const Text('Yes, Place Order'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final secondary = Theme.of(context).colorScheme.secondary;

    if (isLoading) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 20),
              Text('Placing your order...', style: TextStyle(fontSize: 16)),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text('Saved Address'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).pushNamed(AddPlaceScreen.routeName);
            },
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: Consumer<Places>(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.location_off, size: 48, color: Colors.grey.shade400),
              const SizedBox(height: 12),
              const Text('No address saved yet'),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  side: BorderSide(color: secondary),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).pushNamed(AddPlaceScreen.routeName);
                },
                icon: Icon(Icons.add, color: secondary),
                label: Text('Add address', style: TextStyle(color: secondary)),
              ),
            ],
          ),
        ),
        builder: (ctx, places, ch) {
          if (places.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (places.places.isEmpty) {
            return ch!;
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            itemCount: places.places.length,
            itemBuilder: (context, index) {
              final place = places.places[index];

              return Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () => onAddressTap(place),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          radius: 22,
                          backgroundColor: secondary.withValues(alpha: 0.12),
                          child: Icon(
                            getAddressIcon(place.addressType),
                            color: secondary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 3,
                                    ),
                                    decoration: BoxDecoration(
                                      color: secondary.withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      place.addressType,
                                      style: TextStyle(
                                        color: secondary,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                place.fullName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${place.roomNo}, ${place.area}',
                                style: TextStyle(color: Colors.grey.shade700),
                              ),
                              Text(
                                '${place.city}, ${place.pincode}',
                                style: TextStyle(color: Colors.grey.shade700),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                place.phoneNumber,
                                style: TextStyle(color: Colors.grey.shade600),
                              ),
                            ],
                          ),
                        ),
                        showPopupMenu(context, place.id, place),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
