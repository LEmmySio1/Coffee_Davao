import 'package:flutter/material.dart';

import '../../../core/models/cafe.dart';
import '../../../core/models/review.dart';
import '../../../core/services/supabase_service.dart';

class ItemDetailsScreen extends StatefulWidget {
  const ItemDetailsScreen({super.key, required this.cafe});

  final Cafe cafe;

  @override
  State<ItemDetailsScreen> createState() => _ItemDetailsScreenState();
}

class _ItemDetailsScreenState extends State<ItemDetailsScreen> {
  late Future<List<Review>> _reviewsFuture;

  @override
  void initState() {
    super.initState();
    _reviewsFuture = _fetchReviews();
  }

  Future<List<Review>> _fetchReviews() async {
    final client = SupabaseService.client;
    if (client == null) {
      return const [];
    }

    final data = await client
        .from('reviews')
        .select('id, rating, comment, processing_time, user_id, status, cafe_id')
        .eq('cafe_id', widget.cafe.id)
        .order('id', ascending: true);

    return (data as List<dynamic>)
        .map((item) => Review.fromMap(item as Map<String, dynamic>))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Details from an Item'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
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
                if (widget.cafe.imageUrl.isNotEmpty) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.network(
                      widget.cafe.imageUrl,
                      width: double.infinity,
                      height: 220,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: double.infinity,
                          height: 220,
                          color: Colors.white12,
                          alignment: Alignment.center,
                          child: const Icon(
                            Icons.image_not_supported_outlined,
                            color: Colors.white,
                            size: 40,
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                Text(
                  widget.cafe.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  widget.cafe.address,
                  style: const TextStyle(color: Colors.white70, height: 1.5),
                ),
                const SizedBox(height: 12),
                Text(
                  'Hours: ${widget.cafe.hours}',
                  style: const TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 10),
                Text(
                  'Price range: ${widget.cafe.priceRange}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Features',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 12),
                  if (widget.cafe.features.isEmpty)
                    const Text('No features listed.')
                  else
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: widget.cafe.features
                          .map(
                            (feature) => Chip(
                              label: Text(feature),
                            ),
                          )
                          .toList(),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Reviews',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 12),
                  FutureBuilder<List<Review>>(
                    future: _reviewsFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (snapshot.hasError) {
                        return Text('Unable to load reviews: ${snapshot.error}');
                      }

                      final reviews = snapshot.data ?? [];
                      if (reviews.isEmpty) {
                        return const Text('No reviews found for this cafe.');
                      }

                      return Column(
                        children: reviews
                            .map(
                              (review) => Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  title: Text('Rating: ${review.rating}'),
                                  subtitle: Text(
                                    '${review.comment}\nBy: ${review.userId}\nProcessing time: ${review.processingTime}',
                                  ),
                                  trailing: Text(review.status),
                                ),
                              ),
                            )
                            .toList(),
                      );
                    },
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
