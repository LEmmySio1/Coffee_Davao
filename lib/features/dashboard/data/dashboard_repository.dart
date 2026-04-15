import '../../../core/models/cafe.dart';
import '../../../core/models/review.dart';
import '../../../core/services/supabase_service.dart';

class DashboardDataBundle {
  const DashboardDataBundle({
    required this.cafes,
    required this.reviews,
    required this.profileCount,
  });

  final List<Cafe> cafes;
  final List<Review> reviews;
  final int profileCount;
}

class DashboardRepository {
  DashboardRepository({this.client});

  final dynamic client;

  dynamic get _client => client ?? SupabaseService.client;

  Future<DashboardDataBundle> fetchDashboardData() async {
    final activeClient = _client;
    if (activeClient == null) {
      return const DashboardDataBundle(
        cafes: [],
        reviews: [],
        profileCount: 0,
      );
    }

    final cafesData = await activeClient
        .from('cafes')
        .select('id, name, address, features, hours, price_range, image_url')
        .order('id', ascending: true);

    final reviewsData = await activeClient
        .from('reviews')
        .select('id, rating, comment, processing_time, user_id, status, cafe_id')
        .order('id', ascending: true);

    final profilesData = await activeClient.from('profiles').select('id');

    return DashboardDataBundle(
      cafes: (cafesData as List<dynamic>)
          .map((item) => Cafe.fromMap(item as Map<String, dynamic>))
          .toList(),
      reviews: (reviewsData as List<dynamic>)
          .map((item) => Review.fromMap(item as Map<String, dynamic>))
          .toList(),
      profileCount: (profilesData as List<dynamic>).length,
    );
  }
}
