import 'package:flutter/material.dart';

import '../../../core/models/cafe.dart';
import '../../../core/models/review.dart';
import '../../auth/data/auth_repository.dart';
import '../data/dashboard_repository.dart';
import '../../item_details/presentation/item_details_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key, required this.authRepository});

  final AuthRepository authRepository;

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late Future<DashboardDataBundle> _dashboardFuture;
  final _repository = DashboardRepository();

  @override
  void initState() {
    super.initState();
    _dashboardFuture = _repository.fetchDashboardData();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DashboardDataBundle>(
      future: _dashboardFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return _DashboardError(
            message: snapshot.error.toString(),
            onRetry: () {
              setState(() {
                _dashboardFuture = _repository.fetchDashboardData();
              });
            },
          );
        }

        final data = snapshot.data ??
            const DashboardDataBundle(cafes: [], reviews: [], profileCount: 0);
        final cafes = data.cafes;
        final reviews = data.reviews;
        final averageRating = _averageRating(reviews);

        return RefreshIndicator(
          onRefresh: () async {
            setState(() {
              _dashboardFuture = _repository.fetchDashboardData();
            });
            await _dashboardFuture;
          },
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            children: [
              _DashboardHero(
                displayName: widget.authRepository.displayName,
                authMode: widget.authRepository.authMode,
              ),
              const SizedBox(height: 18),
              LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth >= 900;
                  return GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: isWide ? 4 : 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: isWide ? 1.45 : 0.92,
                    children: [
                      _MetricCard(
                        title: 'Cafes',
                        value: '${cafes.length}',
                        subtitle: 'All available cafe records',
                        color: const Color(0xFF8A4B2A),
                        icon: Icons.storefront_outlined,
                      ),
                      _MetricCard(
                        title: 'Reviews',
                        value: '${reviews.length}',
                        subtitle: 'All review entries loaded',
                        color: const Color(0xFF2C6E63),
                        icon: Icons.reviews_outlined,
                      ),
                      _MetricCard(
                        title: 'Profiles',
                        value: '${data.profileCount}',
                        subtitle: 'User profiles in database',
                        color: const Color(0xFF4C5D9A),
                        icon: Icons.people_outline,
                      ),
                      _MetricCard(
                        title: 'Avg Rating',
                        value: averageRating,
                        subtitle: 'Computed from reviews table',
                        color: const Color(0xFFB85C38),
                        icon: Icons.star_outline,
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 18),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Available Cafes',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Tap one or two items here to open the details screen.',
                        style: TextStyle(color: Colors.black54),
                      ),
                      const SizedBox(height: 16),
                      if (cafes.isEmpty)
                        const Text(
                          'No cafes were returned by Supabase. If your table already has rows, add a SELECT RLS policy for anon or authenticated users.',
                        )
                      else
                        ...cafes.map(
                          (cafe) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _CafeRow(
                              cafe: cafe,
                              reviewCount: reviews
                                  .where((review) => review.cafeId == cafe.id)
                                  .length,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _averageRating(List<Review> reviews) {
    if (reviews.isEmpty) {
      return '0.0';
    }

    final values = reviews
        .map((review) => double.tryParse(review.rating) ?? 0)
        .toList(growable: false);
    final total = values.fold<double>(0, (sum, value) => sum + value);
    return (total / values.length).toStringAsFixed(1);
  }
}

class _DashboardHero extends StatelessWidget {
  const _DashboardHero({
    required this.displayName,
    required this.authMode,
  });

  final String displayName;
  final AuthMode authMode;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          colors: [Color(0xFF3B2418), Color(0xFF9A5B37)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome, $displayName',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            authMode == AuthMode.guest
                ? 'You are using Guest mode. Dashboard data still attempts to load from Supabase.'
                : 'You are signed in. Explore available cafes, open item details, and review account information.',
            style: const TextStyle(color: Colors.white70, height: 1.5),
          ),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.color,
    required this.icon,
  });

  final String title;
  final String value;
  final String subtitle;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundColor: color.withValues(alpha: 0.14),
              foregroundColor: color,
              child: Icon(icon),
            ),
            const SizedBox(height: 18),
            Text(
              value,
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            Text(
              subtitle,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.black54,
                fontSize: 13,
                height: 1.25,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CafeRow extends StatelessWidget {
  const _CafeRow({required this.cafe, required this.reviewCount});

  final Cafe cafe;
  final int reviewCount;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => ItemDetailsScreen(cafe: cafe),
          ),
        );
      },
      child: Ink(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: const Color(0xFF8A4B2A).withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _CafeImage(cafe: cafe),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    cafe.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(cafe.address, style: const TextStyle(color: Colors.black54)),
                  const SizedBox(height: 6),
                  Text(
                    'Hours: ${cafe.hours}',
                    style: const TextStyle(color: Colors.black54),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Price: ${cafe.priceRange}',
                    style: const TextStyle(
                      color: Color(0xFF8A4B2A),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '$reviewCount reviews',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 6),
                const Text('View details'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CafeImage extends StatelessWidget {
  const _CafeImage({required this.cafe});

  final Cafe cafe;

  @override
  Widget build(BuildContext context) {
    if (cafe.imageUrl.isEmpty) {
      return CircleAvatar(
        radius: 24,
        backgroundColor: const Color(0xFF8A4B2A),
        child: Text(
          '${cafe.id}',
          style: const TextStyle(color: Colors.white),
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Image.network(
        cafe.imageUrl,
        width: 56,
        height: 56,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: 56,
            height: 56,
            color: const Color(0xFFE9D7CB),
            alignment: Alignment.center,
            child: const Icon(
              Icons.image_not_supported_outlined,
              color: Color(0xFF8A4B2A),
            ),
          );
        },
      ),
    );
  }
}

class _DashboardError extends StatelessWidget {
  const _DashboardError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Dashboard could not load data.',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: onRetry,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
