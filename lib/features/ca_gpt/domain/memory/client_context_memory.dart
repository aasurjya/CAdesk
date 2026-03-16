/// Auto-loaded client context for personalized agent responses.
class ClientContextMemory {
  const ClientContextMemory({
    this.clientName,
    this.pan,
    this.assessmentYear,
    this.filingStatus,
    this.openNoticesCount = 0,
    this.lastFilingDate,
  });

  static const empty = ClientContextMemory();

  final String? clientName;
  final String? pan;
  final String? assessmentYear;
  final String? filingStatus;
  final int openNoticesCount;
  final DateTime? lastFilingDate;

  bool get hasContext => clientName != null || pan != null;

  /// Formats the context as a system prompt snippet.
  String toPromptContext() {
    if (!hasContext) return '';

    final buffer = StringBuffer();
    buffer.writeln('Current client context:');
    if (clientName != null) buffer.writeln('- Name: $clientName');
    if (pan != null) buffer.writeln('- PAN: $pan');
    if (assessmentYear != null) buffer.writeln('- AY: $assessmentYear');
    if (filingStatus != null) buffer.writeln('- Filing status: $filingStatus');
    if (openNoticesCount > 0) {
      buffer.writeln('- Open notices: $openNoticesCount');
    }
    if (lastFilingDate != null) {
      buffer.writeln(
        '- Last filing: ${lastFilingDate!.toIso8601String().split("T").first}',
      );
    }
    return buffer.toString();
  }

  ClientContextMemory copyWith({
    String? clientName,
    String? pan,
    String? assessmentYear,
    String? filingStatus,
    int? openNoticesCount,
    DateTime? lastFilingDate,
  }) {
    return ClientContextMemory(
      clientName: clientName ?? this.clientName,
      pan: pan ?? this.pan,
      assessmentYear: assessmentYear ?? this.assessmentYear,
      filingStatus: filingStatus ?? this.filingStatus,
      openNoticesCount: openNoticesCount ?? this.openNoticesCount,
      lastFilingDate: lastFilingDate ?? this.lastFilingDate,
    );
  }
}
