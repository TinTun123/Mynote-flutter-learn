import 'package:flutter/material.dart';
import 'package:mynote/constants/routes.dart';
import 'package:mynote/services/auth/auth_exception.dart';
import 'package:mynote/services/auth/auth_service.dart';
import 'package:mynote/utilities/dialogs/error_dialog.dart';

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
              await AuthService.firebase().createUser(
                email: email,
                password: password,
              );
              final user = AuthService.firebase().currentUser;
              await AuthService.firebase().sendEmailVerification();

              if (mounted) {
                Navigator.of(context).pushNamed(verifyEmailRoute);
              }
            } on WeakPasswordException catch (e) {
              if (mounted) {
                await showErrorDialog(context, e.toString());
              }
            } on EmailAlreadyInUseException catch (e) {
              if (mounted) {
                await showErrorDialog(context, e.toString());
              }
            } on InvalidEmailException catch (e) {
              if (mounted) {
                await showErrorDialog(context, e.toString());
              }
            } on GenericAuthException catch (e) {
              if (mounted) {
                await showErrorDialog(context, e.toString());
              }
            } catch (e) {
              if (mounted) {
                await showErrorDialog(context, e.toString());
              }
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
