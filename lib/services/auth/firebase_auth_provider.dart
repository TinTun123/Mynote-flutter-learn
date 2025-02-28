import 'package:mynote/services/auth/auth_exception.dart';
import 'package:mynote/services/auth/auth_provider.dart';
import 'package:mynote/services/auth/auth_user.dart';
import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuth, FirebaseAuthException;

class FirebaseAuthProvider implements AuthProvider {
  @override
  Future<AuthUser?> createUser({required String email, required String password}) async {
    // TODO: implement createUser
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password: password);
      final user = currentUser;
      if (user != null) {
        return user;
      } else {
        throw UserNotLoginException();
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == "weak-password") {
        throw WeakPasswordException();
      } else if (e.code == "invalid-email") {
        throw InvalidEmailException();
      } else if (e.code == "email-already-in-use") {
        throw EmailAlreadyInUseException();
      } else {
        throw GenericAuthException();
      }
    } 
    catch (e) {
      throw GenericAuthException();
    }
  }

  @override
  // TODO: implement currentUser
  AuthUser? get currentUser {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return AuthUser.fromFirebaseUser(user);
    } else {
      return null;
    }
  }

  @override
  Future<void> logOut() {
    final user = currentUser;

    if (user != null) {
      return FirebaseAuth.instance.signOut();
    } else {
      throw UserNotLoginException();
    }
  }

  @override
  Future<AuthUser?> login({required String email, required String password}) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);
      final user = currentUser;
      if (user != null) {
        return user;
      } else {
        throw UserNotLoginException();
      }
    } on FirebaseAuthException catch (e) {
        if (e.code == "invalid-credential") {
          throw InvalidCredentialsException();
        } else if (e.code == "user-not-found") {
          throw UserNotFoundException();  

        } else if (e.code == "wrong-password") {
          throw WrongPasswordException();
        } else {
          throw GenericAuthException();
        } 
      } catch (e) {
      throw GenericAuthException();
    }
  }

  @override
  Future<void> sendEmailVerification() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await user.sendEmailVerification();
    } else {
      throw UserNotLoginException();
    }
  }

}