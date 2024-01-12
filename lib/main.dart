import 'package:cvapp/constants/routes.dart';
import 'package:cvapp/screens/dashboard.dart';
import 'package:cvapp/screens/login_screen.dart';
import 'package:cvapp/screens/register_screen.dart';
import 'package:cvapp/screens/verify_email_screen.dart';
import 'package:cvapp/services/auth/service.dart';
import 'package:flutter/material.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomePage(),
      routes: {
        loginRoute: (context) => const LoginPage(),
        registerRoute: (context) => const RegisterPage(),
        notesRoute: (context) => const Dashboard(),
        verifyEmailRoute: (context) => const VerifyEmailPage(),
      }));
}

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: AuthService.firebase().initialize(),
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.done:
            final user = AuthService.firebase().currentUser;
            if (user != null) {
              if (user.isEmailVerified) {
                return const Dashboard();
              } else {
                return const VerifyEmailPage();
              }
            } else {
              return const LoginPage();
            }
          default:
            return const CircularProgressIndicator();
        }
      },
    );
  }
}
