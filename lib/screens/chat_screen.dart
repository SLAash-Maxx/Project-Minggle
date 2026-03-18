// lib/screens/chat_screen.dart
// Full chat section: list of conversations + individual chat view.

import 'package:flutter/material.dart';
import '../models/app_data.dart';

// ── Chat list (main chat tab) ──────────────────────────────────────────────────
class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _state = AppState.instance;

  @override
  Widget build(BuildContext context) {
    final conversations = _state.conversations;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F0F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        title: const Text(
          'Messages',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A1A2E),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search_rounded, color: Color(0xFFE91E8C)),
            onPressed: () {},
          ),
        ],
      ),
      body: conversations.isEmpty
          ? _EmptyChats()
          : Column(
              children: [
                // ── Matches row (liked profiles) ─────────────────────────
                _MatchesRow(),
                const Divider(height: 1),

                // ── Conversation list ─────────────────────────────────────
                Expanded(
                  child: ListView.builder(
                    itemCount: conversations.length,
                    itemBuilder: (context, index) {
                      return _ConversationTile(
                        conversation: conversations[index],
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => _ChatDetailScreen(
                                conversation: conversations[index],
                              ),
                            ),
                          );
                          setState(() {}); // refresh last message
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}

// ── Horizontal matches row ────────────────────────────────────────────────────
class _MatchesRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final liked = AppState.instance.likedProfiles;
    if (liked.isEmpty) return const SizedBox.shrink();

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Your Likes',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: Color(0xFF9B59B6),
              ),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 80,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: liked.length,
              itemBuilder: (ctx, i) => _MatchAvatar(profile: liked[i]),
            ),
          ),
        ],
      ),
    );
  }
}

class _MatchAvatar extends StatelessWidget {
  final UserProfile profile;
  const _MatchAvatar({required this.profile});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [Color(0xFFE91E8C), Color(0xFF7B2FF7)],
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFE91E8C).withOpacity(0.3),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ],
            ),
            padding: const EdgeInsets.all(2),
            child: CircleAvatar(
              radius: 26,
              backgroundImage: NetworkImage(profile.imageUrl),
              onBackgroundImageError: (_, __) {},
              backgroundColor: const Color(0xFFEEE0FF),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            profile.name,
            style: const TextStyle(fontSize: 11, color: Color(0xFF1A1A2E)),
          ),
        ],
      ),
    );
  }
}

// ── Single conversation tile ──────────────────────────────────────────────────
class _ConversationTile extends StatelessWidget {
  final Conversation conversation;
  final VoidCallback onTap;

  const _ConversationTile({required this.conversation, required this.onTap});

  String _formatTime(DateTime? dt) {
    if (dt == null) return '';
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    return '${diff.inDays}d';
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      leading: CircleAvatar(
        radius: 28,
        backgroundImage: NetworkImage(conversation.user.imageUrl),
        onBackgroundImageError: (_, __) {},
        backgroundColor: const Color(0xFFEEE0FF),
      ),
      title: Text(
        conversation.user.name,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 15,
          color: Color(0xFF1A1A2E),
        ),
      ),
      subtitle: Text(
        conversation.lastMessage,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(fontSize: 13, color: Colors.grey[600]),
      ),
      trailing: Text(
        _formatTime(conversation.lastTime),
        style: TextStyle(fontSize: 12, color: Colors.grey[500]),
      ),
      onTap: onTap,
    );
  }
}

// ── Empty state ───────────────────────────────────────────────────────────────
class _EmptyChats extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              color: const Color(0xFFF0E6FF),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.chat_bubble_outline_rounded,
                size: 44, color: Color(0xFF7B2FF7)),
          ),
          const SizedBox(height: 16),
          const Text('No messages yet',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E))),
          const SizedBox(height: 6),
          Text('Start liking profiles to match!',
              style: TextStyle(fontSize: 14, color: Colors.grey[500])),
        ],
      ),
    );
  }
}

// ── Individual chat detail screen ─────────────────────────────────────────────
class _ChatDetailScreen extends StatefulWidget {
  final Conversation conversation;
  const _ChatDetailScreen({required this.conversation});

  @override
  State<_ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<_ChatDetailScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    setState(() {
      widget.conversation.messages.add(
        ChatMessage(text: text, isMe: true, timestamp: DateTime.now()),
      );
      _controller.clear();
    });
    Future.delayed(const Duration(milliseconds: 100), () {
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
    final user = widget.conversation.user;
    final messages = widget.conversation.messages;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F0F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF1A1A2E), size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        titleSpacing: 0,
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundImage: NetworkImage(user.imageUrl),
              onBackgroundImageError: (_, __) {},
              backgroundColor: const Color(0xFFEEE0FF),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1A2E),
                  ),
                ),
                const Text(
                  'Active recently',
                  style: TextStyle(fontSize: 11, color: Colors.green),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.videocam_rounded, color: Color(0xFFE91E8C)),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.more_vert_rounded, color: Color(0xFF1A1A2E)),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // Messages list
          Expanded(
            child: messages.isEmpty
                ? Center(
                    child: Text(
                      'Say hi to ${user.name}! 👋',
                      style: TextStyle(color: Colors.grey[500], fontSize: 14),
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    itemCount: messages.length,
                    itemBuilder: (ctx, i) => _MessageBubble(message: messages[i]),
                  ),
          ),

          // Input bar
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: SafeArea(
              top: false,
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline_rounded,
                        color: Color(0xFF7B2FF7), size: 26),
                    onPressed: () {},
                  ),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF4EFF8),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: TextField(
                        controller: _controller,
                        decoration: const InputDecoration(
                          hintText: 'Type a message…',
                          border: InputBorder.none,
                          hintStyle: TextStyle(color: Colors.grey),
                        ),
                        onSubmitted: (_) => _sendMessage(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: _sendMessage,
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [Color(0xFFE91E8C), Color(0xFF7B2FF7)],
                        ),
                      ),
                      child: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Single message bubble ─────────────────────────────────────────────────────
class _MessageBubble extends StatelessWidget {
  final ChatMessage message;
  const _MessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final isMe = message.isMe;
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.72,
        ),
        decoration: BoxDecoration(
          gradient: isMe
              ? const LinearGradient(
                  colors: [Color(0xFFE91E8C), Color(0xFF7B2FF7)],
                )
              : null,
          color: isMe ? null : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: Radius.circular(isMe ? 18 : 4),
            bottomRight: Radius.circular(isMe ? 4 : 18),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          message.text,
          style: TextStyle(
            fontSize: 14,
            color: isMe ? Colors.white : const Color(0xFF1A1A2E),
            height: 1.3,
          ),
        ),
      ),
    );
  }
}
