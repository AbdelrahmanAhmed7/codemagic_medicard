enum AppFailureType {
  network,
  timeout,
  unauthorized,
  forbidden,
  notFound,
  server,
  unexpected,
}

class AppFailure {
  final AppFailureType type;
  final String? message;
  final int? statusCode;

  const AppFailure(
      this.type, {
        this.message,
        this.statusCode,
      });

  const AppFailure.network() : this(AppFailureType.network);
  const AppFailure.timeout() : this(AppFailureType.timeout);
  const AppFailure.unauthorized() : this(AppFailureType.unauthorized);
  const AppFailure.forbidden() : this(AppFailureType.forbidden);
  const AppFailure.notFound() : this(AppFailureType.notFound);
  const AppFailure.server({int? statusCode})
      : this(AppFailureType.server, statusCode: statusCode);
  const AppFailure.unexpected([String? message])
      : this(AppFailureType.unexpected, message: message);
}

