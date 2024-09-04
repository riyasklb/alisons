import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:task1/models/get_product_mode.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<Getproduct> _productData;

  @override
  void initState() {
    super.initState();
    _productData = _fetchProductData();
  }

  Future<Getproduct> _fetchProductData() async {
    
      print('----------1----------');
  SharedPreferences prefs = await SharedPreferences.getInstance();
  print('----------2----------');
  String? token = prefs.getString('token');
 print('----------3----------');

  if (token == null ) {
    print('----------3----------');
    throw Exception('Token or ID not found');
  }
print('----------4----------');
  final url = Uri.parse('https://swan.alisonsnewdemo.online/api/home?id=bDy&token=$token');
print('----------5----------');
  final response = await http.post(url);
print('----------6----------');
  if (response.statusCode == 200) {
      print('${response.statusCode}-----------7---------');
    return Getproduct.fromJson(json.decode(response.body));
  } else {
    throw Exception('Failed to load product data');
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home Page'),
      ),
      body: FutureBuilder<Getproduct>(
        future: _productData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            return _buildProductList(snapshot.data!);
          } else {
            return Center(child: Text('No data found'));
          }
        },
      ),
    );
  }

  Widget _buildProductList(Getproduct data) {
    return ListView.builder(
      itemCount: data.ourProducts.length,
      itemBuilder: (context, index) {
        var product = data.ourProducts[index];
      //  https://swan.alisonsnewdemo.online/images/product/1696583677A53FAWzwjfJ0WhmpRtWP7T4znCiZENZf0b5JQUXw.webp
      // https://swan.alisonsnewdemo.online/images/category/1695626477.jpg
    //  https://swan.alisonsnewdemo.online/images/banner/1695716382_1_sH4k9mEPpOeGBInBvUUc9G2X3tXUhPE41ZH3Vp5B.webp
        return ListTile(
          leading:CircleAvatar(backgroundImage: NetworkImage('https://swan.alisonsnewdemo.online/images/product/${product.image}'),),
          title: Text(product.name),
          subtitle: Text('Price: ${product.price}'),
        );
      },
    );
  }
}
