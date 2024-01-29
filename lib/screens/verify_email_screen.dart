// ignore_for_file: use_build_context_synchronously

import 'package:cvapp/services/auth/bloc/auth_bloc.dart';
import 'package:cvapp/services/auth/bloc/auth_event.dart';
import 'package:cvapp/services/auth/service.dart';
import 'package:flutter/material.dart';
import 'package:cvapp/constants/routes.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class VerifyEmailPage extends StatefulWidget {
  const VerifyEmailPage({Key? key}) : super(key: key);

  @override
  State<VerifyEmailPage> createState() => _VerifyEmailPageState();
}

class _VerifyEmailPageState extends State<VerifyEmailPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify email'),
      ),
      body: Column(
        children: [
          const Text("Activate your account"),
          const Text("Didn't get verification link? Click below"),
          TextButton(
            onPressed: () {
              context.read<AuthBloc>().add(
                    const AuthEventSendEmailVerification(),
                  );
            },
            child: const Text('Send email verification'),
          ),
          TextButton(
            onPressed: () {
              context.read<AuthBloc>().add(
                    const AuthEventLogOut(),
                  );
            },
            child: const Text('Restart'),
          )
        ],
      ),
    );
  }
}
