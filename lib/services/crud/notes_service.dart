import 'dart:async';

import 'package:cvapp/services/crud/crud_exceptions.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
//communication with db

class NotesService {
  Database? _db;

  final _noteStreamController =
      StreamController<List<DatabaseNote>>.broadcast();

  List<DatabaseNote> _notes = [];

  //cache for DB
  Future<void> _cacheNotes() async {
    final allNotes = await getAllNotes();
    _notes = allNotes.toList();
    _noteStreamController.add(_notes);
  }

  Future<DatabaseNote> updateNote({
    required DatabaseNote note,
    required String text,
  }) async {
    final db = _getDatabaseOrThrow();
    //assure that note exists
    await getNote(id: note.id);

    final updateCount = await db.update(noteTable, {
      textColumn: text,
      isSynchronized: 0,
    });

    if (updateCount == 0) {
      throw CouldNotUpdateNote();
    } else {
      return await getNote(id: note.id);
    }
  }

  Future<Iterable<DatabaseNote>> getAllNotes() async {
    final db = _getDatabaseOrThrow();
    final allNotes = await db.query(noteTable);
    final result = allNotes.map((e) => DatabaseNote.fromRow(e));
    if (allNotes.isEmpty) {
      throw CouldNotGetNote();
    } else {
      return result;
    }
  }

  Future<DatabaseNote> getNote({required int id}) async {
    final db = _getDatabaseOrThrow();
    final notes = await db.query(
      noteTable,
      limit: 1,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (notes.isEmpty) {
      throw CouldNotGetNote;
    } else {
      final note = DatabaseNote.fromRow(notes.first);
      _notes.removeWhere((element) => note.id == id);
      _notes.add(note);
      _noteStreamController.add(_notes);
      return note;
    }
  }

  Future<int> deleteAllNotes() async {
    final db = _getDatabaseOrThrow();
    final numberOfDeleted = await db.delete(noteTable);
    _notes = [];
    _noteStreamController.add(_notes);
    return numberOfDeleted;
  }

  Future<void> deleteNote({required int id}) async {
    final db = _getDatabaseOrThrow();
    final deletedCount = db.delete(noteTable, where: 'id = ?', whereArgs: [id]);
    if (deletedCount == 0) {
      throw CouldNotDeleteNote();
    } else {
      final countBefore = _notes.length;
      _notes.removeWhere((element) => element.id == id);
      if (_notes.length != countBefore) {
        _noteStreamController.add(_notes);
      }
    }
  }

  Future<DatabaseNote> createNote({required DatabaseUser owner}) async {
    final db = _getDatabaseOrThrow();
    final dbUser = await getUser(email: owner.email);
    if (dbUser != owner) {
      //make sure owner exists
      throw CouldNotFindUser();
    }
    //create note
    const text = '';
    final noteId = await db.insert(noteTable, {
      userIdColumn: owner.id,
      textColumn: text,
      isSynchronized: 1,
    });

    final note = DatabaseNote(
      id: noteId,
      userId: owner.id,
      text: text,
      isSyncWithServer: true,
    );

    _notes.add(note);
    _noteStreamController.add(_notes);

    return note;
  }

  Future<DatabaseUser> getUser({required String email}) async {
    final db = _getDatabaseOrThrow();
    final result = await db.query(
      userTable,
      limit: 1,
      where: 'email = ?',
      whereArgs: [email.toLowerCase()],
    );
    if (result.isEmpty) {
      throw CouldNotFindUser();
    } else {
      return DatabaseUser.fromRow(result.first);
    }
  }

  Future<DatabaseUser> createUser({required String email}) async {
    final db = _getDatabaseOrThrow();
    final result = await db.query(
      userTable,
      limit: 1,
      where: 'email = ?',
      whereArgs: [email.toLowerCase()],
    );
    if (result.isNotEmpty) {
      throw UserAlreadyExists();
    }
    final userId = await db.insert(
      userTable,
      {emailColumn: email.toLowerCase()},
    );
    return DatabaseUser(id: userId, email: email);
  }

  Future<void> deleteUser({required String email}) async {
    final db = _getDatabaseOrThrow();
    final deletedCount = await db.delete(
      userTable,
      where: 'email = ?',
      whereArgs: [email.toLowerCase()],
    );
    if (deletedCount != 1) {
      throw CouldNotDeleteUser();
    }
  }

  //internal func that there is no need to make everywhere same if else statement
  Database _getDatabaseOrThrow() {
    final db = _db;
    if (db == null) {
      throw DbIsNotOpen();
    } else {
      return db;
    }
  }

  Future<void> close() async {
    final db = _db;
    if (db == null) {
      throw DbIsNotOpen();
    } else {
      await db.close();
      _db = null;
    }
  }

  Future<void> open() async {
    if (_db != null) {
      throw DatabaseAlreadyOpenException();
    }
    try {
      final docsPath = await getApplicationDocumentsDirectory();
      final dbPath = join(docsPath.path, dbName);
      final db = await openDatabase(dbPath);
      _db = db;

      await db.execute(createUserTable);
      await db.execute(createNoteTable);
      //adding db to internal cache list
      await _cacheNotes();
    } on MissingPlatformDirectoryException {
      throw UnableToGetDocDirectory();
    }
  }
}

@immutable
class DatabaseUser {
  final int id;
  final String email;

  const DatabaseUser({
    required this.id,
    required this.email,
  });
  // db data to class fields
  DatabaseUser.fromRow(Map<String, Object?> map)
      : id = map[idColumn] as int,
        email = map[emailColumn] as String;

  @override
  String toString() => 'Person, ID = $id, email = $email';

  @override
  bool operator ==(covariant DatabaseUser other) =>
      id == other.id; // comparing DatabaseUser objects

  @override
  int get hashCode => id.hashCode;
}

@immutable
class DatabaseNote {
  final int id;
  final int userId;
  final String text;
  final bool isSyncWithServer;

  const DatabaseNote({
    required this.id,
    required this.userId,
    required this.text,
    required this.isSyncWithServer,
  });

  DatabaseNote.fromRow(Map<String, Object?> map)
      : id = map[idColumn] as int,
        userId = map[userIdColumn] as int,
        text = map[textColumn] as String,
        isSyncWithServer = (map[isSynchronized] as int) == 1 ? true : false;

  @override
  operator ==(covariant DatabaseNote other) => id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'Note, ID = $id, userId = $userId, text = $text, Is synchronized = $isSyncWithServer';
}

const dbName = "notes.db";
const noteTable = "note";
const userTable = "user";
const idColumn = "id";
const emailColumn = "email";
const userIdColumn = "user_id";
const textColumn = "text";
const isSynchronized = "is_sync_with_server";

const createUserTable = '''CREATE TABLE IF NOT EXISTS "user" (
"id"	INTEGER NOT NULL,
"email"	TEXT NOT NULL UNIQUE,
PRIMARY KEY("id" AUTOINCREMENT)
)''';

const createNoteTable = '''CREATE TABLE IF NOT EXISTS"note" (
"id"	INTEGER NOT NULL,
"user_id"	INTEGER NOT NULL,
"text"	TEXT,
"is_sync_with_server"	INTEGER NOT NULL DEFAULT 0,
FOREIGN KEY("user_id") REFERENCES "user"("id"),
PRIMARY KEY("id" AUTOINCREMENT)
)''';
