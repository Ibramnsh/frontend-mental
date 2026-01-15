import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/daily_checkin.dart';
import '../models/user.dart';
import '../services/auth_service.dart';
import '../services/checkin_service.dart';
import '../services/chat_service.dart';
import 'checkin_screen.dart';
import 'chat_list_screen.dart';
import 'chat_screen.dart';
import 'history_screen.dart';
import 'toolbox_screen.dart';
import 'quiz_screen.dart';
import '../main.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // --- Palet Warna (Konsisten dengan AuthScreen) ---
  final Color _primaryColor = const Color(0xFF5B9A8B);
  final Color _backgroundColor = const Color(0xFFF7F9F9);
  final Color _textColor = const Color(0xFF2D3B38);
  final Color _surfaceColor = Colors.white;

  // State Data
  User? _user;
  DailyCheckin? _todayCheckin;
  List<dynamic> _recentSessions = [];
  bool _isLoading = true;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final results = await Future.wait([
        AuthService.getUser(),
        CheckinService.getTodayCheckin(),
        ChatService.getSessions(),
      ]);

      if (mounted) {
        setState(() {
          _user = results[0] as User?;
          _todayCheckin = results[1] as DailyCheckin?;
          List<dynamic> allSessions = results[2] as List<dynamic>;
          _recentSessions = allSessions.take(3).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error loading home data: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _logout() async {
    await AuthService.logout();
    if (mounted) {
      authWrapperKey.currentState?.logout();
    }
  }

  // Helper Icon Mood
  IconData _getMoodIcon(int mood) {
    switch (mood) {
      case 1:
        return Icons.sentiment_very_dissatisfied_rounded;
      case 2:
        return Icons.sentiment_dissatisfied_rounded;
      case 3:
        return Icons.sentiment_neutral_rounded;
      case 4:
        return Icons.sentiment_satisfied_rounded;
      case 5:
        return Icons.sentiment_very_satisfied_rounded;
      default:
        return Icons.help_outline_rounded;
    }
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning,';
    if (hour < 17) return 'Good Afternoon,';
    return 'Good Evening,';
  }

  void _navigateToCheckin() async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
          builder: (_) => CheckinScreen(existingCheckin: _todayCheckin)),
    );
    if (result == true) _loadData();
  }

  void _navigateToChatList() {
    Navigator.of(context)
        .push(
          MaterialPageRoute(builder: (_) => const ChatListScreen()),
        )
        .then((_) => _loadData());
  }

  void _openChatSession(String sessionId) {
    Navigator.of(context)
        .push(
          MaterialPageRoute(builder: (_) => ChatScreen(sessionId: sessionId)),
        )
        .then((_) => _loadData());
  }

  // --- UI BUILDERS ---

  // 1. HOME TAB (Updated dengan Header Baru)
  Widget _buildHomeTab() {
    return RefreshIndicator(
      color: _primaryColor,
      onRefresh: _loadData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.zero, // Padding 0 agar header menempel ke atas
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- Custom Header Section ---
            Container(
              padding: const EdgeInsets.fromLTRB(24, 60, 24, 30),
              decoration: BoxDecoration(
                color: _primaryColor,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
                boxShadow: [
                  BoxShadow(
                    color: _primaryColor.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.wb_sunny_outlined,
                                color: Colors.white.withOpacity(0.8), size: 16),
                            const SizedBox(width: 6),
                            Text(
                              _getGreeting(),
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white.withOpacity(0.9),
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _user != null ? _user!.name : 'Friend',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Let's take a moment for yourself.",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: Colors.white.withOpacity(0.3), width: 2),
                    ),
                    child: CircleAvatar(
                      radius: 24,
                      backgroundColor: Colors.white.withOpacity(0.2),
                      child: Text(
                        _user != null && _user!.name.isNotEmpty
                            ? _user!.name[0].toUpperCase()
                            : '?',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // --- Body Content ---
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildDailyCheckinCard(),
                  const SizedBox(height: 24),
                  _buildChatCompanionCard(),
                  const SizedBox(height: 32),
                  if (_recentSessions.isNotEmpty) ...[
                    _buildRecentConversationsList(),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget Terpisah: Kartu Daily Check-in
  Widget _buildDailyCheckinCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: _surfaceColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Daily Check-in",
                style: TextStyle(
                  color: _textColor,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.calendar_today_rounded,
                    color: _primaryColor, size: 18),
              )
            ],
          ),
          const SizedBox(height: 20),
          if (_todayCheckin != null) ...[
            // Tampilan jika sudah check-in
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _StatItemDark(
                  // Menggunakan versi Dark Text karena background putih
                  label: 'Mood',
                  icon: _getMoodIcon(_todayCheckin!.mood),
                  value: '${_todayCheckin!.mood}/5',
                  color: _primaryColor,
                ),
                _StatItemDark(
                  label: 'Energy',
                  icon: Icons.battery_charging_full_rounded,
                  value: _todayCheckin!.energy.toUpperCase(),
                  color: _primaryColor,
                ),
                _StatItemDark(
                  label: 'Sleep',
                  icon: _todayCheckin!.sleep
                      ? Icons.bedtime_rounded
                      : Icons.bedtime_off_rounded,
                  value: _todayCheckin!.sleep ? 'Good' : 'Poor',
                  color: _primaryColor,
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => _navigateToCheckin(),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: _primaryColor),
                  foregroundColor: _primaryColor,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text('Journal Updated',
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ] else ...[
            // Tampilan jika belum check-in
            Text(
              "How are you feeling right now?",
              style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _navigateToCheckin(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primaryColor,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text('Check In Now',
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // Widget Terpisah: Kartu Chat Companion
  Widget _buildChatCompanionCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: _surfaceColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.spa_rounded, color: _primaryColor),
              ),
              const SizedBox(width: 12),
              Text(
                'AI Companion',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: _textColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Need someone to talk to? Share your thoughts safely here.',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              // Ganti jadi Filled Button agar variatif
              onPressed: _navigateToChatList,
              style: ElevatedButton.styleFrom(
                backgroundColor: _textColor, // Warna gelap untuk kontras
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text('Start Chatting'),
            ),
          ),
        ],
      ),
    );
  }

  // Widget Terpisah: Recent Conversations
  Widget _buildRecentConversationsList() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Conversations',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: _textColor,
              ),
            ),
            TextButton(
              onPressed: _navigateToChatList,
              child: Text('See All', style: TextStyle(color: _primaryColor)),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _recentSessions.length,
          itemBuilder: (context, index) {
            final session = _recentSessions[index];
            final date = DateTime.parse(session['updatedAt']);
            final title = session['title'] ?? 'New Chat';
            final lastMessage = session['last_message'] ?? 'No messages yet';

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: _surfaceColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                leading: CircleAvatar(
                  radius: 20,
                  backgroundColor: _primaryColor.withOpacity(0.1),
                  child: Icon(Icons.history_rounded,
                      size: 20, color: _primaryColor),
                ),
                title: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style:
                      TextStyle(fontWeight: FontWeight.w600, color: _textColor),
                ),
                subtitle: Text(
                  lastMessage,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                ),
                trailing: Text(
                  DateFormat('MMM d').format(date),
                  style: TextStyle(fontSize: 10, color: Colors.grey.shade400),
                ),
                onTap: () => _openChatSession(session['_id']),
              ),
            );
          },
        ),
      ],
    );
  }

  // 2. TOOLS TAB
  Widget _buildToolsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(
              height: 20), // Tambahan spacer karena tidak ada custom header
          Text(
            'Wellness Tools',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: _textColor,
            ),
          ),
          const SizedBox(height: 24),
          _buildToolCard(
            'Emotional First Aid',
            'Breathing exercises & grounding',
            Icons.self_improvement_rounded,
            () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const ToolboxScreen())),
          ),
          const SizedBox(height: 16),
          _buildToolCard(
            'Mood Check-up',
            'Take a quick quiz to understand stress',
            Icons.insights_rounded,
            () => Navigator.push(
                context, MaterialPageRoute(builder: (_) => const QuizScreen())),
          ),
        ],
      ),
    );
  }

  Widget _buildToolCard(
      String title, String subtitle, IconData icon, VoidCallback onTap) {
    return Container(
      decoration: BoxDecoration(
        color: _surfaceColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _primaryColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: _primaryColor),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: _textColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                            fontSize: 12, color: Colors.grey.shade500),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right_rounded, color: Colors.grey.shade400),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 3. PROFILE TAB
  Widget _buildProfileTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border:
                  Border.all(color: _primaryColor.withOpacity(0.3), width: 2),
            ),
            child: CircleAvatar(
              radius: 48,
              backgroundColor: _primaryColor.withOpacity(0.1),
              child: Text(
                _user != null && _user!.name.isNotEmpty
                    ? _user!.name[0].toUpperCase()
                    : '?',
                style: TextStyle(
                  fontSize: 36,
                  color: _primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _user?.name ?? 'Guest User',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: _textColor,
            ),
          ),
          Text(
            _user?.email ?? '',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 40),
          Container(
            decoration: BoxDecoration(
              color: _surfaceColor,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                ListTile(
                  leading: Icon(Icons.bar_chart_rounded, color: _primaryColor),
                  title:
                      Text('Mood History', style: TextStyle(color: _textColor)),
                  trailing: Icon(Icons.chevron_right_rounded,
                      color: Colors.grey.shade400),
                  onTap: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const HistoryScreen())),
                ),
                Divider(
                    height: 1,
                    indent: 20,
                    endIndent: 20,
                    color: Colors.grey.shade100),
                ListTile(
                  leading:
                      Icon(Icons.info_outline_rounded, color: _primaryColor),
                  title: Text('About & Disclaimer',
                      style: TextStyle(color: _textColor)),
                  trailing: Icon(Icons.chevron_right_rounded,
                      color: Colors.grey.shade400),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _logout,
              icon: Icon(Icons.logout_rounded,
                  color: Colors.red.shade400, size: 20),
              label:
                  Text('Logout', style: TextStyle(color: Colors.red.shade400)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade50,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      // AppBar custom logic: Hilang di Home, Muncul di Tools/Profile
      appBar: _currentIndex == 0
          ? null
          : AppBar(
              title: Text(
                _currentIndex == 1 ? 'Tools' : 'Profile',
                style:
                    TextStyle(color: _textColor, fontWeight: FontWeight.bold),
              ),
              backgroundColor: Colors.transparent,
              elevation: 0,
              centerTitle: true,
              automaticallyImplyLeading: false, // Menghilangkan tombol back
            ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: _primaryColor))
          : IndexedStack(
              index: _currentIndex,
              children: [
                _buildHomeTab(),
                _buildToolsTab(),
                _buildProfileTab(),
              ],
            ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: _surfaceColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: _primaryColor,
          unselectedItemColor: Colors.grey.shade400,
          type: BottomNavigationBarType.fixed,
          showSelectedLabels: true,
          showUnselectedLabels: false,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home_rounded),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.grid_view_rounded),
              activeIcon: Icon(Icons.grid_view_rounded),
              label: 'Tools',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline_rounded),
              activeIcon: Icon(Icons.person_rounded),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}

// Widget StatItem Khusus Background Putih
class _StatItemDark extends StatelessWidget {
  final String label;
  final IconData icon;
  final String value;
  final Color color;

  const _StatItemDark({
    required this.label,
    required this.icon,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
              fontSize: 16, fontWeight: FontWeight.bold, color: color),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade500,
          ),
        ),
      ],
    );
  }
}
