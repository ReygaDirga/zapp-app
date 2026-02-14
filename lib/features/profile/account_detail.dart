import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:zapp/core/cache/user_cache.dart';
import 'user_info.dart';

class AccountDetailsPage extends StatefulWidget {
  const AccountDetailsPage({Key? key}) : super(key: key);

  @override
  State<AccountDetailsPage> createState() => _AccountDetailsPageState();
}

class _AccountDetailsPageState extends State<AccountDetailsPage> {
  File? _imageFile;

  User? user;
  String? username;
  String? email;
  String? avatarUrl;
  String? fullname;
  Timer? _retryTimer;
  bool _isFetching = false;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();

    _retryTimer = Timer.periodic(
      const Duration(seconds: 5),
          (_) => _loadUserProfile(),
    );
  }

  Future<void> _loadUserProfile() async {
    if (UserCache.isReady) {
      setState(() {
        user = UserCache.user;
        username = UserCache.username;
        email = UserCache.email;
        fullname = UserCache.fullname;
        avatarUrl = UserCache.avatarUrl;
      });
      return;
    }

    if (_isFetching) return;

    _isFetching = true;
    try{
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
        email = currentUser.email;
        username = response['username'];
        fullname = response['fullname'];
        avatarUrl = response['avatar_url'];
      });

      _retryTimer?.cancel();
    } catch(e) {
      debugPrint('Profile Page: fetch failed, will retry...');
    } finally {
      _isFetching = false;
    }
  }

  @override
  void dispose() {
    _retryTimer?.cancel();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? picked =
      await picker.pickImage(source: ImageSource.gallery);

    if (picked == null) return;

    final file = File(picked.path);

    setState(() {
      _imageFile = file;
    });

    final supabase = Supabase.instance.client;
    final currentUser = supabase.auth.currentUser;

    if (currentUser == null) return;

    final fileExt = picked.path.split('.').last;
    final fileName = '${currentUser.id}_${DateTime.now().millisecondsSinceEpoch}.$fileExt';

    try {
      if (avatarUrl != null && avatarUrl!.isNotEmpty) {
        final uri = Uri.parse(avatarUrl!);
        final oldPath = uri.pathSegments.last;
        await supabase.storage.from('avatars').remove([oldPath]);
      }

      await supabase.storage
        .from('avatars')
        .upload(fileName, file, fileOptions: const FileOptions(upsert: true));

      final imageUrl = supabase.storage
        .from('avatars')
        .getPublicUrl(fileName);

      await supabase
        .from('profiles')
        .update({'avatar_url': imageUrl})
        .eq('user_id', currentUser.id);
      
      UserCache.avatarUrl = imageUrl;

    if (!mounted) return;

    setState(() {
      avatarUrl = imageUrl;
      _imageFile = null;
    });
    } catch (e) {
      debugPrint('Upload failed : $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Account Details',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(height: 24),

          Center(
            child: Stack(
              children: [
                CircleAvatar(
                  radius: 45,
                  backgroundImage: _imageFile != null
                      ? FileImage(_imageFile!)
                      : (avatarUrl != null && avatarUrl!.isNotEmpty
                        ? NetworkImage(avatarUrl!)
                        : const AssetImage('assets/icon/profile.jpg'))
                          as ImageProvider,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.camera_alt,
                        size: 18,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          Center(
            child: Text(
              username ?? '-',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          const SizedBox(height: 24),

          Container(
            width: double.infinity,
            height: 40,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            color: const Color(0xFFF2F2F2),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'User Info',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit, size: 20),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => UserInfoPage(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Full Name',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  fullname ?? '-',
                  style: TextStyle(fontSize: 15),
                ),
                SizedBox(height: 20),
                Text(
                  'Email',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  email ?? '-',
                  style: TextStyle(fontSize: 15),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
