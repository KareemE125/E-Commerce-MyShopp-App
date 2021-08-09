import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:my_shop_app/main.dart';
import 'package:my_shop_app/screens/my_orders_screen.dart';
import 'package:my_shop_app/screens/products_overview_screen.dart';
import 'package:my_shop_app/screens/user_products_screen.dart';

class MyAppDrawer extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          AppBar( title: Text('Where To Go!'),),
          Divider(height: 5,thickness: 3,color: Colors.pink[100],),
          ListTile(leading: Icon(Icons.shop_two),title: Text('SHOP'),onTap: (){Navigator.of(context).pushReplacementNamed('/');},),
          Divider(height: 5,thickness: 3,color: Colors.pink[100],),
          ListTile(leading: Icon(Icons.my_library_books_sharp),title: Text('MY ORDERS'),onTap: (){Navigator.of(context).pushReplacementNamed(MyOrdersScreen.routeName);},),
          Divider(height: 5,thickness: 3,color:Colors.pink[100]),
          ListTile(leading: Icon(Icons.edit_outlined),title: Text('MANGE PRODUCTS'),onTap: (){Navigator.of(context).pushReplacementNamed(UserProductsScreen.routeName);},),
          Divider(height: 5,thickness: 3,color:Colors.pink[100]),
          Spacer(),
          Divider(height: 5,thickness: 3,color:Colors.pink[100]),
          ListTile(
            leading: Icon(Icons.logout),
            title: Text('LOGOUT'),
            onTap: (){
              Navigator.of(context).pushAndRemoveUntil( MaterialPageRoute(builder: (_)=>MyApp()), (route) => true);
              FirebaseAuth.instance.signOut();
            },
          ),
          Divider(height: 5,thickness: 3,color:Colors.pink[100]),
          SizedBox(height: 5,)
        ],
      ),
    );
  }
}
