/// Base class for typed AI gateway errors.
sealed class AiError implements Exception {
  const AiError(this.message, {this.statusCode, this.retryAfterMs});

  final String message;
  final int? statusCode;
  final int? retryAfterMs;

  @override
  String toString() => '$runtimeType: $message';
}

/// The provider rate-limited the request.
class RateLimitError extends AiError {
  const RateLimitError(super.message, {super.retryAfterMs})
    : super(statusCode: 429);
}

/// Authentication or authorization failed.
class AuthError extends AiError {
  const AuthError(super.message) : super(statusCode: 401);
}

/// The model refused the request due to content policy.
class ContentFilterError extends AiError {
  const ContentFilterError(super.message) : super(statusCode: 400);
}

/// The model endpoint is unreachable or returned a server error.
class ServiceUnavailableError extends AiError {
  const ServiceUnavailableError(super.message, {int? statusCode})
    : super(statusCode: statusCode ?? 503);
}

/// A catch-all for unexpected errors from the AI provider.
class UnknownAiError extends AiError {
  const UnknownAiError(super.message, {super.statusCode});
}
