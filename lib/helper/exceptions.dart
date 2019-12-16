enum AppExceptionType { FetchDataException, AppException }

class AppException implements Exception {
  final _message;
  final _prefix;
  final type;
  AppException(
      [this._message, this._prefix, this.type = AppExceptionType.AppException]);

  String toString() {
    return "$_prefix$_message";
  }
}

class FetchDataException extends AppException {
  FetchDataException([String message])
      : super(message, "Error During Communication: ",
            AppExceptionType.FetchDataException);
}

class BadRequestException extends AppException {
  BadRequestException([message]) : super(message, "Invalid Request: ");
}

class UnauthorisedException extends AppException {
  UnauthorisedException([message]) : super(message, "Unauthorised: ");
}

class InvalidInputException extends AppException {
  InvalidInputException([String message]) : super(message, "Invalid Input: ");
}

class HttpException extends AppException {
  HttpException([String message]) : super(message, "Http Exception: ");
}
