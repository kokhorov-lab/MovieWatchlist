import 'package:flutter/material.dart';
import 'package:frontend/model/movie_model.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:frontend/service/service.dart';

class MovieDetailsScreen extends StatelessWidget {
  final Movie movie;
  final ApiService apiService = ApiService();
  MovieDetailsScreen({super.key, required this.movie});

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isDesktop = screenWidth >= 800;

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: const BoxDecoration(
            color: Colors.black54,
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Backdrop + Content Section
            Stack(
              children: [
                // Atmospheric Blurred Backdrop Image
                if (movie.posterUrl != null && movie.posterUrl!.isNotEmpty)
                  Positioned.fill(
                    child: Image.network(
                      movie.posterUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const SizedBox(),
                    ),
                  ),

                // Gradient Overlay for readability
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.4),
                          const Color(0xFF121212).withOpacity(0.85),
                          const Color(0xFF121212),
                        ],
                        stops: const [0.0, 0.6, 1.0],
                      ),
                    ),
                  ),
                ),

                // Foreground Content
                SafeArea(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: isDesktop ? 64.0 : 20.0,
                      vertical: 24.0,
                    ),
                    child: isDesktop
                        ? _buildDesktopLayout(context)
                        : _buildMobileLayout(context),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Mobile Layout: Vertical Stack
  Widget _buildMobileLayout(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(child: _buildPosterWidget(height: 380)),
        const SizedBox(height: 24),
        _buildMovieDetails(context),
      ],
    );
  }

  // Desktop/Tablet Layout: Side-by-Side
  Widget _buildDesktopLayout(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildPosterWidget(height: 480, width: 320),
        const SizedBox(width: 40),
        Expanded(child: _buildMovieDetails(context)),
      ],
    );
  }

  // Poster Image Widget with Fallback
  Widget _buildPosterWidget({required double height, double? width}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          color: Colors.grey[900],
          boxShadow: const [
            BoxShadow(
              color: Colors.black54,
              blurRadius: 15,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: movie.posterUrl != null && movie.posterUrl!.isNotEmpty
            ? Image.network(
                movie.posterUrl!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    _buildFallbackPoster(),
              )
            : _buildFallbackPoster(),
      ),
    );
  }

  Widget _buildFallbackPoster() {
    return const Center(
      child: Icon(Icons.movie, size: 80, color: Colors.white38),
    );
  }

  // Movie Details & Action Buttons
  Widget _buildMovieDetails(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          movie.title,
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 12),

        // Release Year, Runtime, Creator Meta Row
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 12,
          runSpacing: 8,
          children: [
            _buildMetaChip('${movie.releaseYear}'),
            if (movie.runtime != null) _buildMetaChip('${movie.runtime} min'),
          ],
        ),

        const SizedBox(height: 16),

        // Rating Star Row
        Row(
          children: [
            RatingBarIndicator(
              rating: movie.rating!.toDouble(),
              itemBuilder: (context, index) =>
                  const Icon(Icons.star_rounded, color: Colors.amber),
              itemCount: 5,
              itemSize: 24.0,
              direction: Axis.horizontal,
            ),
            const SizedBox(width: 8),
            Text(
              movie.rating!.toStringAsFixed(1),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Genre Tags
        if (movie.genre.isNotEmpty)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: movie.genre
                .map(
                  (g) => Chip(
                    label: Text(
                      g,
                      style: const TextStyle(color: Colors.black, fontSize: 12),
                    ),
                    backgroundColor: Colors.white.withOpacity(0.12),
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    side: BorderSide.none,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                )
                .toList(),
          ),

        const SizedBox(height: 24),

        // Action Buttons Row
        Wrap(
          spacing: 16,
          runSpacing: 12,
          children: [
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(
                Icons.play_arrow_rounded,
                color: Colors.black,
                size: 28,
              ),
              label: const Text(
                'Play',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
            OutlinedButton.icon(
              onPressed: () => _addToWatchlist(context, movie.id),
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text(
                'Add to Watchlist',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.white54),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 32),

        // Overview / Synopsis Section
        const Text(
          'Overview',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          movie.overview,
          style: TextStyle(fontSize: 15, height: 1.6, color: Colors.grey[300]),
        ),
      ],
    );
  }

  Widget _buildMetaChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.white24, width: 0.8),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white70,
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Future<void> _addToWatchlist(BuildContext context, String? movieId) async {
    // Guard clause against null or empty IDs
    if (movieId == null || movieId.isEmpty) {
      debugPrint('Error: Movie ID is null or empty!');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to add: Invalid Movie ID'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    try {
      debugPrint('Sending request to watchlist for movie ID: $movieId');
      await apiService.addToWatchList(movieId);

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Added to Watchlist'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      debugPrint('Watchlist error: $e');
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
