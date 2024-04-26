import 'dart:convert';
import 'dart:js_interop';

import 'package:flutter/material.dart';
import 'package:one_of/src/oneOf/one_of_base.dart';
import 'package:ory_client/ory_client.dart';
import 'package:dio/browser.dart';
import 'package:dio/dio.dart';
import 'package:test_flutter_application/org_main.dart';
import 'package:universal_html/html.dart';
import 'package:built_value/json_object.dart';
// import 'one_of_1.dart';

class SignUpScreen extends StatelessWidget {
  String flowid;
  JsonObject csrf_token;
  // var response;
  SignUpScreen({super.key, required this.flowid, required this.csrf_token});
  // const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: Center(
        child: SizedBox(
          width: 400,
          child: Card(
            child: SignUpForm(flowid: flowid, csrf_token: csrf_token,)
            // child: SignUpForm()
          ),
        ),
      ),
    );
  }
}

class SignUpForm extends StatefulWidget {
  const SignUpForm({super.key, required this.flowid, required this.csrf_token});
  // const SignUpForm({super.key});
  // var response;
  final String flowid;
  final JsonObject csrf_token;

  @override
  State<SignUpForm> createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm> {
  final _uaepassEmailTextController = TextEditingController();
  final _prefEmailTextController = TextEditingController();
  final _uaepassPhnoTextController = TextEditingController();
  final _prefPhnoTextController = TextEditingController();
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

  

  void _submitSignUpPage() async {
    print(widget.flowid);

    final jsonobject = JsonObject({
      'UAEPass email': _uaepassEmailTextController.text,
      'Preferred email': _prefEmailTextController.text,
      'UAEPass phone': _uaepassPhnoTextController.text,
      'Preferred phone': _prefPhnoTextController.text
      });

    // final b = UpdateRegistrationFlowBody((builder) {
    //   builder
    //     ..oneOf = 'password' as OneOf?
    //     ..method = 'password'
    //     ..password = _passwordTextController.text
    //     ..traits = jsonobject;
    // });
    
    final p_bd = UpdateRegistrationFlowWithPasswordMethod((builder) {
      builder
        ..method = 'password'
        ..password = _passwordTextController.text
        ..traits = jsonobject
        ..csrfToken = widget.csrf_token.asString;
    });


    final bd = UpdateRegistrationFlowBody((builder) {
      builder
        .oneOf = OneOf.fromValue1(value: p_bd);
    });
   

    // UpdateRegistrationFlowBody b = UpdateRegistrationFlowBodyBuilder().build();
    // final body = {
    //   'traits': {
    //     'email': _emailTextController.text
    //   },
    //   'password': _passwordTextController.text,
    //   'method': 'password',
    //   'provider': 'kratos'
    // };

    final api = OryClient(dio: DioForBrowser(options)).getFrontendApi();
    final response = await api.updateRegistrationFlow(flow: widget.flowid, updateRegistrationFlowBody: bd);
    Navigator.of(context).pushNamed('/welcome');
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Sign up', style: Theme.of(context).textTheme.headlineMedium),
          Padding(
            padding: const EdgeInsets.all(8),
            child: TextFormField(
              controller: _uaepassEmailTextController,
              decoration: const InputDecoration(hintText: 'UAE Pass Email'),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: TextFormField(
              controller: _prefEmailTextController,
              decoration: const InputDecoration(hintText: 'Preferred Email'),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: TextFormField(
              controller: _uaepassPhnoTextController,
              decoration: const InputDecoration(hintText: 'UAE Pass Ph no'),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: TextFormField(
              controller: _prefPhnoTextController,
              decoration: const InputDecoration(hintText: 'Preferred Ph no'),
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
            onPressed: _submitSignUpPage,
            child: const Text('Sign up'),
          ),
        ],
      ),
    );
  }
}
