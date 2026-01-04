import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../blocs/trip_bloc.dart';
import '../blocs/auth_bloc.dart';
import '../models/trip.dart';
import 'package:intl/intl.dart';
import 'trip_detail_screen.dart';
import 'profile_screen.dart';
import '../widgets/glass_container.dart';
import '../utils/responsive_layout.dart';
import '../blocs/theme_bloc.dart';
import 'city_detail_screen.dart';
import '../models/city.dart';
import 'package:hive/hive.dart';
import 'all_trips_screen.dart';
import 'my_bookings_screen.dart';
import '../widgets/nav_button.dart';
import '../widgets/shimmer_loading.dart';
import '../widgets/interactive_stats_section.dart';
import '../widgets/expandable_card.dart';
import '../widgets/interactive_travel_tips_section.dart';
import '../widgets/enhanced_seasonal_section.dart';
import '../utils/booking_utils.dart';
import 'package:dio/dio.dart';
import 'dart:async';
import 'dart:math';
import 'dart:convert';
import '../widgets/universal_image_picker.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final _searchController = TextEditingController();
  final _dio = Dio();
  String _searchQuery = "";
  final Set<String> _likedCities = {};
  bool _showFavoritesOnly = false;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  
  // World Search State
  List<dynamic> _externalResults = [];
  bool _isSearchingWorld = false;
  Timer? _searchDebounce;
  
  final _featuredScrollController = ScrollController();
  bool _showLeftArrow = false;
  bool _showRightArrow = true;

  @override
  void initState() {
    super.initState();
    context.read<TripBloc>().add(LoadTrips());
    _loadFavorites();
    _searchController.addListener(() {
      final query = _searchController.text.toLowerCase();
      setState(() {
        _searchQuery = query;
      });
      
      if (query.length > 2) {
        _onSearchChanged(query);
      } else {
        setState(() => _externalResults = []);
      }
    });

    _featuredScrollController.addListener(() {
      setState(() {
        _showLeftArrow = _featuredScrollController.offset > 0;
        _showRightArrow = _featuredScrollController.offset < _featuredScrollController.position.maxScrollExtent;
      });
    });
    
    // Smooth fade-in animation for content
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    _fadeController.forward();
  }

  void _loadFavorites() {
    final box = Hive.box<String>('favorites');
    setState(() {
      _likedCities.addAll(box.values);
    });
  }

  void _toggleFavorite(String cityName) {
    final box = Hive.box<String>('favorites');
    setState(() {
      if (_likedCities.contains(cityName)) {
        _likedCities.remove(cityName);
        final key = box.keys.firstWhere((k) => box.get(k) == cityName, orElse: () => null);
        if (key != null) box.delete(key);
      } else {
        _likedCities.add(cityName);
        box.add(cityName);
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _fadeController.dispose();
    _featuredScrollController.dispose();
    _searchDebounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_searchDebounce?.isActive ?? false) _searchDebounce!.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 500), () {
      _searchWorld(query);
    });
  }

  Future<void> _searchWorld(String query) async {
    if (query.isEmpty) return;
    
    setState(() => _isSearchingWorld = true);
    
    try {
      List<dynamic> combinedResults = [];

      // 1. Search for Countries & their major cities
      final countryRes = await _dio.get('https://restcountries.com/v3.1/name/$query');
      if (countryRes.statusCode == 200) {
        for (var c in countryRes.data) {
          final countryName = c['name']['common'];
          final region = c['region'];
          
          // Add the country itself
          combinedResults.add({
            'type': 'country',
            'name': countryName,
            'subtitle': region,
            'imageUrl': c['flags']['png'],
            'budget': _getBudgetForRegion(region),
            'places': _getPlacesForCountry(countryName),
            'season': _getSeasonForMonth(),
            'description': "Experience the rich culture and stunning landscapes of $countryName.",
          });

          // Fetch major cities using Nominatim for this country
          try {
            final cityRes = await _dio.get(
              'https://nominatim.openstreetmap.org/search',
              queryParameters: {
                'country': countryName,
                'featuretype': 'city',
                'format': 'json',
                'limit': 3,
              }
            );
            if (cityRes.statusCode == 200) {
              for (var city in cityRes.data) {
                combinedResults.add({
                  'type': 'city',
                  'name': city['display_name'].split(',')[0],
                  'subtitle': countryName,
                  'imageUrl': 'https://images.unsplash.com/photo-1449824913935-59a10b8d2000?auto=format&fit=crop&w=400&q=80',
                  'budget': 1500.0 + Random().nextInt(2000),
                  'places': ["City Center", "Museums", "Parks"],
                  'season': _getSeasonForMonth(),
                  'description': "A must-visit urban destination in $countryName.",
                });
              }
            }
          } catch (_) {}
        }
      }

      // 2. Direct City Search (if no country matches or to supplement)
      if (combinedResults.length < 5) {
        final directCityRes = await _dio.get(
          'https://nominatim.openstreetmap.org/search',
          queryParameters: {
            'q': query,
            'format': 'json',
            'addressdetails': 1,
            'limit': 5,
          }
        );
        if (directCityRes.statusCode == 200) {
          for (var c in directCityRes.data) {
            final name = c['display_name'].split(',')[0];
            final countryCode = c['address']?['country_code'];
            // Skip if already added
            if (combinedResults.any((res) => res['name'] == name)) continue;
            
            combinedResults.add({
              'type': 'city',
              'name': name,
              'subtitle': c['display_name'].split(',').skip(1).take(2).join(','),
              'imageUrl': 'https://images.unsplash.com/photo-1514924013411-cbf25faa35bb?auto=format&fit=crop&w=400&q=80',
              'flagUrl': countryCode != null ? 'https://flagcdn.com/w80/${countryCode.toLowerCase()}.png' : null,
              'budget': 1200.0 + Random().nextInt(1500),
              'places': ["Landmarks", "Shopping", "Food Street"],
              'season': _getSeasonForMonth(),
              'description': "Discover the hidden treasures and unique atmosphere of $name.",
            });
          }
        }
      }

      setState(() {
        _externalResults = combinedResults.take(8).toList();
        _isSearchingWorld = false;
      });
    } catch (e) {
      print("Search error: $e");
      setState(() => _isSearchingWorld = false);
    }
  }

  String _getSeasonForMonth() {
    final month = DateTime.now().month;
    if (month >= 3 && month <= 5) return "Spring";
    if (month >= 6 && month <= 8) return "Summer";
    if (month >= 9 && month <= 11) return "Autumn";
    return "Winter";
  }

  double _getBudgetForRegion(String region) {
    switch(region) {
      case 'Europe': return 2500.0;
      case 'Asia': return 1500.0;
      case 'Americas': return 2200.0;
      case 'Africa': return 1200.0;
      case 'Oceania': return 2800.0;
      default: return 1800.0;
    }
  }

  List<String> _getPlacesForCountry(String country) {
    return ["Capital City", "Historic Sites", "National Parks", "Local Markets", "Coastal Areas"];
  }

  Widget _buildHeaderTab({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required Color color,
    bool isActive = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          margin: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isActive ? Colors.white : Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: isActive ? Colors.white : Colors.white.withOpacity(0.2)),
          ),
          child: Row(
            children: [
              Icon(icon, color: isActive ? color : Colors.white, size: 18),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: isActive ? Colors.black87 : Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLikedCities(BuildContext context) {
    final likedList = CityData.cities.where((c) => _likedCities.contains(c.name)).toList();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Your Liked Cities", style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: -1)),
                IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close_rounded)),
              ],
            ),
            const SizedBox(height: 20),
            if (likedList.isEmpty)
              const Center(child: Padding(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: Text("No liked cities yet. Explore and heart them!"),
              ))
            else
              Expanded(
                child: ListView.builder(
                  itemCount: likedList.length,
                  itemBuilder: (context, index) => ListTile(
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: CachedNetworkImage(imageUrl: likedList[index].imageUrl, width: 50, height: 50, fit: BoxFit.cover),
                    ),
                    title: Text(likedList[index].name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(likedList[index].country),
                    trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                    onTap: () {
                      Navigator.pop(context);
                      _navigateToCityDetail(context, likedList[index]);
                    },
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Container(
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              theme.colorScheme.primary.withOpacity(0.9),
              theme.colorScheme.secondary.withOpacity(0.8),
            ],
          ),
        ),
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: BlocListener<TripBloc, TripState>(
            listener: (context, state) {
              if (state is TripError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: Colors.redAccent,
                  ),
                );
              }
            },
            child: BlocBuilder<TripBloc, TripState>(
              builder: (context, state) {
                return ResponsiveLayout(
                  mobile: _buildContent(context, state, isDesktop: false),
                  desktop: _buildContent(context, state, isDesktop: true),
                );
              },
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddTripDialog(context),
        label: const Text('New Trip'),
        icon: const Icon(Icons.add_location_alt_rounded),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }

  Widget _buildContent(BuildContext context, TripState state, {required bool isDesktop}) {
    final theme = Theme.of(context);
    final tripCount = state is TripsLoaded ? state.trips.length : 0;
    
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        // App Bar / Header (Scrolls away)
        SliverAppBar(
          floating: true,
          pinned: false,
          snap: false,
          backgroundColor: Colors.transparent,
          elevation: 0,
          toolbarHeight: 90,
          title: Padding(
            padding: EdgeInsets.only(left: isDesktop ? 60 : 20),
            child: Text(
              'Smart Planner',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 28,
                color: Colors.white,
                letterSpacing: -1,
              ),
            ),
          ),
          centerTitle: false,
          actions: [
            Padding(
              padding: EdgeInsets.only(right: isDesktop ? 60 : 20),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, state) {
                      ImageProvider? imageProvider;
                      if (state is Authenticated && state.user.profilePicture != null && state.user.profilePicture!.isNotEmpty) {
                        final String pic = state.user.profilePicture!;
                        if (pic.startsWith('data:image')) {
                          final commaIndex = pic.indexOf(',');
                          if (commaIndex != -1) {
                            imageProvider = MemoryImage(base64Decode(pic.substring(commaIndex + 1)));
                          }
                        } else {
                          String url = pic;
                          if (url.startsWith('/')) {
                            url = "http://127.0.0.1:8000$url";
                          } else if (!url.startsWith('http')) {
                            url = "http://127.0.0.1:8000/media/$url";
                          }
                          final user = state.user;
                          imageProvider = NetworkImage("$url?v=${user.hashCode}");
                        }
                      }

                      return Row(
                        children: [
                          BlocBuilder<TripBloc, TripState>(
                            builder: (context, tripState) {
                              return Stack(
                                children: [
                                  IconButton(
                                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const MyBookingsScreen())),
                                    icon: const Icon(Icons.confirmation_number_rounded, color: Colors.white, size: 28),
                                    tooltip: 'My Bookings',
                                  ),
                                  if (tripState is TripsLoaded)
                                    ...[
                                      () {
                                        final count = tripState.trips.expand((t) => t.bookings ?? []).length;
                                        if (count > 0) {
                                          return Positioned(
                                            right: 8,
                                            top: 8,
                                            child: Container(
                                              padding: const EdgeInsets.all(4),
                                              decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                                              constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                                              child: Text(
                                                "$count",
                                                style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                                                textAlign: TextAlign.center,
                                              ),
                                            ),
                                          );
                                        }
                                        return const SizedBox.shrink();
                                      }(),
                                    ],
                                ],
                              );
                            },
                          ),
                          IconButton(
                            onPressed: () => Navigator.pushNamed(context, '/liked'),
                            icon: const Icon(Icons.favorite_rounded, color: Colors.white, size: 28),
                            tooltip: 'Liked Places',
                          ),
                          const SizedBox(width: 8),
                          MouseRegion(
                            cursor: SystemMouseCursors.click,
                            child: GestureDetector(
                              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfileScreen())),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                padding: const EdgeInsets.all(2),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white.withOpacity(0.5), width: 2),
                                ),
                                child: CircleAvatar(
                                  radius: 24,
                                  backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                                  backgroundImage: imageProvider,
                                  child: imageProvider == null ? const Icon(Icons.person, color: Colors.white) : null,
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(width: 16),
                  NavButton(
                    icon: Icons.exit_to_app_rounded,
                    color: Colors.white,
                    onPressed: () => context.read<AuthBloc>().add(LogoutRequested()),
                  ),
                ],
              ),
            ),
          ],
        ),

        // Search Bar & Filters Section
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(isDesktop ? 60 : 20, 20, isDesktop ? 60 : 20, 10),
            child: _buildSearchBar(context),
          ),
        ),

        // Quick Stats Section - Fully Interactive
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.only(top: 24, bottom: 8),
            child: () {
              int countriesCount = 0;
              double totalBudget = 0;
              int citiesCount = _likedCities.length;
              
              if (state is TripsLoaded) {
                citiesCount += state.trips.length;
                final countries = <String>{};
                for (var t in state.trips) {
                  countries.add(t.destination); // Simple mapping for now
                  totalBudget += t.budget ?? 0;
                }
                
                // Add countries from liked cities
                for (var cityName in _likedCities) {
                  try {
                    final city = CityData.cities.firstWhere((c) => c.name == cityName);
                    countries.add(city.country);
                  } catch(_) {}
                }
                countriesCount = countries.length;
              }
              
              // If still 0 and we have liked cities, at least guess
              if (countriesCount == 0 && _likedCities.isNotEmpty) {
                 countriesCount = (_likedCities.length / 2).ceil().clamp(1, 10);
              }

              return InteractiveStatsSection(
                tripCount: tripCount,
                citiesExplored: citiesCount,
                countriesVisited: countriesCount,
                totalBudgetSaved: totalBudget > 0 ? totalBudget : tripCount * 125.0,
              );
            }(),
          ),
        ),


        // Featured Destinations Carousel
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(isDesktop ? 60 : 20, 32, 0, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "✨ Featured Destinations",
                  style: TextStyle(
                    fontSize: isDesktop ? 28 : 22,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Handpicked places for your next adventure",
                  style: TextStyle(
                    fontSize: 14,
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Stack(
            children: [
              SizedBox(
                height: 300,
                child: ListView.builder(
                  controller: _featuredScrollController,
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.only(left: isDesktop ? 60 : 20, right: 60),
                  itemCount: 6,
                  itemBuilder: (context, index) {
                    final featuredCities = [
                      CityData.cities.firstWhere((c) => c.name == "Paris"),
                      CityData.cities.firstWhere((c) => c.name == "Kyoto"),
                      CityData.cities.firstWhere((c) => c.name == "Santorini"),
                      CityData.cities.firstWhere((c) => c.name == "Dubai"),
                      CityData.cities.firstWhere((c) => c.name == "New York"),
                      CityData.cities.firstWhere((c) => c.name == "Bali"),
                    ];
                    return ExpandableDestinationCard(
                      city: featuredCities[index],
                      isFavorite: _likedCities.contains(featuredCities[index].name),
                      onFavorite: () => _toggleFavorite(featuredCities[index].name),
                      onPlanTrip: () {
                        _navigateToCityDetail(context, featuredCities[index]);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text("✨ Plan Trip Added Successfully!"),
                            backgroundColor: theme.colorScheme.primary,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              // Arrows
              if (isDesktop) ...[
                if (_showLeftArrow)
                  Positioned(
                    left: 40,
                    top: 130,
                    child: _buildScrollButton(Icons.chevron_left, () {
                      _featuredScrollController.animateTo(
                        _featuredScrollController.offset - 400,
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeInOut,
                      );
                    }),
                  ),
                if (_showRightArrow)
                  Positioned(
                    right: 40,
                    top: 130,
                    child: _buildScrollButton(Icons.chevron_right, () {
                      _featuredScrollController.animateTo(
                        _featuredScrollController.offset + 400,
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeInOut,
                      );
                    }),
                  ),
              ],
            ],
          ),
        ),


        // Your Adventures Section
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(isDesktop ? 60 : 20, 40, 20, 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "🎒 Your Adventures",
                  style: TextStyle(
                    fontSize: isDesktop ? 28 : 22,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                if (state is TripsLoaded && state.trips.isNotEmpty)
                  TextButton(
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AllTripsScreen())),
                    child: Text(
                      "See All →",
                      style: TextStyle(
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),

        // Trips List/Grid
        if (state is TripLoading)
          SliverToBoxAdapter(
            child: SizedBox(
              height: 240,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: isDesktop ? 60 : 20),
                itemCount: 3,
                itemBuilder: (context, index) => Container(
                  width: 280,
                  margin: const EdgeInsets.only(right: 20),
                  child: const CardShimmer(isHorizontal: true),
                ),
              ),
            ),
          ),
        
        if (state is TripsLoaded)
          state.trips.isEmpty 
            ? SliverToBoxAdapter(child: _buildEmptyTripsState(context))
            : SliverToBoxAdapter(
                child: SizedBox(
                  height: 280,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.symmetric(horizontal: isDesktop ? 60 : 20),
                    itemCount: state.trips.where((t) => 
                      t.title.toLowerCase().contains(_searchQuery) || 
                      t.destination.toLowerCase().contains(_searchQuery)
                    ).length,
                    itemBuilder: (context, index) {
                      final filteredTrips = state.trips.where((t) => 
                        t.title.toLowerCase().contains(_searchQuery) || 
                        t.destination.toLowerCase().contains(_searchQuery)
                      ).toList();
                      return _TripCardHorizontal(
                        key: ValueKey('trip_${filteredTrips[index].id}_${filteredTrips[index].imageUrl}'),
                        trip: filteredTrips[index],
                      );
                    },
                  ),
                ),
              ),

        // Travel Tips Section - Fully Interactive
        const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.only(top: 40),
            child: InteractiveTravelTipsSection(),
          ),
        ),


        // Seasonal Picks Section - Dynamic Season-Based Content
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: EnhancedSeasonalSection(
              onCityTap: (city) => _navigateToCityDetail(context, city),
            ),
          ),
        ),


        // Explore the World Section
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(isDesktop ? 60 : 20, 40, isDesktop ? 60 : 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _showFavoritesOnly ? "❤️ Your Liked Destinations" : "🌍 Explore the World",
                      style: TextStyle(
                        fontSize: isDesktop ? 28 : 22,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  _showFavoritesOnly ? "Places you've saved for later" : "Discover your next great adventure",
                  style: TextStyle(
                    fontSize: 14,
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
        ),
        
        // Discovery Grid
        SliverPadding(
          padding: EdgeInsets.symmetric(horizontal: isDesktop ? 60 : 20),
          sliver: SliverGrid(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: isDesktop ? 4 : 2,
              childAspectRatio: 0.75,
              crossAxisSpacing: 20,
              mainAxisSpacing: 20,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final currentFilteredCities = CityData.cities.where((c) {
                  final matchesSearch = c.name.toLowerCase().contains(_searchQuery) || c.country.toLowerCase().contains(_searchQuery);
                  final isFavorite = _likedCities.contains(c.name);
                  if (_showFavoritesOnly) return matchesSearch && isFavorite;
                  return matchesSearch;
                }).toList();

                if (index >= currentFilteredCities.length || index >= 4) return null;
                final city = currentFilteredCities[index];

                return _CityCard(
                  key: ValueKey('city_${city.name}'),
                  city: city, 
                  isLiked: _likedCities.contains(city.name),
                  onLike: (val) => _toggleFavorite(city.name),
                  onTap: () => _navigateToCityDetail(context, city),
                );
              },
              childCount: min(CityData.cities.where((c) {
                final matchesSearch = c.name.toLowerCase().contains(_searchQuery) || c.country.toLowerCase().contains(_searchQuery);
                final isFavorite = _likedCities.contains(c.name);
                if (_showFavoritesOnly) return matchesSearch && isFavorite;
                return matchesSearch;
              }).length, 4),
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 100)),
      ],
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    final theme = Theme.of(context);
    final tripState = context.read<TripBloc>().state;
    
    // Get matching results
    final matchingCities = CityData.cities.where((c) =>
      _searchQuery.isNotEmpty && 
      (c.name.toLowerCase().contains(_searchQuery) || 
       c.country.toLowerCase().contains(_searchQuery))
    ).take(5).toList();
    
    final matchingTrips = tripState is TripsLoaded 
      ? tripState.trips.where((t) =>
          _searchQuery.isNotEmpty && 
          (t.title.toLowerCase().contains(_searchQuery) || 
           t.destination.toLowerCase().contains(_searchQuery))
        ).take(3).toList()
      : <Trip>[];

    return Column(
      children: [
        Container(
          height: 56,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.08),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: TextField(
            controller: _searchController,
            cursorColor: Colors.black,
            style: TextStyle(color: theme.colorScheme.onSurface, fontSize: 16),
            decoration: InputDecoration(
              hintText: "Search any country or city in the world...",
              hintStyle: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.4)),
              prefixIcon: _isSearchingWorld 
                ? Padding(
                    padding: const EdgeInsets.all(12),
                    child: SizedBox(
                      width: 20, 
                      height: 20, 
                      child: CircularProgressIndicator(strokeWidth: 2, color: theme.colorScheme.primary)
                    ),
                  )
                : TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.5, end: 1.0),
                    duration: const Duration(seconds: 1),
                    curve: Curves.easeInOut,
                    builder: (context, value, child) => Opacity(
                      opacity: value,
                      child: child,
                    ),
                    onEnd: () => setState(() {}),
                    child: Icon(Icons.search_rounded, color: theme.colorScheme.onSurface, size: 24),
                  ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 18),
              suffixIcon: _searchQuery.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.close_rounded, color: Colors.white60, size: 20),
                    onPressed: () {
                      _searchController.clear();
                      setState(() => _externalResults = []);
                    },
                  )
                : null,
            ),
          ),
        ),
        // Dropdown Results
        if (_searchQuery.isNotEmpty && (matchingCities.isNotEmpty || matchingTrips.isNotEmpty || _externalResults.isNotEmpty))
          Container(
            margin: const EdgeInsets.only(top: 8),
            constraints: const BoxConstraints(maxHeight: 400),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface.withOpacity(0.98),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: theme.colorScheme.primary.withOpacity(0.2)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 30,
                  offset: const Offset(0, 15),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Your Trips Section (Internal)
                    if (matchingTrips.isNotEmpty) ...[
                      _buildSearchSectionHeader(theme, "Your Adventures", Icons.bookmark, Colors.amber),
                      ...matchingTrips.map((trip) => _buildInternalResultTile(context, theme, trip)),
                    ],

                    // External World Results
                    if (_externalResults.isNotEmpty) ...[
                      _buildSearchSectionHeader(theme, "World Results", Icons.language, theme.colorScheme.primary),
                      ..._externalResults.map((result) => _buildExternalResultTile(context, theme, result)),
                    ],

                    // Local Cities (Predefined)
                    if (matchingCities.isNotEmpty) ...[
                      _buildSearchSectionHeader(theme, "Staff Picks", Icons.star, theme.colorScheme.secondary),
                      ...matchingCities.map((city) => _buildInternalCityTile(context, theme, city)),
                    ],
                    
                    if (matchingTrips.isEmpty && matchingCities.isEmpty && _externalResults.isEmpty && !_isSearchingWorld)
                      Padding(
                        padding: const EdgeInsets.all(24),
                        child: Center(
                          child: Text("No results found for \"$_searchQuery\"", style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.5))),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildSearchSectionHeader(ThemeData theme, String title, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 8),
          Text(
            title.toUpperCase(),
            style: TextStyle(
              fontSize: 11,
              letterSpacing: 1.2,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInternalResultTile(BuildContext context, ThemeData theme, Trip trip) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: Colors.amber.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
        child: const Icon(Icons.flight_takeoff, color: Colors.amber, size: 20),
      ),
      title: Text(trip.title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(trip.destination, style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurface.withOpacity(0.5))),
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => TripDetailScreen(trip: trip))),
    );
  }

  Widget _buildInternalCityTile(BuildContext context, ThemeData theme, City city) {
    return ListTile(
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          'https://flagcdn.com/w80/${city.countryCode.toLowerCase()}.png',
          width: 40,
          height: 30,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => const Icon(Icons.flag),
        ),
      ),
      title: Text(city.name, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Row(
        children: [
          Text(city.country, style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurface.withOpacity(0.5))),
        ],
      ),
      onTap: () => _navigateToCityDetail(context, city),
    );
  }

  Widget _buildExternalResultTile(BuildContext context, ThemeData theme, dynamic result) {
    final isCountry = result['type'] == 'country';
    final flagUrl = isCountry ? result['imageUrl'] : result['flagUrl'];
    
    return ListTile(
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: flagUrl != null 
          ? Image.network(flagUrl, width: 40, height: 30, fit: BoxFit.cover, errorBuilder: (c, e, s) => const Icon(Icons.flag))
          : Container(
              width: 40, height: 30, 
              color: theme.colorScheme.primary.withOpacity(0.1),
              child: Icon(Icons.location_city, color: theme.colorScheme.primary, size: 20)
            ),
      ),
      title: Text(result['name'], style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(result['subtitle'], maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurface.withOpacity(0.5))),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text("\$${result['budget']}", style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold, fontSize: 13)),
          const Text("Est. Budget", style: TextStyle(fontSize: 9, color: Colors.grey)),
        ],
      ),
      onTap: () {
        // Build a temporary City object to show details
        final tempCity = City(
          name: result['name'],
          country: isCountry ? result['name'] : result['subtitle'].split(',').last.trim(),
          countryCode: isCountry ? "" : (result['flagUrl']?.toString().split('/').last.split('.').first ?? ""),
          imageUrl: result['imageUrl'],
          description: isCountry 
            ? "Exploration in ${result['name']}, ${result['subtitle']}. Discover hidden gems and local culture."
            : "A vibrant location in ${result['subtitle']}. Perfect for your next adventure.",
          mustVisit: List<String>.from(result['places']),
          averageDailyCost: (result['budget'] as num).toDouble(),
        );
        _navigateToCityDetail(context, tempCity);
      },
    );
  }


  Widget _buildEmptyTripsState(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: GlassContainer(
        padding: const EdgeInsets.all(32),
        borderRadius: 28,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white10,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.map_outlined, size: 48, color: Theme.of(context).colorScheme.onSurface),
            ),
            const SizedBox(height: 20),
            Text(
              "Ready for your next trip?",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface),
            ),
            const SizedBox(height: 8),
            Text(
              "Create your first adventure and we'll help you plan every detail.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6), fontSize: 14),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _showAddTripDialog(context),
              icon: const Icon(Icons.add),
              label: const Text("Start Planning"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToCityDetail(BuildContext context, City city) {
    Navigator.push(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 400),
        reverseTransitionDuration: const Duration(milliseconds: 400),
        pageBuilder: (context, animation, secondaryAnimation) => CityDetailScreen(city: city),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(begin: const Offset(0.05, 0), end: Offset.zero)
                .animate(CurvedAnimation(parent: animation, curve: Curves.easeOut)),
              child: child,
            ),
          );
        },
      ),
    );
  }

  void _showAddTripDialog(BuildContext context) {
    final titleController = TextEditingController();
    final destinationController = TextEditingController();
    String? base64Image;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.transparent,
        contentPadding: EdgeInsets.zero,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20),
        content: StatefulBuilder(
          builder: (context, setDialogState) => GlassContainer(
             padding: const EdgeInsets.all(28),
             child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                  Text("New Adventure", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
                  const SizedBox(height: 8),
                  Text("Where would you like to go next?", style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6), fontSize: 14)),
                 const SizedBox(height: 28),
                  _buildDialogField(titleController, "Trip Title", Icons.title),
                  const SizedBox(height: 16),
                  _buildDialogField(destinationController, "Destination", Icons.location_on_outlined),
                  const SizedBox(height: 20),
                  
                  // Image Selector
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          base64Image == null ? "No cover image selected (Optional)" : "✨ Cover image selected!",
                          style: TextStyle(
                            fontSize: 13, 
                            color: base64Image == null 
                              ? Theme.of(context).colorScheme.onSurface.withOpacity(0.5)
                              : Colors.greenAccent
                          ),
                        ),
                      ),
                      UniversalImagePicker(
                        onImageSelected: (base64) {
                          setDialogState(() => base64Image = base64);
                        },
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            base64Image == null ? Icons.add_photo_alternate_outlined : Icons.check_circle_outline,
                            color: base64Image == null 
                              ? Theme.of(context).colorScheme.onSurface 
                              : Colors.greenAccent,
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context), 
                        child: Text("Cancel", style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7)))
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton(
                        onPressed: () {
                            if (titleController.text.isNotEmpty && destinationController.text.isNotEmpty) {
                              // Check for duplicates
                              bool exists = false;
                              final state = context.read<TripBloc>().state;
                              if (state is TripsLoaded) {
                                exists = state.trips.any((t) => t.destination.toLowerCase() == destinationController.text.toLowerCase());
                              }

                              if (exists) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text("A trip to ${destinationController.text} is already planned!"),
                                    backgroundColor: Colors.orangeAccent,
                                  ),
                                );
                                return;
                              }

                             context.read<TripBloc>().add(CreateTrip(Trip(
                               id: 0,
                               title: titleController.text,
                               destination: destinationController.text,
                               startDate: DateTime.now(),
                               endDate: DateTime.now().add(const Duration(days: 7)),
                               imageUrl: base64Image,
                               createdAt: DateTime.now(),
                             )));
                             Navigator.pop(context);
                           }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.onSurface, 
                          foregroundColor: Theme.of(context).colorScheme.surface,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text("Create"),
                     ),
                   ],
                 )
              ],
             ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterButton({
    required bool isActive, 
    required IconData icon, 
    required String label, 
    required VoidCallback onPressed,
    Color activeColor = Colors.white,
  }) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: isActive ? activeColor.withValues(alpha: 0.2) : Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: isActive ? activeColor.withValues(alpha: 0.5) : Colors.white.withValues(alpha: 0.12)),
          ),
          child: Row(
            children: [
              Icon(icon, color: isActive ? activeColor : Colors.white70, size: 18),
              const SizedBox(width: 6),
              Text(label, style: TextStyle(color: isActive ? activeColor : Colors.white70, fontWeight: FontWeight.w600, fontSize: 13)),
            ],
          ),
        ),
      ),
    );
  }


  Widget _buildDialogField(TextEditingController controller, String label, IconData icon) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        prefixIcon: Icon(icon, color: Colors.white70),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.white24),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildScrollButton(IconData icon, VoidCallback onPressed) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.white),
        onPressed: onPressed,
      ),
    );
  }
}

// Horizontal Trip Card for carousel
class _TripCardHorizontal extends StatefulWidget {
  final Trip trip;
  
  const _TripCardHorizontal({super.key, required this.trip});

  @override
  State<_TripCardHorizontal> createState() => _TripCardHorizontalState();
}

class _TripCardHorizontalState extends State<_TripCardHorizontal> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final trip = widget.trip;
    
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => Navigator.push(
          context,
          PageRouteBuilder(
            transitionDuration: const Duration(milliseconds: 400),
            pageBuilder: (context, animation, _) => FadeTransition(opacity: animation, child: TripDetailScreen(trip: trip)),
          ),
        ),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: 300,
          margin: const EdgeInsets.only(right: 20, bottom: 20),
          transform: Matrix4.identity()..translate(0.0, _isHovered ? -10.0 : 0.0, 0.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            color: Colors.white.withOpacity(0.1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(_isHovered ? 0.3 : 0.1),
                blurRadius: _isHovered ? 25 : 15,
                offset: Offset(0, _isHovered ? 12 : 8),
              ),
            ],
            border: Border.all(color: Colors.white.withOpacity(_isHovered ? 0.3 : 0.1)),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: Stack(
              children: [
                // Background Image/Gradient
                Positioned.fill(
                  child: _buildCardImage(trip.imageUrl),
                ),
                // Overlay for better text visibility
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ),
                // Content
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.flight_takeoff_rounded, color: Colors.white, size: 20),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              "EXPLORE",
                              style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Text(
                        trip.title,
                        style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: -0.5),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(Icons.location_on_rounded, color: Colors.white70, size: 14),
                          const SizedBox(width: 4),
                          Text(
                            trip.destination,
                            style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 13, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.image_search_rounded, color: Colors.white70, size: 22),
                            tooltip: "Change Cover",
                            onPressed: () => _showEditImageDialog(context, trip),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, color: Colors.white70, size: 24),
                            onPressed: () => _confirmDelete(context, trip),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showEditImageDialog(BuildContext context, Trip trip) {
    String selectedImage = trip.imageUrl ?? "";
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text("Edit Trip Cover", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Choose a local photo to update your trip cover.", style: TextStyle(color: Colors.white70, fontSize: 13)),
            const SizedBox(height: 20),
            UniversalImagePicker(
              initialImage: selectedImage,
              onImageSelected: (base64) => selectedImage = base64,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              final updatedTrip = trip.copyWith(imageUrl: selectedImage.isEmpty ? null : selectedImage);
              context.read<TripBloc>().add(UpdateTrip(updatedTrip));
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text("Update Picture"),
          ),
        ],
      ),
    );
  }

  Widget _buildCardImage(String? imageUrl) {
    if (imageUrl != null && imageUrl.startsWith('data:image')) {
      final commaIndex = imageUrl.indexOf(',');
      if (commaIndex != -1) {
        try {
          return Image.memory(base64Decode(imageUrl.substring(commaIndex + 1)), fit: BoxFit.cover);
        } catch (e) {
          return Container(color: Colors.black26);
        }
      }
    }
    
    String? fullUrl = imageUrl;
    if (fullUrl != null && fullUrl.isNotEmpty) {
      if (fullUrl.startsWith('/')) {
        fullUrl = "http://127.0.0.1:8000$fullUrl";
      } else if (!fullUrl.startsWith('http')) {
        fullUrl = "http://127.0.0.1:8000/media/$fullUrl";
      }
      fullUrl = "$fullUrl?v=${fullUrl.length}";
    }

    return CachedNetworkImage(
      imageUrl: fullUrl ?? "https://images.unsplash.com/photo-1503220317375-aaad61436b1b?q=80&w=2070&auto=format&fit=crop",
      cacheKey: fullUrl,
      fit: BoxFit.cover,
      placeholder: (context, url) => Container(color: Colors.black26),
      errorWidget: (context, url, error) => Container(color: Colors.black26),
    );
  }

  void _confirmDelete(BuildContext context, Trip trip) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text("Delete Trip?", style: TextStyle(color: Colors.white)),
        content: Text("Are you sure you want to delete '${trip.title}'?", style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          TextButton(
            onPressed: () {
              context.read<TripBloc>().add(DeleteTrip(trip.id));
              Navigator.pop(context);
            }, 
            child: const Text("Delete", style: TextStyle(color: Colors.redAccent))
          ),
        ],
      ),
    );
  }

  Widget _buildDialogField(TextEditingController controller, String label, IconData icon) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        prefixIcon: Icon(icon, color: Colors.white70),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.white24),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.white),
        ),
      ),
    );
  }
}

// Simplified City Card for better performance
class _CityCard extends StatefulWidget {
  final City city;
  final bool isLiked;
  final Function(bool) onLike;
  final VoidCallback onTap;

  const _CityCard({
    super.key,
    required this.city, 
    required this.isLiked, 
    required this.onLike,
    required this.onTap,
  });

  @override
  State<_CityCard> createState() => _CityCardState();
}

class _CityCardState extends State<_CityCard> with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  late AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  IconData _getSeasonIcon(String cityName) {
    // Determine season based on city name or just random for variety
    final hash = cityName.length % 4;
    switch(hash) {
      case 0: return Icons.wb_sunny_rounded;
      case 1: return Icons.ac_unit_rounded;
      case 2: return Icons.eco_rounded;
      default: return Icons.park_rounded;
    }
  }

  Color _getSeasonColor(String cityName) {
    final hash = cityName.length % 4;
    switch(hash) {
      case 0: return Colors.orangeAccent;
      case 1: return Colors.lightBlueAccent;
      case 2: return Colors.lightGreenAccent;
      default: return Colors.deepOrangeAccent;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final seasonIcon = _getSeasonIcon(widget.city.name);
    final seasonColor = _getSeasonColor(widget.city.name);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: _isHovered ? 1.05 : 1.0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              boxShadow: _isHovered ? [
                BoxShadow(
                  color: seasonColor.withOpacity(0.3),
                  blurRadius: 20,
                  spreadRadius: 2,
                  offset: const Offset(0, 8),
                )
              ] : [],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Stack(
                children: [
                  // City Image
                  CachedNetworkImage(
                    imageUrl: widget.city.imageUrl.startsWith('http') 
                        ? widget.city.imageUrl
                        : (widget.city.imageUrl.startsWith('/') 
                            ? "http://127.0.0.1:8000${widget.city.imageUrl}"
                            : "http://127.0.0.1:8000/media/${widget.city.imageUrl}"),
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                    placeholder: (context, url) => Container(color: Colors.grey[900]),
                  ),
                  
                  // Gradient Overlay
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          _isHovered ? Colors.transparent : Colors.black.withOpacity(0.2),
                          Colors.black.withOpacity(0.8),
                        ],
                      ),
                    ),
                  ),

                  // Season Badge (CSS-like animation)
                  Positioned(
                    top: 12,
                    right: 12,
                    child: AnimatedOpacity(
                      opacity: _isHovered ? 1.0 : 0.8,
                      duration: const Duration(milliseconds: 300),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.black45,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: seasonColor.withOpacity(0.5)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(seasonIcon, color: seasonColor, size: 14),
                            const SizedBox(width: 4),
                            Text(
                              "BEST SEASON",
                              style: TextStyle(color: seasonColor, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Content
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.city.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(2),
                              child: Image.network(
                                'https://flagcdn.com/w40/${widget.city.countryCode.toLowerCase()}.png',
                                width: 16,
                                height: 12,
                                fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              widget.city.country,
                              style: const TextStyle(color: Colors.white70, fontSize: 13),
                            ),
                          ],
                        ),
                        
                        // New: Detailed Description on Hover
                        AnimatedSize(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          child: Container(
                            height: _isHovered ? null : 0,
                            margin: const EdgeInsets.only(top: 8),
                            child: Text(
                              widget.city.description,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 11,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            if (_isHovered)
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    BookingDialogUtils.showBookingDialog(
                                      context: context,
                                      cityName: widget.city.name,
                                      seasonalOffer: "Quick Booking Package",
                                      primaryColor: theme.colorScheme.primary,
                                      icon: Icons.flash_on_rounded,
                                    );
                                  },
                                  icon: const Icon(Icons.flight_takeoff, size: 14),
                                  label: const Text("Plan Trip", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: theme.colorScheme.primary,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                    minimumSize: const Size(double.infinity, 32),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                ),
                              )
                            else 
                              Text(
                                "Package Deals Available",
                                style: TextStyle(
                                  color: theme.colorScheme.primary.withOpacity(0.7),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Shimmer Effect on Hover
                  if (_isHovered)
                    AnimatedBuilder(
                      animation: _shimmerController,
                      builder: (context, child) {
                        return Positioned.fill(
                          child: FractionalTranslation(
                            translation: Offset(_shimmerController.value * 2 - 1, -1),
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Colors.white.withOpacity(0),
                                    Colors.white.withOpacity(0.15),
                                    Colors.white.withOpacity(0),
                                  ],
                                  stops: const [0.3, 0.5, 0.7],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
