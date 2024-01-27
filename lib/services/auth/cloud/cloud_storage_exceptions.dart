//All cloud exceptions will be typed in this class for better handling
class CloudStorageExceptions implements Exception {
  const CloudStorageExceptions();
}

class CouldNotCreateNoteException extends CloudStorageExceptions {}

class CouldNotGetAllNotesExcteption extends CloudStorageExceptions {}

class CouldNotUpdateNoteExcteption extends CloudStorageExceptions {}

class CouldNotDeleteNoteException extends CloudStorageExceptions {}

class CouldNotUpdateNoteException extends CloudStorageExceptions {}

class CouldNotGetAllNotesException extends CloudStorageExceptions {}
