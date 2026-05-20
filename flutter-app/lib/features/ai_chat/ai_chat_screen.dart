import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/glass_card.dart';
import '../../providers/ai_chat_provider.dart';

// Outer build is static — _ChatHeader and _SuggestedPanel never rebuild
class AiChatScreen extends ConsumerStatefulWidget {
  const AiChatScreen({super.key});

  @override
  ConsumerState<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends ConsumerState<AiChatScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();

  static const _suggested = [
    'What is BTC doing right now?',
    'Is now a good time to buy ETH?',
    'Explain the current funding rates',
    'What happened to SOL today?',
    'Show me historical patterns similar to today',
    'Is the market in a bull or bear phase?',
  ];

  void _send(String text) {
    ref.read(aiChatProvider).send(text);
    _controller.clear();
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
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: Row(
        children: [
          // Chat area — header and input are static; only the list rebuilds
          Expanded(
            child: Column(
              children: [
                const _ChatHeader(),
                // Rebuilds only when messages or isTyping changes
                Expanded(
                  child: Consumer(
                    builder: (_, ref, __) {
                      final messages = ref.watch(
                        aiChatProvider.select((n) => n.messages),
                      );
                      final isTyping = ref.watch(
                        aiChatProvider.select((n) => n.isTyping),
                      );
                      return ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(20),
                        itemCount: messages.length + (isTyping ? 1 : 0),
                        itemBuilder: (_, i) {
                          if (i == messages.length) {
                            return const _TypingIndicator();
                          }
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: _ChatMessage(message: messages[i]),
                          );
                        },
                      );
                    },
                  ),
                ),
                _ChatInput(controller: _controller, onSend: _send),
              ],
            ),
          ),

          // Suggested sidebar — fully static
          Container(
            width: 260,
            decoration: const BoxDecoration(
              color: AppColors.bgSecondary,
              border: Border(left: BorderSide(color: AppColors.borderSubtle)),
            ),
            child: _SuggestedPanel(
              prompts: _suggested,
              onTap: _send,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}

class _ChatHeader extends StatelessWidget {
  const _ChatHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.borderSubtle)),
      ),
      child: Row(
        children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              gradient: AppColors.gradientGreen,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.psychology_rounded, color: Colors.black, size: 18),
          ),
          const SizedBox(width: 10),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('AI Trading Copilot', style: TextStyle(
                fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white,
              )),
              Text('GPT-4 · RAG-powered · News-aware', style: TextStyle(
                fontSize: 10, color: AppColors.textMuted,
              )),
            ],
          ),
          const Spacer(),
          NeonBadge(label: 'Online', color: AppColors.brandGreen, icon: Icons.circle),
        ],
      ),
    );
  }
}

class _ChatMessage extends StatelessWidget {
  final ChatMessage message;
  const _ChatMessage({required this.message});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!message.isUser) ...[
          Container(
            width: 32, height: 32,
            decoration: BoxDecoration(
              gradient: AppColors.gradientGreen,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.psychology_rounded, color: Colors.black, size: 15),
          ),
          const SizedBox(width: 8),
        ],
        Flexible(
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: message.isUser
                  ? AppColors.brandGreen.withAlpha(20)
                  : AppColors.bgCard,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(12),
                topRight: const Radius.circular(12),
                bottomLeft: Radius.circular(message.isUser ? 12 : 2),
                bottomRight: Radius.circular(message.isUser ? 2 : 12),
              ),
              border: Border.all(
                color: message.isUser
                    ? AppColors.brandGreen.withAlpha(30)
                    : AppColors.borderSubtle,
              ),
            ),
            child: Text(
              message.text,
              style: const TextStyle(
                fontSize: 13, color: Color(0xCCFFFFFF), height: 1.6,
              ),
            ),
          ),
        ),
        if (message.isUser) const SizedBox(width: 8),
      ],
    );
  }
}

// Must stay StatefulWidget — uses AnimationController with TickerProvider
class _TypingIndicator extends StatefulWidget {
  const _TypingIndicator();

  @override
  State<_TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<_TypingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 800))
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 32, height: 32,
          decoration: BoxDecoration(
            gradient: AppColors.gradientGreen,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.psychology_rounded, color: Colors.black, size: 15),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.bgCard,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.borderSubtle),
          ),
          child: AnimatedBuilder(
            animation: _c,
            builder: (_, __) => Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(3, (i) => Container(
                width: 6, height: 6,
                margin: const EdgeInsets.symmetric(horizontal: 2),
                decoration: BoxDecoration(
                  color: AppColors.brandGreen.withAlpha(
                    (100 + 100 * ((_c.value + i * 0.3) % 1.0)).toInt(),
                  ),
                  shape: BoxShape.circle,
                ),
              )),
            ),
          ),
        ),
      ],
    );
  }
}

class _ChatInput extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onSend;
  const _ChatInput({required this.controller, required this.onSend});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.borderSubtle)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.bgCard,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.borderSubtle),
              ),
              child: TextField(
                controller: controller,
                style: const TextStyle(fontSize: 14, color: Colors.white),
                onSubmitted: onSend,
                decoration: const InputDecoration(
                  hintText: 'Ask anything about crypto markets...',
                  hintStyle: TextStyle(color: AppColors.textDisabled, fontSize: 14),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                  isDense: true,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: () => onSend(controller.text),
            child: Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                gradient: AppColors.gradientGreen,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [BoxShadow(
                  color: AppColors.brandGreen.withAlpha(80),
                  blurRadius: 12, offset: const Offset(0, 4),
                )],
              ),
              child: const Icon(Icons.send_rounded, color: Colors.black, size: 18),
            ),
          ),
        ],
      ),
    );
  }
}

class _SuggestedPanel extends StatelessWidget {
  final List<String> prompts;
  final ValueChanged<String> onTap;
  const _SuggestedPanel({required this.prompts, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(16),
          child: Text('Suggested Prompts', style: TextStyle(
            fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textMuted,
          )),
        ),
        ...prompts.map((p) => GestureDetector(
          onTap: () => onTap(p),
          child: Container(
            margin: const EdgeInsets.fromLTRB(12, 0, 12, 6),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.bgCard,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.borderSubtle),
            ),
            child: Row(
              children: [
                Expanded(child: Text(p, style: const TextStyle(
                  fontSize: 12, color: AppColors.textMuted,
                ))),
                const Icon(Icons.arrow_forward_rounded, size: 14,
                    color: AppColors.textDisabled),
              ],
            ),
          ),
        )),
      ],
    );
  }
}
