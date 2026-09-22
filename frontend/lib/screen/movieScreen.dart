import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:frontend/model/movie_model.dart';
import 'package:frontend/service/service.dart';
import 'package:frontend/router/app_router.dart';
import 'package:go_router/go_router.dart';

class MovieListScreen extends StatefulWidget {
  const MovieListScreen({super.key});

  @override
  State<MovieListScreen> createState() => _MovieListScreenState();
}

class _MovieListScreenState extends State<MovieListScreen> {
  final ApiService apiService = ApiService();
  late Future<List<Movie>> _moviesFuture;
  late Future<List<Movie>> _watchlistFuture;
  bool _isSearch = false;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _moviesFuture = apiService.fetchMovie();
    _watchlistFuture = apiService.fetchWatchlist();
  }

  void _refreshWatchlist() {
    setState(() {
      _watchlistFuture = apiService.fetchWatchlist();
    });
  }

  void _toggleSearch() {
    setState(() {
      _isSearch = !_isSearch;
      if (_isSearch) {
        _searchFocusNode.requestFocus();
      } else {
        _searchController.clear();
        _searchQuery = '';
      }
    });
  }

  Future<void> _addToWatchlist(String movieId) async {
    try {
      await apiService.addToWatchList(movieId);
      if (!mounted) return;
      _refreshWatchlist();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Added to Watchlist!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _handleLogout() async {
    try {
      await authNotifier.logout();
      if (!mounted) return;
      Navigator.of(context).pop(); // Close profile dialog
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Logout failed: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showProfileDialog() {
    final user = authNotifier.user;

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: const Color(0xFF1E293B),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.redAccent,
                  child: Icon(Icons.person, size: 36, color: Colors.white),
                ),
                const SizedBox(height: 12),
                Text(
                  user?.name ?? 'User Name',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  user?.email ?? 'user@example.com',
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    minimumSize: const Size(double.infinity, 44),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: _handleLogout,
                  icon: const Icon(Icons.logout, color: Colors.white),
                  label: const Text(
                    'Logout',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F172A),
        elevation: 0,
        leading: const Center(
          child: Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              'CineStream',
              style: TextStyle(
                color: Colors.redAccent,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        leadingWidth: 120,
        actions: [
          // Isolated search cross-fade replacement
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 200),
            crossFadeState: _isSearch
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            firstChild: IconButton(
              icon: const Icon(Icons.search, color: Colors.white),
              onPressed: _toggleSearch,
            ),
            secondChild: Container(
              width: 180,
              height: 38,
              margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.only(top: 3.5, left: 5.5),
                child: TextField(
                  controller: _searchController,
                  focusNode: _searchFocusNode,
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                  decoration: InputDecoration(
                    hintText: 'Search...',
                    hintStyle: const TextStyle(
                      color: Colors.white54,
                      fontSize: 13,
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 9),
                    suffixIcon: IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      icon: const Icon(
                        Icons.close,
                        color: Colors.white54,
                        size: 16,
                      ),
                      onPressed: _toggleSearch,
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value.trim().toLowerCase();
                    });
                  },
                ),
              ),
            ),
          ),
          Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.bookmark_outline, color: Colors.white),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
          ),
          ListenableBuilder(
            listenable: authNotifier,
            builder: (context, _) {
              if (authNotifier.isLoggedIn) {
                return IconButton(
                  icon: const Icon(Icons.account_circle, color: Colors.white),
                  onPressed: _showProfileDialog,
                );
              } else {
                return TextButton(
                  onPressed: () {
                    // Navigate to sign-in route
                  },
                  child: const Text(
                    'Sign In',
                    style: TextStyle(
                      color: Colors.redAccent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              }
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      drawer: _buildLeftDrawer(),
      body: FutureBuilder<List<Movie>>(
        future: _moviesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.redAccent),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: Colors.redAccent,
                    size: 48,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '${snapshot.error}',
                    style: const TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                    ),
                    onPressed: () {
                      setState(() {
                        _moviesFuture = apiService.fetchMovie();
                      });
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'No movies available.',
                style: TextStyle(color: Colors.white70),
              ),
            );
          }

          final allMovies = snapshot.data!;
          final filteredMovies = _searchQuery.isEmpty
              ? allMovies
              : allMovies
                    .where((m) => m.title.toLowerCase().contains(_searchQuery))
                    .toList();

          final dramaMovies = filteredMovies
              .where((m) => m.genre.any((g) => g.toLowerCase() == 'drama'))
              .toList();
          final thrillerMovies = filteredMovies
              .where((m) => m.genre.any((g) => g.toLowerCase() == 'thriller'))
              .toList();
          final horrorMovies = filteredMovies
              .where((m) => m.genre.any((g) => g.toLowerCase() == 'horror'))
              .toList();
          final actionMovies = filteredMovies
              .where((m) => m.genre.any((g) => g.toLowerCase() == 'action'))
              .toList();

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12),
                if (_searchQuery.isEmpty) ...[
                  _buildHeroCarousel(allMovies),
                  const SizedBox(height: 20),
                ],
                if (_searchQuery.isNotEmpty) ...[
                  _buildSectionHeader('Search Results', onSeeAll: () {}),
                  filteredMovies.isNotEmpty
                      ? _buildHorizontalMovieList(filteredMovies)
                      : Column(
                          children: [
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16.0),
                              child: Container(
                                width: MediaQuery.of(context).size.width,
                                height:
                                    MediaQuery.of(context).size.height - 150,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.movie_rounded,
                                      size: 80,
                                      color: Colors.grey,
                                    ),
                                    Text(
                                      'No movies found matching your search.',
                                      style: TextStyle(color: Colors.white54),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                ] else ...[
                  _buildSectionHeader('Discover Movies', onSeeAll: () {}),
                  _buildHorizontalMovieList(allMovies),
                  if (actionMovies.isNotEmpty) ...[
                    _buildSectionHeader('Action', onSeeAll: () {}),
                    _buildHorizontalMovieList(actionMovies),
                  ],
                  if (dramaMovies.isNotEmpty) ...[
                    _buildSectionHeader('Drama', onSeeAll: () {}),
                    _buildHorizontalMovieList(dramaMovies),
                  ],
                  if (thrillerMovies.isNotEmpty) ...[
                    _buildSectionHeader('Thriller', onSeeAll: () {}),
                    _buildHorizontalMovieList(thrillerMovies),
                  ],
                  if (horrorMovies.isNotEmpty) ...[
                    _buildSectionHeader('Horror', onSeeAll: () {}),
                    _buildHorizontalMovieList(horrorMovies),
                  ],
                ],
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }

  // Hero Highlight Slideshow
  Widget _buildHeroCarousel(List<Movie> heroMovies) {
    final double screenWidth = MediaQuery.sizeOf(context).width;

    final double dynamicHeight = screenWidth > 1600
        ? 400.0
        : screenWidth > 1290
        ? 420.0
        : 300.0;

    final double dynamicViewportFraction = screenWidth > 1600
        ? 0.5
        : screenWidth > 1290
        ? 0.8
        : 0.9;

    return CarouselSlider(
      options: CarouselOptions(
        height: dynamicHeight,
        viewportFraction: dynamicViewportFraction,
        enlargeCenterPage: true,
        autoPlay: true,
        autoPlayInterval: const Duration(seconds: 5),
      ),
      items: heroMovies.map((movie) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 6.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: const Color(0xFF1E293B),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.network(
                  movie.posterUrl ?? '',
                  fit: BoxFit.cover,
                  filterQuality: FilterQuality.high,
                  errorBuilder: (context, error, stackTrace) =>
                      Container(color: Colors.blueGrey[900]),
                ),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black.withOpacity(0.85),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
                Positioned(
                  bottom: 24,
                  left: 24,
                  right: 24,
                  child: Text(
                    movie.title,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: screenWidth > 1290 ? 24 : 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  // Section Header with View All
  Widget _buildSectionHeader(String title, {required VoidCallback onSeeAll}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          TextButton(
            onPressed: onSeeAll,
            child: const Text(
              'View All',
              style: TextStyle(color: Colors.redAccent, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  // Horizontal Movie List for Sections
  Widget _buildHorizontalMovieList(List<Movie> movies) {
    final double screenWidth = MediaQuery.sizeOf(context).width;
    final bool isDesktop = screenWidth >= 1290 && screenWidth <= 1920;

    final double cardWidth = isDesktop ? 220.0 : 130.0;
    final double listHeight = isDesktop ? 320.0 : 230.0;
    final double imageHeight = isDesktop ? 240.0 : 160.0;

    return SizedBox(
      height: listHeight,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        itemCount: movies.length,
        itemBuilder: (context, index) {
          final movie = movies[index];
          return Container(
            width: cardWidth,
            margin: const EdgeInsets.only(right: 12.0),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(
                  children: [
                    InkWell(
                      onTap: () async {
                        await context.push('/movies/details', extra: movie);
                        _refreshWatchlist();
                      },
                      child: ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(12),
                        ),
                        child:
                            movie.posterUrl != null &&
                                movie.posterUrl!.isNotEmpty
                            ? Image.network(
                                movie.posterUrl!,
                                height: imageHeight,
                                width: cardWidth,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    _buildImagePlaceholder(
                                      cardWidth,
                                      imageHeight,
                                    ),
                              )
                            : _buildImagePlaceholder(cardWidth, imageHeight),
                      ),
                    ),
                    Positioned(
                      top: 6,
                      right: 6,
                      child: InkWell(
                        onTap: () => _addToWatchlist(movie.id),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.6),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.bookmark_add_outlined,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        movie.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: isDesktop ? 14 : 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${movie.releaseYear}',
                        style: TextStyle(
                          color: Colors.amber,
                          fontSize: isDesktop ? 12 : 10,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildImagePlaceholder(double width, double height) {
    return Container(
      width: width,
      height: height,
      color: Colors.blueGrey[900],
      child: const Icon(Icons.movie, color: Colors.white38, size: 50),
    );
  }

  // Watchlist Drawer
  Widget _buildLeftDrawer() {
    return Drawer(
      backgroundColor: const Color(0xFF1E293B),
      child: Column(
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: Color(0xFF0F172A)),
            child: Row(
              children: const [
                Icon(Icons.bookmark, color: Colors.redAccent, size: 32),
                SizedBox(width: 12),
                Text(
                  'My Watchlist',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Movie>>(
              future: _watchlistFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: Colors.redAccent),
                  );
                }

                if (snapshot.hasError ||
                    !snapshot.hasData ||
                    snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text(
                      'Your watchlist is empty.',
                      style: TextStyle(color: Colors.white54),
                    ),
                  );
                }

                final watchlist = snapshot.data!;
                return ListView.separated(
                  itemCount: watchlist.length,
                  separatorBuilder: (context, index) =>
                      const Divider(color: Colors.white10),
                  itemBuilder: (context, index) {
                    final movie = watchlist[index];
                    return ListTile(
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child:
                            movie.posterUrl != null &&
                                movie.posterUrl!.isNotEmpty
                            ? Image.network(
                                movie.posterUrl!,
                                width: 45,
                                height: 65,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    _buildImagePlaceholder(45, 65),
                              )
                            : _buildImagePlaceholder(45, 65),
                      ),
                      title: Text(
                        movie.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                      subtitle: Text(
                        '${movie.releaseYear}',
                        style: const TextStyle(
                          color: Colors.amber,
                          fontSize: 12,
                        ),
                      ),
                    );
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
