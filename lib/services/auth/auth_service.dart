import 'package:mynote/services/auth/auth_provider.dart';
import 'package:mynote/services/auth/auth_user.dart';

class AuthService implements AuthProvider {
  final AuthProvider provider;

  AuthService(this.provider);
  
  @override
  Future<AuthUser?> createUser({required String email, required String password}) {
    return provider.createUser(email: email, password: password);
  }
  
  @override
  AuthUser? get currentUser => provider.currentUser;
  
  @override
  Future<void> logOut() {
    return provider.logOut();
  }
  
  @override
  Future<AuthUser?> login({required String email, required String password}) {
    return provider.login(email: email, password: password);
  }
  
  @override
  Future<void> sendEmailVerification() {
    return provider.sendEmailVerification();
  }
}