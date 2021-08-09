import 'dart:async';
import 'dart:convert';
import 'dart:core';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:my_shop_app/models/http_exception.dart';
import 'package:my_shop_app/providers/product.dart';


class Products with ChangeNotifier{

  final String token;
  final String userId;
  List _items = [];

  Products({this.token, this.userId});


  List get items => [..._items];

  List get favoriteItems => _items.where((element) => (element as Product).isFavorite ==true ).toList();

  Future<void> fetchAndSetProducts([bool filterByCreatorId = false]) async
  {
    Uri url;
    filterByCreatorId == true
    ? url = Uri.parse('https://shop-app-cfd99-default-rtdb.firebaseio.com/products.json?auth=$token&orderBy="creatorId"&equalTo="$userId"')
    : url = Uri.parse('https://shop-app-cfd99-default-rtdb.firebaseio.com/products.json?auth=$token');

    final http.Response response = await http.get(url);
    final Map<String,dynamic> fetchedProducts = jsonDecode(response.body) as Map<String,dynamic>;

    url = Uri.parse('https://shop-app-cfd99-default-rtdb.firebaseio.com/userFavorites/$userId.json?auth=$token');
    final http.Response favoritesResponse = await http.get(url);
    final Map<String,dynamic> favoriteProducts = jsonDecode(favoritesResponse.body) as Map<String,dynamic>;

    _items.clear();
    if(fetchedProducts == null){ notifyListeners(); return; }
    fetchedProducts.forEach((productId, productData) => _items.add(Product(
      id: productId,
      title: productData['title'],
      price: productData['price'],
      description: productData['description'],
      imageUrl: productData['imageUrl'],
      isFavorite: favoriteProducts == null ? false : favoriteProducts[productId] ?? false,
    )));

    notifyListeners();
  }

  Future<void> addProduct(Product product) async
  {
    final Uri url = Uri.parse('https://shop-app-cfd99-default-rtdb.firebaseio.com/products.json?auth=$token');
    final response = await http.post(url, body: json.encode({
      'title': product.title,
      'price': product.price,
      'description': product.description,
      'imageUrl': product.imageUrl,
      'creatorId' : userId
    }));

    _items.add(Product(
      id: json.decode(response.body)['name'],
      title: product.title,
      price: product.price,
      description: product.description,
      imageUrl: product.imageUrl,
    ));

    notifyListeners();
  }

  /// We Added this if condition in "editProduct(...)" & "removeProduct(...)" functions,
  /// ---------------------------------------------------------------------------------------------
  ///    if(response.statusCode >= 400){  throw HttpException('Failed to edit the product');  }
  /// ---------------------------------------------------------------------------------------------
  /// because unfortunately "delete" & "patch"  does NOT throw an error
  /// if we get a response error status code back from the server.
  /// error status code is >= 400.

  Future<void> editProduct(String id, Product modifiedProduct) async
  {
    final Uri url = Uri.parse('https://shop-app-cfd99-default-rtdb.firebaseio.com/products/$id.json?auth=$token');
    final response = await http.patch(url,body: jsonEncode({
      'title': modifiedProduct.title,
      'price': modifiedProduct.price,
      'description': modifiedProduct.description,
      'imageUrl': modifiedProduct.imageUrl,
    }));

    if(response.statusCode >= 400){  throw HttpException('Failed to edit the product');  }

    _items[_items.indexWhere((element) => element.id == id)] = modifiedProduct;
    notifyListeners();
  }

  Future<void> toggleFavoriteForProduct(String id, Product product) async
  {
    product.isFavorite = !product.isFavorite;
    notifyListeners();

    try
    {
      final Uri url = Uri.parse('https://shop-app-cfd99-default-rtdb.firebaseio.com/userFavorites/$userId/$id.json?auth=$token');
      final response = await http.put( url,body: jsonEncode(product.isFavorite) );
      if (response.statusCode >= 400) { throw HttpException('Failed to add to favorites'); }
    }
    catch(error)
    {
      product.isFavorite = !product.isFavorite;
      notifyListeners();
      throw error;
    }

  }

  Future<void> removeProduct(String id) async
  {
    final Uri url = Uri.parse('https://shop-app-cfd99-default-rtdb.firebaseio.com/products/$id.json?auth=$token');
    final response = await http.delete(url);

    if(response.statusCode >= 400){  throw HttpException('Failed to delete the product');  }

    _items.removeWhere((element) => element.id == id);
    notifyListeners();
  }

}

/*
  Product(
      id: 'p1',
      title: 'Red Shirt',
      description: 'A red shirt - it is pretty red!',
      price: 29.99,
      imageUrl:
      'https://cdn.pixabay.com/photo/2016/10/02/22/17/red-t-shirt-1710578_1280.jpg',
    ),
    Product(
      id: 'p2',
      title: 'Trousers',
      description: 'A nice pair of trousers.',
      price: 59.99,
      imageUrl:
      'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e8/Trousers%2C_dress_%28AM_1960.022-8%29.jpg/512px-Trousers%2C_dress_%28AM_1960.022-8%29.jpg',
    ),
    Product(
      id: 'p3',
      title: 'Yellow Scarf',
      description: 'Warm and cozy - exactly what you need for the winter.',
      price: 19.99,
      imageUrl:
      'https://live.staticflickr.com/4043/4438260868_cc79b3369d_z.jpg',
    ),
    Product(
      id: 'p4',
      title: 'A Pan',
      description: 'Prepare any meal you want.',
      price: 49.99,
      imageUrl:
      'https://upload.wikimedia.org/wikipedia/commons/thumb/1/14/Cast-Iron-Pan.jpg/1024px-Cast-Iron-Pan.jpg',
    ),
*/