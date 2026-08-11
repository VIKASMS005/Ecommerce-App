import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:shopping_app/models/place_model.dart';
import 'package:shopping_app/providers/cart.dart';
import 'package:firebase_auth/firebase_auth.dart';

class OrderItems {
  final String id;
  final double amount;
  final DateTime date;
  final List<CartItem> products;
  final PlaceModel address;

  OrderItems(this.id, this.amount, this.date, this.products, this.address);
}

class Orders with ChangeNotifier {
  List<OrderItems> _orders = [];

  List<OrderItems> get orders {
    return [..._orders];
  }

  String? get _userId => FirebaseAuth.instance.currentUser?.uid;

  Future<void> fetchAndSetOrders() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final token = await user.getIdToken();
    final url = Uri.parse(
      'https://shopping-app-8c5f9-default-rtdb.asia-southeast1.firebasedatabase.app/orders/$_userId.json?auth=$token',
    );
    final response = await http.get(url);
    final List<OrderItems> loadedOrders = [];
    final extractedData = json.decode(response.body);
    if (extractedData == null) {
      return;
    }
    (extractedData as Map<String, dynamic>).forEach((orderId, orderData) {
      if (orderData == null || orderData['address'] == null) {
        return;
      }
      final address = PlaceModel.fromMap(
        orderData['address'],
        id: orderData['address']['id'],
      );
      loadedOrders.add(
        OrderItems(
          orderId,
          (orderData['amount'] as num).toDouble(),
          DateTime.parse(orderData['dateTime']),
          (orderData['products'] as List<dynamic>)
              .map(
                (item) => CartItem(
                  id: item['id'],
                  title: item['title'],
                  quantity: item['quantity'],
                  price: (item['price'] as num).toDouble(),
                  imageUrl: item['imageUrl'] ?? '',
                ),
              )
              .toList(),
          address,
        ),
      );
    });
    debugPrint(response.body);
    _orders = loadedOrders.reversed.toList();
    notifyListeners();
  }

  Future<OrderItems> addOrders(
    List<CartItem> cartProducts,
    double total,
    PlaceModel address,
  ) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('User not logged in');
    }
    final token = await user.getIdToken();
    final url = Uri.parse(
      'https://shopping-app-8c5f9-default-rtdb.asia-southeast1.firebasedatabase.app/orders/$_userId.json?auth=$token',
    );
    final timestamp = DateTime.now();
    try {
      final response = await http.post(
        url,
        body: json.encode({
          'amount': total,
          'dateTime': timestamp.toIso8601String(),
          'address': {
            ...address.toMap(),
            'location': {
              'latitude': address.location.latitude,
              'longitude': address.location.longitude,
            },
          },
          'products':
              cartProducts
                  .map(
                    (cp) => {
                      'id': cp.id,
                      'title': cp.title,
                      'quantity': cp.quantity,
                      'price': cp.price,
                    },
                  )
                  .toList(),
        }),
      );

      if (response.statusCode >= 400) {
        throw Exception('Failed to place order: ${response.body}');
      }

      final decoded = json.decode(response.body);
      final orderId = decoded['name'] as String?;

      if (orderId == null) {
        throw Exception('Order was not saved correctly');
      }

      final newOrder = OrderItems(
        orderId,
        total,
        timestamp,
        cartProducts,
        address,
      );
      _orders.insert(0, newOrder);
      notifyListeners();
      return newOrder;
    } catch (error) {
      debugPrint(error.toString());
      rethrow;
    }
  }
}
