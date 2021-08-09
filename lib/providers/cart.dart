import 'package:flutter/material.dart';

class CartItem{
  String id;
  String title;
  int quantity;
  double price;

  CartItem({@required this.id, @required this.title, @required this.quantity, @required this.price});
}



class Cart with ChangeNotifier{

  Map<String,CartItem> _cartItems = {};

  Map<String,CartItem> get cartItems => {..._cartItems};


  void addCartItem(String productId, String title, double price){
    if(_cartItems.containsKey(productId)){
      _cartItems[productId].quantity++;
    }
    else{
      _cartItems[productId] = CartItem(id: DateTime.now().toString(), title: title, quantity: 1, price: price);
    }
    notifyListeners();
  }

  void removeCartItem(String productId){
    _cartItems.remove(productId);
    notifyListeners();
  }

  void undoItemAddition(String productId){
    if(_cartItems[productId].quantity>1)
    {
      _cartItems[productId].quantity--;
    }
    else
    {
      _cartItems.remove(productId);
    }
    notifyListeners();
  }

  void clearCart(){
    _cartItems.clear();
    notifyListeners();
  }

  double get totalAmount{
    double sum=0;
    _cartItems.forEach((key, value) { sum = sum + (value.quantity * value.price); });
    return sum;
  }

}