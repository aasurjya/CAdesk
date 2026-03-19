import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ca_app/core/theme/app_colors.dart';

// ---------------------------------------------------------------------------
// Domain types
// ---------------------------------------------------------------------------

enum _MessageRole { user, assistant }

class _Citation {
  const _Citation({required this.source, required this.reference});

  final String source;
  final String reference;
}

class _ChatMessage {
  const _ChatMessage({
    required this.role,
    required this.content,
    this.citations = const [],
  });

  final _MessageRole role;
  final String content;
  final List<_Citation> citations;
}

class _QuickPrompt {
  const _QuickPrompt({required this.label, required this.query});

  final String label;
  final String query;
}

// ---------------------------------------------------------------------------
// Mock data
// ---------------------------------------------------------------------------

const _mockQuickPrompts = <_QuickPrompt>[
  _QuickPrompt(
    label: 'Section 80C limits',
    query: 'What are the deduction limits under Section 80C?',
  ),
  _QuickPrompt(
    label: 'HRA exemption',
    query: 'How to calculate HRA exemption under Section 10(13A)?',
  ),
  _QuickPrompt(
    label: 'TDS on salary',
    query: 'TDS rates on salary for AY 2026-27',
  ),
  _QuickPrompt(
    label: 'Capital gains',
    query: 'Short-term vs long-term capital gains tax rates',
  ),
];

final _mockConversation = <_ChatMessage>[
  const _ChatMessage(
    role: _MessageRole.user,
    content: 'What is the maximum deduction under Section 80C for AY 2026-27?',
  ),
  const _ChatMessage(
    role: _MessageRole.assistant,
    content:
        'Under Section 80C of the Income Tax Act, 1961, the maximum deduction allowed is Rs. 1,50,000 per financial year for AY 2026-27.\n\n'
        'Eligible investments include:\n'
        '- PPF, EPF, and VPF contributions\n'
        '- ELSS mutual funds (3-year lock-in)\n'
        '- Life insurance premiums\n'
        '- NSC and tax-saver FDs (5-year lock-in)\n'
        '- Tuition fees for children (up to 2)\n'
        '- Principal repayment on home loan',
    citations: [
      _Citation(source: 'IT Act 1961', reference: 'Section 80C'),
      _Citation(
        source: 'Finance Act 2025',
        reference: 'No revision to 80C limit',
      ),
      _Citation(source: 'CBDT Circular', reference: 'Circular 04/2025'),
    ],
  ),
  const _ChatMessage(
    role: _MessageRole.user,
    content: 'Is NPS included in 80C or separate?',
  ),
  const _ChatMessage(
    role: _MessageRole.assistant,
    content:
        'NPS has a dual benefit:\n\n'
        '1. **Section 80CCD(1)**: Employee contribution up to 10% of salary is part of the 80C umbrella (within Rs. 1.5L limit)\n\n'
        '2. **Section 80CCD(1B)**: Additional deduction of Rs. 50,000 over and above the 80C limit\n\n'
        'So an employee can claim up to Rs. 2,00,000 total (1.5L under 80C + 50K under 80CCD(1B)).',
    citations: [
      _Citation(source: 'IT Act 1961', reference: 'Section 80CCD(1)'),
      _Citation(source: 'IT Act 1961', reference: 'Section 80CCD(1B)'),
    ],
  ),
];

final _mockHistory = <String>[
  'Section 80C deductions',
  'GST return filing dates',
  'TDS on professional fees',
  'Advance tax due dates FY 2025-26',
];

// ---------------------------------------------------------------------------
// Screen
// ---------------------------------------------------------------------------

/// Chat interface for CA GPT — a tax law RAG assistant.
class CaGptChatScreen extends ConsumerStatefulWidget {
  const CaGptChatScreen({super.key});

  @override
  ConsumerState<CaGptChatScreen> createState() => _CaGptChatScreenState();
}

class _CaGptChatScreenState extends ConsumerState<CaGptChatScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  var _messages = List<_ChatMessage>.of(_mockConversation);

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage(String text) {
    if (text.trim().isEmpty) return;
    setState(() {
      _messages = [
        ..._messages,
        _ChatMessage(role: _MessageRole.user, content: text.trim()),
      ];
    });
    _controller.clear();
    // Scroll to bottom after frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final messages = _messages;
    final theme = Theme.of(context);
    final isWide = MediaQuery.sizeOf(context).width > 720;

    return Scaffold(
      backgroundColor: AppColors.neutral50,
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.primary.withAlpha(18),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.auto_awesome,
                size: 20,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'CA GPT',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppColors.neutral900,
                  ),
                ),
                Text(
                  'PAN: ABCDE1234F  |  AY 2026-27',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: AppColors.secondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      body: Row(
        children: [
          // Sidebar (tablet/desktop)
          if (isWide)
            SizedBox(width: 220, child: _HistorySidebar(history: _mockHistory)),

          // Chat area
          Expanded(
            child: Column(
              children: [
                // Quick prompts
                _QuickPromptsRow(
                  prompts: _mockQuickPrompts,
                  onTap: (q) => _sendMessage(q.query),
                ),

                // Messages
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                    itemCount: messages.length,
                    itemBuilder: (context, index) =>
                        _MessageBubble(message: messages[index]),
                  ),
                ),

                // Input
                _ChatInput(
                  controller: _controller,
                  onSend: () => _sendMessage(_controller.text),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Message bubble
// ---------------------------------------------------------------------------

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message});

  final _ChatMessage message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isUser = message.role == _MessageRole.user;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.all(14),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * 0.78,
        ),
        decoration: BoxDecoration(
          color: isUser ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: isUser ? null : Border.all(color: AppColors.neutral200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message.content,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isUser ? Colors.white : AppColors.neutral900,
                height: 1.5,
              ),
            ),
            if (message.citations.isNotEmpty) ...[
              const SizedBox(height: 10),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: message.citations
                    .map((c) => _CitationChip(citation: c))
                    .toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Citation chip
// ---------------------------------------------------------------------------

class _CitationChip extends StatelessWidget {
  const _CitationChip({required this.citation});

  final _Citation citation;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.secondary.withAlpha(18),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.secondary.withAlpha(40)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.link_rounded, size: 12, color: AppColors.secondary),
          const SizedBox(width: 4),
          Text(
            '${citation.source}: ${citation.reference}',
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.secondary,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Quick prompts
// ---------------------------------------------------------------------------

class _QuickPromptsRow extends StatelessWidget {
  const _QuickPromptsRow({required this.prompts, required this.onTap});

  final List<_QuickPrompt> prompts;
  final ValueChanged<_QuickPrompt> onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        itemCount: prompts.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final p = prompts[index];
          return ActionChip(
            label: Text(p.label),
            onPressed: () => onTap(p),
            labelStyle: const TextStyle(fontSize: 12),
            side: BorderSide(color: AppColors.primary.withAlpha(40)),
          );
        },
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Chat input
// ---------------------------------------------------------------------------

class _ChatInput extends StatelessWidget {
  const _ChatInput({required this.controller, required this.onSend});

  final TextEditingController controller;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 8, 16),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.neutral100)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: 'Ask about tax law, sections, circulars...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: const BorderSide(color: AppColors.neutral200),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
              ),
              onSubmitted: (_) => onSend(),
            ),
          ),
          const SizedBox(width: 8),
          IconButton.filled(
            onPressed: onSend,
            icon: const Icon(Icons.send_rounded),
            style: IconButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// History sidebar
// ---------------------------------------------------------------------------

class _HistorySidebar extends StatelessWidget {
  const _HistorySidebar({required this.history});

  final List<String> history;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(right: BorderSide(color: AppColors.neutral100)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              'History',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.neutral900,
              ),
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 4),
              itemCount: history.length,
              itemBuilder: (context, index) {
                return ListTile(
                  dense: true,
                  leading: const Icon(
                    Icons.chat_bubble_outline_rounded,
                    size: 16,
                    color: AppColors.neutral400,
                  ),
                  title: Text(
                    history[index],
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.neutral600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  onTap: () {},
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
