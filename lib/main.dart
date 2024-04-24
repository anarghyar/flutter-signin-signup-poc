import 'package:flutter/material.dart';
import 'package:test_flutter_application/pages/landing.dart';
import 'package:test_flutter_application/pages/signin.dart';
import 'package:test_flutter_application/pages/signup.dart';
import 'package:ory_client/ory_client.dart';
import 'package:dio/browser.dart';
import 'package:dio/dio.dart';
import 'package:universal_html/html.dart';
import 'package:built_value/json_object.dart';

void main() => runApp(MaterialApp(
  // home: MainScreen(),
  // initialRoute: "",
  routes: {
    '/': (context) => const MainScreen(),
    '/signin': (context) => const SignInScreen(),
    '/signup': (context) => SignUpScreen(flowid: "", csrf_token: JsonObject({}),),
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

  // final dio = DioForBrowser(options);

  void _showSignUpPage() async {
    final api = OryClient(dio: DioForBrowser(options)).getFrontendApi();
    final response = await api.createBrowserRegistrationFlow();
    String flowid = response.data!.id;
    JsonObject? csrf_token = (response.data?.ui.nodes.first.attributes.oneOf.value as UiNodeInputAttributes).value;
    // print(response.redirects);
    Navigator.push(context,
    MaterialPageRoute(
      builder: (context) => SignUpScreen(flowid: flowid, csrf_token: csrf_token!,)
      // builder: (context) => const SignUpScreen()
    ));
    // Navigator.of(context).pushNamed('/signup');  // NOTE: Can use 'return_to' in reg. function to redirect; also use ui container to render the signup form; pass response data to signup page
  }
  void _showSignInPage() {
    Navigator.of(context).pushNamed('/signin');
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