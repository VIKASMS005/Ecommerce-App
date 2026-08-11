import 'package:flutter/material.dart';
import '../providers/orders.dart';
import 'package:intl/intl.dart';

class OrderItem extends StatefulWidget {
  final OrderItems order;

  const OrderItem(this.order, {super.key});

  @override
  State<OrderItem> createState() => _OrderItemState();
}

class _OrderItemState extends State<OrderItem> {
  var _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(10),
      child: Column(
        children: [
          ListTile(
            title: Text(
              NumberFormat.simpleCurrency(
                locale: 'hi-IN',
                decimalDigits: 2,
              ).format(widget.order.amount),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              DateFormat('dd/MM/yyyy - hh:mm ').format(widget.order.date),
              style: const TextStyle(color: Colors.black54),
            ),
            trailing: IconButton(
              onPressed: () {
                setState(() {
                  _expanded = !_expanded;
                });
              },
              icon: Icon(_expanded ? Icons.expand_less : Icons.expand_more),
            ),
          ),

          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child:
                _expanded
                    ? Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 4,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ...widget.order.products.map(
                            (product) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 2),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      product.title,
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Text('${product.quantity}x '),
                                  const SizedBox(width: 5),
                                  Text(
                                    NumberFormat.simpleCurrency(
                                      locale: 'hi-IN',
                                      decimalDigits: 2,
                                    ).format(product.price),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 5),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Order ID : ',
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.black38,
                                ),
                              ),
                              SelectableText(
                                widget.order.id.substring(0, 8),
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 5),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Delivered To : ',
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.black38,
                                ),
                              ),
                              Text(
                                '${widget.order.address.fullName},${widget.order.address.phoneNumber}',
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '${widget.order.address.roomNo},${widget.order.address.area}',
                              ),
                              Text(
                                '${widget.order.address.city},${widget.order.address.state},${widget.order.address.pincode}',
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                        ],
                      ),
                    )
                    : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}
