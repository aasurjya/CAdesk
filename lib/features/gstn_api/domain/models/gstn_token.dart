/// Immutable OAuth token issued by the GSTN authentication service.
class GstnToken {
  const GstnToken({
    required this.accessToken,
    required this.expiresIn,
    required this.issuedAt,
    this.tokenType = 'Bearer',
  });

  /// The access token string to include in GSTN API request headers.
  final String accessToken;

  /// Token type — always "Bearer" for GSTN APIs.
  final String tokenType;

  /// Lifetime of the token in seconds from [issuedAt].
  final int expiresIn;

  /// UTC timestamp when this token was issued.
  final DateTime issuedAt;

  /// Computed expiry timestamp.
  DateTime get expiresAt => issuedAt.add(Duration(seconds: expiresIn));

  /// Whether the token has passed its expiry time.
  bool get isExpired => DateTime.now().isAfter(expiresAt);

  GstnToken copyWith({
    String? accessToken,
    String? tokenType,
    int? expiresIn,
    DateTime? issuedAt,
  }) {
    return GstnToken(
      accessToken: accessToken ?? this.accessToken,
      tokenType: tokenType ?? this.tokenType,
      expiresIn: expiresIn ?? this.expiresIn,
      issuedAt: issuedAt ?? this.issuedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GstnToken &&
          runtimeType == other.runtimeType &&
          accessToken == other.accessToken &&
          tokenType == other.tokenType &&
          expiresIn == other.expiresIn &&
          issuedAt == other.issuedAt;

  @override
  int get hashCode => Object.hash(accessToken, tokenType, expiresIn, issuedAt);
}
