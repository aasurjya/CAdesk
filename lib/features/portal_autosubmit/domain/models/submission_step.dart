/// Represents each discrete stage of a portal auto-submission workflow.
enum SubmissionStep {
  pending('Pending'),
  loggingIn('Logging In'),
  filling('Filling Form'),
  otp('OTP Required'),
  submitting('Submitting'),
  downloading('Downloading Ack'),
  done('Done'),
  failed('Failed');

  const SubmissionStep(this.label);

  /// Human-readable label for display in the UI.
  final String label;
}
