import "dart:async";

import "package:mynote/services/crud/crud_exception.dart";
import "package:sqflite/sqflite.dart";
import "package:path/path.dart" show join;
import "package:path_provider/path_provider.dart";


class NoteService {
  Database? _db;
  List<DatabaseNote> _notes = [];
  late final StreamController<List<DatabaseNote>> _notesStreamController; 

  Stream<List<DatabaseNote>> get allnotes => _notesStreamController.stream;

  static final NoteService _shared = NoteService._sharedInstance();
  NoteService._sharedInstance() {
    _notesStreamController = StreamController<List<DatabaseNote>>.broadcast(
      onListen: () {
        _notesStreamController.sink.add(_notes);
      }
    );
  }

  factory NoteService() => _shared;

  Future<DatabaseUser> getOrCreateUser ({required String email}) async {
    try {
      final user = await getUser(email: email);
      return user;

    } on CouldNotFoundUser {
      final createdUser = await createUser(email: email);
      return createdUser;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> _cacheNotes () async {

    final allNotes = await getAllNotes();
    _notes = allNotes.toList();
    _notesStreamController.add(_notes);

  }

  Database _getDatabaseOrThrow() {
    final db = _db;
    if (db == null) {
      throw DatabaseNotOpenException();
    } else {
      return db;
    }
  }

  Future<void> _ensureDbIsOpen() async {
    try {
      await open();
    } on DatabaseAlreadyOpenException {
      // do nothing
    }
  }

  Future<void> open() async {
    if (_db != null) {
      throw DatabaseAlreadyOpenException();
    }

    try {
      final docPath = await getApplicationDocumentsDirectory();
      
      final dbPath = join(docPath.path, dbName);
      print(dbPath);
      final db = await openDatabase(dbPath);
      _db = db;

    try {
      await db.execute(createUserTable);
      print("User table created or already exists");
    } catch (e) {
      print('Error creating user table: $e');
    }

    // Create note table and handle exception if it already exists
    try {
      await db.execute(createNoteTable);
      print("Note table created");
    } catch (e) {
      print('Error creating note table: $e');
    }

      print("create Tables --------------------------------------------------------------");
      await _cacheNotes();
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
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final deleteCount = await db.delete(userTable, where: "$emailColumn = ?", whereArgs: [email.toLowerCase()]);

    if (deleteCount != 1) {
      throw CouldNotDeleteUser();
    }
    
  }

  Future<DatabaseUser> getUser({required String email}) async {
    await _ensureDbIsOpen();  
    final db = _getDatabaseOrThrow();
    print("Useremail inside gteUser: $email");
    final result = await db.query(
      userTable,
      where: 'email = ?',
      whereArgs: [email.toLowerCase()],
    );

    if (result.isEmpty) {
      print('Throw User not found in getUser');
      throw CouldNotFoundUser();
    } else {
      final user = DatabaseUser.fromRow(result.first);
      print('User found in getUser: $user');
      return user;
    }


  }

  Future<DatabaseUser> createUser({required String email}) async {
    print("CreateUser called!");
    await _ensureDbIsOpen();
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

  Future<DatabaseNote> createNote({required DatabaseUser user}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final dbUser = await getUser(email: user.email);

    if (dbUser != user) {
      throw CouldNotFoundUser();
    }
    final String text = "";
    final noteId = await db.insert(noteTable, {
        user_idColumn: user.id, 
        textColumn: text, 
        is_synced_with_cloudColumn: 1
      });

    final note = DatabaseNote(id: noteId, user_id: user.id, text: text, is_synced_with_cloud: true);
    _notes.add(note);
    _notesStreamController.add(_notes);
    print(note);
    return note;
    
  }

  Future<void> deleteNote ({required int noteId}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final deleteCount = await db.delete(
      noteTable, 
      where: "$noteIdColumn = ?", 
      whereArgs: [noteId]
      );

    if (deleteCount == 0) {
      throw CanNotDeleteNote(); 
    } else {
      _notes.removeWhere((note) => note.id == noteId);
      _notesStreamController.add(_notes);
    }
  }

  Future<int> deleteAllNotes() async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final deleteCount = await db.delete(noteTable);
    _notes = [];
    _notesStreamController.add(_notes);
    return deleteCount;
  }

  Future<DatabaseNote> getNote({required int noteId}) async {
    await _ensureDbIsOpen();  
    final db = _getDatabaseOrThrow();
    final notes = await db.query(
      noteTable,
      where: "$noteIdColumn = ?",
      whereArgs: [noteId]
    );

    if (notes.isEmpty) {
      throw CouldNotFindNote();
    } else {
      final note = DatabaseNote.fromMap(notes.first);
      _notes.removeWhere((note) => note.id == noteId);
      _notes.add(note);
      _notesStreamController.add(_notes);
      return note;
    }
  }

  Future<Iterable<DatabaseNote>> getAllNotes () async{
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final notes = await db.query(noteTable);  

    return notes.map((noteRow) {
      return DatabaseNote.fromMap(noteRow);
    });
  }

  Future<DatabaseNote> updateNote({required DatabaseNote note, required String text}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    await getNote(noteId: note.id);

    final updateCount = db.update(noteTable, {
      textColumn: text,
      is_synced_with_cloudColumn: 0
      }, where: "id = ?", whereArgs: [note.id]);

    if (updateCount == 0) {
      throw CouldNotUpdateNote();
    } else {
      final updatedNote = await getNote(noteId: note.id);
      _notes.removeWhere((note) => note.id == updatedNote.id);
      _notes.add(updatedNote);
      _notesStreamController.add(_notes);
      return updatedNote;
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
