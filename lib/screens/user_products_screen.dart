import 'package:flutter/material.dart';
import 'package:my_shop_app/models/loading_spinner.dart';
import 'package:my_shop_app/providers/products.dart';
import 'package:my_shop_app/screens/edit_product_screen.dart';
import 'package:my_shop_app/widgets/my_app_drawer.dart';
import 'package:provider/provider.dart';


class UserProductsScreen extends StatelessWidget {
  static const routeName = '/user-products';

  Future<void> _refreshUserProducts(BuildContext context) async
  {
    await Provider.of<Products>(context, listen: false).fetchAndSetProducts(true)
    .catchError((error){
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Couldn\'t refresh.' ),
        duration: Duration(seconds: 2),
      ));
    });
  }

  void deleteBtnClick(var productsData, BuildContext context, int i){
    productsData.removeProduct(productsData.items[i].id)
    .then((_){
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Product is deleted successfully'),
        duration: Duration(seconds: 2),
      ));
      Navigator.of(context).pop();
    })
    .catchError((error){
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to delete'),
        duration: Duration(seconds: 2),
      ));
      Navigator.of(context).pop();
    });
    LoadingSpinner(context);
  }

  @override
  Widget build(BuildContext context) {

    print('hi');
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Products'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: (){ Navigator.of(context).pushNamed(EditProductScreen.routeName); },
          ),
        ],
      ),
      drawer: MyAppDrawer(),
      body: RefreshIndicator(
        onRefresh: ()=> _refreshUserProducts(context),
        color: Colors.white,
        backgroundColor: Colors.teal,
        displacement: 20,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: FutureBuilder(
            future: _refreshUserProducts(context),
            builder: (ctx,snapShot){
              return snapShot.connectionState == ConnectionState.waiting
              ? Center(child: CircularProgressIndicator())
              : Consumer<Products>(
                  builder: (context, productsData, child) => ListView.builder(
                    itemCount: productsData.items.length,
                    itemBuilder: (_, i) => Column(
                      children: [
                        ListTile(
                          title: Text(productsData.items[i].title),
                          leading: CircleAvatar(
                            backgroundImage: NetworkImage(productsData.items[i].imageUrl),
                            onBackgroundImageError:(o,s) {return;},
                          ),
                          trailing: FittedBox(
                            child: Row(
                              children: <Widget>[
                                IconButton(
                                  icon: Icon(Icons.edit),
                                  onPressed: () {
                                    Navigator.of(context).pushNamed(EditProductScreen.routeName,arguments: productsData.items[i].id);
                                  },
                                  color: Theme.of(context).primaryColor,
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete),
                                  onPressed: ()=> deleteBtnClick(productsData, context, i),
                                  color: Theme.of(context).errorColor,
                                ),
                              ],
                            ),
                          ),
                        ),
                        Divider(),
                      ],
                    ),
                  ),
                );
            },
          )
        ),
      ),
    );
  }
}
