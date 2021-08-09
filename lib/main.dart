import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:my_shop_app/providers/cart.dart';
import 'package:my_shop_app/providers/orders.dart';
import 'package:my_shop_app/providers/products.dart';
import 'package:my_shop_app/screens/auth_screen.dart';
import 'package:my_shop_app/screens/cart_screen.dart';
import 'package:my_shop_app/screens/edit_product_screen.dart';
import 'package:my_shop_app/screens/my_orders_screen.dart';
import 'package:my_shop_app/screens/user_products_screen.dart';
import 'package:my_shop_app/screens/products_overview_screen.dart';
import 'package:my_shop_app/screens/product_detail_screen.dart';

void main() async
{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(MyApp());
}

class MyApp extends StatefulWidget
{
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp>
{
  FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  bool isLogged = false;
  String currentUserToken;
  String currentUserId;
  Products products;
  Orders orders;

  @override
  void initState()
  {
    _firebaseAuth.authStateChanges().listen((user) async
    {
      if( user != null )
      {
        await user.getIdToken().then((token){
          setState(() {
            currentUserToken = token;
            currentUserId = user.uid;
            isLogged = true;
          });
        });
        products = Products(token: currentUserToken, userId: currentUserId);
        orders = Orders(token: currentUserToken, userId: currentUserId);
      }
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider( create: (context)=> products ),
        ChangeNotifierProvider( create: (context)=> Cart() ),
        ChangeNotifierProvider( create: (context)=> orders ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'MyShop',
        theme: ThemeData(
          primarySwatch: Colors.teal,
          accentColor: Colors.pink,
          fontFamily: 'Lato',
        ),
        home: isLogged? ProductsOverviewScreen() : AuthScreen(),
        routes: {
          ProductDetailScreen.routeName: (ctx) => ProductDetailScreen(),
          CartScreen.routeName: (ctx) => CartScreen(),
          MyOrdersScreen.routeName: (ctx) => MyOrdersScreen(),
          UserProductsScreen.routeName: (ctx) => UserProductsScreen(),
          EditProductScreen.routeName: (ctx) => EditProductScreen(),
          AuthScreen.routeName: (ctx) => AuthScreen(),
        }
      ),
    );
  }
}