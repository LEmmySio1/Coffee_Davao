class Cafe {
  const Cafe({
    required this.id,
    required this.name,
    required this.address,
    required this.features,
    required this.hours,
    required this.priceRange,
    required this.imageUrl,
  });

  final int id;
  final String name;
  final String address;
  final List<String> features;
  final String hours;
  final String priceRange;
  final String imageUrl;

  factory Cafe.fromMap(Map<String, dynamic> map) {
    return Cafe(
      id: _parseInt(map['id']),
      name: (map['name'] ?? 'Unnamed cafe').toString(),
      address: (map['address'] ?? 'No address provided').toString(),
      features: _parseFeatures(map['features'] ?? map['service_requirements']),
      hours: (map['hours'] ?? map['weekday_hours'] ?? 'Hours unavailable')
          .toString(),
      priceRange: (map['price_range'] ?? 'Price unavailable').toString(),
      imageUrl: (map['image_url'] ?? '').toString(),
    );
  }

  static int _parseInt(dynamic value) {
    if (value is int) {
      return value;
    }

    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static List<String> _parseFeatures(dynamic raw) {
    if (raw == null) {
      return const [];
    }

    if (raw is List) {
      return raw.map((item) => item.toString()).toList();
    }

    final text = raw.toString().replaceAll('[', '').replaceAll(']', '');
    return text
        .split(',')
        .map((item) => item.replaceAll('"', '').replaceAll("'", '').trim())
        .where((item) => item.isNotEmpty)
        .toList();
  }
}
