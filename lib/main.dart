import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import 'theme_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );
  runApp(const ConnectSphereApp());
}

// ─────────────────────────────────────────────
// THEME & CONSTANTS
// ─────────────────────────────────────────────

class AppColors {
  static const bg = Color(0xFF0A0A0F);
  static const surface = Color(0xFF13131A);
  static const surface2 = Color(0xFF1C1C26);
  static const surface3 = Color(0xFF242430);
  static const border = Color(0x12FFFFFF);
  static const border2 = Color(0x1FFFFFFF);
  static const textPrimary = Color(0xFFF5F5F7);
  static const textMuted = Color(0xFF8E8E9A);
  static const accent = Color(0xFF7C6BF8);
  static const accentLight = Color(0xFF9B8AFB);
  static const accentPink = Color(0xFFF85B8A);
  static const teal = Color(0xFF2DD4BF);
  static const green = Color(0xFF22C55E);
  static const amber = Color(0xFFF59E0B);
}

class LightColors {
  static const bg = Color(0xFFF8FAFC);
  static const surface = Color(0xFFFFFFFF);
  static const surface2 = Color(0xFFF1F5F9);
  static const surface3 = Color(0xFFE2E8F0);
  static const border = Color(0x1A000000);
  static const border2 = Color(0x33000000);
  static const textPrimary = Color(0xFF0F172A);
  static const textMuted = Color(0xFF64748B);
  static const accent = Color(0xFF7C6BF8);
  static const accentLight = Color(0xFF9B8AFB);
  static const accentPink = Color(0xFFF85B8A);
  static const teal = Color(0xFF2DD4BF);
  static const green = Color(0xFF22C55E);
  static const amber = Color(0xFFF59E0B);
}

const kAccentGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [AppColors.accent, AppColors.accentLight],
);

const kPinkGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [AppColors.accent, AppColors.accentPink],
);

const kTealGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [AppColors.accent, AppColors.teal],
);

const kBgGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [Color(0xFF0A0A0F), Color(0xFF13131A), Color(0xFF0A0A0F)],
);

// ─────────────────────────────────────────────
// MODELS
// ─────────────────────────────────────────────

class UserModel {
  String name;
  String handle;
  int age;
  String bio;
  String emoji;
  String location;
  int followers;
  int following;
  int posts;

  UserModel({
    required this.name,
    required this.handle,
    required this.age,
    required this.bio,
    required this.emoji,
    required this.location,
    required this.followers,
    required this.following,
    required this.posts,
  });
}

class StoryModel {
  final String name;
  final String emoji;
  final Color color;
  const StoryModel(
      {required this.name, required this.emoji, required this.color});
}

class PostModel {
  final String userId;
  String username;
  String location;
  final String timeAgo;
  String emoji;
  final Color bgColor1;
  final Color bgColor2;
  String caption;
  int likes;
  int comments;
  bool liked;
  bool saved;
  final bool isVideo;

  PostModel({
    required this.userId,
    required this.username,
    required this.location,
    required this.timeAgo,
    required this.emoji,
    required this.bgColor1,
    required this.bgColor2,
    required this.caption,
    required this.likes,
    required this.comments,
    this.liked = false,
    this.saved = false,
    this.isVideo = false,
  });
}

class AnonChatPreview {
  final String id;
  final String emoji;
  final Color color1;
  final Color color2;
  final String preview;
  final String timeAgo;
  final int unread;
  final bool online;

  const AnonChatPreview({
    required this.id,
    required this.emoji,
    required this.color1,
    required this.color2,
    required this.preview,
    required this.timeAgo,
    this.unread = 0,
    this.online = false,
  });
}

class ChatMessage {
  final String text;
  final bool isMe;
  final DateTime time;
  ChatMessage(this.text, this.isMe) : time = DateTime.now();
}

class NotificationModel {
  final String emoji;
  final String username;
  final String action;
  final String timeAgo;
  final bool isRead;
  final Color color;

  const NotificationModel({
    required this.emoji,
    required this.username,
    required this.action,
    required this.timeAgo,
    required this.isRead,
    required this.color,
  });
}

class DMConversation {
  final String userId;
  final String username;
  final String emoji;
  final Color color1;
  final Color color2;
  String lastMessage;
  final String timeAgo;
  int unread;
  final bool online;
  final List<ChatMessage> messages;

  DMConversation({
    required this.userId,
    required this.username,
    required this.emoji,
    required this.color1,
    required this.color2,
    required this.lastMessage,
    required this.timeAgo,
    this.unread = 0,
    this.online = false,
    List<ChatMessage>? messages,
  }) : messages = messages ?? [];
}

// ─────────────────────────────────────────────
// SAMPLE DATA
// ─────────────────────────────────────────────

final List<StoryModel> sampleStories = [
  StoryModel(name: 'Aarav', emoji: '🧑‍💻', color: AppColors.accent),
  StoryModel(name: 'Diya', emoji: '🎵', color: AppColors.accentPink),
  StoryModel(name: 'Ishaan', emoji: '✈️', color: AppColors.teal),
  StoryModel(name: 'Meera', emoji: '🎨', color: AppColors.amber),
  StoryModel(name: 'Isha', emoji: '📚', color: AppColors.green),
  StoryModel(name: 'Vivaan', emoji: '💻', color: const Color(0xFF818CF8)),
];

final List<PostModel> samplePosts = [
  PostModel(
    userId: 'vivaan_k',
    username: 'Vivaan K.',
    location: 'Mumbai',
    timeAgo: '2h ago',
    emoji: '🏙️',
    bgColor1: const Color(0xFF0F2027),
    bgColor2: const Color(0xFF2C5364),
    caption:
        'Golden hour hits different in Mumbai 🧡 The city never sleeps and I\'m here for it.',
    likes: 2400,
    comments: 134,
  ),
  PostModel(
    userId: 'ananya_s',
    username: 'Ananya S.',
    location: 'Delhi',
    timeAgo: '5h ago',
    emoji: '💃',
    bgColor1: const Color(0xFF360033),
    bgColor2: const Color(0xFF0B8793),
    caption:
        'When the beat drops and you forget everything 🎵✨ Dance is my therapy.',
    likes: 8100,
    comments: 892,
    liked: true,
    isVideo: true,
  ),
  PostModel(
    userId: 'rohan_m',
    username: 'Rohan M.',
    location: 'Bangalore',
    timeAgo: '8h ago',
    emoji: '🚀',
    bgColor1: const Color(0xFF1A1A2E),
    bgColor2: const Color(0xFF16213E),
    caption:
        'Shipped our first feature this week. The grind is real but so is the reward. 🚀',
    likes: 5300,
    comments: 241,
    isVideo: true,
  ),
  PostModel(
    userId: 'kavya_r',
    username: 'Kavya R.',
    location: 'Hyderabad',
    timeAgo: '12h ago',
    emoji: '🌿',
    bgColor1: const Color(0xFF11998E),
    bgColor2: const Color(0xFF38EF7D),
    caption: 'Sunday mornings are for slow coffee and good thoughts ☕🌿',
    likes: 3700,
    comments: 188,
  ),
];

final Map<String, UserModel> userProfiles = {
  'vivaan_k': UserModel(
      name: 'Vivaan K.',
      handle: '@vivaan_k',
      age: 24,
      bio: 'Night owl 🌃 Mumbai local. Into street photography and chai.',
      emoji: '🏙️',
      location: 'Mumbai',
      followers: 14200,
      following: 890,
      posts: 312),
  'ananya_s': UserModel(
      name: 'Ananya S.',
      handle: '@ananya_s',
      age: 22,
      bio: 'Dancer 💃 Delhi. Classical meets contemporary. Reels every week!',
      emoji: '💃',
      location: 'Delhi',
      followers: 48900,
      following: 210,
      posts: 621),
  'rohan_m': UserModel(
      name: 'Rohan M.',
      handle: '@rohan_m',
      age: 26,
      bio:
          'SWE @ Startup 🚀 Bangalore. Building cool stuff and drinking too much coffee.',
      emoji: '🚀',
      location: 'Bangalore',
      followers: 5300,
      following: 402,
      posts: 89),
  'kavya_r': UserModel(
      name: 'Kavya R.',
      handle: '@kavya_r',
      age: 23,
      bio: 'Plant parent 🌿 Hyderabad. Slow mornings, warm light, good vibes.',
      emoji: '🌿',
      location: 'Hyderabad',
      followers: 9800,
      following: 567,
      posts: 203),
};

final List<AnonChatPreview> anonChats = [
  AnonChatPreview(
      id: '#2841',
      emoji: '🦊',
      color1: AppColors.accent,
      color2: AppColors.teal,
      preview: "That's such an interesting perspective...",
      timeAgo: '2m',
      unread: 3,
      online: true),
  AnonChatPreview(
      id: '#1156',
      emoji: '🐺',
      color1: AppColors.accentPink,
      color2: const Color(0xFFFF8A80),
      preview: "Same! I've been thinking about that too 😊",
      timeAgo: '1h'),
  AnonChatPreview(
      id: '#7734',
      emoji: '🐸',
      color1: AppColors.amber,
      color2: const Color(0xFFEF4444),
      preview: 'Ended · 2h conversation',
      timeAgo: '3h'),
];

final List<DMConversation> dmConversations = [
  DMConversation(
    userId: 'vivaan_k',
    username: 'Vivaan K.',
    emoji: '🏙️',
    color1: const Color(0xFF0F2027),
    color2: const Color(0xFF2C5364),
    lastMessage: 'That photo spot in Bandra is 🔥',
    timeAgo: '5m',
    unread: 2,
    online: true,
    messages: [
      ChatMessage("Hey! Loved your latest post!", false),
      ChatMessage("Thanks man! Shot it at 5am haha", true),
      ChatMessage("That photo spot in Bandra is 🔥", false),
    ],
  ),
  DMConversation(
    userId: 'ananya_s',
    username: 'Ananya S.',
    emoji: '💃',
    color1: const Color(0xFF360033),
    color2: const Color(0xFF0B8793),
    lastMessage: 'When are you posting the next reel?',
    timeAgo: '1h',
    online: true,
    messages: [
      ChatMessage("Love your dance content!", true),
      ChatMessage("Aww thank you so much 🥹", false),
      ChatMessage("When are you posting the next reel?", false),
    ],
  ),
  DMConversation(
    userId: 'rohan_m',
    username: 'Rohan M.',
    emoji: '🚀',
    color1: const Color(0xFF1A1A2E),
    color2: const Color(0xFF16213E),
    lastMessage: "Let's collaborate on that project 🤝",
    timeAgo: '3h',
    messages: [
      ChatMessage("Saw your launch post, congrats!", true),
      ChatMessage("Thanks! It was a crazy week lol", false),
      ChatMessage("Let's collaborate on that project 🤝", true),
    ],
  ),
];

final List<NotificationModel> notifications = [
  NotificationModel(
      emoji: '❤️',
      username: 'Vivaan K.',
      action: 'liked your post',
      timeAgo: '2m',
      isRead: false,
      color: AppColors.accentPink),
  NotificationModel(
      emoji: '💬',
      username: 'Ananya S.',
      action: 'commented: "Absolutely stunning! 😍"',
      timeAgo: '10m',
      isRead: false,
      color: AppColors.accent),
  NotificationModel(
      emoji: '👤',
      username: 'Rohan M.',
      action: 'started following you',
      timeAgo: '30m',
      isRead: false,
      color: AppColors.teal),
  NotificationModel(
      emoji: '❤️',
      username: 'Kavya R.',
      action: 'liked your photo',
      timeAgo: '1h',
      isRead: true,
      color: AppColors.accentPink),
  NotificationModel(
      emoji: '🔁',
      username: 'Ishaan T.',
      action: 'shared your post',
      timeAgo: '2h',
      isRead: true,
      color: AppColors.green),
  NotificationModel(
      emoji: '💬',
      username: 'Meera K.',
      action: 'replied to your story',
      timeAgo: '4h',
      isRead: true,
      color: AppColors.amber),
  NotificationModel(
      emoji: '👤',
      username: 'Diya R.',
      action: 'started following you',
      timeAgo: '5h',
      isRead: true,
      color: AppColors.teal),
];

const List<String> anonReplies = [
  "That's such an interesting perspective... 🤔",
  "I never thought about it that way!",
  "Honestly, same. We're not so different 😊",
  "Okay but what made you think of that?",
  "This is why I love anonymous chats lol",
  "You seem like a genuinely thoughtful person ✨",
  "Deep. I'll be thinking about this all day.",
  "Agreed 100%. Most people don't get that.",
];

const List<String> dmReplies = [
  "Haha yeah for sure! 😄",
  "That's so cool!",
  "Let me check and get back to you 👀",
  "Absolutely, let's do it!",
  "Wow I didn't know that!",
  "Missing those vibes tbh 😔",
  "Sounds like a plan! 🙌",
];

// ─────────────────────────────────────────────
// APP ROOT — FIXED: Provider wraps MaterialApp
// ─────────────────────────────────────────────

class ConnectSphereApp extends StatelessWidget {
  const ConnectSphereApp({super.key});

  ThemeData _buildDarkTheme() {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.bg,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.accent,
        secondary: AppColors.accentPink,
        surface: AppColors.surface,
      ),
      fontFamily: 'SF Pro Display',
      useMaterial3: true,
    );
  }

  ThemeData _buildLightTheme() {
    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: LightColors.bg,
      colorScheme: const ColorScheme.light(
        primary: LightColors.accent,
        secondary: LightColors.accentPink,
        surface: LightColors.surface,
      ),
      fontFamily: 'SF Pro Display',
      useMaterial3: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    // FIX: ChangeNotifierProvider wraps MaterialApp so all routes can access it
    return ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            title: 'ConnectSphere',
            debugShowCheckedModeBanner: false,
            themeMode: themeProvider.themeMode,
            theme: _buildLightTheme(),
            darkTheme: _buildDarkTheme(),
            home: const LoginScreen(),
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────
// SHARED WIDGETS
// ─────────────────────────────────────────────

class GradientButton extends StatefulWidget {
  final String label;
  final VoidCallback onTap;
  final Gradient gradient;
  final double height;
  final Widget? icon;

  const GradientButton({
    super.key,
    required this.label,
    required this.onTap,
    this.gradient = kAccentGradient,
    this.height = 56,
    this.icon,
  });

  @override
  State<GradientButton> createState() => _GradientButtonState();
}

class _GradientButtonState extends State<GradientButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 120));
    _scale = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) {
        _ctrl.reverse();
        widget.onTap();
      },
      onTapCancel: () => _ctrl.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          height: widget.height,
          decoration: BoxDecoration(
            gradient: widget.gradient,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                  color: AppColors.accent.withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8))
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.icon != null) ...[
                widget.icon!,
                const SizedBox(width: 10)
              ],
              Text(widget.label,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.3)),
            ],
          ),
        ),
      ),
    );
  }
}

class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final double radius;
  final Color? color;

  const GlassCard(
      {super.key,
      required this.child,
      this.padding,
      this.radius = 16,
      this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color ?? AppColors.surface,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: AppColors.border2, width: 0.5),
      ),
      child: child,
    );
  }
}

class _IconBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _IconBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: AppColors.surface2,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border, width: 0.5),
        ),
        child: Icon(icon, color: AppColors.textPrimary, size: 18),
      ),
    );
  }
}

class NavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  const NavBar({super.key, required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border, width: 0.5)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            _navItem(0, Icons.home_rounded, Icons.home_outlined, 'Home'),
            _navItem(
                1, Icons.explore_rounded, Icons.explore_outlined, 'Explore'),
            _uploadNavItem(context),
            _anonNavItem(),
            _navItem(3, Icons.person_rounded, Icons.person_outlined, 'Profile'),
          ],
        ),
      ),
    );
  }

  Widget _navItem(int index, IconData active, IconData inactive, String label) {
    final isActive = currentIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => onTap(index),
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(isActive ? active : inactive,
                color: isActive ? AppColors.accent : AppColors.textMuted,
                size: 24),
            const SizedBox(height: 4),
            Text(label,
                style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: isActive ? AppColors.accent : AppColors.textMuted)),
          ],
        ),
      ),
    );
  }

  Widget _uploadNavItem(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: () => showModalBottomSheet(
          context: context,
          backgroundColor: AppColors.surface,
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
          builder: (_) => const UploadBottomSheet(),
        ),
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: const BoxDecoration(
                  gradient: kPinkGradient, shape: BoxShape.circle),
              child:
                  const Icon(Icons.add_rounded, color: Colors.white, size: 24),
            ),
          ],
        ),
      ),
    );
  }

  Widget _anonNavItem() {
    final isActive = currentIndex == 2;
    return Expanded(
      child: GestureDetector(
        onTap: () => onTap(2),
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ShaderMask(
              shaderCallback: (bounds) => kTealGradient.createShader(bounds),
              child: Icon(Icons.handshake_rounded,
                  color: Colors.white, size: isActive ? 28 : 24),
            ),
            const SizedBox(height: 4),
            ShaderMask(
              shaderCallback: (bounds) => kTealGradient.createShader(bounds),
              child: const Text('Connect',
                  style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// UPLOAD BOTTOM SHEET
// ─────────────────────────────────────────────

class UploadBottomSheet extends StatefulWidget {
  const UploadBottomSheet({super.key});
  @override
  State<UploadBottomSheet> createState() => _UploadBottomSheetState();
}

class _UploadBottomSheetState extends State<UploadBottomSheet> {
  int _selected = 0;
  final _captionCtrl = TextEditingController();
  bool _uploaded = false;
  bool _isPosting = false;

  @override
  void dispose() {
    _captionCtrl.dispose();
    super.dispose();
  }

  Future<void> _post() async {
    if (_captionCtrl.text.trim().isEmpty) return;
    setState(() => _isPosting = true);
    await Future.delayed(const Duration(milliseconds: 1200));
    final emojis = ['🎉', '🌟', '🔥', '✨', '💫', '🎨', '🎵', '🚀'];
    final newPost = PostModel(
      userId: 'arjun_dev',
      username: 'Arjun Dev',
      location: 'Mumbai',
      timeAgo: 'Just now',
      emoji: emojis[Random().nextInt(emojis.length)],
      bgColor1: const Color(0xFF2D1B69),
      bgColor2: const Color(0xFF11998E),
      caption: _captionCtrl.text.trim(),
      likes: 0,
      comments: 0,
      isVideo: _selected == 1,
    );
    samplePosts.insert(0, newPost);
    if (mounted) {
      setState(() => _isPosting = false);
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(_selected == 1 ? '🎬 Video posted!' : '📸 Photo posted!'),
        backgroundColor: AppColors.surface2,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
                child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                        color: AppColors.border2,
                        borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 20),
            const Text('Create Post',
                style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.w800)),
            const SizedBox(height: 20),
            Row(children: [
              Expanded(
                  child: _TypeBtn(
                      label: '📷  Photo',
                      active: _selected == 0,
                      onTap: () => setState(() => _selected = 0))),
              const SizedBox(width: 12),
              Expanded(
                  child: _TypeBtn(
                      label: '🎬  Video',
                      active: _selected == 1,
                      onTap: () => setState(() => _selected = 1))),
            ]),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () => setState(() => _uploaded = !_uploaded),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: 140,
                decoration: BoxDecoration(
                  gradient: _uploaded
                      ? const LinearGradient(
                          colors: [Color(0xFF2D1B69), Color(0xFF11998E)])
                      : null,
                  color: _uploaded ? null : AppColors.surface2,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                      color: _uploaded ? Colors.transparent : AppColors.border2,
                      width: _uploaded ? 0 : 1),
                ),
                child: _uploaded
                    ? Center(
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                            Text(_selected == 1 ? '🎬' : '📸',
                                style: const TextStyle(fontSize: 40)),
                            const SizedBox(height: 8),
                            Text(
                                _selected == 1
                                    ? 'Video ready to post!'
                                    : 'Photo ready to post!',
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600)),
                          ]))
                    : Center(
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                  color: AppColors.surface3,
                                  borderRadius: BorderRadius.circular(12)),
                              child: Icon(
                                  _selected == 1
                                      ? Icons.video_call_rounded
                                      : Icons.add_photo_alternate_outlined,
                                  color: AppColors.textMuted,
                                  size: 24),
                            ),
                            const SizedBox(height: 10),
                            Text(
                                'Tap to select ${_selected == 1 ? "video" : "photo"}',
                                style: const TextStyle(
                                    color: AppColors.textMuted, fontSize: 13)),
                          ])),
              ),
            ),
            const SizedBox(height: 14),
            Container(
              decoration: BoxDecoration(
                  color: AppColors.surface2,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border2, width: 0.5)),
              child: TextField(
                controller: _captionCtrl,
                style:
                    const TextStyle(color: AppColors.textPrimary, fontSize: 14),
                maxLines: 2,
                decoration: const InputDecoration(
                    hintText: 'Write a caption...',
                    hintStyle: TextStyle(color: AppColors.textMuted),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(14)),
              ),
            ),
            const SizedBox(height: 16),
            GradientButton(
              label: _isPosting ? 'Posting...' : 'Share Post',
              onTap: _isPosting ? () {} : _post,
              gradient: _selected == 1 ? kTealGradient : kPinkGradient,
              icon: Icon(
                  _selected == 1
                      ? Icons.videocam_rounded
                      : Icons.photo_camera_rounded,
                  color: Colors.white,
                  size: 20),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _TypeBtn extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;
  const _TypeBtn(
      {required this.label, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 44,
        decoration: BoxDecoration(
          gradient: active ? kPinkGradient : null,
          color: active ? null : AppColors.surface2,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: active ? Colors.transparent : AppColors.border2,
              width: 0.5),
        ),
        child: Center(
            child: Text(label,
                style: TextStyle(
                    color: active ? Colors.white : AppColors.textMuted,
                    fontSize: 14,
                    fontWeight: FontWeight.w700))),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// 1. LOGIN SCREEN
// ─────────────────────────────────────────────

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fade;
  late Animation<Offset> _slide;
  bool _obscure = true;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900));
    _fade = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(
        parent: _ctrl, curve: const Interval(0, 0.6, curve: Curves.easeOut)));
    _slide = Tween<Offset>(begin: const Offset(0, 0.06), end: Offset.zero)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _login() {
    Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const MainShell(),
          transitionDuration: const Duration(milliseconds: 500),
          transitionsBuilder: (_, anim, __, child) =>
              FadeTransition(opacity: anim, child: child),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Stack(
        children: [
          Positioned(
              top: -80,
              right: -80,
              child: Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(colors: [
                        AppColors.accent.withValues(alpha: 0.3),
                        Colors.transparent
                      ])))),
          Positioned(
              bottom: 80,
              left: -60,
              child: Container(
                  width: 220,
                  height: 220,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(colors: [
                        AppColors.accentPink.withValues(alpha: 0.25),
                        Colors.transparent
                      ])))),
          SafeArea(
            child: FadeTransition(
              opacity: _fade,
              child: SlideTransition(
                position: _slide,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Welcome\nback 👋',
                          style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 36,
                              fontWeight: FontWeight.w800,
                              height: 1.15,
                              letterSpacing: -0.5)),
                      const SizedBox(height: 8),
                      const Text('Sign in to continue exploring',
                          style: TextStyle(
                              color: AppColors.textMuted, fontSize: 16)),
                      const SizedBox(height: 40),
                      _inputField(
                          hint: 'Email address',
                          icon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress),
                      const SizedBox(height: 14),
                      _passwordField(),
                      const SizedBox(height: 12),
                      const Align(
                          alignment: Alignment.centerRight,
                          child: Text('Forgot password?',
                              style: TextStyle(
                                  color: AppColors.accent,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600))),
                      const SizedBox(height: 28),
                      GradientButton(
                          label: 'Sign In',
                          onTap: _login,
                          gradient: kPinkGradient),
                      const SizedBox(height: 24),
                      _divider(),
                      const SizedBox(height: 16),
                      Row(children: [
                        Expanded(child: _socialBtn('🍎', 'Apple')),
                        const SizedBox(width: 12),
                        Expanded(child: _socialBtn('🇬', 'Google')),
                      ]),
                      const SizedBox(height: 32),
                      Center(
                          child: RichText(
                              text: const TextSpan(
                                  style: TextStyle(
                                      color: AppColors.textMuted, fontSize: 14),
                                  children: [
                            TextSpan(text: 'New here? '),
                            TextSpan(
                                text: 'Create account',
                                style: TextStyle(
                                    color: AppColors.accent,
                                    fontWeight: FontWeight.w700)),
                          ]))),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _inputField(
      {required String hint,
      required IconData icon,
      TextInputType? keyboardType}) {
    return Container(
      decoration: BoxDecoration(
          color: AppColors.surface2,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border2, width: 0.5)),
      child: TextField(
        keyboardType: keyboardType,
        style: const TextStyle(color: AppColors.textPrimary, fontSize: 15),
        decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: AppColors.textMuted),
            prefixIcon: Icon(icon, color: AppColors.textMuted, size: 20),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.all(18)),
      ),
    );
  }

  Widget _passwordField() {
    return Container(
      decoration: BoxDecoration(
          color: AppColors.surface2,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border2, width: 0.5)),
      child: TextField(
        obscureText: _obscure,
        style: const TextStyle(color: AppColors.textPrimary, fontSize: 15),
        decoration: InputDecoration(
          hintText: 'Password',
          hintStyle: const TextStyle(color: AppColors.textMuted),
          prefixIcon: const Icon(Icons.lock_outline,
              color: AppColors.textMuted, size: 20),
          suffixIcon: GestureDetector(
              onTap: () => setState(() => _obscure = !_obscure),
              child: Icon(
                  _obscure
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: AppColors.textMuted,
                  size: 20)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(18),
        ),
      ),
    );
  }

  Widget _divider() {
    return const Row(children: [
      Expanded(child: Divider(color: AppColors.border2, thickness: 0.5)),
      Padding(
          padding: EdgeInsets.symmetric(horizontal: 12),
          child: Text('or continue with',
              style: TextStyle(color: AppColors.textMuted, fontSize: 12))),
      Expanded(child: Divider(color: AppColors.border2, thickness: 0.5)),
    ]);
  }

  Widget _socialBtn(String emoji, String label) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
          color: AppColors.surface2,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border2, width: 0.5)),
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Text(emoji, style: const TextStyle(fontSize: 18)),
        const SizedBox(width: 8),
        Text(label,
            style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w600)),
      ]),
    );
  }
}

// ─────────────────────────────────────────────
// 2. MAIN SHELL
// ─────────────────────────────────────────────

class MainShell extends StatefulWidget {
  const MainShell({super.key});
  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _idx = 0;

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = <Widget>[
      HomeScreen(onRefresh: () => setState(() {})),
      const ExploreScreen(),
      const AnonScreen(),
      const ProfileScreen(isOwnProfile: true),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: IndexedStack(index: _idx, children: _screens),
      bottomNavigationBar: NavBar(
        currentIndex: _idx,
        onTap: (i) => setState(() => _idx = i),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// 3. HOME SCREEN
// ─────────────────────────────────────────────

class HomeScreen extends StatefulWidget {
  final VoidCallback? onRefresh;
  const HomeScreen({super.key, this.onRefresh});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  void _toggleLike(int index) =>
      setState(() => samplePosts[index].liked = !samplePosts[index].liked);
  void _toggleSave(int index) =>
      setState(() => samplePosts[index].saved = !samplePosts[index].saved);

  void _deletePost(int index) {
    setState(() => samplePosts.removeAt(index));
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: const Text('Post deleted'),
      backgroundColor: AppColors.surface2,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
  }

  void _showEditPost(BuildContext context, int index) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => EditPostSheet(
        post: samplePosts[index],
        onSave: (newCaption) =>
            setState(() => samplePosts[index].caption = newCaption),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(child: _buildStories()),
                  SliverToBoxAdapter(
                      child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                    child: Row(children: [
                      const Text('For you',
                          style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.w700)),
                      const SizedBox(width: 16),
                      const Text('Following',
                          style: TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 16,
                              fontWeight: FontWeight.w500)),
                    ]),
                  )),
                  SliverList(
                      delegate: SliverChildBuilderDelegate(
                    (context, index) => _PostCard(
                      post: samplePosts[index],
                      onLike: () => _toggleLike(index),
                      onSave: () => _toggleSave(index),
                      onDelete: () => _deletePost(index),
                      onEdit: () => _showEditPost(context, index),
                      isOwn: samplePosts[index].userId == 'arjun_dev',
                    ),
                    childCount: samplePosts.length,
                  )),
                  const SliverToBoxAdapter(child: SizedBox(height: 16)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 16, 8),
      child: Row(children: [
        ShaderMask(
          shaderCallback: (b) => kPinkGradient.createShader(b),
          child: const Text('ConnectSphere',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3)),
        ),
        const Spacer(),
        // FIX: Consumer<ThemeProvider> now works because provider is at root
        Consumer<ThemeProvider>(
          builder: (context, themeProvider, child) {
            return GestureDetector(
              onTap: () {
                final newMode = themeProvider.themeMode == ThemeMode.light
                    ? ThemeMode.dark
                    : ThemeMode.light;
                themeProvider.setThemeMode(newMode);
              },
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                    color: AppColors.surface2,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border, width: 0.5)),
                child: Icon(
                    themeProvider.themeMode == ThemeMode.light
                        ? Icons.dark_mode
                        : Icons.light_mode,
                    color: AppColors.textPrimary,
                    size: 20),
              ),
            );
          },
        ),
        const SizedBox(width: 6),
        GestureDetector(
          onTap: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => const NotificationsScreen())),
          child: Stack(children: [
            Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                    color: AppColors.surface2,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border, width: 0.5)),
                child: const Icon(Icons.notifications_outlined,
                    color: AppColors.textPrimary, size: 18)),
            Positioned(
                top: 6,
                right: 6,
                child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                        color: AppColors.accentPink, shape: BoxShape.circle))),
          ]),
        ),
        const SizedBox(width: 6),
        GestureDetector(
          onTap: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => const DMInboxScreen())),
          child: Stack(children: [
            Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                    color: AppColors.surface2,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border, width: 0.5)),
                child: const Icon(Icons.send_outlined,
                    color: AppColors.textPrimary, size: 18)),
            Positioned(
                top: 6,
                right: 6,
                child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                        color: AppColors.accentPink, shape: BoxShape.circle))),
          ]),
        ),
      ]),
    );
  }

  Widget _buildStories() {
    return SizedBox(
      height: 104,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: sampleStories.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) return const _AddStoryItem();
          return _StoryItem(story: sampleStories[index - 1]);
        },
      ),
    );
  }
}

class EditPostSheet extends StatefulWidget {
  final PostModel post;
  final ValueChanged<String> onSave;
  const EditPostSheet({super.key, required this.post, required this.onSave});
  @override
  State<EditPostSheet> createState() => _EditPostSheetState();
}

class _EditPostSheetState extends State<EditPostSheet> {
  late TextEditingController _ctrl;
  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.post.caption);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                  child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                          color: AppColors.border2,
                          borderRadius: BorderRadius.circular(2)))),
              const SizedBox(height: 20),
              const Text('Edit Post',
                  style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.w800)),
              const SizedBox(height: 16),
              Container(
                  decoration: BoxDecoration(
                      color: AppColors.surface2,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.border2, width: 0.5)),
                  child: TextField(
                      controller: _ctrl,
                      style: const TextStyle(
                          color: AppColors.textPrimary, fontSize: 14),
                      maxLines: 4,
                      decoration: const InputDecoration(
                          hintText: 'Edit your caption...',
                          hintStyle: TextStyle(color: AppColors.textMuted),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.all(14)))),
              const SizedBox(height: 16),
              GradientButton(
                label: 'Save Changes',
                onTap: () {
                  widget.onSave(_ctrl.text.trim());
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: const Text('✅ Post updated!'),
                      backgroundColor: AppColors.surface2,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12))));
                },
                gradient: kAccentGradient,
              ),
              const SizedBox(height: 8),
            ]),
      ),
    );
  }
}

class _AddStoryItem extends StatelessWidget {
  const _AddStoryItem();
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 14),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
                color: AppColors.surface2,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.border2, width: 1)),
            child: const Icon(Icons.add_rounded,
                color: AppColors.textMuted, size: 26)),
        const SizedBox(height: 5),
        const Text('Your story',
            style: TextStyle(color: AppColors.textMuted, fontSize: 10)),
      ]),
    );
  }
}

class _StoryItem extends StatelessWidget {
  final StoryModel story;
  const _StoryItem({required this.story});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => StoryViewerScreen(story: story),
            transitionsBuilder: (_, anim, __, child) =>
                FadeTransition(opacity: anim, child: child),
          )),
      child: Padding(
        padding: const EdgeInsets.only(right: 14),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: 66,
            height: 66,
            padding: const EdgeInsets.all(2),
            decoration: const BoxDecoration(
                gradient: kPinkGradient, shape: BoxShape.circle),
            child: Container(
                decoration: const BoxDecoration(
                    color: AppColors.bg, shape: BoxShape.circle),
                child: Center(
                    child: Text(story.emoji,
                        style: const TextStyle(fontSize: 26)))),
          ),
          const SizedBox(height: 5),
          Text(story.name,
              style: const TextStyle(color: AppColors.textMuted, fontSize: 10),
              overflow: TextOverflow.ellipsis),
        ]),
      ),
    );
  }
}

class _PostCard extends StatefulWidget {
  final PostModel post;
  final VoidCallback onLike, onSave, onDelete, onEdit;
  final bool isOwn;
  const _PostCard(
      {required this.post,
      required this.onLike,
      required this.onSave,
      required this.onDelete,
      required this.onEdit,
      required this.isOwn});
  @override
  State<_PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<_PostCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _heartCtrl;
  late Animation<double> _heartScale;

  @override
  void initState() {
    super.initState();
    _heartCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 300));
    _heartScale = TweenSequence([
      TweenSequenceItem(tween: Tween<double>(begin: 1, end: 1.3), weight: 40),
      TweenSequenceItem(
          tween: Tween<double>(begin: 1.3, end: 0.95), weight: 30),
      TweenSequenceItem(tween: Tween<double>(begin: 0.95, end: 1), weight: 30),
    ]).animate(CurvedAnimation(parent: _heartCtrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _heartCtrl.dispose();
    super.dispose();
  }

  void _onLike() {
    _heartCtrl.forward(from: 0);
    widget.onLike();
  }

  void _openUserProfile() {
    final user = userProfiles[widget.post.userId];
    if (user != null) {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => ProfileScreen(
                  isOwnProfile: false, user: user, post: widget.post)));
    }
  }

  void _showPostOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Center(
              child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                      color: AppColors.border2,
                      borderRadius: BorderRadius.circular(2)))),
          const SizedBox(height: 16),
          if (widget.isOwn) ...[
            _OptionTile(
                icon: Icons.edit_rounded,
                label: 'Edit Caption',
                color: AppColors.accent,
                onTap: () {
                  Navigator.pop(context);
                  widget.onEdit();
                }),
            _OptionTile(
                icon: Icons.delete_rounded,
                label: 'Delete Post',
                color: AppColors.accentPink,
                onTap: () {
                  Navigator.pop(context);
                  widget.onDelete();
                }),
          ] else ...[
            _OptionTile(
                icon: Icons.person_outline_rounded,
                label: 'View Profile',
                color: AppColors.accent,
                onTap: () {
                  Navigator.pop(context);
                  _openUserProfile();
                }),
            _OptionTile(
                icon: Icons.flag_outlined,
                label: 'Report Post',
                color: AppColors.amber,
                onTap: () => Navigator.pop(context)),
          ],
          _OptionTile(
              icon: Icons.share_rounded,
              label: 'Share',
              color: AppColors.teal,
              onTap: () => Navigator.pop(context)),
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final post = widget.post;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: GlassCard(
        radius: 20,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
            child: Row(children: [
              GestureDetector(
                onTap: _openUserProfile,
                child: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                        gradient: LinearGradient(
                            colors: [post.bgColor1, post.bgColor2]),
                        shape: BoxShape.circle),
                    child: Center(
                        child: Text(post.emoji,
                            style: const TextStyle(fontSize: 18)))),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: GestureDetector(
                  onTap: _openUserProfile,
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(post.username,
                            style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 13,
                                fontWeight: FontWeight.w700)),
                        Text('${post.location} · ${post.timeAgo}',
                            style: const TextStyle(
                                color: AppColors.textMuted, fontSize: 11)),
                      ]),
                ),
              ),
              GestureDetector(
                  onTap: _showPostOptions,
                  child: const Icon(Icons.more_horiz,
                      color: AppColors.textMuted, size: 20)),
            ]),
          ),
          Stack(children: [
            Container(
              height: 220,
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [post.bgColor1, post.bgColor2])),
              child: Center(
                  child:
                      Text(post.emoji, style: const TextStyle(fontSize: 64))),
            ),
            if (post.isVideo) ...[
              Positioned(
                  top: 10,
                  left: 10,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(8)),
                    child: const Row(children: [
                      Icon(Icons.videocam_rounded,
                          color: Colors.white, size: 14),
                      SizedBox(width: 4),
                      Text('VIDEO',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1))
                    ]),
                  )),
              const Center(
                  child: Icon(Icons.play_circle_filled_rounded,
                      color: Colors.white54, size: 56)),
            ],
          ]),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
            child: Row(children: [
              GestureDetector(
                  onTap: _onLike,
                  child: ScaleTransition(
                      scale: _heartScale,
                      child: Icon(
                          post.liked
                              ? Icons.favorite_rounded
                              : Icons.favorite_border_rounded,
                          color: post.liked
                              ? AppColors.accentPink
                              : AppColors.textMuted,
                          size: 24))),
              const SizedBox(width: 4),
              Text(_fmt(post.likes + (post.liked ? 1 : 0)),
                  style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 13,
                      fontWeight: FontWeight.w600)),
              const SizedBox(width: 16),
              const Icon(Icons.chat_bubble_outline_rounded,
                  color: AppColors.textMuted, size: 22),
              const SizedBox(width: 4),
              Text(_fmt(post.comments),
                  style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 13,
                      fontWeight: FontWeight.w600)),
              const SizedBox(width: 16),
              const Icon(Icons.send_outlined,
                  color: AppColors.textMuted, size: 22),
              const Spacer(),
              GestureDetector(
                  onTap: widget.onSave,
                  child: Icon(
                      post.saved
                          ? Icons.bookmark_rounded
                          : Icons.bookmark_border_rounded,
                      color:
                          post.saved ? AppColors.accent : AppColors.textMuted,
                      size: 22)),
            ]),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 14),
            child: RichText(
                text: TextSpan(
                    style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 13,
                        height: 1.5),
                    children: [
                  TextSpan(
                      text: '${post.username} ',
                      style: const TextStyle(fontWeight: FontWeight.w700)),
                  TextSpan(text: post.caption),
                ])),
          ),
        ]),
      ),
    );
  }

  String _fmt(int n) =>
      n >= 1000 ? '${(n / 1000).toStringAsFixed(1)}K' : n.toString();
}

class _OptionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _OptionTile(
      {required this.icon,
      required this.label,
      required this.color,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
            color: AppColors.surface2, borderRadius: BorderRadius.circular(14)),
        child: Row(children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 14),
          Text(label,
              style: TextStyle(
                  color: color, fontSize: 15, fontWeight: FontWeight.w600))
        ]),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// 4. EXPLORE SCREEN
// ─────────────────────────────────────────────

class ExploreScreen extends StatelessWidget {
  const ExploreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
                padding: EdgeInsets.fromLTRB(20, 12, 20, 4),
                child: Text('Explore',
                    style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5))),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 14),
              child: Container(
                decoration: BoxDecoration(
                    color: AppColors.surface2,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border, width: 0.5)),
                child: const TextField(
                  style: TextStyle(color: AppColors.textPrimary, fontSize: 15),
                  decoration: InputDecoration(
                      hintText: 'Search people, topics, trends...',
                      hintStyle:
                          TextStyle(color: AppColors.textMuted, fontSize: 14),
                      prefixIcon: Icon(Icons.search_rounded,
                          color: AppColors.textMuted, size: 20),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 14)),
                ),
              ),
            ),
            SizedBox(
              height: 36,
              child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    _FilterChip(label: 'All', active: true),
                    _FilterChip(label: 'People'),
                    _FilterChip(label: 'Videos'),
                    _FilterChip(label: 'Music'),
                    _FilterChip(label: 'Travel'),
                    _FilterChip(label: 'Food'),
                  ]),
            ),
            const SizedBox(height: 14),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                          height: 340,
                          child: Row(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Expanded(
                                    child: _ExploreCell(
                                        emoji: '🌃',
                                        label: 'Night Vibes',
                                        color1: const Color(0xFF0F2027),
                                        color2: const Color(0xFF2C5364))),
                                const SizedBox(width: 10),
                                Expanded(
                                    child: Column(children: [
                                  Expanded(
                                      child: _ExploreCell(
                                          emoji: '🎵',
                                          label: 'Music',
                                          color1: const Color(0xFF360033),
                                          color2: const Color(0xFF0B8793))),
                                  const SizedBox(height: 10),
                                  Expanded(
                                      child: _ExploreCell(
                                          emoji: '🌿',
                                          label: 'Nature',
                                          color1: const Color(0xFF11998E),
                                          color2: const Color(0xFF38EF7D))),
                                ])),
                              ])),
                      const SizedBox(height: 24),
                      const Text('Trending now 🔥',
                          style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 18,
                              fontWeight: FontWeight.w700)),
                      const SizedBox(height: 12),
                      ..._buildTrends(),
                      const SizedBox(height: 20),
                      const Text('Suggested people',
                          style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 18,
                              fontWeight: FontWeight.w700)),
                      const SizedBox(height: 12),
                      SizedBox(
                          height: 120,
                          child: ListView(
                              scrollDirection: Axis.horizontal,
                              children: [
                                _SuggestedUser(
                                    emoji: '🧑',
                                    name: 'Aarav M.',
                                    handle: '@aaravm'),
                                _SuggestedUser(
                                    emoji: '👩',
                                    name: 'Diya R.',
                                    handle: '@diya_r'),
                                _SuggestedUser(
                                    emoji: '🧑‍🎨',
                                    name: 'Meera K.',
                                    handle: '@meerak'),
                                _SuggestedUser(
                                    emoji: '👨‍💻',
                                    name: 'Vivaan',
                                    handle: '@vivaan'),
                              ])),
                      const SizedBox(height: 16),
                    ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static List<Widget> _buildTrends() {
    final trends = [
      ('#MumbaiNights', '24.5K posts', '🏙️'),
      ('#AnonTalks', '18.2K posts', '🎭'),
      ('#DanceCulture', '12.7K posts', '💃'),
      ('#TechIndia', '9.4K posts', '💻')
    ];
    return trends
        .asMap()
        .entries
        .map((e) => Container(
              margin: const EdgeInsets.only(bottom: 10),
              child: GlassCard(
                  padding: const EdgeInsets.all(12),
                  child: Row(children: [
                    Text('${e.key + 1}',
                        style: const TextStyle(
                            color: AppColors.accent,
                            fontSize: 14,
                            fontWeight: FontWeight.w800)),
                    const SizedBox(width: 14),
                    Expanded(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                          Text(e.value.$1,
                              style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700)),
                          Text(e.value.$2,
                              style: const TextStyle(
                                  color: AppColors.textMuted, fontSize: 11)),
                        ])),
                    Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                            color: AppColors.surface2,
                            borderRadius: BorderRadius.circular(10)),
                        child: Center(
                            child: Text(e.value.$3,
                                style: const TextStyle(fontSize: 20)))),
                  ])),
            ))
        .toList();
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool active;
  const _FilterChip({required this.label, this.active = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
          gradient: active ? kAccentGradient : null,
          color: active ? null : AppColors.surface2,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: active ? Colors.transparent : AppColors.border2,
              width: 0.5)),
      child: Text(label,
          style: TextStyle(
              color: active ? Colors.white : AppColors.textMuted,
              fontSize: 12,
              fontWeight: FontWeight.w600)),
    );
  }
}

class _ExploreCell extends StatelessWidget {
  final String emoji, label;
  final Color color1, color2;
  const _ExploreCell(
      {required this.emoji,
      required this.label,
      required this.color1,
      required this.color2});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: Stack(fit: StackFit.expand, children: [
        Container(
            decoration: BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [color1, color2])),
            child: Center(
                child: Text(emoji, style: const TextStyle(fontSize: 42)))),
        Positioned(
            bottom: 10,
            left: 10,
            child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                    color: Colors.black45,
                    borderRadius: BorderRadius.circular(20)),
                child: Text(label,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w700)))),
      ]),
    );
  }
}

class _SuggestedUser extends StatelessWidget {
  final String emoji, name, handle;
  const _SuggestedUser(
      {required this.emoji, required this.name, required this.handle});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      margin: const EdgeInsets.only(right: 10),
      child: GlassCard(
          padding: const EdgeInsets.all(10),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Container(
                width: 42,
                height: 42,
                decoration: const BoxDecoration(
                    color: AppColors.surface2, shape: BoxShape.circle),
                child: Center(
                    child: Text(emoji, style: const TextStyle(fontSize: 22)))),
            const SizedBox(height: 6),
            Text(name,
                style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 11,
                    fontWeight: FontWeight.w700),
                overflow: TextOverflow.ellipsis),
            Text(handle,
                style:
                    const TextStyle(color: AppColors.textMuted, fontSize: 10),
                overflow: TextOverflow.ellipsis),
          ])),
    );
  }
}

// ─────────────────────────────────────────────
// 5. ANON SCREEN
// ─────────────────────────────────────────────

class AnonScreen extends StatelessWidget {
  const AnonScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: CustomScrollView(slivers: [
          SliverToBoxAdapter(child: _buildHero(context)),
          SliverToBoxAdapter(child: _buildStats()),
          SliverToBoxAdapter(child: _buildStartBtn(context)),
          const SliverToBoxAdapter(
              child: Padding(
                  padding: EdgeInsets.fromLTRB(16, 0, 16, 12),
                  child: Text('Your anonymous chats',
                      style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w700)))),
          SliverList(
              delegate: SliverChildBuilderDelegate(
                  (ctx, i) => _AnonChatTile(chat: anonChats[i]),
                  childCount: anonChats.length)),
          SliverToBoxAdapter(child: _buildPrivacyNote()),
          const SliverToBoxAdapter(child: SizedBox(height: 16)),
        ]),
      ),
    );
  }

  Widget _buildHero(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      child: Column(children: [
        Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
                gradient: kTealGradient,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                      color: AppColors.teal.withValues(alpha: 0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 8))
                ]),
            child: const Icon(Icons.handshake_rounded,
                color: Colors.white, size: 34)),
        const SizedBox(height: 16),
        const Text('Anonymous Connect',
            style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 24,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.3)),
        const SizedBox(height: 8),
        const Text('Talk freely. No judgement.\nYour identity stays yours.',
            textAlign: TextAlign.center,
            style: TextStyle(
                color: AppColors.textMuted, fontSize: 14, height: 1.5)),
      ]),
    );
  }

  Widget _buildStats() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
      child: Row(children: [
        Expanded(
            child: _StatCard(
                number: '2.4K', label: 'Online now', color: AppColors.teal)),
        const SizedBox(width: 10),
        Expanded(
            child: _StatCard(
                number: '98%', label: 'Safe chats', color: AppColors.green)),
        const SizedBox(width: 10),
        Expanded(
            child: _StatCard(
                number: '0', label: 'Data stored', color: AppColors.accent)),
      ]),
    );
  }

  Widget _buildStartBtn(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
      child: _PulsingButton(
          onTap: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => const AnonChatScreen()))),
    );
  }

  Widget _buildPrivacyNote() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: GlassCard(
          padding: const EdgeInsets.all(16),
          child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.lock_rounded, color: AppColors.teal, size: 18),
                SizedBox(width: 10),
                Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      Text('Privacy first',
                          style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 13,
                              fontWeight: FontWeight.w700)),
                      SizedBox(height: 4),
                      Text(
                          'No names. No photos. No history saved after you leave. Just honest conversations with real people.',
                          style: TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 12,
                              height: 1.5)),
                    ])),
              ])),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String number, label;
  final Color color;
  const _StatCard(
      {required this.number, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Column(children: [
          Text(number,
              style: TextStyle(
                  color: color, fontSize: 20, fontWeight: FontWeight.w800)),
          const SizedBox(height: 3),
          Text(label,
              style: const TextStyle(color: AppColors.textMuted, fontSize: 10)),
        ]));
  }
}

class _PulsingButton extends StatefulWidget {
  final VoidCallback onTap;
  const _PulsingButton({required this.onTap});
  @override
  State<_PulsingButton> createState() => _PulsingButtonState();
}

class _PulsingButtonState extends State<_PulsingButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1800))
      ..repeat(reverse: true);
    _pulse = Tween<double>(begin: 1.0, end: 1.03)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _pulse,
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          height: 56,
          decoration: BoxDecoration(
              gradient: kTealGradient,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                    color: AppColors.teal.withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8))
              ]),
          child:
              const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(Icons.handshake_rounded, color: Colors.white, size: 22),
            SizedBox(width: 10),
            Text('Start Anonymous Chat',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700)),
          ]),
        ),
      ),
    );
  }
}

class _AnonChatTile extends StatelessWidget {
  final AnonChatPreview chat;
  const _AnonChatTile({required this.chat});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
          context, MaterialPageRoute(builder: (_) => const AnonChatScreen())),
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
        child: GlassCard(
            padding: const EdgeInsets.all(14),
            child: Row(children: [
              Stack(children: [
                Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                        gradient:
                            LinearGradient(colors: [chat.color1, chat.color2]),
                        shape: BoxShape.circle),
                    child: Center(
                        child: Text(chat.emoji,
                            style: const TextStyle(fontSize: 22)))),
                if (chat.online)
                  Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                          width: 13,
                          height: 13,
                          decoration: BoxDecoration(
                              color: AppColors.green,
                              shape: BoxShape.circle,
                              border: Border.all(
                                  color: AppColors.surface, width: 2)))),
              ]),
              const SizedBox(width: 12),
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Text('Stranger ${chat.id}',
                        style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 14,
                            fontWeight: FontWeight.w700)),
                    const SizedBox(height: 3),
                    Text(chat.preview,
                        style: const TextStyle(
                            color: AppColors.textMuted, fontSize: 12),
                        overflow: TextOverflow.ellipsis),
                  ])),
              Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Text(chat.timeAgo,
                    style: const TextStyle(
                        color: AppColors.textMuted, fontSize: 11)),
                if (chat.unread > 0) ...[
                  const SizedBox(height: 4),
                  Container(
                      width: 20,
                      height: 20,
                      decoration: const BoxDecoration(
                          gradient: kAccentGradient, shape: BoxShape.circle),
                      child: Center(
                          child: Text('${chat.unread}',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800)))),
                ],
              ]),
            ])),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// 6. PROFILE SCREEN
// ─────────────────────────────────────────────

class ProfileScreen extends StatefulWidget {
  final bool isOwnProfile;
  final UserModel? user;
  final PostModel? post;
  const ProfileScreen(
      {super.key, required this.isOwnProfile, this.user, this.post});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tab;
  bool _following = false;
  final emojis = [
    '🏙️',
    '☕',
    '💻',
    '🚀',
    '🌃',
    '🎧',
    '📱',
    '🌍',
    '🎨',
    '⚡',
    '🏋️',
    '🎮'
  ];

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 3, vsync: this);
    _tab.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  UserModel get _profileUser =>
      widget.user ??
      UserModel(
        name: 'Arjun Dev',
        handle: '@arjundev',
        age: 24,
        bio:
            'Startup mindset 🚀 · Coffee addict ☕\nBuilding the future one line at a time. DMs open!',
        emoji: '🧑',
        location: 'Mumbai',
        followers: 14200,
        following: 892,
        posts: 248,
      );

  String _fmtNum(int n) =>
      n >= 1000 ? '${(n / 1000).toStringAsFixed(1)}K' : n.toString();

  void _showEditProfile() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => EditProfileSheet(
          user: _profileUser,
          onSave: (n, b) => setState(() {
                _profileUser.name = n;
                _profileUser.bio = b;
              })),
    );
  }

  @override
  Widget build(BuildContext context) {
    final u = _profileUser;
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: CustomScrollView(slivers: [
        SliverToBoxAdapter(child: _buildCoverAndAvatar(u)),
        SliverToBoxAdapter(child: _buildInfo(u)),
        SliverToBoxAdapter(child: _buildBioAndStats(u)),
        SliverToBoxAdapter(child: _buildButtons()),
        SliverToBoxAdapter(child: _buildTabSection()),
      ]),
    );
  }

  Widget _buildCoverAndAvatar(UserModel u) {
    return Stack(clipBehavior: Clip.none, children: [
      Container(
        height: 160,
        decoration: const BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF2D1B69), Color(0xFF11998E)])),
        child: SafeArea(
            bottom: false,
            child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (!widget.isOwnProfile)
                        GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Container(
                                width: 38,
                                height: 38,
                                decoration: BoxDecoration(
                                    color: Colors.black26,
                                    borderRadius: BorderRadius.circular(12)),
                                child: const Icon(
                                    Icons.arrow_back_ios_new_rounded,
                                    color: Colors.white,
                                    size: 18)))
                      else
                        const SizedBox.shrink(),
                      if (widget.isOwnProfile)
                        _IconBtn(icon: Icons.settings_outlined, onTap: () {}),
                    ]))),
      ),
      Positioned(
          bottom: -44,
          left: 20,
          child: Container(
            width: 80,
            height: 80,
            padding: const EdgeInsets.all(2.5),
            decoration: const BoxDecoration(
                gradient: kPinkGradient, shape: BoxShape.circle),
            child: Container(
                decoration: const BoxDecoration(
                    color: AppColors.surface2, shape: BoxShape.circle),
                child: Center(
                    child:
                        Text(u.emoji, style: const TextStyle(fontSize: 34)))),
          )),
    ]);
  }

  Widget _buildInfo(UserModel u) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 52, 20, 0),
      child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(u.name,
              style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3)),
          const SizedBox(height: 2),
          Text('${u.handle} · ${u.location}',
              style: const TextStyle(color: AppColors.textMuted, fontSize: 13)),
        ]),
        const Spacer(),
        if (widget.isOwnProfile)
          GestureDetector(
              onTap: _showEditProfile,
              child: Container(
                  height: 36,
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  decoration: BoxDecoration(
                      color: AppColors.surface2,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border2, width: 0.5)),
                  child: const Center(
                      child: Text('Edit profile',
                          style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 13,
                              fontWeight: FontWeight.w600)))))
        else
          GestureDetector(
            onTap: () => setState(() => _following = !_following),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: 36,
              padding: const EdgeInsets.symmetric(horizontal: 18),
              decoration: BoxDecoration(
                  gradient: _following ? null : kAccentGradient,
                  color: _following ? AppColors.surface2 : null,
                  borderRadius: BorderRadius.circular(12),
                  border: _following
                      ? Border.all(color: AppColors.border2, width: 0.5)
                      : null),
              child: Center(
                  child: Text(_following ? 'Following' : 'Follow',
                      style: TextStyle(
                          color:
                              _following ? AppColors.textMuted : Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w700))),
            ),
          ),
      ]),
    );
  }

  Widget _buildBioAndStats(UserModel u) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(u.bio,
            style: const TextStyle(
                color: AppColors.textMuted, fontSize: 13, height: 1.5)),
        const SizedBox(height: 16),
        Row(children: [
          _ProfileStat(number: '${u.posts}', label: 'Posts'),
          const SizedBox(width: 32),
          _ProfileStat(number: _fmtNum(u.followers), label: 'Followers'),
          const SizedBox(width: 32),
          _ProfileStat(number: _fmtNum(u.following), label: 'Following'),
        ]),
      ]),
    );
  }

  Widget _buildButtons() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(children: [
        Expanded(
            child: GestureDetector(
          // FIX: AI Chat button now navigates to AIChatScreen
          onTap: () => Navigator.push(
              context, MaterialPageRoute(builder: (_) => const AIChatScreen())),
          child: Container(
              height: 38,
              decoration: BoxDecoration(
                  gradient: kAccentGradient,
                  borderRadius: BorderRadius.circular(12)),
              child: Center(
                  child: Text(widget.isOwnProfile ? 'AI Chat ✨' : 'Message',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w700)))),
        )),
        const SizedBox(width: 10),
        Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
                color: AppColors.surface2,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border2, width: 0.5)),
            child: Icon(
                widget.isOwnProfile ? Icons.qr_code_rounded : Icons.more_horiz,
                color: AppColors.textPrimary,
                size: 18)),
      ]),
    );
  }

  Widget _buildTabSection() {
    return Column(children: [
      Container(
          decoration: const BoxDecoration(
              border: Border(
                  bottom: BorderSide(color: AppColors.border, width: 0.5))),
          child: TabBar(
            controller: _tab,
            indicatorColor: AppColors.accent,
            indicatorWeight: 2,
            labelColor: AppColors.accent,
            unselectedLabelColor: AppColors.textMuted,
            tabs: const [
              Tab(icon: Icon(Icons.grid_view_rounded, size: 20)),
              Tab(icon: Icon(Icons.video_collection_outlined, size: 20)),
              Tab(icon: Icon(Icons.favorite_border_rounded, size: 20))
            ],
          )),
      GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.all(2),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3, crossAxisSpacing: 2, mainAxisSpacing: 2),
        itemCount: emojis.length,
        itemBuilder: (_, i) => Container(
            color: AppColors.surface2,
            child: Center(
                child: Text(emojis[i], style: const TextStyle(fontSize: 30)))),
      ),
    ]);
  }
}

class EditProfileSheet extends StatefulWidget {
  final UserModel user;
  final Function(String name, String bio) onSave;
  const EditProfileSheet({super.key, required this.user, required this.onSave});
  @override
  State<EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends State<EditProfileSheet> {
  late TextEditingController _nameCtrl, _bioCtrl;
  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.user.name);
    _bioCtrl = TextEditingController(text: widget.user.bio);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _bioCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                    child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                            color: AppColors.border2,
                            borderRadius: BorderRadius.circular(2)))),
                const SizedBox(height: 20),
                const Text('Edit Profile',
                    style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.w800)),
                const SizedBox(height: 20),
                const Text('Name',
                    style: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 12,
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Container(
                    decoration: BoxDecoration(
                        color: AppColors.surface2,
                        borderRadius: BorderRadius.circular(14),
                        border:
                            Border.all(color: AppColors.border2, width: 0.5)),
                    child: TextField(
                        controller: _nameCtrl,
                        style: const TextStyle(
                            color: AppColors.textPrimary, fontSize: 14),
                        decoration: const InputDecoration(
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.all(14)))),
                const SizedBox(height: 14),
                const Text('Bio',
                    style: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 12,
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Container(
                    decoration: BoxDecoration(
                        color: AppColors.surface2,
                        borderRadius: BorderRadius.circular(14),
                        border:
                            Border.all(color: AppColors.border2, width: 0.5)),
                    child: TextField(
                        controller: _bioCtrl,
                        style: const TextStyle(
                            color: AppColors.textPrimary, fontSize: 14),
                        maxLines: 3,
                        decoration: const InputDecoration(
                            hintText: 'Tell the world about yourself...',
                            hintStyle: TextStyle(color: AppColors.textMuted),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.all(14)))),
                const SizedBox(height: 16),
                GradientButton(
                  label: 'Save Profile',
                  onTap: () {
                    widget.onSave(_nameCtrl.text.trim(), _bioCtrl.text.trim());
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: const Text('✅ Profile updated!'),
                        backgroundColor: AppColors.surface2,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12))));
                  },
                  gradient: kAccentGradient,
                ),
                const SizedBox(height: 8),
              ])),
    );
  }
}

class _ProfileStat extends StatelessWidget {
  final String number, label;
  const _ProfileStat({required this.number, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(number,
          style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w800)),
      Text(label,
          style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
    ]);
  }
}

// ─────────────────────────────────────────────
// 7. NOTIFICATIONS SCREEN
// ─────────────────────────────────────────────

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});
  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  late List<NotificationModel> _notifs;

  @override
  void initState() {
    super.initState();
    _notifs = List.from(notifications);
  }

  @override
  Widget build(BuildContext context) {
    final unread = _notifs.where((n) => !n.isRead).toList();
    final read = _notifs.where((n) => n.isRead).toList();

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
            padding: const EdgeInsets.fromLTRB(8, 8, 16, 8),
            child: Row(children: [
              GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Padding(
                      padding: EdgeInsets.all(8),
                      child: Icon(Icons.arrow_back_ios_new_rounded,
                          color: AppColors.textPrimary, size: 20))),
              const SizedBox(width: 4),
              const Text('Notifications',
                  style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 22,
                      fontWeight: FontWeight.w800)),
              const Spacer(),
              GestureDetector(
                onTap: () => setState(() {
                  _notifs = _notifs
                      .map((n) => NotificationModel(
                          emoji: n.emoji,
                          username: n.username,
                          action: n.action,
                          timeAgo: n.timeAgo,
                          isRead: true,
                          color: n.color))
                      .toList();
                }),
                child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                        color: AppColors.surface2,
                        borderRadius: BorderRadius.circular(10)),
                    child: const Text('Mark all read',
                        style: TextStyle(
                            color: AppColors.accent,
                            fontSize: 12,
                            fontWeight: FontWeight.w600))),
              ),
            ])),
        Expanded(
            child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
              if (unread.isNotEmpty) ...[
                Padding(
                    padding: const EdgeInsets.only(bottom: 10, top: 4),
                    child: Row(children: [
                      const Text('New',
                          style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 14,
                              fontWeight: FontWeight.w700)),
                      const SizedBox(width: 8),
                      Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                              gradient: kPinkGradient,
                              borderRadius: BorderRadius.circular(10)),
                          child: Text('${unread.length}',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800))),
                    ])),
                ...unread.map((n) => _NotifTile(notif: n)),
                const SizedBox(height: 16),
              ],
              if (read.isNotEmpty) ...[
                const Padding(
                    padding: EdgeInsets.only(bottom: 10),
                    child: Text('Earlier',
                        style: TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 14,
                            fontWeight: FontWeight.w700))),
                ...read.map((n) => _NotifTile(notif: n)),
              ],
            ])),
      ])),
    );
  }
}

class _NotifTile extends StatelessWidget {
  final NotificationModel notif;
  const _NotifTile({required this.notif});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
          color: notif.isRead ? AppColors.surface : AppColors.surface2,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: notif.isRead ? AppColors.border : AppColors.border2,
              width: 0.5)),
      child: Row(children: [
        Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
                color: notif.color.withValues(alpha: 0.15),
                shape: BoxShape.circle),
            child: Center(
                child:
                    Text(notif.emoji, style: const TextStyle(fontSize: 20)))),
        const SizedBox(width: 12),
        Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          RichText(
              text: TextSpan(
                  style: const TextStyle(
                      color: AppColors.textPrimary, fontSize: 13, height: 1.4),
                  children: [
                TextSpan(
                    text: '${notif.username} ',
                    style: const TextStyle(fontWeight: FontWeight.w700)),
                TextSpan(text: notif.action),
              ])),
          const SizedBox(height: 3),
          Text(notif.timeAgo,
              style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
        ])),
        if (!notif.isRead)
          Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                  gradient: kPinkGradient, shape: BoxShape.circle)),
      ]),
    );
  }
}

// ─────────────────────────────────────────────
// 8. DM INBOX
// ─────────────────────────────────────────────

class DMInboxScreen extends StatefulWidget {
  const DMInboxScreen({super.key});
  @override
  State<DMInboxScreen> createState() => _DMInboxScreenState();
}

class _DMInboxScreenState extends State<DMInboxScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
            padding: const EdgeInsets.fromLTRB(8, 8, 16, 16),
            child: Row(children: [
              GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Padding(
                      padding: EdgeInsets.all(8),
                      child: Icon(Icons.arrow_back_ios_new_rounded,
                          color: AppColors.textPrimary, size: 20))),
              const SizedBox(width: 4),
              ShaderMask(
                  shaderCallback: (b) => kPinkGradient.createShader(b),
                  child: const Text('Messages',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w800))),
              const Spacer(),
              _IconBtn(icon: Icons.edit_outlined, onTap: () {}),
            ])),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
          child: Container(
            decoration: BoxDecoration(
                color: AppColors.surface2,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border, width: 0.5)),
            child: const TextField(
                style: TextStyle(color: AppColors.textPrimary, fontSize: 14),
                decoration: InputDecoration(
                    hintText: 'Search messages...',
                    hintStyle: TextStyle(color: AppColors.textMuted),
                    prefixIcon: Icon(Icons.search_rounded,
                        color: AppColors.textMuted, size: 20),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 12))),
          ),
        ),
        Expanded(
            child: ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: dmConversations.length,
          itemBuilder: (ctx, i) => _DMTile(
              convo: dmConversations[i],
              onTap: () async {
                await Navigator.push(
                    ctx,
                    MaterialPageRoute(
                        builder: (_) =>
                            DMChatScreen(convo: dmConversations[i])));
                setState(() {});
              }),
        )),
      ])),
    );
  }
}

class _DMTile extends StatelessWidget {
  final DMConversation convo;
  final VoidCallback onTap;
  const _DMTile({required this.convo, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          child: GlassCard(
              padding: const EdgeInsets.all(14),
              child: Row(children: [
                Stack(children: [
                  Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                          gradient: LinearGradient(
                              colors: [convo.color1, convo.color2]),
                          shape: BoxShape.circle),
                      child: Center(
                          child: Text(convo.emoji,
                              style: const TextStyle(fontSize: 24)))),
                  if (convo.online)
                    Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                            width: 14,
                            height: 14,
                            decoration: BoxDecoration(
                                color: AppColors.green,
                                shape: BoxShape.circle,
                                border: Border.all(
                                    color: AppColors.surface, width: 2)))),
                ]),
                const SizedBox(width: 12),
                Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      Text(convo.username,
                          style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 15,
                              fontWeight: FontWeight.w700)),
                      const SizedBox(height: 3),
                      Text(convo.lastMessage,
                          style: TextStyle(
                              color: convo.unread > 0
                                  ? AppColors.textPrimary
                                  : AppColors.textMuted,
                              fontSize: 13,
                              fontWeight: convo.unread > 0
                                  ? FontWeight.w600
                                  : FontWeight.normal),
                          overflow: TextOverflow.ellipsis),
                    ])),
                Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  Text(convo.timeAgo,
                      style: const TextStyle(
                          color: AppColors.textMuted, fontSize: 11)),
                  if (convo.unread > 0) ...[
                    const SizedBox(height: 4),
                    Container(
                        width: 20,
                        height: 20,
                        decoration: const BoxDecoration(
                            gradient: kAccentGradient, shape: BoxShape.circle),
                        child: Center(
                            child: Text('${convo.unread}',
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800)))),
                  ],
                ]),
              ]))),
    );
  }
}

// ─────────────────────────────────────────────
// 9. DM CHAT SCREEN
// ─────────────────────────────────────────────

class DMChatScreen extends StatefulWidget {
  final DMConversation convo;
  const DMChatScreen({super.key, required this.convo});
  @override
  State<DMChatScreen> createState() => _DMChatScreenState();
}

class _DMChatScreenState extends State<DMChatScreen> {
  final _ctrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  bool _isTyping = false;
  int _replyIdx = 0;

  @override
  void dispose() {
    _ctrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _send() {
    final text = _ctrl.text.trim();
    if (text.isEmpty) return;
    setState(() {
      widget.convo.messages.add(ChatMessage(text, true));
      _ctrl.clear();
      _isTyping = true;
    });
    _scrollToBottom();
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (!mounted) return;
      setState(() {
        _isTyping = false;
        widget.convo.messages
            .add(ChatMessage(dmReplies[_replyIdx % dmReplies.length], false));
        _replyIdx++;
      });
      _scrollToBottom();
    });
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 80), () {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(_scrollCtrl.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
          child: Column(children: [
        _buildHeader(),
        Expanded(
            child: ListView.builder(
          controller: _scrollCtrl,
          padding: const EdgeInsets.all(16),
          itemCount: widget.convo.messages.length + (_isTyping ? 1 : 0) + 1,
          itemBuilder: (ctx, i) {
            if (i == 0) return const _DateDivider();
            final idx = i - 1;
            if (_isTyping && idx == widget.convo.messages.length)
              return const _TypingBubble();
            return _MessageBubble(msg: widget.convo.messages[idx]);
          },
        )),
        _buildInput(),
      ])),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 8, 16, 12),
      decoration: const BoxDecoration(
          border:
              Border(bottom: BorderSide(color: AppColors.border, width: 0.5))),
      child: Row(children: [
        GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Padding(
                padding: EdgeInsets.all(8),
                child: Icon(Icons.arrow_back_ios_new_rounded,
                    color: AppColors.textPrimary, size: 20))),
        GestureDetector(
          onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => ProfileScreen(
                      isOwnProfile: false,
                      user: userProfiles[widget.convo.userId]))),
          child: Stack(children: [
            Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                        colors: [widget.convo.color1, widget.convo.color2]),
                    shape: BoxShape.circle),
                child: Center(
                    child: Text(widget.convo.emoji,
                        style: const TextStyle(fontSize: 20)))),
            if (widget.convo.online)
              Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                          color: AppColors.green,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.bg, width: 2)))),
          ]),
        ),
        const SizedBox(width: 10),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(widget.convo.username,
              style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w700)),
          Row(children: [
            Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                    color: widget.convo.online
                        ? AppColors.green
                        : AppColors.textMuted,
                    shape: BoxShape.circle)),
            const SizedBox(width: 5),
            Text(widget.convo.online ? 'Active now' : 'Offline',
                style: TextStyle(
                    color: widget.convo.online
                        ? AppColors.green
                        : AppColors.textMuted,
                    fontSize: 11)),
          ]),
        ]),
        const Spacer(),
        _IconBtn(icon: Icons.videocam_outlined, onTap: () {}),
        const SizedBox(width: 6),
        _IconBtn(icon: Icons.more_horiz, onTap: () {}),
      ]),
    );
  }

  Widget _buildInput() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 12, 14),
      decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(top: BorderSide(color: AppColors.border, width: 0.5))),
      child: Row(children: [
        Expanded(
            child: Container(
          decoration: BoxDecoration(
              color: AppColors.surface2,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.border, width: 0.5)),
          child: TextField(
              controller: _ctrl,
              style:
                  const TextStyle(color: AppColors.textPrimary, fontSize: 14),
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _send(),
              decoration: const InputDecoration(
                  hintText: 'Message...',
                  hintStyle:
                      TextStyle(color: AppColors.textMuted, fontSize: 14),
                  border: InputBorder.none,
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 18, vertical: 12))),
        )),
        const SizedBox(width: 8),
        GestureDetector(
            onTap: _send,
            child: Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                    gradient: kAccentGradient,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                          color: AppColors.accent.withValues(alpha: 0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4))
                    ]),
                child: const Icon(Icons.send_rounded,
                    color: Colors.white, size: 18))),
      ]),
    );
  }
}

// ─────────────────────────────────────────────
// 10. ANON CHAT SCREEN
// ─────────────────────────────────────────────

class AnonChatScreen extends StatefulWidget {
  const AnonChatScreen({super.key});
  @override
  State<AnonChatScreen> createState() => _AnonChatScreenState();
}

class _AnonChatScreenState extends State<AnonChatScreen> {
  final List<ChatMessage> _msgs = [
    ChatMessage("Hey! So I've been thinking about something 👀", false),
    ChatMessage("Oh yeah? Tell me everything 😄", true),
    ChatMessage(
        "Do you think people are fundamentally good or does society just keep them in check?",
        false),
    ChatMessage(
        "Wow okay jumping straight in! I think... mostly good? But environment shapes everything.",
        true),
  ];
  final _controller = TextEditingController();
  final _scrollCtrl = ScrollController();
  bool _isTyping = false;
  int _replyIdx = 0;

  @override
  void dispose() {
    _controller.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _msgs.add(ChatMessage(text, true));
      _controller.clear();
      _isTyping = true;
    });
    _scrollToBottom();
    Future.delayed(const Duration(milliseconds: 1400), () {
      if (!mounted) return;
      setState(() {
        _isTyping = false;
        _msgs.add(
            ChatMessage(anonReplies[_replyIdx % anonReplies.length], false));
        _replyIdx++;
      });
      _scrollToBottom();
    });
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 80), () {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(_scrollCtrl.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
          child: Column(children: [
        _buildHeader(),
        _buildEncryptedBadge(),
        Expanded(
            child: ListView.builder(
          controller: _scrollCtrl,
          padding: const EdgeInsets.all(16),
          itemCount: _msgs.length + (_isTyping ? 1 : 0) + 1,
          itemBuilder: (ctx, i) {
            if (i == 0) return const _DateDivider();
            final idx = i - 1;
            if (_isTyping && idx == _msgs.length) return const _TypingBubble();
            return _MessageBubble(msg: _msgs[idx]);
          },
        )),
        _buildInput(),
      ])),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 8, 16, 12),
      decoration: const BoxDecoration(
          border:
              Border(bottom: BorderSide(color: AppColors.border, width: 0.5))),
      child: Row(children: [
        GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Padding(
                padding: EdgeInsets.all(8),
                child: Icon(Icons.arrow_back_ios_new_rounded,
                    color: AppColors.textPrimary, size: 20))),
        Stack(children: [
          Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                  gradient: kTealGradient, shape: BoxShape.circle),
              child: const Center(
                  child: Text('🦊', style: TextStyle(fontSize: 20)))),
          Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                      color: AppColors.green,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.bg, width: 2)))),
        ]),
        const SizedBox(width: 10),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Stranger #2841',
              style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w700)),
          Row(children: [
            Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                    color: AppColors.green, shape: BoxShape.circle)),
            const SizedBox(width: 5),
            const Text('Online · Anonymous',
                style: TextStyle(color: AppColors.green, fontSize: 11))
          ]),
        ]),
        const Spacer(),
        _IconBtn(icon: Icons.more_horiz, onTap: () {}),
      ]),
    );
  }

  Widget _buildEncryptedBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: AppColors.surface2,
      child: Row(children: [
        const Icon(Icons.lock_rounded, color: AppColors.teal, size: 14),
        const SizedBox(width: 7),
        Text('End-to-end encrypted · No personal data shared',
            style: TextStyle(
                color: AppColors.textMuted.withValues(alpha: 0.8),
                fontSize: 11)),
      ]),
    );
  }

  Widget _buildInput() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 12, 14),
      decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(top: BorderSide(color: AppColors.border, width: 0.5))),
      child: Row(children: [
        Expanded(
            child: Container(
          decoration: BoxDecoration(
              color: AppColors.surface2,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.border, width: 0.5)),
          child: TextField(
              controller: _controller,
              style:
                  const TextStyle(color: AppColors.textPrimary, fontSize: 14),
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _sendMessage(),
              decoration: const InputDecoration(
                  hintText: 'Message anonymously...',
                  hintStyle:
                      TextStyle(color: AppColors.textMuted, fontSize: 14),
                  border: InputBorder.none,
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 18, vertical: 12))),
        )),
        const SizedBox(width: 8),
        GestureDetector(
            onTap: _sendMessage,
            child: Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                    gradient: kTealGradient,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                          color: AppColors.teal.withValues(alpha: 0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4))
                    ]),
                child: const Icon(Icons.send_rounded,
                    color: Colors.white, size: 18))),
      ]),
    );
  }
}

// ─────────────────────────────────────────────
// SHARED CHAT WIDGETS
// ─────────────────────────────────────────────

class _DateDivider extends StatelessWidget {
  const _DateDivider();
  @override
  Widget build(BuildContext context) {
    return Center(
        child: Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
      decoration: BoxDecoration(
          color: AppColors.surface2, borderRadius: BorderRadius.circular(20)),
      child: const Text('Today',
          style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
    ));
  }
}

class _MessageBubble extends StatelessWidget {
  final ChatMessage msg;
  const _MessageBubble({required this.msg});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: msg.isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        constraints:
            BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.72),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
        decoration: BoxDecoration(
          gradient: msg.isMe ? kAccentGradient : null,
          color: msg.isMe ? null : AppColors.surface2,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: Radius.circular(msg.isMe ? 20 : 5),
            bottomRight: Radius.circular(msg.isMe ? 5 : 20),
          ),
        ),
        child: Text(msg.text,
            style: const TextStyle(
                color: AppColors.textPrimary, fontSize: 14, height: 1.4)),
      ),
    );
  }
}

class _TypingBubble extends StatelessWidget {
  const _TypingBubble();
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: const BoxDecoration(
            color: AppColors.surface2,
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
                bottomLeft: Radius.circular(5),
                bottomRight: Radius.circular(20))),
        child: Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(3, (i) => _TypingDot(delay: i * 200))),
      ),
    );
  }
}

class _TypingDot extends StatefulWidget {
  final int delay;
  const _TypingDot({required this.delay});
  @override
  State<_TypingDot> createState() => _TypingDotState();
}

class _TypingDotState extends State<_TypingDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _anim = Tween<double>(begin: 0.2, end: 1)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _ctrl.repeat(reverse: true);
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3),
      child: FadeTransition(
          opacity: _anim,
          child: Container(
              width: 7,
              height: 7,
              decoration: const BoxDecoration(
                  color: AppColors.textMuted, shape: BoxShape.circle))),
    );
  }
}

// ─────────────────────────────────────────────
// 11. AI CHAT SCREEN
// ─────────────────────────────────────────────

class AIChatScreen extends StatefulWidget {
  const AIChatScreen({super.key});

  @override
  State<AIChatScreen> createState() => _AIChatScreenState();
}

class _AIChatScreenState extends State<AIChatScreen> {
  final List<ChatMessage> messages = [];
  final TextEditingController _msgCtrl = TextEditingController();
  bool _isLoading = false;

  // Replace with your OpenAI API key from https://platform.openai.com/api-keys
  static const String _openAiApiKey = 'sk-your-api-key-here';
  static const String _openAiApiUrl =
      'https://api.openai.com/v1/chat/completions';

  @override
  void dispose() {
    _msgCtrl.dispose();
    super.dispose();
  }

  Future<String> _getAIResponse(String userMessage) async {
    try {
      if (_openAiApiKey == 'sk-your-api-key-here') {
        return 'Please set your OpenAI API key in the code.\nVisit: https://platform.openai.com/api-keys\n\nThen replace _openAiApiKey in the AIChatScreen class.';
      }

      final List<Map<String, String>> conversationHistory = [];
      final int startIndex = messages.length > 10 ? messages.length - 10 : 0;
      for (int i = startIndex; i < messages.length; i++) {
        conversationHistory.add({
          'role': messages[i].isMe ? 'user' : 'assistant',
          'content': messages[i].text,
        });
      }
      conversationHistory.add({'role': 'user', 'content': userMessage});

      final response = await http
          .post(
            Uri.parse(_openAiApiUrl),
            headers: {
              'Authorization': 'Bearer $_openAiApiKey',
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'model': 'gpt-3.5-turbo',
              'messages': conversationHistory,
              'temperature': 0.7,
              'max_tokens': 500,
            }),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices'][0]['message']['content'].trim() as String;
      } else if (response.statusCode == 401) {
        return 'Invalid API key. Please check your OpenAI API key.';
      } else if (response.statusCode == 429) {
        return 'Rate limit exceeded. Please wait a moment before sending another message.';
      } else {
        final errorData = jsonDecode(response.body);
        return 'Error: ${errorData['error']['message'] ?? 'Something went wrong'}';
      }
    } catch (e) {
      return 'Connection error: ${e.toString()}\n\nMake sure your API key is set correctly.';
    }
  }

  void _sendMessage() async {
    if (_msgCtrl.text.trim().isEmpty) return;
    final userMessage = _msgCtrl.text.trim();
    setState(() {
      messages.add(ChatMessage(userMessage, true));
      _msgCtrl.clear();
      _isLoading = true;
    });
    final aiResponse = await _getAIResponse(userMessage);
    if (mounted) {
      setState(() {
        messages.add(ChatMessage(aiResponse, false));
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0.5,
        title: const Row(
          children: [
            Icon(Icons.smart_toy_rounded, color: AppColors.accent, size: 24),
            SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('AI Chat',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary)),
                Text('Powered by OpenAI',
                    style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w400,
                        color: AppColors.textMuted)),
              ],
            ),
          ],
        ),
        centerTitle: false,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Icon(Icons.arrow_back_rounded,
              color: AppColors.textPrimary, size: 22),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: messages.isEmpty
                ? Center(
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 100,
                            height: 100,
                            decoration: const BoxDecoration(
                                gradient: kAccentGradient,
                                shape: BoxShape.circle),
                            child: const Icon(Icons.smart_toy_rounded,
                                color: Colors.white, size: 50),
                          ),
                          const SizedBox(height: 24),
                          const Text('AI Chat',
                              style: TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700)),
                          const SizedBox(height: 8),
                          const Text('Powered by OpenAI',
                              style: TextStyle(
                                  color: AppColors.textMuted, fontSize: 12)),
                          const SizedBox(height: 20),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 40),
                            child: Text(
                                'Ask me anything, and I\'ll provide intelligent responses.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: AppColors.textMuted, fontSize: 14)),
                          ),
                          const SizedBox(height: 32),
                          _SuggestionChip(
                              text: 'Explain quantum computing',
                              onTap: () {
                                _msgCtrl.text = 'Explain quantum computing';
                                _sendMessage();
                              }),
                          const SizedBox(height: 10),
                          _SuggestionChip(
                              text: 'Write a poem about nature',
                              onTap: () {
                                _msgCtrl.text = 'Write a poem about nature';
                                _sendMessage();
                              }),
                          const SizedBox(height: 10),
                          _SuggestionChip(
                              text: 'Help me debug code',
                              onTap: () {
                                _msgCtrl.text = 'Help me debug code';
                                _sendMessage();
                              }),
                          const SizedBox(height: 10),
                          _SuggestionChip(
                              text: 'What\'s the weather today?',
                              onTap: () {
                                _msgCtrl.text = 'What\'s the weather today?';
                                _sendMessage();
                              }),
                        ],
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: messages.length,
                    reverse: true,
                    itemBuilder: (ctx, i) {
                      final msg = messages[messages.length - 1 - i];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          mainAxisAlignment: msg.isMe
                              ? MainAxisAlignment.end
                              : MainAxisAlignment.start,
                          children: [
                            Flexible(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 12),
                                decoration: BoxDecoration(
                                  color: msg.isMe
                                      ? AppColors.accent
                                      : AppColors.surface2,
                                  borderRadius: BorderRadius.circular(18),
                                  border: msg.isMe
                                      ? null
                                      : Border.all(
                                          color: AppColors.border, width: 0.5),
                                ),
                                child: Text(msg.text,
                                    style: TextStyle(
                                        color: msg.isMe
                                            ? Colors.white
                                            : AppColors.textPrimary,
                                        fontSize: 14)),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
          if (_isLoading)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.surface2,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: const Row(
                      children: [
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(AppColors.accent),
                          ),
                        ),
                        SizedBox(width: 10),
                        Text('AI is thinking...',
                            style: TextStyle(
                                color: AppColors.textMuted, fontSize: 13)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: AppColors.surface,
              border:
                  Border(top: BorderSide(color: AppColors.border, width: 0.5)),
            ),
            child: SafeArea(
              top: false,
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.surface2,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: AppColors.border, width: 0.5),
                      ),
                      child: TextField(
                        controller: _msgCtrl,
                        enabled: !_isLoading,
                        decoration: const InputDecoration(
                          hintText: 'Ask me anything...',
                          hintStyle: TextStyle(color: AppColors.textMuted),
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          border: InputBorder.none,
                        ),
                        style: const TextStyle(color: AppColors.textPrimary),
                        onSubmitted: (_) => _sendMessage(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: _isLoading ? null : _sendMessage,
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: const BoxDecoration(
                        gradient: kAccentGradient,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.send_rounded,
                          color: _isLoading ? Colors.grey : Colors.white,
                          size: 20),
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

class _SuggestionChip extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  const _SuggestionChip({required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.accent, width: 1.5),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Text(text,
            style: const TextStyle(
                color: AppColors.accent,
                fontSize: 13,
                fontWeight: FontWeight.w600)),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// 12. STORY VIEWER SCREEN
// ─────────────────────────────────────────────

class StoryViewerScreen extends StatefulWidget {
  final StoryModel story;
  const StoryViewerScreen({super.key, required this.story});
  @override
  State<StoryViewerScreen> createState() => _StoryViewerScreenState();
}

class _StoryViewerScreenState extends State<StoryViewerScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _progress;
  // FIX: _replyCtrl is now actually assigned to the TextField
  final _replyCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _ctrl =
        AnimationController(vsync: this, duration: const Duration(seconds: 4))
          ..forward();
    _progress = Tween<double>(begin: 0, end: 1).animate(_ctrl);
    _ctrl.addStatusListener((s) {
      if (s == AnimationStatus.completed && mounted) Navigator.pop(context);
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _replyCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(fit: StackFit.expand, children: [
        Container(
            decoration: BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
              widget.story.color.withValues(alpha: 0.6),
              Colors.black
            ]))),
        SafeArea(
            child: Column(children: [
          Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
              child: AnimatedBuilder(
                  animation: _progress,
                  builder: (_, __) => LinearProgressIndicator(
                      value: _progress.value,
                      backgroundColor: Colors.white24,
                      color: Colors.white,
                      minHeight: 2.5,
                      borderRadius: BorderRadius.circular(2)))),
          Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
              child: Row(children: [
                Container(
                    width: 34,
                    height: 34,
                    decoration: const BoxDecoration(
                        color: Colors.white24, shape: BoxShape.circle),
                    child: Center(
                        child: Text(widget.story.emoji,
                            style: const TextStyle(fontSize: 18)))),
                const SizedBox(width: 10),
                Text(widget.story.name,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w700)),
                const SizedBox(width: 8),
                const Text('2 hours ago',
                    style: TextStyle(color: Colors.white60, fontSize: 12)),
                const Spacer(),
                GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.close_rounded,
                        color: Colors.white, size: 24)),
              ])),
          Expanded(
              child: Center(
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                Text(widget.story.emoji, style: const TextStyle(fontSize: 80)),
                const SizedBox(height: 20),
                Text("Golden hour in ${widget.story.name}'s world ✨",
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700),
                    textAlign: TextAlign.center),
                const SizedBox(height: 8),
                const Text('Some days just feel perfect',
                    style: TextStyle(color: Colors.white70, fontSize: 14)),
              ]))),
          Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
              child: Row(children: [
                Expanded(
                    child: Container(
                  height: 44,
                  decoration: BoxDecoration(
                      color: Colors.white12,
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(color: Colors.white30, width: 0.5)),
                  // FIX: controller is now assigned
                  child: TextField(
                      controller: _replyCtrl,
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                      decoration: const InputDecoration(
                          hintText: 'Reply...',
                          hintStyle: TextStyle(color: Colors.white60),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 18, vertical: 12))),
                )),
                const SizedBox(width: 10),
                const Icon(Icons.favorite_border_rounded,
                    color: Colors.white, size: 26),
                const SizedBox(width: 10),
                const Icon(Icons.send_outlined, color: Colors.white, size: 24),
              ])),
        ])),
      ]),
    );
  }
}
