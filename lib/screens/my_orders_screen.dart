import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:my_shop_app/providers/orders.dart';
import 'package:my_shop_app/widgets/my_app_drawer.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class MyOrdersScreen extends StatefulWidget {
  static const routeName = '/order-screen';

  @override
  _MyOrdersScreenState createState() => _MyOrdersScreenState();
}

class _MyOrdersScreenState extends State<MyOrdersScreen> {
  bool isInit = true;
  Orders orders;

  @override
  void didChangeDependencies() {
    /// the if condition because didChangeDependencies may be called multiple times.
    if(isInit)
    {
      orders = Provider.of<Orders>(context);
      isInit = false;
    }
    super.didChangeDependencies();
  }


  @override
  void dispose() {
    orders.orders.forEach((element){ element.isExpanded = false; });
    super.dispose();
  }

  Future<void> _refreshUserOrders(BuildContext context) async
  {
    await orders.fetchAndSetOrders()
    .catchError((error){
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Couldn\'t refresh.' ),
        duration: Duration(seconds: 2),
      ));
    });
  }

  Widget productsSummaryOrLIst(bool isExpanded,int index){
    return isExpanded ? Expanded(
      child: Container(
        height: 250,
        child: ListView.builder(
            itemCount: orders.orders[index].products.length,
            itemBuilder: (_,i){
              return Card(
                child: ListTile(
                  title: Text(orders.orders[index].products[i].title),
                  subtitle: Text('${(orders.orders[index].products[i].price * orders.orders[index].products[i].quantity).toStringAsFixed(2)} EPG'),
                  trailing: Text('x${orders.orders[index].products[i].quantity}'),
                ),
              );
            }
        ),
      ),
    )
        :
    Expanded(
      child: Text(
          '${orders.orders[index].products.map((e) => '${e.quantity}x ${e.title.toString()}')}'),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ordering'),
      ),
      drawer: MyAppDrawer(),
      body: RefreshIndicator(
        onRefresh: ()=> _refreshUserOrders(context),
        color: Colors.white,
        backgroundColor: Colors.teal,
        displacement: 20,
        child: orders.orders.isEmpty
          ? Center(child: Text('No Orders',style: TextStyle(fontSize: 30, letterSpacing: 2),),)
          : ListView.builder(
              itemCount: orders.orders.length,
              itemBuilder: (_,index){
                return Card(
                  margin: EdgeInsets.symmetric(vertical: 10,horizontal: 10),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: ListTile(
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              'Order Of :  ${DateFormat.yMMMd().format(orders.orders[index].dateTime)}',
                              style: TextStyle(fontSize: 18),
                            ),
                          ),
                          Text(
                              '${(orders.orders[index].amount).toStringAsFixed(2)} EPG',
                              style: TextStyle(fontSize: 17.5,color: Colors.grey[700])
                          ),
                        ],
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top:10),
                        child:  Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            productsSummaryOrLIst(orders.orders[index].isExpanded,index),
                            IconButton(
                              icon: orders.orders[index].isExpanded? Icon(Icons.keyboard_arrow_up_rounded) :Icon(Icons.keyboard_arrow_down_rounded),
                              alignment: Alignment.bottomCenter,
                              onPressed: (){setState(() {
                                orders.orders[index].isExpanded = !orders.orders[index].isExpanded;
                              });},
                            ),
                          ],),
                      ),
                    ),
                  ),
                );
              },
          ),
      ),
    );
  }
}
