import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:task1/screens/home_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Login and Home Demo',
      home: LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailPhoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailPhoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> loginUser(String emailOrPhone, String password) async {
    final url = Uri.parse(
        'https://swan.alisonsnewdemo.online/api/login?email_phone=$emailOrPhone&password=$password');

    setState(() {
      _isLoading = true; // Show the loader
    });

    try {
      final response = await http.post(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['success'] == 1) {
          // Successful login
          print('${response.statusCode}----------------------------------------');
          print('Login Successful: $data');
          
          // Store the token in SharedPreferences
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('token', data['customerdata']['token']);
          await prefs.setString('id', data['customerdata']['id']);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Login Successful')),
          );

          // Navigate to HomePage
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomePage()),
          );
        } else {
          // Login failed according to the API response
          print('Login Failed: ${data['message']}');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Login Failed: ${data['message']}')),
          );
        }
      } else {
        // HTTP request failed
        print('HTTP Error: ${response.statusCode}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('HTTP Error: ${response.statusCode}')),
        );
      }
    } catch (e) {
      print('Error occurred during login: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error occurred during login')),
      );
    } finally {
      setState(() {
        _isLoading = false; // Hide the loader
      });
    }
  }

  void _login() async {
    final emailPhone = _emailPhoneController.text;
    final password = _passwordController.text;

    if (emailPhone.isEmpty || password.isEmpty) {
      // Show an error message if fields are empty
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter both email/phone and password')),
      );
      return;
    }

    await loginUser(emailPhone, password);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Stack(
          children: [
            Column(
              children: [
                TextField(
                  controller: _emailPhoneController,
                  decoration: InputDecoration(
                    labelText: 'Email or Phone',
                  ),
                ),
                TextField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: 'Password',
                  ),
                  obscureText: true,
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _login,
                  child:_isLoading?CircularProgressIndicator(): Text('Login'),
                ),
              ],
            ),
            // if (_isLoading)
            //   Center(
            //     child: CircularProgressIndicator(),
            //   ),
          ],
        ),
      ),
    );
  }
}
