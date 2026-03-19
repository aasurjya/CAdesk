/// Portal type enum with display names and base URL configuration.
///
/// Each portal value carries its human-readable [displayName] and the
/// default API [baseUrl] (overridable via `--dart-define` at build time).
///
/// Note: This enum is specific to the HTTP client layer. The domain layer
/// uses [Portal] from `portal_request.dart` and [PortalType] from
/// `portal_credential.dart`. Conversion helpers are provided below.
enum PortalEndpoint {
  itd(
    displayName: 'Income Tax Department',
    baseUrl: String.fromEnvironment(
      'ITD_API_BASE_URL',
      defaultValue: 'https://eportal.incometax.gov.in',
    ),
    defaultTimeoutSeconds: 30,
  ),
  gstn(
    displayName: 'GST Network',
    baseUrl: String.fromEnvironment(
      'GSTN_API_BASE_URL',
      defaultValue: 'https://api.gstn.gov.in',
    ),
    defaultTimeoutSeconds: 30,
  ),
  traces(
    displayName: 'TRACES',
    baseUrl: String.fromEnvironment(
      'TRACES_API_BASE_URL',
      defaultValue: 'https://www.tdscpc.gov.in',
    ),
    defaultTimeoutSeconds: 45,
  ),
  mca(
    displayName: 'Ministry of Corporate Affairs',
    baseUrl: String.fromEnvironment(
      'MCA_API_BASE_URL',
      defaultValue: 'https://api.mca.gov.in',
    ),
    defaultTimeoutSeconds: 30,
  ),
  epfo(
    displayName: 'EPFO',
    baseUrl: String.fromEnvironment(
      'EPFO_API_BASE_URL',
      defaultValue: 'https://unifiedportal-emp.epfindia.gov.in',
    ),
    defaultTimeoutSeconds: 30,
  );

  const PortalEndpoint({
    required this.displayName,
    required this.baseUrl,
    required this.defaultTimeoutSeconds,
  });

  /// Human-readable portal name for UI and logs.
  final String displayName;

  /// Default base URL for the portal API.
  final String baseUrl;

  /// Default request timeout in seconds.
  final int defaultTimeoutSeconds;
}
