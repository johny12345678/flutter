import 'package:cvapp/services/auth/firebase_auth_provider.dart';
import 'package:cvapp/services/auth/provider.dart';
import 'package:cvapp/services/auth/user.dart';

class AuthService implements AuthProvider {
  final AuthProvider provider;
  AuthService(this.provider);

  factory AuthService.firebase() => AuthService(FirebaseAuthProvider());

  @override
  Future<AuthUser> createAccount({
    required String email,
    required String password,
  }) =>
      provider.createAccount(email: email, password: password);

  @override
  AuthUser? get currentUser => provider.currentUser;

  @override
  Future<AuthUser> logIn({
    required String email,
    required String password,
  }) =>
      provider.logIn(
        email: email,
        password: password,
      );

  @override
  Future<void> logout() => provider.logout();

  @override
  Future<void> sendEmailVerification() => provider.sendEmailVerification();
}
