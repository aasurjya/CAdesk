import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ca_app/features/ca_gpt/domain/models/knowledge_article.dart';
import 'package:ca_app/features/ca_gpt/domain/models/notice_draft.dart';
import 'package:ca_app/features/ca_gpt/domain/services/notice_drafting_service.dart';
import 'package:ca_app/features/ca_gpt/domain/services/section_lookup_service.dart';
import 'package:ca_app/features/ca_gpt/domain/services/tax_calendar_service.dart';

// ---------------------------------------------------------------------------
// Service providers (static classes — placeholder providers for DI seams)
// ---------------------------------------------------------------------------

/// Placeholder provider for SectionLookupService.
/// Since the service uses only static methods, call them directly in code.
final sectionLookupProvider = Provider<SectionLookupService>((_) {
  throw UnimplementedError(
    'SectionLookupService uses static methods — '
    'call SectionLookupService.lookupSection() directly.',
  );
});

/// Placeholder provider for NoticeDraftingService.
/// Since the service uses only static methods, call them directly in code.
final noticeDraftingProvider = Provider<NoticeDraftingService>((_) {
  throw UnimplementedError(
    'NoticeDraftingService uses static methods — '
    'call NoticeDraftingService.draftReply() directly.',
  );
});

/// Placeholder provider for TaxCalendarService.
/// Since the service uses only static methods, call them directly in code.
final taxCalendarServiceProvider = Provider<TaxCalendarService>((_) {
  throw UnimplementedError(
    'TaxCalendarService uses static methods — '
    'call TaxCalendarService.getDeadlines() directly.',
  );
});

// ---------------------------------------------------------------------------
// Chat message model
// ---------------------------------------------------------------------------

/// An immutable chat message within the CA GPT chat session.
class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.text,
    required this.isUser,
    required this.at,
  });

  final String id;
  final String text;
  final bool isUser;
  final DateTime at;

  ChatMessage copyWith({
    String? id,
    String? text,
    bool? isUser,
    DateTime? at,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      text: text ?? this.text,
      isUser: isUser ?? this.isUser,
      at: at ?? this.at,
    );
  }
}

// ---------------------------------------------------------------------------
// Chat notifier
// ---------------------------------------------------------------------------

/// Notifier managing the list of chat messages in the CA GPT session.
class ChatNotifier extends Notifier<List<ChatMessage>> {
  @override
  List<ChatMessage> build() => List.unmodifiable([
    ChatMessage(
      id: 'welcome',
      text:
          'Hello! I am CA GPT. Ask me about any tax section, notice reply, or compliance deadline.',
      isUser: false,
      at: DateTime(2026, 1, 1),
    ),
  ]);

  void addMessage(ChatMessage message) {
    state = List.unmodifiable([...state, message]);
  }

  void clearHistory() {
    state = const [];
  }
}

/// Provider for the list of chat messages.
final chatMessagesProvider =
    NotifierProvider<ChatNotifier, List<ChatMessage>>(ChatNotifier.new);

// ---------------------------------------------------------------------------
// Section search results
// ---------------------------------------------------------------------------

/// Holds the current section-search result list.
final sectionSearchResultsProvider =
    NotifierProvider<_SectionSearchNotifier, List<KnowledgeArticle>>(
      _SectionSearchNotifier.new,
    );

class _SectionSearchNotifier extends Notifier<List<KnowledgeArticle>> {
  @override
  List<KnowledgeArticle> build() => const [];

  void update(List<KnowledgeArticle> results) {
    state = List.unmodifiable(results);
  }
}

// ---------------------------------------------------------------------------
// Notice draft
// ---------------------------------------------------------------------------

/// Notifier for the currently generated notice draft (null if none).
class _NoticeDraftNotifier extends Notifier<NoticeDraft?> {
  @override
  NoticeDraft? build() => null;

  void update(NoticeDraft? draft) {
    state = draft;
  }
}

/// Provider holding the currently generated [NoticeDraft], or null.
final noticeDraftProvider =
    NotifierProvider<_NoticeDraftNotifier, NoticeDraft?>(
      _NoticeDraftNotifier.new,
    );

// ---------------------------------------------------------------------------
// Calendar events notifier (TaxDeadline list for FY)
// ---------------------------------------------------------------------------

/// Notifier managing the list of [TaxDeadline] events for the visible FY.
class CalendarNotifier extends Notifier<List<TaxDeadline>> {
  @override
  List<TaxDeadline> build() {
    // Current FY 2025-26 (starting year 2025).
    return List.unmodifiable(TaxCalendarService.getDeadlines(2025));
  }

  void loadYear(int financialYear) {
    state = List.unmodifiable(TaxCalendarService.getDeadlines(financialYear));
  }
}

/// Provider for tax calendar events.
final calendarEventsProvider =
    NotifierProvider<CalendarNotifier, List<TaxDeadline>>(CalendarNotifier.new);

// ---------------------------------------------------------------------------
// Selected calendar month (for filtering)
// ---------------------------------------------------------------------------

/// Notifier for the currently viewed calendar month.
class _SelectedMonthNotifier extends Notifier<DateTime> {
  @override
  DateTime build() =>
      DateTime(DateTime.now().year, DateTime.now().month);

  void update(DateTime month) {
    state = month;
  }
}

/// Provider for the selected calendar month (year + month only).
final selectedCalendarMonthProvider =
    NotifierProvider<_SelectedMonthNotifier, DateTime>(
      _SelectedMonthNotifier.new,
    );
