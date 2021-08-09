import 'package:flutter/material.dart';
import 'package:my_shop_app/providers/cart.dart';
import 'package:my_shop_app/providers/product.dart';
import 'package:my_shop_app/providers/products.dart';
import 'package:provider/provider.dart';

class ProductDetailScreen extends StatelessWidget {

  static const routeName = '/product-detail';

  @override
  Widget build(BuildContext context) {

    final productId = ModalRoute.of(context).settings.arguments as String; // is the id!
    final Product loadedProduct = Provider.of<Products>(context,listen: false).items.firstWhere((element) => element.id == productId );

    return Scaffold(
      appBar: AppBar(
        title: Text( loadedProduct.title ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.add_shopping_cart,
            ),
            onPressed: () {
              Provider.of<Cart>(context,listen: false).addCartItem(loadedProduct.id, loadedProduct.title, loadedProduct.price);
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text('item added to the cart'),
                duration: Duration(seconds: 2),
                action: SnackBarAction(
                  label: 'undo',
                  textColor: Colors.pinkAccent,
                  onPressed: (){ Provider.of<Cart>(context,listen: false).undoItemAddition(loadedProduct.id); },
                ),
              ));
            },
            color: Theme.of(context).accentColor,
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true,
            snap: false,
            pinned: false,
            automaticallyImplyLeading: false,
            forceElevated: true,
            elevation: 0,
            expandedHeight: 300,
            backgroundColor: Colors.white60,
            flexibleSpace: FlexibleSpaceBar(
              background:Container(
                  alignment: Alignment.center,
                  child: Image.network(loadedProduct.imageUrl,fit: BoxFit.cover,)
              ),
            ),
          ),
          SliverFillRemaining(
                hasScrollBody: true,
                child: Column(
                  children: [
                    Container(
                      alignment: Alignment.center,
                        child: Text('Description',style: TextStyle(color: Colors.white,fontSize: 25,letterSpacing: 1),),
                        height: 50,
                        color: Theme.of(context).primaryColor,
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                      child: Container(
                        color: Colors.white38,
                        alignment: Alignment.topLeft,
                        padding: EdgeInsets.all(15),
                        child: Text(
                          'Title: ${loadedProduct.title} \n\n'
                          'Price: ${loadedProduct.price} EPG\n\n'
                          'Favorites: ${loadedProduct.isFavorite ? 'YES' : 'NO'}\n\n'
                          'description: ${loadedProduct.description}\n'   ,
                          style: TextStyle(color: Colors.black,fontSize: 22),
                        ),
                      ),
                  ),
                    ),
                  ]
                ),
              ),
        ],

      ),
    );
  }
}
