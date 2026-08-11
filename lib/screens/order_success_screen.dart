import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shopping_app/screens/manage_screens/orders_screen.dart';
import 'package:shopping_app/screens/tabs_screen.dart';
import '../providers/orders.dart';

class OrderSuccessScreen extends StatelessWidget {
  const OrderSuccessScreen({super.key});

  static const routeName = '/order-success';

  @override
  Widget build(BuildContext context) {
    final order = ModalRoute.of(context)!.settings.arguments as OrderItems;
    final deviceSize = MediaQuery.of(context).size;
    final estimatedDelivery = DateTime.now().add(const Duration(days: 2));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Placed'),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 20),

            Image.asset(
              'assets/images/order_success.png',
              height: deviceSize.height * 0.2,
            ),

            const SizedBox(height: 20),
            Text(
              'Order Placed Successfully!',
              style: TextStyle(
                fontSize: deviceSize.width * 0.065,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              'Thank you for shopping with us.\nYour order has been confirmed.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: deviceSize.width * 0.04,
              ),
            ),

            const SizedBox(height: 30),

            Card(
              elevation: 6,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.shopping_bag_outlined,
                          color: Colors.green,
                        ),
                        const SizedBox(width: 8),

                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Order ID",
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 12,
                                ),
                              ),
                              SelectableText(
                                order.id.substring(0, 8),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 30),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Order Date",
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 12,
                              ),
                            ),

                            Text(
                              DateFormat(
                                'dd MMM yyyy, hh:mm a',
                              ).format(DateTime.now()),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    Divider(height: 35, color: Colors.grey[400]),

                    Row(
                      children: [
                        const Icon(
                          Icons.local_shipping_outlined,
                          color: Colors.green,
                        ),
                        const SizedBox(width: 8),

                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Estimated Delivery",
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 12,
                                ),
                              ),

                              Text(
                                DateFormat(
                                  'dd MMM yyyy',
                                ).format(estimatedDelivery),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 30),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            "Confirmed",
                            style: TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Divider(height: 35, color: Colors.grey[400]),

                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          color: Colors.green,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Delivery Address",
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 12,
                                ),
                              ),
                              Text(
                                order.address.fullName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                '${order.address.roomNo}, ${order.address.area}',
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 12,
                                ),
                              ),
                              Text(
                                '${order.address.city}, ${order.address.state},${order.address.pincode}',
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 12,
                                ),
                              ),
                              Text(
                                order.address.phoneNumber,
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(
                    context,
                  ).pushReplacementNamed(TabsScreen.routeName);
                },
                style: ElevatedButton.styleFrom(
                  elevation: 8,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                    side: BorderSide(color: Colors.green, width: 1),
                  ),
                  backgroundColor: Colors.green,
                ),
                child: Text(
                  'Continue Shopping',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.of(
                    context,
                  ).pushReplacementNamed(OrdersScreen.routeName);
                },
                style: OutlinedButton.styleFrom(
                  elevation: 8,
                  side: BorderSide(color: Colors.green, width: 2),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                child: Text(
                  'View Orders',
                  style: TextStyle(fontSize: 16, color: Colors.green),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
