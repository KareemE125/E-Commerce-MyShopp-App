import 'dart:convert';
import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;

import 'package:my_shop_app/providers/cart.dart';

class OrderItem{
  final String id;
  final double amount;
  final List<CartItem> products;
  final DateTime dateTime;
  bool isExpanded = false;

  OrderItem({@required this.id, @required this.amount,  @required this.products,  @required this.dateTime, this.isExpanded = false});
}

class Orders with ChangeNotifier{
  final String token;
  final String userId;
  List<OrderItem> _orders = [];

  Orders({this.token, this.userId});


  List<OrderItem> get orders => [..._orders];

  Future<void> fetchAndSetOrders() async
  {
    final Uri url = Uri.parse('https://shop-app-cfd99-default-rtdb.firebaseio.com/orders/$userId.json?auth=$token');
    final response = await http.get(url);
    Map<String,dynamic> fetchedOrders = jsonDecode(response.body);

    _orders.clear();
    if(fetchedOrders == null){ notifyListeners(); return; }
    fetchedOrders.forEach((orderId, orderData) => _orders.insert(0,OrderItem(
        id: orderId,
        amount: orderData['amount'],
        products: (orderData['products list'] as List<dynamic>).map((item) => CartItem(
            id: item['id'], title: item['title'], quantity: item['quantity'], price: item['price']
        )).toList(),
        dateTime: DateTime.parse(orderData['dateTime'])
    )));

    notifyListeners();
  }

  Future<void> placeNewOrder(List<CartItem> cartItems, double total) async
  {
    final DateTime dateTimeNow = DateTime.now();

    final Uri url = Uri.parse('https://shop-app-cfd99-default-rtdb.firebaseio.com/orders/$userId.json?auth=$token');
    final response = await http.post(url, body: jsonEncode({
      'products list': cartItems.map((cartItem) => {
         'id': cartItem.id,
         'title': cartItem.title,
         'quantity': cartItem.quantity,
         'price': cartItem.price,
      }).toList(),
      'amount': total,
      'dateTime': dateTimeNow.toIso8601String(),
      'isExpanded' : false
    }));

    _orders.insert(0, OrderItem(
       id: jsonDecode(response.body)['name'],
       amount: total,
       products: cartItems,
       dateTime: dateTimeNow,)
    );
    notifyListeners();
  }

}