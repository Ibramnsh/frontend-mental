import 'package:flutter/material.dart';
import '../models/chat_message.dart';
import '../services/chat_service.dart';

class ChatScreen extends StatefulWidget {
  final String sessionId;

  const ChatScreen({super.key, required this.sessionId});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  // Palet Warna
  final Color _primaryColor = const Color(0xFF5B9A8B);
  final Color _backgroundColor = const Color(0xFFF7F9F9);
  final Color _surfaceColor = Colors.white;
  final Color _textColor = const Color(0xFF2D3B38);

  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  List<ChatMessage> _messages = [];
  ChatMode _mode = ChatMode.listening;
  bool _isLoading = false;
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  Future<void> _loadMessages() async {
    setState(() => _isLoading = true);
    final messages = await ChatService.getSessionMessages(widget.sessionId);
    setState(() {
      _messages = messages;
      _isLoading = false;
    });
    Future.delayed(const Duration(milliseconds: 100), _scrollToBottom);
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || _isSending) return;

    _messageController.clear();
    setState(() => _isSending = true);

    final result = await ChatService.sendMessage(text, _mode, widget.sessionId);

    if (result['success']) {
      setState(() {
        _messages.add(result['userMessage']);
        _messages.add(result['aiResponse']);
      });
      _scrollToBottom();
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(result['error'] ?? 'Error'),
              backgroundColor: Colors.red),
        );
      }
    }
    setState(() => _isSending = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        title: Text('AI Companion',
            style: TextStyle(color: _textColor, fontWeight: FontWeight.bold)),
        backgroundColor: _surfaceColor,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded,
              color: _textColor, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            color: Colors.grey.shade100,
            height: 1.0,
          ),
        ),
      ),
      body: Column(
        children: [
          // --- MODE SELECTOR ---
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            color: _surfaceColor,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _ModeChip(
                    label: 'Listening 👂',
                    selected: _mode == ChatMode.listening,
                    primaryColor: _primaryColor,
                    onTap: () => setState(() => _mode = ChatMode.listening)),
                const SizedBox(width: 12),
                _ModeChip(
                    label: 'Solution 💡',
                    selected: _mode == ChatMode.solution,
                    primaryColor: _primaryColor,
                    onTap: () => setState(() => _mode = ChatMode.solution)),
              ],
            ),
          ),

          // --- CHAT MESSAGES ---
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator(color: _primaryColor))
                : _messages.isEmpty
                    ? Center(
                        child: Padding(
                        padding: const EdgeInsets.all(40),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: _primaryColor.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(Icons.spa_rounded,
                                  size: 64, color: _primaryColor),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              'Hello!',
                              style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: _textColor),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'I\'m here to listen without judgment.\nHow are you feeling right now?',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Colors.grey.shade600, height: 1.5),
                            ),
                          ],
                        ),
                      ))
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 20),
                        itemCount: _messages.length,
                        itemBuilder: (ctx, i) => _MessageBubble(
                          message: _messages[i],
                          primaryColor: _primaryColor,
                          textColor: _textColor,
                        ),
                      ),
          ),

          // --- INPUT FIELD ---
          Container(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
            decoration: BoxDecoration(
              color: _surfaceColor,
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 20,
                    offset: const Offset(0, -5))
              ],
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(30)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: _backgroundColor,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: TextField(
                      controller: _messageController,
                      style: TextStyle(color: _textColor),
                      decoration: InputDecoration(
                        hintText: _mode == ChatMode.listening
                            ? 'Share your thoughts...'
                            : 'Ask for advice...',
                        hintStyle: TextStyle(color: Colors.grey.shade400),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 14),
                      ),
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _sendMessage(),
                      enabled: !_isSending,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: _sendMessage,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _isSending ? Colors.grey.shade300 : _primaryColor,
                      shape: BoxShape.circle,
                      boxShadow: _isSending
                          ? null
                          : [
                              BoxShadow(
                                  color: _primaryColor.withOpacity(0.4),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4))
                            ],
                    ),
                    child: _isSending
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white))
                        : const Icon(Icons.arrow_upward_rounded,
                            color: Colors.white, size: 24),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// --- WIDGETS ---

class _ModeChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color primaryColor;

  const _ModeChip({
    required this.label,
    required this.selected,
    required this.onTap,
    required this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
            color: selected ? primaryColor : Colors.transparent,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
                color: selected ? primaryColor : Colors.grey.shade300,
                width: 1.5)),
        child: Text(label,
            style: TextStyle(
                fontSize: 13,
                color: selected ? Colors.white : Colors.grey.shade600,
                fontWeight: FontWeight.bold)),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final Color primaryColor;
  final Color textColor;

  const _MessageBubble({
    required this.message,
    required this.primaryColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(
            top: 8, bottom: 8, left: isUser ? 60 : 0, right: isUser ? 0 : 60),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
            color: isUser ? primaryColor : Colors.white,
            boxShadow: [
              if (!isUser)
                BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 5,
                    offset: const Offset(0, 2))
            ],
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(20),
              topRight: const Radius.circular(20),
              bottomLeft: isUser ? const Radius.circular(20) : Radius.zero,
              bottomRight: isUser ? Radius.zero : const Radius.circular(20),
            )),
        child: Text(
          message.message,
          style: TextStyle(
              color: isUser ? Colors.white : textColor,
              height: 1.4,
              fontSize: 15),
        ),
      ),
    );
  }
}
