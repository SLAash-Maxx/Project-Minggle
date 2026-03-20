import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MessageScreen extends StatefulWidget {
  final String peerUid;
  final String peerName;
  final String peerPic;

  const MessageScreen({
    super.key,
    required this.peerUid,
    required this.peerName,
    required this.peerPic,
  });

  @override
  State<MessageScreen> createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
  final TextEditingController _controller = TextEditingController();
  final String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? "";
  late final String _chatId;
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    _chatId = currentUserId.hashCode <= widget.peerUid.hashCode
        ? "${currentUserId}_${widget.peerUid}"
        : "${widget.peerUid}_$currentUserId";
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _sendRequest() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _sending) return;
    setState(() => _sending = true);
    try {
      final meSnap = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUserId)
          .get();
      final meData = meSnap.data() ?? {};
      await FirebaseFirestore.instance
          .collection('message_requests')
          .doc(_chatId)
          .set({
        'senderId': currentUserId,
        'receiverId': widget.peerUid,
        'senderName': meData['name'] ?? 'User',
        'senderPic': meData['profilePic'] ?? '',
        'receiverName': widget.peerName,
        'receiverPic': widget.peerPic,
        'message': text,
        'timestamp': FieldValue.serverTimestamp(),
        'status': 'pending',
      });
      _controller.clear();
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  Future<void> _acceptRequest(Map<String, dynamic> reqData) async {
    if (_sending) return;
    setState(() => _sending = true);
    try {
      final batch = FirebaseFirestore.instance.batch();
      batch.set(
        FirebaseFirestore.instance.collection('chats').doc(_chatId),
        {'accepted': true, 'acceptedAt': FieldValue.serverTimestamp()},
        SetOptions(merge: true),
      );
      final msgRef = FirebaseFirestore.instance
          .collection('chats')
          .doc(_chatId)
          .collection('messages')
          .doc();
      batch.set(msgRef, {
        'senderId': reqData['senderId'],
        'content': reqData['message'],
        'timestamp': reqData['timestamp'] ?? FieldValue.serverTimestamp(),
      });
      batch.delete(FirebaseFirestore.instance
          .collection('message_requests')
          .doc(_chatId));
      await batch.commit();
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  Future<void> _declineRequest() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF252525),
        title: const Text('Decline request?',
            style: TextStyle(color: Colors.white)),
        content: Text(
          'The message from ${widget.peerName} will be deleted.',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey))),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Decline',
                  style: TextStyle(color: Color(0xFFFF4D6D)))),
        ],
      ),
    );
    if (confirmed != true) return;
    await FirebaseFirestore.instance
        .collection('message_requests')
        .doc(_chatId)
        .delete();
    if (mounted) Navigator.pop(context);
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _sending) return;
    setState(() => _sending = true);
    try {
      await FirebaseFirestore.instance
          .collection('chats')
          .doc(_chatId)
          .collection('messages')
          .add({
        'senderId': currentUserId,
        'content': text,
        'timestamp': FieldValue.serverTimestamp(),
      });
      _controller.clear();
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('message_requests')
          .doc(_chatId)
          .snapshots(),
      builder: (context, reqSnap) {
        if (reqSnap.connectionState == ConnectionState.waiting) {
          return _scaffold(_loadingBody());
        }
        final requestExists =
            reqSnap.hasData && reqSnap.data != null && reqSnap.data!.exists;
        if (requestExists) {
          final reqData = reqSnap.data!.data() as Map<String, dynamic>;
          final isSender = reqData['senderId'] == currentUserId;
          return _scaffold(
            isSender
                ? _requestSentBody(reqData['message'] ?? '')
                : _requestReceivedBody(reqData),
          );
        }
        return StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('chats')
              .doc(_chatId)
              .snapshots(),
          builder: (context, chatSnap) {
            if (chatSnap.connectionState == ConnectionState.waiting) {
              return _scaffold(_loadingBody());
            }
            final accepted = chatSnap.hasData &&
                chatSnap.data != null &&
                chatSnap.data!.exists &&
                ((chatSnap.data!.data() as Map<String, dynamic>? ??
                        {})['accepted']) ==
                    true;
            if (accepted) return _scaffold(_normalChatBody());
            return _scaffold(_firstMessageBody());
          },
        );
      },
    );
  }

  Scaffold _scaffold(Widget body) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A1A),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        titleSpacing: 0,
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: const Color(0xFF333333),
              backgroundImage: widget.peerPic.isNotEmpty
                  ? NetworkImage(widget.peerPic)
                  : null,
              child: widget.peerPic.isEmpty
                  ? const Icon(Icons.person, color: Colors.white54, size: 18)
                  : null,
            ),
            const SizedBox(width: 10),
            Text(widget.peerName,
                style: const TextStyle(color: Colors.white, fontSize: 18)),
          ],
        ),
      ),
      body: body,
    );
  }

  Widget _loadingBody() {
    return const Center(
        child: CircularProgressIndicator(color: Color(0xFFFF4D6D)));
  }

  Widget _firstMessageBody() {
    return Column(
      children: [
        Expanded(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircleAvatar(
                    radius: 48,
                    backgroundColor: const Color(0xFF333333),
                    backgroundImage: widget.peerPic.isNotEmpty
                        ? NetworkImage(widget.peerPic)
                        : null,
                    child: widget.peerPic.isEmpty
                        ? const Icon(Icons.person,
                            color: Colors.white54, size: 48)
                        : null,
                  ),
                  const SizedBox(height: 16),
                  Text(widget.peerName,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  const Text(
                    "Send a message request to start chatting.\nThey will need to accept before you can continue.",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white54, fontSize: 13),
                  ),
                ],
              ),
            ),
          ),
        ),
        _inputBar(onSend: _sendRequest, hintText: "Send a message request…"),
      ],
    );
  }

  Widget _requestSentBody(String message) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          margin: const EdgeInsets.all(12),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF252525),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFFF4D6D).withOpacity(0.4)),
          ),
          child: Row(
            children: [
              const Icon(Icons.schedule, color: Color(0xFFFF4D6D), size: 18),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  "Waiting for ${widget.peerName} to accept your request.",
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 10),
                  constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.72),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF4D6D),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Text(message,
                      style: const TextStyle(
                          color: Colors.white, fontSize: 16)),
                ),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.watch_later_outlined,
                        color: Colors.grey, size: 14),
                    const SizedBox(width: 4),
                    Text("Request pending",
                        style:
                            TextStyle(color: Colors.grey[600], fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
        ),
        Container(
          margin: const EdgeInsets.all(12),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: BoxDecoration(
            color: const Color(0xFF252525),
            borderRadius: BorderRadius.circular(25),
          ),
          child: Row(
            children: [
              const Icon(Icons.lock_outline, color: Colors.grey, size: 18),
              const SizedBox(width: 10),
              Text(
                "Waiting for ${widget.peerName} to accept…",
                style: const TextStyle(color: Colors.grey, fontSize: 14),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _requestReceivedBody(Map<String, dynamic> reqData) {
    final message = reqData['message'] ?? '';
    return Column(
      children: [
        Container(
          width: double.infinity,
          margin: const EdgeInsets.all(12),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF252525),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFFF4D6D).withOpacity(0.4)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.mark_chat_unread_outlined,
                      color: Color(0xFFFF4D6D), size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "${widget.peerName} sent you a message request",
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              const Text(
                "Accept to start chatting, or decline to remove this request.",
                style: TextStyle(color: Colors.white54, fontSize: 12),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 10),
                  constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.72),
                  decoration: BoxDecoration(
                    color: const Color(0xFF333333),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Text(message,
                      style: const TextStyle(
                          color: Colors.white, fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white70,
                    side: const BorderSide(color: Colors.white24),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: _sending ? null : _declineRequest,
                  child: const Text("Decline", style: TextStyle(fontSize: 15)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF4D6D),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: _sending ? null : () => _acceptRequest(reqData),
                  child: _sending
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2))
                      : const Text("Accept",
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _normalChatBody() {
    return Column(
      children: [
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('chats')
                .doc(_chatId)
                .collection('messages')
                .orderBy('timestamp', descending: true)
                .snapshots(),
            builder: (context, snap) {
              if (!snap.hasData) {
                return const Center(
                    child:
                        CircularProgressIndicator(color: Color(0xFFFF4D6D)));
              }
              final docs = snap.data!.docs;
              if (docs.isEmpty) {
                return const Center(
                    child: Text("Say something! 👋",
                        style: TextStyle(color: Colors.white54)));
              }
              return ListView.builder(
                reverse: true,
                padding: const EdgeInsets.symmetric(
                    horizontal: 15, vertical: 10),
                itemCount: docs.length,
                itemBuilder: (context, i) {
                  final data = docs[i].data() as Map<String, dynamic>;
                  final isMe = data['senderId'] == currentUserId;
                  return Align(
                    alignment:
                        isMe ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.72),
                      decoration: BoxDecoration(
                        color: isMe
                            ? const Color(0xFFFF4D6D)
                            : const Color(0xFF333333),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Text(data['content'] ?? "",
                          style: const TextStyle(
                              color: Colors.white, fontSize: 16)),
                    ),
                  );
                },
              );
            },
          ),
        ),
        _inputBar(onSend: _sendMessage, hintText: "Type a message…"),
      ],
    );
  }

  Widget _inputBar(
      {required VoidCallback onSend, required String hintText}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              style: const TextStyle(color: Colors.white),
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: const TextStyle(color: Colors.grey),
                filled: true,
                fillColor: const Color(0xFF333333),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                    borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 12),
              ),
              onSubmitted: (_) => onSend(),
            ),
          ),
          const SizedBox(width: 8),
          CircleAvatar(
            backgroundColor: const Color(0xFFFF4D6D),
            child: IconButton(
              icon: _sending
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2))
                  : const Icon(Icons.send, color: Colors.white, size: 20),
              onPressed: _sending ? null : onSend,
            ),
          ),
        ],
      ),
    );
  }
}
