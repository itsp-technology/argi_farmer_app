abstract class Failure {
  final String message;
  const Failure(this.message);
}

class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Remote gateway error occurred.']);
}

class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Local cache access failed.']);
}