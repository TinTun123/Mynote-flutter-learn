

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:mynote/constants/routes.dart';
import 'package:mynote/firebase_options.dart';
import 'package:mynote/utilities/show_error_dialog.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
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
        title: const Text('Login'),
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
        
            final userCredential =  await FirebaseAuth.instance.signInWithEmailAndPassword(
              email: email,
              password: password,
            );

            final user = userCredential.user;
            if (user != null && user.emailVerified) {
              Navigator.of(context).pushNamedAndRemoveUntil(notesRoute, (route) => false);
            } else {
              await showErrorDialog(context, "Please verify your email first");
            }
            Navigator.of(context).pushNamedAndRemoveUntil(notesRoute, (route) => false);

            } on FirebaseAuthException catch (e) {
              if (e.code == "invalid-credential") {
                await showErrorDialog(context, "Invalid credentials");
              } else if (e.code == "user-not-found") {
                await showErrorDialog(context, "User not found");

              } else if (e.code == "wrong-password") {
                await showErrorDialog(context, "Wrong password");

              } else {
                await showErrorDialog(context, "An error occurred");
              }
            } catch (e) {
              await showErrorDialog(context, "An error occurred: ${e.toString()}");
            }
            }, child: const Text("Login")),
            TextButton(onPressed: () {
              Navigator.of(context).pushNamedAndRemoveUntil(registerRoute, (route) => false);
            }, child: const Text("Not registered yet? Register here!")),
        ],
      ),
    );
  } 
}

