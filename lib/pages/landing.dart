import 'package:flutter/material.dart';
import 'package:test_flutter_application/services/auth.dart';
import 'package:dio/browser.dart';
import 'package:dio/dio.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});
  
  void _logout() {
    final options = BaseOptions(
      baseUrl: "http://localhost:4433",
      connectTimeout: const Duration(seconds: 10000),
      receiveTimeout: const Duration(seconds: 5000),
      headers: {
        "Accept": "application/json",
      },
      validateStatus: (status) {
        // here we prevent the request from throwing an error when the status code is less than 500 (internal server error)
        return status! < 500;
      },
    );
    final dio = DioForBrowser(options);

    final auth = AuthService(dio);
    auth.logout();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: Center(
        child: SizedBox(
          width: 400,
          child: Column(
            children: [
              const Card(
                child: Text('Welcome!'),
              ),
              TextButton(
                onPressed: _logout,
                child: const Text('Logout'))
            ]
          )
        ),
      ),
    );
  }
}