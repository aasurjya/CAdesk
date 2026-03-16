import 'package:ca_app/core/ai/gateway/ai_gateway.dart';
import 'package:ca_app/core/ai/models/ai_request.dart';
import 'package:ca_app/core/ai/models/ai_response.dart';
import 'package:ca_app/core/ai/models/ai_usage.dart';

/// Deterministic mock adapter for testing and offline fallback.
///
/// Returns canned responses based on keyword matching.
class MockAiAdapter implements AiGateway {
  const MockAiAdapter();

  @override
  Future<AiResponse> complete(AiRequest request) async {
    final lastUserMessage =
        request.messages
            .where((m) => m.role.name == 'user')
            .lastOrNull
            ?.content ??
        '';

    final reply = _generateReply(lastUserMessage);

    return AiResponse(
      content: reply,
      usage: const AiUsage(
        promptTokens: 50,
        completionTokens: 100,
        estimatedCostUsd: 0.0,
      ),
    );
  }

  @override
  Stream<AiResponse> streamComplete(AiRequest request) async* {
    final response = await complete(request);
    // Simulate streaming by yielding word by word
    final words = response.content.split(' ');
    final buffer = StringBuffer();
    for (final word in words) {
      if (buffer.isNotEmpty) buffer.write(' ');
      buffer.write(word);
      yield AiResponse(content: buffer.toString(), usage: AiUsage.zero);
      await Future<void>.delayed(const Duration(milliseconds: 20));
    }
    yield response;
  }

  @override
  Future<List<double>> embed(String text) async {
    // Return a deterministic 384-dimensional mock embedding.
    return List<double>.generate(
      384,
      (i) => (text.hashCode * (i + 1) % 1000) / 1000.0,
    );
  }

  @override
  Future<bool> isAvailable() async => true;

  String _generateReply(String query) {
    final q = query.toLowerCase();
    if (q.contains('194c')) {
      return 'Section 194C requires TDS deduction on payments to contractors/'
          'sub-contractors. Rate is 1% for individuals/HUF and 2% for others. '
          'Threshold is ₹30,000 per payment or ₹1 lakh aggregate per year.';
    }
    if (q.contains('80c')) {
      return 'Section 80C allows deductions up to ₹1.5 lakh for investments '
          'in PPF, ELSS, LIC premiums, NSC, home loan principal, and more. '
          'This deduction is only available under the old tax regime.';
    }
    if (q.contains('gst') || q.contains('gstr')) {
      return 'For GST compliance, GSTR-1 is due on the 11th and GSTR-3B on '
          'the 20th of the following month for monthly filers.';
    }
    if (q.contains('tds') || q.contains('194')) {
      return 'TDS must be deposited by the 7th of the following month. '
          'Quarterly returns (24Q, 26Q) are due on the 31st of the month '
          'following each quarter.';
    }
    return 'Based on the Indian tax framework, your query touches on several '
        'provisions. For a detailed analysis, please provide a specific '
        'section number or topic.';
  }
}
