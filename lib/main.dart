import 'package:flutter/material.dart';
import 'package:test_flutter_application/pages/landing.dart';
import 'package:test_flutter_application/pages/signin.dart';
import 'package:test_flutter_application/pages/signup.dart';
import 'package:ory_client/ory_client.dart';
import 'package:dio/browser.dart';
import 'package:dio/dio.dart';
import 'package:built_value/json_object.dart';

void main() => runApp(MaterialApp(
  routes: {
    '/': (context) => const MainScreen(),
    '/signin': (context) => SignInScreen(flowid: "", csrfToken: JsonObject({}),),
    '/signup': (context) => SignUpScreen(flowid: "", csrfToken: JsonObject({}),),
    '/welcome': (context) => const LandingScreen()
  }
));

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {

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

  void _showSignUpPage() async {
    final api = OryClient(dio: DioForBrowser(options)).getFrontendApi();
    final response = await api.createBrowserRegistrationFlow();
    String flowid = response.data!.id;
    JsonObject? csrfToken = (response.data?.ui.nodes.first.attributes.oneOf.value as UiNodeInputAttributes).value;
    Navigator.push(context,
    MaterialPageRoute(
      builder: (context) => SignUpScreen(flowid: flowid, csrfToken: csrfToken!,)
    ));
  }

  void _showSignInPage() async {
    final api = OryClient(dio: DioForBrowser(options)).getFrontendApi();
    final response = await api.createBrowserLoginFlow();
    
    String flowid = response.data!.id;
    JsonObject? csrfToken = (response.data?.ui.nodes.first.attributes.oneOf.value as UiNodeInputAttributes).value;
    Navigator.push(context,
    MaterialPageRoute(
      builder: (context) => SignInScreen(flowid: flowid, csrfToken: csrfToken!,)
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: Center(
        child: SizedBox(
          width: 400,
          child: Card(
            child: Column(
              children: <Widget> [
                TextButton(
                  onPressed: _showSignInPage,
                  child: const Text('Sign in')
                ),
                TextButton(
                  onPressed: _showSignUpPage,
                  child: const Text('Sign up'),
                ),
              ],
            )
          ),
        ),
      ),
    );
  }
}