class UserNotFoundException implements Exception {
  final String message = 'User not found';
}

class InvalidCredentialsException implements Exception {
  final String message = 'Invalid credentials';
}

class PasswordWrongException implements Exception {
  final String message = 'Wrong password';
}

class WeakPasswordException implements Exception {
  final String message = 'Weak password';
} 


class EmailAlreadyInUseException implements Exception {
  final String message = 'Email already in use';
}

class InvalidEmailException implements Exception {
  final String message = 'Invalid email';
}

class EmailNotVerifiedException implements Exception {
  final String message = 'Email not verified';
}

class GenericAuthException implements Exception {
  final String message = 'An error occurred';
} 

class UserNotLoginException implements Exception {
  final String message = 'User not logged in';
} 

class WrongPasswordException implements Exception {
  final String message = 'Wrong password';
}

class InvalidPasswordException implements Exception {
  final String message = 'Invalid password';
} 

class UserDisabledException implements Exception {
  final String message = 'User disabled';
} 