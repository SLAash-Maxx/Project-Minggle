// lib/models/app_data.dart
// Shared data models and state for the Minggle app

class UserProfile {
  final String id;
  final String name;
  final int age;
  final String bio;
  final String imageUrl;
  final String location;
  final List<String> interests;

  const UserProfile({
    required this.id,
    required this.name,
    required this.age,
    required this.bio,
    required this.imageUrl,
    required this.location,
    required this.interests,
  });
}

class ChatMessage {
  final String text;
  final bool isMe;
  final DateTime timestamp;

  const ChatMessage({
    required this.text,
    required this.isMe,
    required this.timestamp,
  });
}

class Conversation {
  final UserProfile user;
  final List<ChatMessage> messages;

  Conversation({required this.user, required this.messages});

  String get lastMessage => messages.isEmpty ? 'Say hi! 👋' : messages.last.text;
  DateTime? get lastTime => messages.isEmpty ? null : messages.last.timestamp;
}

// ─── Central app state ────────────────────────────────────────────────────────
// Use a simple singleton for state so all screens share data
// In production you'd use Provider/Riverpod/Bloc
class AppState {
  AppState._();
  static final AppState instance = AppState._();

  // The 3 sample discovery profiles shown on Home
  final List<UserProfile> discoveryProfiles = const [
    UserProfile(
      id: '1',
      name: 'Anika',
      age: 24,
      bio: 'Coffee lover ☕ | Dog mom 🐶 | Hiking enthusiast. Looking for someone to explore trails and try new cafés with.',
      imageUrl: 'https://randomuser.me/api/portraits/women/44.jpg',
      location: 'Colombo, LK',
      interests: ['Hiking', 'Coffee', 'Photography', 'Travel'],
    ),
    UserProfile(
      id: '2',
      name: 'Rayan',
      age: 27,
      bio: 'Music producer 🎵 | Foodie | Beach bum on weekends. Let\'s grab kottu and talk about life.',
      imageUrl: 'https://randomuser.me/api/portraits/men/32.jpg',
      location: 'Negombo, LK',
      interests: ['Music', 'Food', 'Beach', 'Gaming'],
    ),
    UserProfile(
      id: '3',
      name: 'Nisha',
      age: 22,
      bio: 'Art student 🎨 | Book worm 📚 | Plant parent 🌿. Swipe right if you can handle my painting mess.',
      imageUrl: 'https://randomuser.me/api/portraits/women/68.jpg',
      location: 'Kandy, LK',
      interests: ['Art', 'Reading', 'Plants', 'Yoga'],
    ),
  ];

  // Set of liked profile ids
  final Set<String> _likedIds = {};

  bool isLiked(String id) => _likedIds.contains(id);

  void toggleLike(String id) {
    if (_likedIds.contains(id)) {
      _likedIds.remove(id);
    } else {
      _likedIds.add(id);
    }
  }

  List<UserProfile> get likedProfiles =>
      discoveryProfiles.where((p) => _likedIds.contains(p.id)).toList();

  // Sample conversations (matches who already liked back)
  late final List<Conversation> conversations = [
    Conversation(
      user: discoveryProfiles[0],
      messages: [
        ChatMessage(text: 'Hey! We matched 🎉', isMe: false, timestamp: _hoursAgo(3)),
        ChatMessage(text: 'Hi Anika! Nice to meet you 😊', isMe: true, timestamp: _hoursAgo(3)),
        ChatMessage(text: 'So what do you do for fun around here?', isMe: false, timestamp: _hoursAgo(2)),
      ],
    ),
    Conversation(
      user: discoveryProfiles[1],
      messages: [
        ChatMessage(text: 'Your profile is really cool!', isMe: false, timestamp: _hoursAgo(24)),
        ChatMessage(text: 'Thanks! Yours too 🙌', isMe: true, timestamp: _hoursAgo(23)),
      ],
    ),
  ];

  DateTime _hoursAgo(int h) => DateTime.now().subtract(Duration(hours: h));

  // Current logged-in user's profile
  final UserProfile myProfile = const UserProfile(
    id: 'me',
    name: 'You',
    age: 23,
    bio: 'Add your bio here ✨',
    imageUrl: 'https://randomuser.me/api/portraits/lego/1.jpg',
    location: 'Sri Lanka',
    interests: ['Travel', 'Food', 'Music'],
  );
}
