import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/theme.dart';
import '../providers/auth_provider.dart';
import '../models/post_model.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/feed/feed_screen.dart';
import '../screens/feed/post_item_screen.dart';
import '../screens/feed/item_details_screen.dart';
import '../screens/saved/saved_screen.dart';
import '../screens/chat/chat_list_screen.dart';
import '../screens/chat/chat_room_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/profile/edit_profile_screen.dart';

/// Main app widget that handles auth-aware routing and bottom navigation.
class AppRouter extends StatelessWidget {
  const AppRouter({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    if (authProvider.loading) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          backgroundColor: AppColors.background,
          body: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'assets/images/haramaya_logo.png',
                  width: 100,
                  height: 100,
                ),
                const SizedBox(height: 24),
                const CircularProgressIndicator(color: AppColors.primary),
              ],
            ),
          ),
        ),
      );
    }

    return MaterialApp(
      title: 'Haramaya University Lost & Found',
      theme: buildAppTheme(),
      debugShowCheckedModeBanner: false,
      home: authProvider.isLoggedIn
          ? const MainShell()
          : const LoginScreen(),
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/register':
            return MaterialPageRoute(
                builder: (_) => const RegisterScreen());
          case '/item-details':
            final post = settings.arguments as Post;
            return MaterialPageRoute(
                builder: (_) => ItemDetailsScreen(post: post));
          case '/chat-room':
            final args = settings.arguments as Map<String, dynamic>;
            return MaterialPageRoute(
                builder: (_) => ChatRoomScreen(
                      chatId: args['chatId'],
                      otherUserId: args['otherUserId'],
                    ));
          case '/edit-profile':
            return MaterialPageRoute(
                builder: (_) => const EditProfileScreen());
          default:
            return null;
        }
      },
    );
  }
}

/// Bottom navigation shell with 5 tabs.
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  final List<String> _titles = const [
    'Haramaya Lost & Found',
    'Saved Items',
    'Create Post',
    'Messages',
    'Profile',
  ];

  void _onTabTapped(int index) {
    setState(() => _currentIndex = index);
  }

  void _switchToFeed() {
    setState(() => _currentIndex = 0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_currentIndex]),
        centerTitle: true,
        elevation: 0,
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: AppColors.border,
            height: 1,
          ),
        ),
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          const FeedScreen(),
          const SavedScreen(),
          PostItemScreen(onPostSuccess: _switchToFeed),
          const ChatListScreen(),
          const ProfileScreen(),
        ],
      ),
      // Use Flutter's built-in BottomNavigationBar — it handles safe area automatically
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        elevation: 8,
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Feed',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.bookmark_outline),
            activeIcon: Icon(Icons.bookmark),
            label: 'Saved',
          ),
          BottomNavigationBarItem(
            icon: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primary, Color(0xFF5856D6)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    offset: const Offset(0, 3),
                    blurRadius: 6,
                  ),
                ],
              ),
              child: const Icon(Icons.add, color: Colors.white, size: 26),
            ),
            label: '',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline),
            activeIcon: Icon(Icons.chat_bubble),
            label: 'Chats',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
