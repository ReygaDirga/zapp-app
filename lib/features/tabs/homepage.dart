import 'dart:async';

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:zapp/core/cache/user_cache.dart';
import 'package:zapp/features/support/notifications.dart';
import 'package:zapp/features/profile/profile_page.dart';
import 'package:zapp/routes/route_observer.dart';
import 'package:zapp/core/components/carousel.dart';
import 'package:zapp/core/components/room_cart.dart';

import 'simulation.dart';
import 'history.dart';
import 'news.dart';

import 'package:zapp/features/detail/addroom.dart';
import 'package:zapp/features/detail/detail_room.dart';
import 'package:zapp/features/detail/apiclient.dart';
import 'package:zapp/features/detail/delroom.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  Widget _navItem(IconData icon, String label, int index) {
    final bool isActive = _currentIndex == index;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          height: 3,
          width: isActive ? 70 : 0,
          decoration: BoxDecoration(
            color: Colors.blue,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(height: 6),
        Icon(
          icon,
          color: isActive ? Colors.blue : Colors.grey,
        ),
        const SizedBox(height: 6),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          transitionBuilder: (child, animation) {
            return FadeTransition(opacity: animation, child: child);
          },
          child: isActive
              ? Text(
                  label,
                  key: ValueKey(label),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.blue,
                  ),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: IndexedStack(
        index: _currentIndex,
        children: const [
          HomeContent(),
          SimulationPage(),
          HistoryPage(),
          NewsPage(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: _navItem(Icons.home, 'Home', 0),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: _navItem(Icons.calculate, 'Simulation', 1),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: _navItem(Icons.history, 'History', 2),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: _navItem(Icons.newspaper, 'News', 3),
            label: '',
          ),
        ],
      ),
    );
  }
}

class HomeContent extends StatefulWidget {
  const HomeContent({super.key});

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> with RouteAware {
  String? username;
  User? user;

  Timer? _retryTimer;
  bool _isFetching = false;

  bool _isSelectionMode = false;
  final Set<int> _selectedIndexes = {};

  // ✅ Rooms state
  late Future<List<dynamic>> _futureRooms;

  @override
  void initState() {
    super.initState();
    _loadUsername();
    _futureRooms = _fetchRooms();
  }

  void _startRetryTimer() {
    _retryTimer?.cancel();
    _retryTimer = Timer.periodic(
      const Duration(seconds: 5),
      (_) => _loadUsername(),
    );
  }

  void _stopRetryTimer() {
    _retryTimer?.cancel();
  }

  @override
  void didPush() {
    _startRetryTimer();
  }

  @override
  void didPopNext() {
    _startRetryTimer();
  }

  @override
  void didPushNext() {
    _stopRetryTimer();
  }

  Future<void> _loadUsername() async {
    if (UserCache.isReady) {
      setState(() {
        user = UserCache.user;
        username = UserCache.username;
      });
      return;
    }

    if (_isFetching) return;
    _isFetching = true;

    try {
      final supabase = Supabase.instance.client;
      final currentUser = supabase.auth.currentUser;
      if (currentUser == null) return;

      final response = await supabase
          .from('profiles')
          .select('username, fullname, avatar_url')
          .eq('user_id', currentUser.id)
          .single();

      UserCache.user = currentUser;
      UserCache.email = currentUser.email;
      UserCache.username = response['username'];
      UserCache.fullname = response['fullname'];
      UserCache.avatarUrl = response['avatar_url'];

      if (!mounted) return;
      setState(() {
        user = currentUser;
        username = response['username'];
      });

      _retryTimer?.cancel();
    } catch (_) {
      debugPrint('Homepage: fetch failed, will retry...');
    } finally {
      _isFetching = false;
    }
  }

  // ✅ Fetch rooms from backend
  Future<List<dynamic>> _fetchRooms() async {
    final res = await ApiClient.dio.get('/rooms');
    final data = res.data;

    // API returns List
    if (data is List) return data;

    // API returns { data: [...] }
    if (data is Map && data['data'] is List) return data['data'] as List;

    return [];
  }

  void _refreshRooms() {
    setState(() {
      _futureRooms = _fetchRooms();
      _selectedIndexes.clear();
      _isSelectionMode = false;
    });
  }

  void _toggleSelectionMode() {
    setState(() {
      _isSelectionMode = !_isSelectionMode;
      _selectedIndexes.clear();
    });
  }

  Future<void> _deleteSelectedRooms(List<dynamic> rooms) async {
    if (_selectedIndexes.isEmpty) return;

    final selectedRooms = _selectedIndexes
        .map((i) => rooms[i])
        .whereType<Map>()
        .toList();

    if (selectedRooms.isEmpty) return;

    // For simplicity: delete one-by-one via DeleteRoomPage flow OR direct DELETE calls.
    // Here: if 1 selected -> open DeleteRoomPage; if many -> delete sequentially via API.
    if (selectedRooms.length > 0) {
      final room = selectedRooms.first;
      final roomId = (room['id'] ?? room['room_id'] ?? '').toString();
      final roomName = (room['name'] ?? '-').toString();
      if (roomId.isEmpty) return;

      final confirmed = await showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            "Delete room?",
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            "You are about to delete ${selectedRooms.length} rooms. This action cannot be undone.",
            style: const TextStyle(color: Color(0xFF838383)),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text(
                "Cancel",
                style: TextStyle(color: Color(0xFF838383)),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text(
                "Delete",
                style: TextStyle(color: Color(0xFF092C4C)),
              ),
            ),
          ],
        ),
      );

      if (confirmed != true) return;

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      if (selectedRooms.length == 1) {
        await ApiClient.dio.delete('/rooms/$roomId');
      } else {
        for (final room in selectedRooms) {
          final id = (room['id'] ?? room['room_id'] ?? '').toString();
          if (id.isEmpty) continue;
          await ApiClient.dio.delete('/rooms/$id');
        }
      }

      if (mounted) Navigator.pop(context);
      _refreshRooms();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route is PageRoute) {
      routeObserver.subscribe(this, route);
    }
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    _retryTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: ListView(
          children: [
            const SizedBox(height: 16),
            _header(context),
            const SizedBox(height: 16),
            const TopCarousel(),
            const SizedBox(height: 24),
            _usageHeader(context),
            const SizedBox(height: 12),
            _roomGrid(),
          ],
        ),
      ),
    );
  }

  Widget _header(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ProfilePage()),
            );
          },
          child: CircleAvatar(
            radius: 22,
            backgroundColor: Colors.grey.shade300,
            backgroundImage: UserCache.avatarUrl != null &&
                    UserCache.avatarUrl!.isNotEmpty
                ? NetworkImage(UserCache.avatarUrl!)
                : const AssetImage("assets/icon/profile.jpg") as ImageProvider,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 180,
                child: AnimatedTextKit(
                  repeatForever: true,
                  pause: const Duration(milliseconds: 1000),
                  animatedTexts: [
                    TyperAnimatedText("Hi",
                        textStyle:
                            const TextStyle(fontSize: 14, color: Colors.grey)),
                    TyperAnimatedText("Halo",
                        textStyle:
                            const TextStyle(fontSize: 14, color: Colors.grey)),
                    TyperAnimatedText("Bonjour",
                        textStyle:
                            const TextStyle(fontSize: 14, color: Colors.grey)),
                    TyperAnimatedText("Hola",
                        textStyle:
                            const TextStyle(fontSize: 14, color: Colors.grey)),
                    TyperAnimatedText("Aloha",
                        textStyle:
                            const TextStyle(fontSize: 14, color: Colors.grey)),
                    TyperAnimatedText("您好",
                        textStyle:
                            const TextStyle(fontSize: 14, color: Colors.grey)),
                    TyperAnimatedText("こんにちは",
                        textStyle:
                            const TextStyle(fontSize: 14, color: Colors.grey)),
                    TyperAnimatedText("안녕하세요",
                        textStyle:
                            const TextStyle(fontSize: 14, color: Colors.grey)),
                    TyperAnimatedText("Zdravstvuyte",
                        textStyle:
                            const TextStyle(fontSize: 14, color: Colors.grey)),
                    TyperAnimatedText("Sàwàtdee",
                        textStyle:
                            const TextStyle(fontSize: 14, color: Colors.grey)),
                    TyperAnimatedText("Guten Tag",
                        textStyle:
                            const TextStyle(fontSize: 14, color: Colors.grey)),
                    TyperAnimatedText("Ciao",
                        textStyle:
                            const TextStyle(fontSize: 14, color: Colors.grey)),
                    TyperAnimatedText("مرحبا",
                        textStyle:
                            const TextStyle(fontSize: 14, color: Colors.grey)),
                    TyperAnimatedText("Olá",
                        textStyle:
                            const TextStyle(fontSize: 14, color: Colors.grey)),
                  ],
                ),
              ),
              const SizedBox(height: 2),
              Text(
                username ?? '-',
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ],
          ),
        ),
        IconButton(
          icon: const Icon(Icons.notifications_none_rounded),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const NotificationsPage()),
            );
          },
        )
      ],
    );
  }

  Widget _usageHeader(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: _futureRooms,
      builder: (context, snapshot) {
        final rooms = snapshot.data ?? [];

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _isSelectionMode
                ? Text(
                    "${_selectedIndexes.length} selected",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  )
                : const Text(
                    "Usage by room",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
            Row(
              children: [
                if (_isSelectionMode && _selectedIndexes.isNotEmpty)
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deleteSelectedRooms(rooms),
                  ),
                if (!_isSelectionMode)
                  IconButton(
                    onPressed: () async {
                      final result = await Navigator.push<bool>(
                        context,
                        MaterialPageRoute(builder: (_) => const AddRoom()),
                      );
                      if (result == true) _refreshRooms();
                    },
                    icon: const Icon(Icons.add),
                  ),
                IconButton(
                  onPressed: _toggleSelectionMode,
                  icon: Icon(_isSelectionMode ? Icons.close : Icons.more_vert),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget  _roomGrid() {
    return FutureBuilder<List<dynamic>>(
      future: _futureRooms,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.only(top: 24),
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.hasError) {
          return Text(snapshot.error.toString());
        }

        final rooms = snapshot.data ?? [];

        if (rooms.isEmpty) {
          return const Text("No rooms yet. Add your first room.");
        }

        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: rooms.asMap().entries.map((entry) {
            final index = entry.key;
            final room = entry.value;

            final roomMap = room is Map ? room : <String, dynamic>{};

            final roomName = (roomMap['name'] ?? '-').toString();
            final roomId = (roomMap['id'] ?? roomMap['room_id'] ?? '').toString();

            return GestureDetector(
              onTap: () async {
                if (_isSelectionMode) {
                  setState(() {
                    if (_selectedIndexes.contains(index)) {
                      _selectedIndexes.remove(index);
                    } else {
                      _selectedIndexes.add(index);
                    }
                  });
                } else {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => HomeOfficePage(
                        roomId: roomId,
                        roomName: roomName,
                      ),
                    ),
                  );

                  _refreshRooms();
                }
              },
              onLongPress: () async {
                // Long press: open delete page for single room
                if (roomId.isEmpty) return;

                final result = await Navigator.push<bool>(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DeleteRoomPage(
                      roomId: roomId,
                      roomName: roomName,
                    ),
                  ),
                );
                _refreshRooms();

                if (result == true) _refreshRooms();
              },
              child: Stack(
                children: [
                  RoomUsageCard(
                    percentage: 0,
                    label: roomName,
                    imagePath: "assets/images/home_office.jpg",
                  ),
                  if (_isSelectionMode)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: CircleAvatar(
                        radius: 12,
                        backgroundColor:
                            _selectedIndexes.contains(index) ? Colors.blue : Colors.white,
                        child: _selectedIndexes.contains(index)
                            ? const Icon(Icons.check, size: 14, color: Colors.white)
                            : null,
                      ),
                    ),
                ],
              ),
            );
          }).toList(),
        );
      },
    );
  }
}