import "package:firebase_auth/firebase_auth.dart" show User;
import "package:flutter/foundation.dart";
import "package:mynote/services/auth/auth_provider.dart";

@immutable
class AuthUser {
  final bool isEmailVerified;
  final String? email;
  const AuthUser({required this.isEmailVerified, required this.email});
  
  factory AuthUser.fromFirebaseUser(User user) {
    return AuthUser(isEmailVerified:  user.emailVerified, email: user.email); 
  }

  void testing () {

  }
}

class NotInitializedException implements Exception {
  final String message = "Auth provider not initialized";
}

class MockAuthProvider implements AuthProvider {
  final _isInitialized = false;
  AuthUser? user;
  bool get isInitialized => _isInitialized;
  @override
  Future<AuthUser?> createUser({required String email, required String password}) async {
    
    if (!isInitialized) {
      throw NotInitializedException();
    }

    await Future.delayed(Duration(seconds: 1));
    return login(email: email, password: password);
  }

  @override
  // TODO: implement currentUser
  AuthUser? get currentUser => throw UnimplementedError();

  @override
  Future<void> initialize() {
    // TODO: implement initialize
    throw UnimplementedError();
  }

  @override
  Future<void> logOut() {
    // TODO: implement logOut
    throw UnimplementedError();
  }

  @override
  Future<AuthUser?> login({required String email, required String password}) {
    // TODO: implement login
    throw UnimplementedError();
  }

  @override
  Future<void> sendEmailVerification() {
    // TODO: implement sendEmailVerification
    throw UnimplementedError();
  }

}