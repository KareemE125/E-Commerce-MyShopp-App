import 'package:flutter/material.dart';
import 'package:my_shop_app/providers/cart.dart';
import 'package:my_shop_app/providers/orders.dart';
import 'package:my_shop_app/providers/products.dart';
import 'package:my_shop_app/screens/cart_screen.dart';
import 'package:my_shop_app/widgets/badge.dart';
import 'package:my_shop_app/widgets/my_app_drawer.dart';
import 'package:my_shop_app/widgets/products_grid.dart';
import 'package:provider/provider.dart';


enum menuSelectionOptions{
  All,
  Favorites,
}

class ProductsOverviewScreen extends StatefulWidget {
  @override
  _ProductsOverviewScreenState createState() => _ProductsOverviewScreenState();
}

class _ProductsOverviewScreenState extends State<ProductsOverviewScreen> {
  bool _showFavoritesOnly = false;

  @override
  void initState() {
    /// "listen" is set to false to be able to run the function in initState()
    /// as we have ".of(context)" which throws an error
    /// because when using "context" in initState() it throws an error
    //Provider.of<Products>(context,listen: false).fetchAndSetProducts();
    print('init');
    Provider.of<Orders>(context,listen: false).fetchAndSetOrders();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('MyShop'),
        actions: [
          Consumer<Cart>(
            builder: (_,cart,consumerChild) => Badge(
              child: consumerChild,
              value: cart.cartItems.length.toString()
            ),
            child: IconButton(
              icon: Icon(Icons.shopping_cart),
              onPressed: (){
                Navigator.of(context).pushNamed(CartScreen.routeName);
              },
            ),
          ),
          PopupMenuButton(
            child: Icon(Icons.more_vert),
            itemBuilder: (_)=>[
              PopupMenuItem(child: Text('Show All'),value: menuSelectionOptions.All,),
              PopupMenuItem(child: Text('Show Favorites'),value: menuSelectionOptions.Favorites,),
            ],
            onSelected: (menuSelectionOptions option){
              setState(() {
                if(option == menuSelectionOptions.Favorites){ _showFavoritesOnly = true; }
                else{ _showFavoritesOnly = false; }
              });
            },
          ),
        ],
      ),
      drawer: MyAppDrawer(),
      body:FutureBuilder(
            future: Provider.of<Products>(context,listen: false).fetchAndSetProducts(),
            builder: (ctx,snapShot){
              return snapShot.connectionState == ConnectionState.waiting
                     ? Center(child: CircularProgressIndicator())
                     : ProductsGrid(_showFavoritesOnly);
            },
      ),
    );
  }
}
