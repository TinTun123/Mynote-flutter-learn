import "package:mynote/services/crud/crud_exception.dart";
import "package:sqflite/sqflite.dart";
import "package:path/path.dart" show join;
import "package:path_provider/path_provider.dart";


class NoteService {
  Database? _db;
  Database _getDatabaseOrThrow() {
    final db = _db;
    if (db == null) {
      throw DatabaseNotOpenException();
    } else {
      return db;
    }
  }

  Future<void> open() async {
    if (_db != null) {
      throw DatabaseAlreadyOpenException();
    }

    try {
      final docPath = await getApplicationDocumentsDirectory();
      final dbPath = join(docPath.path, dbName);
      final db = await openDatabase(dbPath);
      _db = db;

      await db.execute(createUserTable);


      await db.execute(createNoteTable);

    } on MissingPlatformDirectoryException catch (e) {
      print(e);
    }
  }

  Future<void> close() async {
    final db = _db;
    if (db == null) {
      throw DatabaseNotOpenException();
    } else {
      await db.close();
      _db = null;
    }

  }

  Future<void> deleteUser ({required String email}) async {
    final db = _getDatabaseOrThrow();
    final deleteCount = await db.delete(userTable, where: "$emailColumn = ?", whereArgs: [email.toLowerCase()]);

    if (deleteCount != 1) {
      throw CouldNotDeleteUser();
    }

    
  }

  Future<DatabaseUser> getUser({required String email}) async {
    final db = _getDatabaseOrThrow();
    final result = await db.query(
      userTable,
      where: 'email = ?',
      whereArgs: [email.toLowerCase()],
    );

    if (result.isEmpty) {
      throw CouldNotFoundUser();
    } else {
      return DatabaseUser.fromRow(result.first);
    }


  }

  Future<DatabaseUser> createUser({required String email}) async {
    final db = _getDatabaseOrThrow();
    final result = await db.query(
      userTable,
      where: 'email = ?',
      whereArgs: [email.toLowerCase()],
    );

    if (result.isNotEmpty) {
      throw UserAlreadyExist();
    }

    int userId = await db.insert(userTable, {emailColumn: email.toLowerCase()});
    return DatabaseUser(id: userId, email: email);

  }

  Future<DatabaseNote> createNote({required DatabaseUser user, required String text}) async {
    final db = _getDatabaseOrThrow();
    final dbUser = await getUser(email: user.email);

    if (dbUser != user) {
      throw CouldNotFoundUser();
    }

    final noteId = await db.insert(noteTable, {
        user_idColumn: user.id, 
        textColumn: text, 
        is_synced_with_cloudColumn: 1
      });

    return DatabaseNote(id: noteId, user_id: user.id, text: text, is_synced_with_cloud: true);

    
  }

  Future<void> deleteNote ({required int noteId}) async {
    final db = _getDatabaseOrThrow();
    final deleteCount = await db.delete(
      noteTable, 
      where: "$noteIdColumn = ?", 
      whereArgs: [noteId]
      );

    if (deleteCount == 0) {
      throw CanNotDeleteNote();
    }
  }

  Future<int> deleteAllNotes({required int userId}) async {
    final db = _getDatabaseOrThrow();
    final deleteCount = await db.delete(
      noteTable, 
      where: "$user_idColumn = ?", 
      whereArgs: [userId]
      );

      if (deleteCount == 0) {
        throw CanNotDeleteNote();
      } else {
        return deleteCount;
      }
  }

  Future<DatabaseNote> getNote({required int noteId}) async {
    final db = _getDatabaseOrThrow();
    final note = await db.query(
      noteTable,
      where: "$noteIdColumn = ?",
      whereArgs: [noteId]
    );

    if (note.isEmpty) {
      throw CouldNotFindNote();
    } else {
      return DatabaseNote.fromMap(note.first);
    }
  }

  Future<Iterable<DatabaseNote>> getAllNotes ({required int userId}) async{
    final db = _getDatabaseOrThrow();
    final notes = await db.query(
      noteTable,
      where: "$user_idColumn = ?",
      whereArgs: [userId]
    );

    return notes.map((noteRow) {
      return DatabaseNote.fromMap(noteRow);
    });
  }

  Future<DatabaseNote> updateNote({required DatabaseNote note, required String text}) async {
    final db = _getDatabaseOrThrow();
    await getNote(noteId: note.id);

    final updateCount = db.update(noteTable, {
      textColumn: text,
      is_synced_with_cloudColumn: 0
    });

    if (updateCount == 0) {
      throw CouldNotUpdateNote();
    } else {
      return await getNote(noteId: note.id);
    }
  }
}


class DatabaseUser {
  final int id;
  final String email;

  const DatabaseUser({required this.id, required this.email});
  DatabaseUser.fromRow(Map<String, dynamic> map)
      : id = map[idColumn] as int,
        email = map[emailColumn] as String;

  @override
  String toString() {
    return "Person, ID = $id: Email = $email";
  }

  @override
  bool operator ==(covariant DatabaseUser other) {
    return id == other.id;
  }
  
  @override
  // TODO: implement hashCode
  int get hashCode => super.hashCode;
  
  
}

const String idColumn = "id";
const String emailColumn = "email"; 


class DatabaseNote {
  final int id;
  final int user_id;
  final String text;
  final bool is_synced_with_cloud;

  DatabaseNote({required this.id, required this.user_id, required this.text, required this.is_synced_with_cloud,});

  DatabaseNote.fromMap(Map<String, dynamic> map) :
    id = map[noteIdColumn] as int,
    user_id = map[user_idColumn] as int,
    text = map[textColumn] as String,
    is_synced_with_cloud = (map[is_synced_with_cloudColumn] as int) == 1 ? true : false;
  
  @override
  String toString() {
    return "Note, ID = $id: User ID = $user_id, Text = $text, Is Synced with Cloud = $is_synced_with_cloud";
  }

  @override
  bool operator ==(covariant DatabaseNote other) {
    return id == other.id;
  }
  
  @override
  // TODO: implement hashCode
  int get hashCode => super.hashCode;
  
}

const String user_idColumn = "user_id";
const String textColumn = "text";
const String is_synced_with_cloudColumn = "is_synced_with_cloud";
const String noteIdColumn = "id";

const String dbName = "mynotedb.db";
const String userTable = "user";
const String noteTable = "note";

const createNoteTable = '''CREATE TABLE "note" (
  "id"	INTEGER NOT NULL UNIQUE,
  "user_id"	INTEGER NOT NULL,
  "text"	TEXT NOT NULL,
  "is_synced_with_cloud"	INTEGER DEFAULT 0,
  PRIMARY KEY("id" AUTOINCREMENT),
  FOREIGN KEY("user_id") REFERENCES "user"("id")
);''';

const createUserTable = '''CREATE TABLE IF NOT EXISTS "user" (
  "id"	INTEGER NOT NULL UNIQUE,
  "email"	TEXT NOT NULL,
  PRIMARY KEY("id" AUTOINCREMENT)
);''';
