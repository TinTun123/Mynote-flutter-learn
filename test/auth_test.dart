
import "package:mynote/services/auth/auth_exception.dart";
import "package:mynote/services/auth/auth_provider.dart";
import "package:mynote/services/auth/auth_user.dart";
import "package:test/test.dart";

void main () {
  group("Mock Authentication", () {
    final provider = MockAuthProvider(); 

    test("Should not be inialized to begin with", () {
      expect(provider.isInitialized, false);
    });

    test("Cannot logout if not initialized", () {
      expect(provider.logOut(), throwsA(const TypeMatcher<NotInitializedException>()));
    });

    test("Should be able to initialized", () async {
      await provider.initialize();
      expect(provider.isInitialized, true);
    });

    test("User should be null after initialization", () {
      expect(provider.currentUser, null) ;
    });

    test("Should be able to initialize in less than in 2 seconds", () async {
      await provider.initialize();

      expect(provider.isInitialized, true);

    }, timeout: const Timeout(Duration(seconds: 2)));

    test("Creat user should elegate to Login function", () async {
      final badUseremail = provider.createUser(email: "foo@bar.com", password: "foobar");
      expect(badUseremail, throwsA(TypeMatcher<UserNotFoundException>()));

      final badUserpwd = provider.createUser(email: "someone@bar.com", password: "foobar");
      expect(badUserpwd, throwsA(TypeMatcher<WrongPasswordException>()));

      final user = await provider.createUser(email: "foo", password: "bar");
      expect(provider.currentUser, user);
      expect(provider.currentUser?.isEmailVerified, false);
    });

    test("Login user should be able to verify", () {
      provider.sendEmailVerification();
      final user = provider.currentUser;
      expect(user, isNot(null));
      expect(user!.isEmailVerified, true);
    });

    test("Should be able to logout and login again", () async {
      await provider.logOut();
      await provider.login(email: 'email', password: "password");
      final user = provider.currentUser;
      expect(user, isNotNull);

    });

  });
}

class NotInitializedException implements Exception {
  final String message = "Auth provider not initialized";
}

class MockAuthProvider implements AuthProvider {
  var _isInitialized = false;
  bool get isInitialized => _isInitialized;
  AuthUser? _user;

  @override
  Future<AuthUser?> createUser({required String email, required String password}) async {
    if (!isInitialized) {
      throw NotInitializedException();
    }

    await Future.delayed(const Duration(seconds: 1));

    return login(email: email, password: password);
  }

  @override
  // TODO: implement currentUser
  AuthUser? get currentUser => _user;

  @override
  Future<void> initialize() async {
    await Future.delayed(const Duration(seconds: 1));
    _isInitialized  = true; 
  }

  @override
  Future<void> logOut() async {
    if (!isInitialized) throw NotInitializedException();
    if (_user == null) throw UserNotFoundException();

    await Future.delayed(const Duration(seconds: 1));
    _user = null;
  }

  @override
  Future<AuthUser?> login({required String email, required String password}) {
    if (!_isInitialized) {
      throw NotInitializedException();
    }

    if (email == "foo@bar.com") throw UserNotFoundException();
    if (password == 'foobar') throw WrongPasswordException();

    const user = AuthUser(isEmailVerified: false, email: "foo@bar.com");
    _user = user;

    return Future.value(user);  
  }

  @override
  Future<void> sendEmailVerification() async  {
    if (!isInitialized) throw NotInitializedException();
    final user = _user;
    if (user == null) throw UserNotFoundException();
    const newUser = AuthUser(isEmailVerified: true, email: "foo@bar.com");
    _user = newUser;
  }

}