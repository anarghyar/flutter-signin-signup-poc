import 'package:flutter/material.dart';
import 'package:built_value/json_object.dart';
import 'package:ory_client/ory_client.dart';
import 'package:dio/dio.dart';
import 'package:one_of/src/oneOf/one_of_base.dart';
import 'package:dio/browser.dart';


class SignInScreen extends StatelessWidget {
  String flowid;
  JsonObject csrfToken;

  SignInScreen({super.key, required this.flowid, required this.csrfToken});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: Center(
        child: SizedBox(
          width: 400,
          child: Card(
            child: SignInForm(flowid: flowid, csrfToken: csrfToken,),
          ),
        ),
      ),
    );
  }
}

class SignInForm extends StatefulWidget {
  const SignInForm({super.key, required this.flowid, required this.csrfToken});

  final String flowid;
  final JsonObject csrfToken;

  @override
  State<SignInForm> createState() => _SignInFormState();
}

class _SignInFormState extends State<SignInForm> {
  final _idTextController = TextEditingController();
  final _passwordTextController = TextEditingController();

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

  void _submitSignInPage() async {

    final p_bd = UpdateLoginFlowWithPasswordMethod((builder) {
      builder
        ..method = 'password'
        ..password = _passwordTextController.text
        ..identifier = _idTextController.text
        ..csrfToken = widget.csrfToken.asString;
    });

    final bd = UpdateLoginFlowBody((builder) {
      builder
        .oneOf = OneOf.fromValue1(value: p_bd);
    });

    final api = OryClient(dio: DioForBrowser(options)).getFrontendApi();
    final response = await api.updateLoginFlow(flow: widget.flowid, updateLoginFlowBody: bd);
    Navigator.of(context).pushNamed('/welcome');
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Sign in', style: Theme.of(context).textTheme.headlineMedium),
          Padding(
            padding: const EdgeInsets.all(8),
            child: TextFormField(
              controller: _idTextController,
              decoration: const InputDecoration(hintText: 'Any ID'),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: TextFormField(
              controller: _passwordTextController,
              decoration: const InputDecoration(hintText: 'Password'),
            ),
          ),
          TextButton(
            style: ButtonStyle(
              foregroundColor: MaterialStateProperty.resolveWith((states) {
                return states.contains(MaterialState.disabled)
                    ? null
                    : Colors.white;
              }),
              backgroundColor: MaterialStateProperty.resolveWith((states) {
                return states.contains(MaterialState.disabled)
                    ? null
                    : Colors.blue;
              }),
            ),
            onPressed: _submitSignInPage,
            child: const Text('Sign in'),
          ),
        ],
      ),
    );
  }
}
