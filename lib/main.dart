import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:mynote/views/login_view.dart';
import 'package:mynote/views/register_view.dart';
import 'package:mynote/views/verify_email_view.dart';
import 'firebase_options.dart';

void main() {
  runApp(MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, npmwithout quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomePage(),
      routes: {
        '/login/': (context) => const LoginView(),
        '/register/': (context) => const RegisterView(),
      },
    ));
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder (
        future: Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        ),
        builder : (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
            final user = FirebaseAuth.instance.currentUser;
           if (user != null) {
            if (user.emailVerified) {
              return const Text("Good to go!");
            } else {
              return const VerifyEmailView();
            }
           } else {
              return const LoginView();
           }
            default:
              return const CircularProgressIndicator();
          }
        }
      );
  }
}

