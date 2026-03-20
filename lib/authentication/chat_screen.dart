import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'message_screen.dart';
import 'message_requests_screen.dart';
import 'astro_chat_screen.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final String currentUserId =
      FirebaseAuth.instance.currentUser?.uid ?? "unknown";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      body: Column(
        children: [
          
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('message_requests')
                .where('receiverId', isEqualTo: currentUserId)
                .where('status', isEqualTo: 'pending')
                .snapshots(),
            builder: (context, reqSnap) {
              final count = reqSnap.data?.docs.length ?? 0;
              if (count == 0) return const SizedBox.shrink();

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const MessageRequestsScreen(),
                    ),
                  );
                },
                child: Container(
                  margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF252525),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                        color: const Color(0xFFFF4D6D).withOpacity(0.5)),
                  ),
                  child: Row(
                    children: [
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          const Icon(Icons.mark_chat_unread_outlined,
                              color: Color(0xFFFF4D6D), size: 26),
                          Positioned(
                            top: -4,
                            right: -4,
                            child: Container(
                              padding: const EdgeInsets.all(3),
                              decoration: const BoxDecoration(
                                color: Color(0xFFFF4D6D),
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                '$count',
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Message Requests",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15),
                            ),
                            Text(
                              count == 1
                                  ? "1 person wants to chat with you"
                                  : "$count people want to chat with you",
                              style: TextStyle(
                                  color: Colors.grey[500], fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios,
                          color: Colors.white24, size: 14),
                    ],
                  ),
                ),
              );
            },
          ),

          
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(currentUserId)
                  .collection('liked_users')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                      child: CircularProgressIndicator(
                          color: Color(0xFFFF4D6D)));
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return _emptyState();
                }

                final likedDocs = snapshot.data!.docs;

                return ListView.separated(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  itemCount: likedDocs.length,
                  separatorBuilder: (_, __) =>
                      const Divider(color: Colors.white10, height: 1),
                  itemBuilder: (context, index) {
                    final peerUid = likedDocs[index].id;
                    return _ChatTile(
                      currentUserId: currentUserId,
                      peerUid: peerUid,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFFF4D6D),
        child: const Icon(Icons.auto_awesome, color: Colors.white),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AstroChatScreen()),
          );
        },
      ),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.favorite_border, color: Colors.grey[700], size: 56),
          const SizedBox(height: 16),
          const Text(
            "No matches yet!",
            style: TextStyle(color: Colors.white70, fontSize: 18),
          ),
          const SizedBox(height: 6),
          Text(
            "Start swiping to find people you like ❤️",
            style: TextStyle(color: Colors.grey[600], fontSize: 13),
          ),
        ],
      ),
    );
  }
}



class _ChatTile extends StatelessWidget {
  final String currentUserId;
  final String peerUid;

  const _ChatTile({required this.currentUserId, required this.peerUid});

  String get _chatId => currentUserId.hashCode <= peerUid.hashCode
      ? "${currentUserId}_$peerUid"
      : "${peerUid}_$currentUserId";

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('users').doc(peerUid).get(),
      builder: (context, userSnap) {
        if (!userSnap.hasData || !userSnap.data!.exists) {
          return const SizedBox.shrink();
        }

        final userData = userSnap.data!.data() as Map<String, dynamic>;
        final peerName = userData['name'] ?? 'User';
        final peerPic =
            userData['profilePic'] ?? 'https://via.placeholder.com/150';

        
        return StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('message_requests')
              .doc(_chatId)
              .snapshots(),
          builder: (context, reqSnap) {
            return StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('chats')
                  .doc(_chatId)
                  .snapshots(),
              builder: (context, chatSnap) {
                final reqExists =
                    reqSnap.hasData && reqSnap.data != null && reqSnap.data!.exists;
                final accepted = chatSnap.hasData &&
                    chatSnap.data != null &&
                    chatSnap.data!.exists &&
                    ((chatSnap.data!.data() as Map<String, dynamic>? ??
                            {})['accepted']) ==
                        true;

                String subtitle;
                Widget? trailingBadge;

                if (reqExists) {
                  final reqData =
                      reqSnap.data!.data() as Map<String, dynamic>;
                  final isSender = reqData['senderId'] == currentUserId;
                  if (isSender) {
                    subtitle = "Request sent · pending";
                    trailingBadge = const Icon(Icons.schedule,
                        color: Colors.grey, size: 16);
                  } else {
                    subtitle = reqData['message'] ?? 'Sent you a request';
                    trailingBadge = Container(
                      width: 10,
                      height: 10,
                      decoration: const BoxDecoration(
                        color: Color(0xFFFF4D6D),
                        shape: BoxShape.circle,
                      ),
                    );
                  }
                } else if (accepted) {
                  subtitle = "Tap to continue chatting";
                } else {
                  subtitle = "Tap to send a message request";
                }

                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 10),
                  leading: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                            color: Colors.white24,
                            width: 2),
                    ),
                    child: CircleAvatar(
                      radius: 28,
                      backgroundColor: const Color(0xFF333333),
                      backgroundImage: NetworkImage(peerPic),
                    ),
                  ),
                  title: Text(
                    peerName,
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 17),
                  ),
                  subtitle: Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        color: reqExists &&
                                (reqSnap.data!.data()
                                        as Map<String, dynamic>)['receiverId'] ==
                                    currentUserId
                            ? Colors.white70
                            : Colors.grey,
                        fontSize: 13),
                  ),
                  trailing: trailingBadge ??
                      const Icon(Icons.arrow_forward_ios,
                          color: Colors.white24, size: 14),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => MessageScreen(
                          peerUid: peerUid,
                          peerName: peerName,
                          peerPic: peerPic,
                        ),
                      ),
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }
}
