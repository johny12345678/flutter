import 'package:cvapp/constants/routes.dart';
import 'package:cvapp/helpers/loading/loading_screed.dart';
import 'package:cvapp/screens/note/create_update_note_view.dart';
import 'package:cvapp/screens/note/notes_screen.dart';
import 'package:cvapp/screens/login_screen.dart';
import 'package:cvapp/screens/register_screen.dart';
import 'package:cvapp/screens/verify_email_screen.dart';
import 'package:cvapp/services/auth/bloc/auth_bloc.dart';
import 'package:cvapp/services/auth/bloc/auth_event.dart';
import 'package:cvapp/services/auth/bloc/auth_state.dart';
import 'package:cvapp/services/auth/firebase_auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: false,
      ),
      home: BlocProvider<AuthBloc>(
        create: (context) => AuthBloc(FirebaseAuthProvider()),
        child: const HomePage(),
      ),
      routes: {
        createUpdateNoteScreen: (context) => const CreateUpdateNoteScreen(),
      }));
}

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    context.read<AuthBloc>().add(const AuthEventInitialize());
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state.isLoading) {
          LoadingScreen().show(
            context: context,
            text: state.loadingText ?? 'Please wait...(main)',
          );
        } else {
          LoadingScreen().hide();
        }
      },
      builder: (context, state) {
        if (state is AuthStateLoggedIn) {
          return const NoteScreen();
        } else if (state is AuthStateLoggedOut) {
          return const LoginPage();
        } else if (state is AuthStateNeedsVerification) {
          return const VerifyEmailPage();
        } else if (state is AuthStateRegistering) {
          return const RegisterPage();
        } else {
          return const Scaffold(
              body: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                Center(child: CircularProgressIndicator()),
              ]));
        }
      },
    );
  }
}
  //   return FutureBuilder(
  //     future: AuthService.firebase().initialize(),
  //     builder: (context, snapshot) {
  //       switch (snapshot.connectionState) {
  //         case ConnectionState.done:
  //           final user = AuthService.firebase().currentUser;
  //           if (user != null) {
  //             if (user.isEmailVerified) {
  //               return const NoteScreen();
  //             } else {
  //               return const VerifyEmailPage();
  //             }
  //           } else {
  //             return const LoginPage();
  //           }
  //         default:
  //           return const CircularProgressIndicator();
  //       }
  //     },
  //   );
  // }

