import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'package:my_shop_app/models/loading_spinner.dart';
import 'package:my_shop_app/providers/cart.dart';
import 'package:my_shop_app/providers/orders.dart';
import 'package:my_shop_app/widgets/cart_list_item.dart';



class CartScreen extends StatelessWidget {
  static const routeName = '/cart-screen';

  void showSnackAndPop(String message, BuildContext context)
  {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      duration: Duration(seconds: 2),
    ));
    Navigator.of(context).pop();
    Navigator.of(context).pop();
  }

  void placeOrderBtn(Cart cart, BuildContext context){

      Provider.of<Orders>(context,listen: false).placeNewOrder(cart.cartItems.values.toList(), cart.totalAmount)
      .then((_){
        cart.clearCart();
        showSnackAndPop('Order Placed Successfully', context);
      })
      .catchError((_){  showSnackAndPop('Failed To Place The Order', context);  });

     LoadingSpinner(context);
  }


  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<Cart>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cart'),
      ),
      body: Column(
        children: [
          Card(
            margin: const EdgeInsets.all(10),
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Total Price: ',style: TextStyle(fontSize: 18),),
                      Chip(
                        label: Text('${cart.totalAmount.toStringAsFixed(2)} EPG',style: TextStyle(fontSize: 16,color: Colors.white),),
                        elevation: 2,
                        backgroundColor: Theme.of(context).primaryColor,
                      ),
                    ],
                  ),
                  SizedBox(height: 15,),
                  ElevatedButton(
                    style: ButtonStyle(
                      padding: MaterialStateProperty.all(const EdgeInsets.all(12)),
                    ),
                    child: Container(width: double.infinity, alignment:Alignment.center,child: Text('Place Order',style: TextStyle(fontSize: 18),)),
                    onPressed: cart.totalAmount > 0? ()=> placeOrderBtn(cart, context) : null
                  ),
                  SizedBox(height: 15,),
                ],
              )
            ),
          ),
          Expanded(child: ListView.builder(
            itemCount: cart.cartItems.length,
            itemBuilder: (_,index)=> CartListItem(cart.cartItems.values.toList()[index],cart.cartItems.keys.toList()[index]),
          ))
        ],
      ),
    );
  }
}
