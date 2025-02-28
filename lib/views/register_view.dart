

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:mynote/constants/routes.dart';
import 'package:mynote/firebase_options.dart';
import 'package:mynote/utilities/show_error_dialog.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {

  late final TextEditingController _email;
  late final TextEditingController _password;

  @override
  void initState() {
    _email = TextEditingController();
    _password = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _email.dispose(); 
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
    appBar: AppBar(
      title: const Text('Register'),
    ),
    body: Column(
        children: [
          TextField(
            controller: _email,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              hintText: 'Enter your email',
            ),
          ),
          TextField(
            controller: _password,
            obscureText: true,
            enableSuggestions: false,
            autocorrect: false,
            decoration: const InputDecoration(
              hintText: 'Enter your password',
            ),
          ),
          TextButton(onPressed:  () async {
            final email = _email.text;
            final password = _password.text;
      
            try {
              await FirebaseAuth.instance.createUserWithEmailAndPassword(
                email: email,
                password: password,
              );
              final user = FirebaseAuth.instance.currentUser;
              user?.sendEmailVerification();
              Navigator.of(context).pushNamed(verifyEmailRoute);

            } on FirebaseAuthException catch (e) {
              if (e.code == "weak-password") {
                await showErrorDialog(context, "The password provided is too weak.");
              } else if (e.code == "invalid-email") {
                await showErrorDialog(context, "The email provided is invalid.");
      
              } else if (e.code == "email-already-in-use") {
                await showErrorDialog(context, "The email provided is already in use.");
              } else {
                await showErrorDialog(context, e.code.toString());
              }
            } catch (e) {
              await showErrorDialog(context, e.toString());
            }
            
            }, child: const Text("Register")),
            TextButton(onPressed: () {
              Navigator.of(context).pushNamedAndRemoveUntil(loginRoute, (route) => false);
            }, child: const Text("Already registered? Login here!")),
        ],
      ),
    );
  }
}
