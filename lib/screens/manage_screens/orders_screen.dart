import 'package:flutter/material.dart';
import '../../providers/orders.dart';
import 'package:provider/provider.dart';
import '../../widgets/order_item.dart';

class OrdersScreen extends StatelessWidget {
  static const routeName = '/orders';

  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    //final orderData = Provider.of<Orders>(context);
    return Scaffold(
      appBar: AppBar(title: Text('Your Orders')),
      body: FutureBuilder(
        future: Provider.of<Orders>(context, listen: false).fetchAndSetOrders(),
        builder: (ctx, dataSnapShot) {
          if (dataSnapShot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (dataSnapShot.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Something went wrong while loading your orders.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      Provider.of<Orders>(
                        context,
                        listen: false,
                      ).fetchAndSetOrders();
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          } else {
            return Consumer<Orders>(
              builder:
                  (context, orderData, child) =>
                      orderData.orders.isEmpty
                          ? const Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.receipt_long_outlined,
                                  size: 80,
                                  color: Colors.grey,
                                ),
                                SizedBox(height: 16),
                                Text(
                                  'No Orders Yet',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Start shopping to see your orders here.',
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                          )
                          : ListView.builder(
                            itemCount: orderData.orders.length,
                            itemBuilder:
                                (ctx, i) => OrderItem(orderData.orders[i]),
                          ),
            );
          }
        },
      ),
    );
  }
}
