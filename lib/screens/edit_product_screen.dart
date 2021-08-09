import 'package:flutter/material.dart';
import 'package:my_shop_app/models/loading_spinner.dart';
import 'package:my_shop_app/providers/product.dart';
import 'package:my_shop_app/providers/products.dart';
import 'package:provider/provider.dart';

class EditProductScreen extends StatefulWidget {
  static const routeName = '/edit-product';

  @override
  _EditProductScreenState createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final FocusNode _priceFocusNode = FocusNode();
  final FocusNode _descriptionFocusNode = FocusNode();
  final FocusNode _imageUrlFocusNode = FocusNode();
  final TextEditingController _imageUrlController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  Map productAssign = {
    'title': '',
    'price': '',
    'description': '',
    'imageUrl': '',
  };
  Product product = Product(id:null, title:null ,price:null ,description:null ,imageUrl:null );
  bool _isInit = true;
  String btnText = 'Add';

  void doubleScreenPopAndMessage(String message){
    Navigator.of(context).pop();
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      duration: Duration(seconds: 2),
    ));
  }

  void _saveForm(){
    if( !_formKey.currentState.validate() ){ return; }

    _formKey.currentState.save();

    if(product.id == null)
    {
      product = Product(
          id: DateTime.now().toString(),
          title: productAssign['title'],
          description: productAssign['description'],
          price: double.parse(productAssign['price']),
          imageUrl: productAssign['imageUrl'] );

      Provider.of<Products>(context, listen: false).addProduct(product)
      .then((_){ doubleScreenPopAndMessage('New product is added'); })
      .catchError((error){  doubleScreenPopAndMessage('Failed to add new product');  });

      LoadingSpinner(context);

    }
    else
    {
      Provider.of<Products>(context, listen: false).editProduct(
          product.id,
          Product(
          id: product.id,
          title: productAssign['title'],
          description: productAssign['description'],
          price: double.parse(productAssign['price']),
          imageUrl: productAssign['imageUrl'] ,
          isFavorite: product.isFavorite )
      )
      .then((_){ doubleScreenPopAndMessage('saved successfully'); })
      .catchError((error){  doubleScreenPopAndMessage('Failed to edit');  });


      LoadingSpinner(context);

    }
  }

  @override
  void initState() {
    _imageUrlFocusNode.addListener((){ if(!_imageUrlFocusNode.hasFocus){ setState((){}); } });
    super.initState();
  }

  @override
  void didChangeDependencies() {
    if(_isInit)
    {
      String productId = ModalRoute.of(context).settings.arguments as String;
      if(productId != null)
      {
        product = Provider.of<Products>(context).items.firstWhere((element) => element.id == productId);

        productAssign['title'] = product.title;
        productAssign['description'] = product.description;
        productAssign['price'] = product.price.toString();
        _imageUrlController.text = productAssign['imageUrl'] = product.imageUrl;

        btnText = 'Save';
      }
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _imageUrlFocusNode.removeListener((){ if(!_imageUrlFocusNode.hasFocus){ setState((){}); } });
    _priceFocusNode.dispose();
    _descriptionFocusNode.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Product'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children:[
              TextFormField(
                initialValue: productAssign['title'],
                decoration: InputDecoration(labelText: 'Title'),
                textInputAction: TextInputAction.next,
                onFieldSubmitted: (_){ FocusScope.of(context).requestFocus(_priceFocusNode); },
                onSaved: (val){ productAssign['title'] = val; },
                validator: (val)
                {
                  if(val.isEmpty){ return 'Please enter a title'; }
                  return null;
                },
              ),
              SizedBox(height: 10,),
              TextFormField(
                initialValue: productAssign['price'],
                decoration: InputDecoration(labelText: 'Price'),
                textInputAction: TextInputAction.next,
                keyboardType: TextInputType.number,
                focusNode: _priceFocusNode,
                onFieldSubmitted: (_){ FocusScope.of(context).requestFocus(_descriptionFocusNode); },
                onSaved: (val){ productAssign['price'] = val; },
                validator: (val){
                  if(val.isEmpty || double.tryParse(val) == null || double.parse(val) <=0 )
                  {
                    return 'Please enter a valid price';
                  }
                  return null;
                },
              ),
              SizedBox(height: 10,),
              TextFormField(
                initialValue: productAssign['description'],
                decoration: InputDecoration(labelText: 'Description'),
                maxLines: 3,
                keyboardType: TextInputType.multiline,
                focusNode: _descriptionFocusNode,
                onSaved: (val){ productAssign['description'] = val; },
                validator: (val){
                  if(val.isEmpty){ return 'Please enter a description'; }
                  return null;
                },
              ),
              SizedBox(height: 10,),
              Row(
                children:[
                  Container(
                    width: 100,
                    height: 100,
                    margin: const EdgeInsets.only(top: 8, right: 10,),
                    padding:const EdgeInsets.all(5),
                    decoration: BoxDecoration( border: Border.all(width: 1, color: Colors.grey,), ),
                    child: _imageUrlController.text.isEmpty ?
                    Text('Enter a URL')
                        :
                    FittedBox(
                      child: Image.network(
                        _imageUrlController.text,
                        fit: BoxFit.cover,
                        errorBuilder:  (context,o,s) {
                          return Text('Failed');
                        }
                      ),
                    ),
                  ),
                  Expanded(
                    child: TextFormField(
                      //initialValue: productAssign['imageUrl'],
                      decoration: InputDecoration(labelText: 'Image URL'),
                      keyboardType: TextInputType.url,
                      textInputAction: TextInputAction.done,
                      controller: _imageUrlController,
                      focusNode: _imageUrlFocusNode,
                      onSaved: (val){ productAssign['imageUrl'] = val; },
                      validator: (val){
                        if(val.isEmpty){ return 'Please enter an URL'; }

                        var urlPattern = r"(https?|http)://([-A-Z0-9.]+)(/[-A-Z0-9+&@#/%=~_|!:,.;]*)?(\?[A-Z0-9+&@#/%=~_|!:‌​,.;]*)?";
                        var match = new RegExp(urlPattern, caseSensitive: false).firstMatch(val);
                        if( match == null )
                        {
                          return 'Please enter a valid URL';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: 30,),
              ElevatedButton(
                child: Text(btnText,style: TextStyle(fontSize: 18),),
                style: ButtonStyle(
                  padding: MaterialStateProperty.all(const EdgeInsets.all(8))
                ),
                onPressed: _saveForm,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
