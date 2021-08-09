import 'package:flutter/material.dart';
import 'package:my_shop_app/providers/cart.dart';
import 'package:my_shop_app/providers/product.dart';
import 'package:my_shop_app/providers/products.dart';
import 'package:provider/provider.dart';

import '../screens/product_detail_screen.dart';

class ProductItem extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    final product = Provider.of<Product>(context);
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: GridTile(
        child: GestureDetector(
          onTap: () {
            Navigator.of(context).pushNamed(ProductDetailScreen.routeName, arguments: product.id);
          },
          child: Image.network(
            product.imageUrl,
            fit: BoxFit.cover,
            errorBuilder:  (context,o,s) {
             return Center(child: Text('No Photo'));
           }
          ),
        ),
        footer: GridTileBar(
          backgroundColor: Colors.black87,
          leading: IconButton(
            icon: product.isFavorite? Icon(Icons.favorite):Icon(Icons.favorite_border_outlined),
            color: Theme.of(context).accentColor,
            onPressed:()
            {
              Provider.of<Products>(context, listen: false).toggleFavoriteForProduct(product.id, product)
              .catchError((error)
              {
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: product.isFavorite? Text('Failed to remove from favorites') : Text('Failed to add to favorites'),
                  duration: Duration(seconds: 1), ));
              });
            },
          ),
          title: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                product.title,
                textAlign: TextAlign.center,
              ),
              Text(
                product.price.toString(),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          trailing: IconButton(
            icon: Icon(
              Icons.add_shopping_cart,
            ),
            onPressed: () {
              Provider.of<Cart>(context,listen: false).addCartItem(product.id, product.title, product.price);
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text('item added to the cart'),
                duration: Duration(seconds: 2),
                action: SnackBarAction(
                  label: 'undo',
                  textColor: Colors.pinkAccent,
                  onPressed: (){ Provider.of<Cart>(context,listen: false).undoItemAddition(product.id); },
                ),
              ));
            },
            color: Theme.of(context).accentColor,
          ),
        ),
      ),
    );
  }
}
