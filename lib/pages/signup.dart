import 'package:flutter/material.dart';
import 'package:one_of/src/oneOf/one_of_base.dart';
import 'package:ory_client/ory_client.dart';
import 'package:dio/browser.dart';
import 'package:dio/dio.dart';
import 'package:built_value/json_object.dart';

class SignUpScreen extends StatelessWidget {
  String flowid;
  JsonObject csrfToken;
  SignUpScreen({super.key, required this.flowid, required this.csrfToken});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: Center(
        child: SizedBox(
          width: 400,
          child: Card(
            child: SignUpForm(flowid: flowid, csrfToken: csrfToken,)
          ),
        ),
      ),
    );
  }
}

class SignUpForm extends StatefulWidget {
  const SignUpForm({super.key, required this.flowid, required this.csrfToken});
  final String flowid;
  final JsonObject csrfToken;

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

    final traitsJsonobject = JsonObject({
      'UAEPass email': _uaepassEmailTextController.text,
      'Preferred email': _prefEmailTextController.text,
      'UAEPass phone': _uaepassPhnoTextController.text,
      'Preferred phone': _prefPhnoTextController.text
      });
    
    final p_bd = UpdateRegistrationFlowWithPasswordMethod((builder) {
      builder
        ..method = 'password'
        ..password = _passwordTextController.text
        ..traits = traitsJsonobject
        ..csrfToken = widget.csrfToken.asString;
    });

    final bd = UpdateRegistrationFlowBody((builder) {
      builder
        .oneOf = OneOf.fromValue1(value: p_bd);
    });
   
    Dio dio = DioForBrowser(options);

    final api = OryClient(dio: dio).getFrontendApi();
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
