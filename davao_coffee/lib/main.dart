import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

const supabaseUrl = 'https://YOUR_SUPABASE_PROJECT_REF.supabase.co';
const supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
  );
  runApp(const MyApp());
}

final supabase = Supabase.instance.client;

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Davao Coffee',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.brown),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  static final List<Widget> _pages = <Widget>[
    const DashboardScreen(),
    const AccountScreen(),
  ];

  static const List<String> _titles = <String>[
    'Complete Dashboard',
    'My Account',
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_selectedIndex]),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onItemTapped,
        destinations: const <NavigationDestination>[
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Account',
          ),
        ],
      ),
    );
  }
}

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  Future<List<Cafe>> _fetchCafes() async {
    final response = await supabase
        .from('cafes')
        .select('id,name,address,price_range,image_url,hours,features')
        .order('id', ascending: true)
        .execute();

    if (response.error != null) {
      throw response.error!;
    }

    return (response.data as List<dynamic>)
        .map((item) => Cafe.fromMap(item as Map<String, dynamic>))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Cafe>>(
      future: _fetchCafes(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error loading cafes: ${snapshot.error}'));
        }
        final cafes = snapshot.data ?? [];
        if (cafes.isEmpty) {
          return const Center(child: Text('No cafes found.'));
        }

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text(
                'Featured Cafés',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.builder(
                  itemCount: cafes.length,
                  itemBuilder: (context, index) {
                    final cafe = cafes[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.brown.shade200,
                          child: Text(cafe.id.toString()),
                        ),
                        title: Text(cafe.name),
                        subtitle: Text(cafe.address),
                        trailing: Text(cafe.priceRange ?? ''),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => ItemDetailScreen(cafe: cafe),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  User? _user;
  UserProfile? _profile;

  @override
  void initState() {
    super.initState();
    _loadSession();
  }

  Future<void> _loadSession() async {
    final user = supabase.auth.currentUser;
    if (user != null) {
      final profile = await _fetchProfile(user.id);
      setState(() {
        _user = user;
        _profile = profile;
      });
    }
  }

  Future<UserProfile?> _fetchProfile(String userId) async {
    final response = await supabase
        .from('profiles')
        .select('id,role')
        .eq('id', userId)
        .single()
        .execute();

    if (response.error != null) {
      return null;
    }
    return UserProfile.fromMap(response.data as Map<String, dynamic>);
  }

  Future<void> _signIn() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter email and password')),
      );
      return;
    }

    final response = await supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );

    if (response.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sign in failed: ${response.error!.message}')),
      );
      return;
    }

    final user = response.user;
    if (user != null) {
      final profile = await _fetchProfile(user.id);
      setState(() {
        _user = user;
        _profile = profile;
      });
    }
  }

  Future<void> _signOut() async {
    await supabase.auth.signOut();
    setState(() {
      _user = null;
      _profile = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_user != null) {
      return SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const CircleAvatar(
              radius: 44,
              backgroundColor: Colors.brown,
              child: Icon(Icons.person, size: 48, color: Colors.white),
            ),
            const SizedBox(height: 16),
            Text(
              _user!.email ?? 'Signed in user',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('User ID: ${_user!.id}'),
            const SizedBox(height: 16),
            Text('Role: ${_profile?.role ?? 'No profile found'}'),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _signOut,
              icon: const Icon(Icons.logout),
              label: const Text('Sign Out'),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: <Widget>[
          const Text(
            'Sign in to your Supabase account',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _emailController,
            decoration: const InputDecoration(labelText: 'Email'),
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _passwordController,
            decoration: const InputDecoration(labelText: 'Password'),
            obscureText: true,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _signIn,
            child: const Text('Sign In'),
          ),
          const SizedBox(height: 12),
          const Text(
            'If you do not have a Supabase account yet, create one in the Supabase dashboard.',
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class ItemDetailScreen extends StatefulWidget {
  const ItemDetailScreen({super.key, required this.cafe});

  final Cafe cafe;

  @override
  State<ItemDetailScreen> createState() => _ItemDetailScreenState();
}

class _ItemDetailScreenState extends State<ItemDetailScreen> {
  late Future<List<Review>> _reviewsFuture;

  @override
  void initState() {
    super.initState();
    _reviewsFuture = _fetchReviews();
  }

  Future<List<Review>> _fetchReviews() async {
    final response = await supabase
        .from('reviews')
        .select('id,rating,comment,processing_time,user_id,status')
        .eq('cafe_id', widget.cafe.id)
        .order('id', ascending: true)
        .execute();

    if (response.error != null) {
      throw response.error!;
    }

    return (response.data as List<dynamic>)
        .map((item) => Review.fromMap(item as Map<String, dynamic>))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.cafe.name),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              widget.cafe.name,
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(widget.cafe.address, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.local_cafe, color: Colors.brown),
                const SizedBox(width: 8),
                Text(widget.cafe.priceRange ?? ''),
                const SizedBox(width: 16),
                const Icon(Icons.schedule, color: Colors.brown),
                const SizedBox(width: 8),
                Expanded(child: Text(widget.cafe.hours ?? '')),
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              'Reviews',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: FutureBuilder<List<Review>>(
                future: _reviewsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error loading reviews: ${snapshot.error}'));
                  }
                  final reviews = snapshot.data ?? [];
                  if (reviews.isEmpty) {
                    return const Center(child: Text('No reviews yet.'));
                  }
                  return ListView.separated(
                    itemCount: reviews.length,
                    separatorBuilder: (_, __) => const Divider(),
                    itemBuilder: (context, index) {
                      final review = reviews[index];
                      return ListTile(
                        title: Text('Rating: ${review.rating}'),
                        subtitle: Text(review.comment),
                        trailing: Text(review.status),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Cafe {
  const Cafe({
    required this.id,
    required this.name,
    required this.address,
    this.priceRange,
    this.imageUrl,
    this.hours,
    this.features,
  });

  final int id;
  final String name;
  final String address;
  final String? priceRange;
  final String? imageUrl;
  final String? hours;
  final String? features;

  factory Cafe.fromMap(Map<String, dynamic> map) {
    return Cafe(
      id: map['id'] as int,
      name: map['name'] as String,
      address: map['address'] as String,
      priceRange: map['price_range'] as String?,
      imageUrl: map['image_url'] as String?,
      hours: map['hours'] as String?,
      features: map['features'] as String?,
    );
  }
}

class Review {
  const Review({
    required this.id,
    required this.rating,
    required this.comment,
    required this.processingTime,
    required this.userId,
    required this.status,
  });

  final int id;
  final String rating;
  final String comment;
  final String? processingTime;
  final String? userId;
  final String? status;

  factory Review.fromMap(Map<String, dynamic> map) {
    return Review(
      id: map['id'] as int,
      rating: map['rating'] as String,
      comment: map['comment'] as String,
      processingTime: map['processing_time'] as String?,
      userId: map['user_id'] as String?,
      status: map['status'] as String?,
    );
  }
}

class UserProfile {
  const UserProfile({required this.id, required this.role});

  final String id;
  final String role;

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      id: map['id'] as String,
      role: map['role'] as String,
    );
  }
}
