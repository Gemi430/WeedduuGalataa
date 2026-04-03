import 'package:flutter/material.dart';
import './scales_screen.dart';
import './albums_screen.dart';
import './singles_screen.dart';
import './favorites_screen.dart';
import './settings_screen.dart';
import './song_detail_screen.dart';
import '../services/song_service.dart';
import '../models/song.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const HomeContent(),
    const ScalesScreen(),
    const AlbumsScreen(),
    const SinglesScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
      onDestinationSelected: (index) {
          FocusManager.instance.primaryFocus?.unfocus();
          setState(() => _selectedIndex = index);
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: "Home"),
          NavigationDestination(icon: Icon(Icons.piano), label: "Scales"),
          NavigationDestination(icon: Icon(Icons.album), label: "Albums"),
          NavigationDestination(icon: Icon(Icons.star), label: "Singles"),
          NavigationDestination(icon: Icon(Icons.settings), label: "Settings"),
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

class _HomeContentState extends State<HomeContent> {
  final TextEditingController _searchController = TextEditingController();
  List<Song> _searchResults = [];
  bool _isSearching = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _onSearch(String query) async {
    if (query.isEmpty) {
      setState(() => _searchResults = []);
      return;
    }
    setState(() => _isSearching = true);
    final results = await SongService().searchSongs(query);
    setState(() {
      _searchResults = results;
      _isSearching = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isShowingResults = _searchController.text.isNotEmpty;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 48),
          _buildWelcomeSection(),
          const SizedBox(height: 16),
          _buildSearchBar(),
          const SizedBox(height: 16),
          if (isShowingResults) ...[
            _buildSearchResults(),
          ] else ...[
            _buildQuickAccessSection(context),
            const SizedBox(height: 24),
            _buildFeaturedSection(context),
            const SizedBox(height: 24),
            _buildRecentSongsSection(context),
          ],
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      controller: _searchController,
      onChanged: _onSearch,
      decoration: InputDecoration(
        hintText: "Search songs...",
        prefixIcon: const Icon(Icons.search, color: Color(0xFF1A237E)),
        suffixIcon: _searchController.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  _searchController.clear();
                  setState(() => _searchResults = []);
                },
              )
            : null,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF1A237E)),
        ),
      ),
    );
  }

  Widget _buildSearchResults() {
    if (_isSearching) {
      return const Center(child: Padding(
        padding: EdgeInsets.all(32),
        child: CircularProgressIndicator(),
      ));
    }

    if (_searchResults.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              Icon(Icons.search_off, size: 48, color: Colors.grey[400]),
              const SizedBox(height: 12),
              Text("No songs found", style: TextStyle(color: Colors.grey[600])),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "${_searchResults.length} result(s)",
          style: TextStyle(color: Colors.grey[600], fontSize: 13),
        ),
        const SizedBox(height: 8),
        ..._searchResults.map((song) => Card(
          margin: const EdgeInsets.only(bottom: 10),
          child: ListTile(
            leading: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFF1A237E).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.music_note, color: Color(0xFF1A237E)),
            ),
            title: Text(song.title, style: const TextStyle(fontWeight: FontWeight.w500)),
            subtitle: song.style != null ? Text("${song.scale ?? ''} - ${song.style}") : null,
            trailing: const Icon(Icons.arrow_forward_ios, size: 14),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => SongDetailScreen(songId: song.id)),
            ),
          ),
        )),
      ],
    );
  }

  Widget _buildWelcomeSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1A237E), Color(0xFF3949AB)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1A237E).withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Welcome Back!",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Find and worship with your favorite gospel songs",
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.music_note, color: Colors.white, size: 32),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAccessSection(BuildContext context) {
    final quickAccessItems = [
      {'icon': Icons.piano, 'label': 'By Scale', 'color': Colors.teal, 'screen': const ScalesScreen()},
      {'icon': Icons.album, 'label': 'Albums', 'color': Colors.purple, 'screen': const AlbumsScreen()},
      {'icon': Icons.star, 'label': 'Singles', 'color': Colors.amber, 'screen': const SinglesScreen()},
      {'icon': Icons.favorite, 'label': 'Favorites', 'color': Colors.pink, 'screen': const FavoritesScreen()},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Quick Access",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: quickAccessItems.map((item) {
            return GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => item['screen'] as Widget),
              ),
              child: Container(
                width: 70,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: (item['color'] as Color).withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        item['icon'] as IconData,
                        color: item['color'] as Color,
                        size: 24,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      item['label'] as String,
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildFeaturedSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Featured Albums",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            TextButton(
              onPressed: () {},
              child: const Text("See All"),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 160,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _buildFeaturedCard("Jaalala Waa", Colors.deepPurple),
              _buildFeaturedCard("Himmatni Qalbii", Colors.teal),
              _buildFeaturedCard("Raga Kiyya", Colors.orange),
              _buildFeaturedCard("Qalbii Jaalala", Colors.pink),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFeaturedCard(String title, Color color) {
    return Container(
      width: 140,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [color, color.withOpacity(0.7)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            bottom: 12,
            left: 12,
            right: 12,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.music_note, color: Colors.white, size: 28),
                const SizedBox(height: 8),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentSongsSection(BuildContext context) {
    final recentSongs = [
      {"title": "Waa Boqonnaa", "artist": "1st Scale - Waltz"},
      {"title": "Namoonni Isaa", "artist": "1st Scale - Slow Rock"},
      {"title": "Eela Eela", "artist": "2nd Scale - Reggae"},
      {"title": "Magaalaa Finfinnee", "artist": "2nd Scale - Chikchika"},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Recent Songs",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            TextButton(
              onPressed: () {},
              child: const Text("See All"),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...recentSongs.map((song) {
          return Card(
            margin: const EdgeInsets.only(bottom: 10),
            child: ListTile(
              leading: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFF1A237E).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.music_note, color: Color(0xFF1A237E)),
              ),
              title: Text(
                song['title'] as String,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              subtitle: Text(song['artist'] as String),
              trailing: const Icon(Icons.favorite_border, color: Colors.grey),
              onTap: () {},
            ),
          );
        }),
      ],
    );
  }
}