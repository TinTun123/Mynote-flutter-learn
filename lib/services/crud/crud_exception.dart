class DatabaseAlreadyOpenException implements Exception {
  final String message = "Database is already open";
}

class UnableToGetDocumentDirectory implements Exception {
  final String message = "Unable to get document directory";
}

class DatabaseNotOpenException implements Exception {
  final String message = "Database is not open";
}

class CouldNotDeleteUser implements Exception {
  final String message = "Could not delete user";
}

class UserAlreadyExist implements Exception {
  final String message = "User already exist";
}

class CouldNotFoundUser implements Exception {
  final String message = "Could not find user";
} 


class CanNotDeleteNote implements Exception {
  final String message = "Can not delete note";
} 

class CouldNotFindNote implements Exception {
  final String message = "Could not find note";
}

class CouldNotUpdateNote implements Exception {
  final String message = "Could not update note";
} 