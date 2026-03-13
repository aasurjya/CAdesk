import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/features/ca_gpt/data/providers/ca_gpt_providers.dart';
import 'package:ca_app/features/ca_gpt/presentation/widgets/chat_bubble.dart';

/// The conversational CA GPT chat interface.
class CaGptChatScreen extends ConsumerStatefulWidget {
  const CaGptChatScreen({super.key});

  @override
  ConsumerState<CaGptChatScreen> createState() => _CaGptChatScreenState();
}

class _CaGptChatScreenState extends ConsumerState<CaGptChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isTyping = false;

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    _controller.clear();
    final now = DateTime.now();
    final userMsg = ChatMessage(
      id: 'user_${now.microsecondsSinceEpoch}',
      text: text,
      isUser: true,
      at: now,
    );

    ref.read(chatMessagesProvider.notifier).addMessage(userMsg);
    setState(() => _isTyping = true);
    _scrollToBottom();

    // Simulate assistant thinking delay
    await Future<void>.delayed(const Duration(milliseconds: 300));

    final reply = _buildMockReply(text);
    final assistantMsg = ChatMessage(
      id: 'bot_${DateTime.now().microsecondsSinceEpoch}',
      text: reply,
      isUser: false,
      at: DateTime.now(),
    );

    if (mounted) {
      ref.read(chatMessagesProvider.notifier).addMessage(assistantMsg);
      setState(() => _isTyping = false);
      _scrollToBottom();
    }
  }

  String _buildMockReply(String query) {
    final q = query.toLowerCase();
    if (q.contains('194c')) {
      return 'Section 194C requires TDS deduction on payments to contractors/sub-contractors. '
          'Rate is 1% for individuals/HUF and 2% for others. Threshold is ₹30,000 per payment '
          'or ₹1 lakh aggregate per year. Transport contractors with PAN may furnish 15I/15J for nil deduction.';
    }
    if (q.contains('80c')) {
      return 'Section 80C allows deductions up to ₹1.5 lakh for investments in PPF, ELSS, LIC premiums, '
          'NSC, home loan principal, and more. This deduction is only available under the old tax regime. '
          'ELSS has the shortest lock-in period of 3 years among 80C instruments.';
    }
    if (q.contains('gst') || q.contains('gstr')) {
      return 'For GST compliance, GSTR-1 is due on the 11th and GSTR-3B on the 20th of the following month '
          'for monthly filers. Quarterly filers follow QRMP scheme with IFF for B2B invoices. '
          'GSTR-9 annual return is due by December 31 of the following FY.';
    }
    if (q.contains('tds') || q.contains('194')) {
      return 'TDS must be deposited by the 7th of the following month (except March, '
          'where the deadline is April 30). Quarterly returns (24Q, 26Q) are due on the '
          '31st of the month following each quarter. Non-deduction attracts interest at 1%/1.5% per month.';
    }
    if (q.contains('notice') || q.contains('143')) {
      return 'For a 143(1) intimation, verify the computation against your ITR filed. '
          'Common discrepancies include TDS mismatch with 26AS, disallowed deductions, or '
          'incorrect income heads. Use the Notice Drafting tab to generate a formal reply.';
    }
    if (q.contains('deadline') ||
        q.contains('due date') ||
        q.contains('calendar')) {
      return 'Key upcoming deadlines: ITR filing for non-audit cases is July 31 (AY 2026-27). '
          'Monthly TDS deposit is the 7th of each month. GSTR-1 is the 11th and GSTR-3B is '
          'the 20th. Check the Tax Calendar tab for your complete compliance schedule.';
    }
    return 'Based on the Indian tax framework, your query about "$query" touches on several provisions. '
        'For a detailed analysis, please use the Section Lookup tab to search specific provisions, '
        'or the Notice Drafting tab for formal correspondence. I am here to assist with any '
        'Income Tax, GST, TDS, or compliance-related questions.';
  }

  void _scrollToBottom() {
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
    final messages = ref.watch(chatMessagesProvider);
    final theme = Theme.of(context);

    return Column(
      children: [
        Expanded(
          child: messages.isEmpty
              ? _EmptyState()
              : ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  itemCount: messages.length + (_isTyping ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (_isTyping && index == messages.length) {
                      return _TypingIndicator();
                    }
                    return ChatBubble(message: messages[index]);
                  },
                ),
        ),
        _InputBar(controller: _controller, onSend: _sendMessage, theme: theme),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.auto_awesome,
              size: 56,
              color: AppColors.secondary.withAlpha(180),
            ),
            const SizedBox(height: 16),
            Text(
              'CA GPT',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
                color: AppColors.neutral900,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Ask about any tax section, notice, or compliance deadline',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.neutral400,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _TypingIndicator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
              color: AppColors.secondary,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.auto_awesome,
              size: 16,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.neutral100,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _Dot(delay: 0),
                SizedBox(width: 4),
                _Dot(delay: 150),
                SizedBox(width: 4),
                _Dot(delay: 300),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot({required this.delay});

  final int delay;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 6,
      height: 6,
      decoration: const BoxDecoration(
        color: AppColors.neutral400,
        shape: BoxShape.circle,
      ),
    );
  }
}

class _InputBar extends StatelessWidget {
  const _InputBar({
    required this.controller,
    required this.onSend,
    required this.theme,
  });

  final TextEditingController controller;
  final VoidCallback onSend;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.neutral200)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                decoration: InputDecoration(
                  hintText: 'Ask about any tax section, notice, or deadline…',
                  hintStyle: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.neutral400,
                  ),
                  filled: true,
                  fillColor: AppColors.neutral50,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: const BorderSide(color: AppColors.neutral200),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: const BorderSide(color: AppColors.neutral200),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: const BorderSide(
                      color: AppColors.primary,
                      width: 1.5,
                    ),
                  ),
                ),
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => onSend(),
                maxLines: 3,
                minLines: 1,
              ),
            ),
            const SizedBox(width: 8),
            FilledButton(
              onPressed: onSend,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: const CircleBorder(),
                padding: const EdgeInsets.all(12),
              ),
              child: const Icon(Icons.send_rounded, size: 20),
            ),
          ],
        ),
      ),
    );
  }
}
