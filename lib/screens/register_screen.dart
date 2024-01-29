// ignore_for_file: use_build_context_synchronously
import 'package:cvapp/services/auth/bloc/auth_bloc.dart';
import 'package:cvapp/services/auth/bloc/auth_event.dart';
import 'package:cvapp/services/auth/bloc/auth_state.dart';
import 'package:cvapp/services/auth/exceptions.dart';
import 'package:cvapp/services/auth/service.dart';
import 'package:cvapp/utilities/dialogs/error_dialog.dart';
import 'package:flutter/material.dart';
import 'package:cvapp/constants/routes.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
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
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) async {
        if (state is AuthStateRegistering) {
          if (state.exception is WeakPasswordAuthException) {
            await errorDialog(context, 'weak password');
          } else if (state.exception is EmailExistAuthException) {
            await errorDialog(context, 'email already exists');
          } else if (state.exception is GenericAuthException) {
            await errorDialog(context, 'failed to register');
          } else if (state.exception is InvalidEmailAuthException) {
            await errorDialog(context, 'invalid email');
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Register'),
        ),
        body: Column(
          children: [
            TextField(
              controller: _email,
              enableSuggestions: false,
              autocorrect: false,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                hintText: 'Enter your email here',
              ),
            ),
            TextField(
              controller: _password,
              obscureText: true,
              enableSuggestions: false,
              autocorrect: false,
              decoration: const InputDecoration(
                hintText: 'Enter your password here',
              ),
            ),
            TextButton(
              onPressed: () async {
                final email = _email.text;
                final password = _password.text;
                context.read<AuthBloc>().add(
                      AuthEventRegister(email: email, password: password),
                    );
              },
              child: const Text('Register'),
            ),
            TextButton(
              onPressed: () {
                context.read<AuthBloc>().add(
                      const AuthEventLogOut(),
                    );
              },
              child: const Text('Already registered? Login here!'),
            )
          ],
        ),
      ),
    );
  }
}
