import 'package:flutter/material.dart';
import 'package:my_shop_app/providers/cart.dart';
import 'package:provider/provider.dart';

class CartListItem extends StatelessWidget {

  final CartItem cartItem;
  final String productId;
  CartListItem(this.cartItem,this.productId);

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(cartItem.id),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: EdgeInsets.symmetric(vertical: 6,horizontal: 10),
        padding: EdgeInsets.only(right: 15),
        color: Colors.red,
        alignment: Alignment.centerRight,
        child: Icon(Icons.delete,color: Colors.white,size: 35,),
      ),
      child: Card(
        margin: EdgeInsets.symmetric(vertical: 5,horizontal: 10),
        child: ListTile(
          title: Text(cartItem.title),
          subtitle: Text('${(cartItem.price * cartItem.quantity).toStringAsFixed(2)} EPG'),
          trailing: Text('x${cartItem.quantity}'),
        ),
      ),
      onDismissed: (direction){ Provider.of<Cart>(context,listen: false).removeCartItem(productId); },
    );
  }

}