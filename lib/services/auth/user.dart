import 'package:firebase_auth/firebase_auth.dart' show User;

class AuthUser {
  final String id;
  final String email;
  final bool isEmailVerified;

  AuthUser({required this.isEmailVerified, required this.email, required this.id});

  factory AuthUser.fromFirebase(User user) => AuthUser(
        email: user.email!,
        isEmailVerified: user.emailVerified,
        id: user.uid,
      );
}
