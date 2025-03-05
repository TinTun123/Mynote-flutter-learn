import 'package:flutter/material.dart';
import 'package:mynote/constants/routes.dart';
import 'package:mynote/services/auth/auth_exception.dart';
import 'package:mynote/services/auth/auth_service.dart';
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
        
            final userCredential =  await AuthService.firebase().login(email: email, password: password);

            final user = AuthService.firebase().currentUser;

            if (user != null && user.isEmailVerified) {
              Navigator.of(context).pushNamedAndRemoveUntil(notesRoute, (route) => false);
            } else {
              await showErrorDialog(context, "Please verify your email first");
            }
            Navigator.of(context).pushNamedAndRemoveUntil(notesRoute, (route) => false);

            } on InvalidEmailException catch (e) {
              await showErrorDialog(context, "Invalid email");
            } on InvalidPasswordException catch (e) {
              await showErrorDialog(context, "Invalid password");
            } on UserNotFoundException catch (e) {
              await showErrorDialog(context, "User not found");
            } on UserDisabledException catch (e) {
              await showErrorDialog(context, "User disabled");
            } on EmailAlreadyInUseException catch (e) {
              await showErrorDialog(context, "Email already in use");
            } on WeakPasswordException catch (e) {
              await showErrorDialog(context, "Weak password");
            } on GenericAuthException catch (e) {
              await showErrorDialog(context, "An error occurred. Please try again later!");
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

