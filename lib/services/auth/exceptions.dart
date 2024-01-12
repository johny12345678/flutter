// login
class UserNotFoundAuthException implements Exception{}

class WrongPasswordAuthException implements Exception{}

//register
class WeakPasswordAuthException implements Exception{}

class EmailExistAuthException implements Exception{}

class InvalidEmailAuthException implements Exception{}

// generic exceptions

class GenericAuthException implements Exception{}

class UserNotLoggedInAuthException implements Exception{}