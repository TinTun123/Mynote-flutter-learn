import 'package:flutter/material.dart';
import 'package:mynote/constants/routes.dart';
import 'package:mynote/services/auth/auth_service.dart';

class VerifyEmailView extends StatefulWidget {
  const VerifyEmailView({super.key});

  @override
  State<VerifyEmailView> createState() => _VerifyEmailViewState();
}

class _VerifyEmailViewState extends State<VerifyEmailView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify Email'),
      ),
      body: Column(
        children: [
          const Text('We have sent you a verification email. Please click the link in the email to verify your account.'),
          const Text('If you did not receive the email, please click the button below to send the email again.'),
          TextButton(onPressed: () async {
            final user = AuthService.firebase().currentUser;
            await AuthService.firebase().sendEmailVerification();
          }, child: const Text("Please send the verification email again!")),
          TextButton(onPressed: () async {
            await AuthService.firebase().logOut();
            Navigator.of(context).pushNamedAndRemoveUntil(loginRoute, (route) => false);
          }, child: const Text("Go back"))
        ]
        ),
    );
  }
}