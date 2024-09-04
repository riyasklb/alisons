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
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token == null) {
      throw Exception('Token not found');
    }

    final url = Uri.parse('https://swan.alisonsnewdemo.online/api/home?id=bDy&token=$token');
    final response = await http.post(url);

    if (response.statusCode == 200) {
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
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, // Number of items per row
        crossAxisSpacing: 10.0, // Horizontal spacing between items
        mainAxisSpacing: 10.0,  // Vertical spacing between items
        childAspectRatio: 0.75,  // Adjust the ratio as needed
      ),
      itemCount: data.ourProducts.length,
      itemBuilder: (context, index) {
        var product = data.ourProducts[index];
        return Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage('https://swan.alisonsnewdemo.online/images/product/${product.image}'),
                      fit: BoxFit.cover,
                    ),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  product.name,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Text(
                  'Price: ${product.price}',
                  style: TextStyle(
                    color: Colors.grey[600],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

}
