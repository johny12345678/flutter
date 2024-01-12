import 'package:cvapp/services/auth/user.dart';

abstract class AuthProvider {
  AuthUser? get currentUser;

  Future<AuthUser> logIn({
    required String email,
    required String password,
  });

  Future<AuthUser> createAccount({
    required String email,
    required String password,
  });

  Future<void> logout();

  Future<void> sendEmailVerification();
}
