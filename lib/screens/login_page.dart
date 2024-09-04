import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:task1/screens/home_screen.dart';

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

  Future<void> _loginUser(String emailOrPhone, String password) async {
    final url = Uri.parse(
        'https://swan.alisonsnewdemo.online/api/login?email_phone=$emailOrPhone&password=$password');

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.post(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['success'] == 1) {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('token', data['customerdata']['token']);
          await prefs.setString('id', data['customerdata']['id']);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Login Successful')),
          );

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomePage()),
          );
        } else {
          _showErrorSnackbar('Login Failed: ${data['message']}');
        }
      } else {
        _showErrorSnackbar('HTTP Error: ${response.statusCode}');
      }
    } catch (e) {
      _showErrorSnackbar('Error occurred during login');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _login() async {
    final emailPhone = _emailPhoneController.text;
    final password = _passwordController.text;

    if (emailPhone.isEmpty || password.isEmpty) {
      _showErrorSnackbar('Please enter both email/phone and password');
      return;
    }

    await _loginUser(emailPhone, password);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _emailPhoneController,
              decoration: InputDecoration(labelText: 'Email or Phone'),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _login,
              child: _isLoading ? CircularProgressIndicator() : Text('Login'),
            ),
          ],
        ),
      ),
    );
  }
}
