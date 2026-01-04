import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/city.dart';
import '../models/seasonal_destination.dart';
import '../models/trip.dart';
import '../repositories/trip_repository.dart';
import '../utils/booking_utils.dart';

/// Simple Seasonal Picks Section with dynamic content based on current season
class EnhancedSeasonalSection extends StatefulWidget {
  final Function(City city)? onCityTap;

  const EnhancedSeasonalSection({super.key, this.onCityTap});

  @override
  State<EnhancedSeasonalSection> createState() => _EnhancedSeasonalSectionState();
}

class _EnhancedSeasonalSectionState extends State<EnhancedSeasonalSection> {
  List<SeasonalDestination> _destinations = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDestinations();
  }

  void _loadDestinations() {
    setState(() {
      _destinations = _getSeasonalDestinations();
      _isLoading = false;
    });
  }

  String get _seasonDisplayName {
    final month = DateTime.now().month;
    if (month >= 3 && month <= 5) return "Spring";
    if (month >= 6 && month <= 8) return "Summer";
    if (month >= 9 && month <= 11) return "Autumn";
    return "Winter";
  }

  String get _seasonalTitle {
    final month = DateTime.now().month;
    if (month >= 3 && month <= 5) return "🌸 Spring Blossom Getaways";
    if (month >= 6 && month <= 8) return "☀️ Summer Beach Paradises";
    if (month >= 9 && month <= 11) return "🍂 Autumn Foliage Adventures";
    return "❄️ Winter Wonderland Escapes";
  }

  Color get _seasonColor {
    final month = DateTime.now().month;
    if (month >= 3 && month <= 5) return const Color(0xFFE91E63);
    if (month >= 6 && month <= 8) return const Color(0xFFFF9800);
    if (month >= 9 && month <= 11) return const Color(0xFFFF5722);
    return const Color(0xFF2196F3);
  }

  IconData get _seasonIcon {
    final month = DateTime.now().month;
    if (month >= 3 && month <= 5) return Icons.local_florist_rounded;
    if (month >= 6 && month <= 8) return Icons.wb_sunny_rounded;
    if (month >= 9 && month <= 11) return Icons.eco_rounded;
    return Icons.ac_unit_rounded;
  }

  LinearGradient get _sectionGradient {
    final month = DateTime.now().month;
    if (month >= 3 && month <= 5) {
      return const LinearGradient(
        colors: [Color(0xFFE91E63), Color(0xFFC2185B)],
        begin: Alignment.topLeft, end: Alignment.bottomRight,
      );
    }
    if (month >= 6 && month <= 8) {
      return const LinearGradient(
        colors: [Color(0xFFFF9800), Color(0xFFF57C00)],
        begin: Alignment.topLeft, end: Alignment.bottomRight,
      );
    }
    if (month >= 9 && month <= 11) {
      return const LinearGradient(
        colors: [Color(0xFF795548), Color(0xFF5D4037)],
        begin: Alignment.topLeft, end: Alignment.bottomRight,
      );
    }
    return const LinearGradient(
      colors: [Color(0xFF00BFA5), Color(0xFF00897B)], // Vivid Teal as in screenshot
      begin: Alignment.topLeft, end: Alignment.bottomRight,
    );
  }

  List<SeasonalDestination> _getSeasonalDestinations() {
    final month = DateTime.now().month;
    if (month == 12 || month <= 2) return _getWinterDestinations();
    if (month >= 3 && month <= 5) return _getSpringDestinations();
    if (month >= 6 && month <= 8) return _getSummerDestinations();
    return _getAutumnDestinations();
  }

  List<SeasonalDestination> _getWinterDestinations() {
    return [
      SeasonalDestination(
        city: CityData.cities.firstWhere((c) => c.name == "Reykjavik"),
        seasonalOffer: "Northern Lights Special",
        discount: 20,
        specialActivity: "Aurora Borealis Tours",
        bestFor: "Snow & Ice Adventures",
        temperature: "-2°C",
        weatherIcon: "❄️",
      ),
      SeasonalDestination(
        city: CityData.cities.firstWhere((c) => c.name == "Dubai"),
        seasonalOffer: "Winter Sun Escape",
        discount: 15,
        specialActivity: "Desert Safari",
        bestFor: "Warm Winter Retreat",
        temperature: "25°C",
        weatherIcon: "☀️",
      ),
      SeasonalDestination(
        city: CityData.cities.firstWhere((c) => c.name == "Kyoto"),
        seasonalOffer: "Winter Temple Tours",
        discount: 18,
        specialActivity: "Hot Spring Experience",
        bestFor: "Cultural Immersion",
        temperature: "5°C",
        weatherIcon: "🌨️",
      ),
    ];
  }

  List<SeasonalDestination> _getSpringDestinations() {
    return [
      SeasonalDestination(
        city: CityData.cities.firstWhere((c) => c.name == "Kyoto"),
        seasonalOffer: "Cherry Blossom Special",
        discount: 25,
        specialActivity: "Sakura Viewing",
        bestFor: "Nature & Culture",
        temperature: "18°C",
        weatherIcon: "🌸",
      ),
      SeasonalDestination(
        city: CityData.cities.firstWhere((c) => c.name == "Paris"),
        seasonalOffer: "Spring in Paris",
        discount: 20,
        specialActivity: "Garden Tours",
        bestFor: "Romantic Getaway",
        temperature: "15°C",
        weatherIcon: "🌷",
      ),
    ];
  }

  List<SeasonalDestination> _getSummerDestinations() {
    return [
      SeasonalDestination(
        city: CityData.cities.firstWhere((c) => c.name == "Santorini"),
        seasonalOffer: "Greek Island Paradise",
        discount: 30,
        specialActivity: "Sunset Cruises",
        bestFor: "Beach & Romance",
        temperature: "28°C",
        weatherIcon: "☀️",
      ),
      SeasonalDestination(
        city: CityData.cities.firstWhere((c) => c.name == "Bali"),
        seasonalOffer: "Tropical Retreat",
        discount: 25,
        specialActivity: "Temple Tours",
        bestFor: "Adventure & Relaxation",
        temperature: "30°C",
        weatherIcon: "🌴",
      ),
    ];
  }

  List<SeasonalDestination> _getAutumnDestinations() {
    return [
      SeasonalDestination(
        city: CityData.cities.firstWhere((c) => c.name == "New York"),
        seasonalOffer: "Fall Foliage Special",
        discount: 22,
        specialActivity: "Central Park Tours",
        bestFor: "City & Nature",
        temperature: "15°C",
        weatherIcon: "🍂",
      ),
      SeasonalDestination(
        city: CityData.cities.firstWhere((c) => c.name == "Kyoto"),
        seasonalOffer: "Autumn Leaves Festival",
        discount: 20,
        specialActivity: "Temple Gardens",
        bestFor: "Nature Photography",
        temperature: "18°C",
        weatherIcon: "🍁",
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const SizedBox(
        height: 380,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40),
      decoration: BoxDecoration(
        gradient: _sectionGradient,
      ),
      child: Stack(
        children: [
          // Background Particles
          Positioned.fill(child: _SeasonalParticleLayer(season: _seasonDisplayName)),
          
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Premium Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white.withOpacity(0.3)),
                      ),
                      child: Icon(_seasonIcon, color: Colors.white, size: 28),
                    ),
                    const SizedBox(width: 18),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _seasonalTitle,
                            style: const TextStyle(
                              fontSize: 28, // Bigger and bolder
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Exclusive $_seasonDisplayName deals ending soon!",
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.white.withOpacity(0.9),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),

                // Interactive Destinations Carousel
                SizedBox(
                  height: 380, // Increased from 340 to prevent overflow during hover scale (1.05 * 340 = 357)
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.only(top: 10, bottom: 20), // Padding for scale
                    itemCount: _destinations.length,
                    itemBuilder: (context, index) {
                      return _InteractiveSeasonalCard(
                        destination: _destinations[index],
                        seasonColor: _seasonColor,
                        onTap: () => widget.onCityTap?.call(_destinations[index].city),
                        onBookNow: () => _showBookingDialog(context, _destinations[index]),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showBookingDialog(BuildContext context, SeasonalDestination destination) {
    BookingDialogUtils.showBookingDialog(
      context: context,
      cityName: destination.city.name,
      seasonalOffer: destination.seasonalOffer,
      primaryColor: _seasonColor,
      icon: _seasonIcon,
    );
  }

  Widget _buildDialogInfo(IconData icon, String text, ThemeData theme) {
    return Row(
      children: [
        Icon(icon, size: 18, color: theme.colorScheme.primary.withOpacity(0.7)),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.8)),
          ),
        ),
      ],
    );
  }

  void _showAllDeals(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (context, scrollController) {
          return Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 12),
                  width: 48,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Icon(_seasonIcon, color: _seasonColor, size: 28),
                      const SizedBox(width: 12),
                      Text(
                        "All $_seasonDisplayName Deals",
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: _destinations.length,
                    itemBuilder: (context, index) {
                      final dest = _destinations[index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                          widget.onCityTap?.call(dest.city);
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: _seasonColor.withOpacity(0.2)),
                          ),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(14),
                                child: CachedNetworkImage(
                                  imageUrl: dest.city.imageUrl,
                                  width: 80,
                                  height: 80,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          dest.city.name,
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: _seasonColor,
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Text(
                                            "SAVE \$35",
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      dest.seasonalOffer,
                                      style: TextStyle(
                                        color: _seasonColor,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      "${dest.weatherIcon} ${dest.temperature} • ${dest.bestFor}",
                                      style: TextStyle(
                                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(Icons.chevron_right),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// Particle layer for seasonal effects (Snow, Sunbeams, etc)
class _SeasonalParticleLayer extends StatefulWidget {
  final String season;
  const _SeasonalParticleLayer({required this.season});

  @override
  State<_SeasonalParticleLayer> createState() => _SeasonalParticleLayerState();
}

class _SeasonalParticleLayerState extends State<_SeasonalParticleLayer> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<_Particle> _particles = [];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 10))..repeat();
    _initParticles();
  }

  void _initParticles() {
    for (int i = 0; i < 20; i++) {
      _particles.add(_Particle());
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: _ParticlePainter(_particles, _controller.value, widget.season),
        );
      },
    );
  }
}

class _Particle {
  double x = 0;
  double y = 0;
  double size = 0;
  double speed = 0;
  double opacity = 0;

  _Particle() {
    x = DateTime.now().microsecondsSinceEpoch % 1000 / 1000;
    y = DateTime.now().microsecondsSinceEpoch % 1000 / 1000;
    size = 2 + (DateTime.now().microsecondsSinceEpoch % 5);
    speed = 0.5 + (DateTime.now().microsecondsSinceEpoch % 10 / 10);
    opacity = 0.1 + (DateTime.now().microsecondsSinceEpoch % 5 / 10);
  }
}

class _ParticlePainter extends CustomPainter {
  final List<_Particle> particles;
  final double progress;
  final String season;

  _ParticlePainter(this.particles, this.progress, this.season);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white;
    for (var p in particles) {
      final yPos = (p.y + progress * p.speed) % 1.0 * size.height;
      final xPos = p.x * size.width;
      paint.color = Colors.white.withOpacity(p.opacity);
      
      if (season == "Winter") {
        canvas.drawCircle(Offset(xPos, yPos), p.size / 2, paint);
      } else if (season == "Spring") {
        paint.color = Colors.pinkAccent.withOpacity(p.opacity);
        canvas.drawCircle(Offset(xPos, yPos), p.size / 1.5, paint);
      } else if (season == "Summer") {
        paint.color = Colors.yellowAccent.withOpacity(p.opacity);
        canvas.drawCircle(Offset(xPos, yPos), p.size * 2, paint);
      } else {
        paint.color = Colors.orangeAccent.withOpacity(p.opacity);
        canvas.drawRect(Rect.fromLTWH(xPos, yPos, p.size, p.size), paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

/// Enhanced Interactive Seasonal Card
class _InteractiveSeasonalCard extends StatefulWidget {
  final SeasonalDestination destination;
  final Color seasonColor;
  final VoidCallback? onTap;
  final VoidCallback? onBookNow;

  const _InteractiveSeasonalCard({
    required this.destination,
    required this.seasonColor,
    this.onTap,
    this.onBookNow,
  });

  @override
  State<_InteractiveSeasonalCard> createState() => _InteractiveSeasonalCardState();
}

class _InteractiveSeasonalCardState extends State<_InteractiveSeasonalCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        cursor: SystemMouseCursors.click,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOutCubic,
          width: 280,
          margin: const EdgeInsets.only(right: 20),
          transform: Matrix4.identity()
            ..translate(0.0, _isHovered ? -15.0 : 0.0, 0.0)
            ..scale(_isHovered ? 1.05 : 1.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(_isHovered ? 0.3 : 0.1),
                blurRadius: _isHovered ? 30 : 15,
                offset: Offset(0, _isHovered ? 15 : 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(32),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Image with Interactive Brightness
                ColorFiltered(
                  colorFilter: ColorFilter.mode(
                    Colors.black.withOpacity(_isHovered ? 0.0 : 0.1),
                    BlendMode.darken,
                  ),
                  child: CachedNetworkImage(
                    imageUrl: widget.destination.city.imageUrl,
                    fit: BoxFit.cover,
                    memCacheHeight: 600,
                    placeholder: (context, url) => Container(color: Colors.grey[900]),
                  ),
                ),
                
                // Bottom Gradient
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(_isHovered ? 0.4 : 0.6),
                        Colors.black.withOpacity(0.9),
                      ],
                      stops: const [0.4, 0.7, 1.0],
                    ),
                  ),
                ),
                
                // Top Badges (Discount and Weather)
                Positioned(
                  top: 16,
                  left: 16,
                  right: 16,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Discount Badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10),
                          ],
                        ),
                        child: Text(
                          "SAVE \$35",
                          style: TextStyle(
                            color: widget.seasonColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      
                      // Weather Badge (Like in screenshot)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white.withOpacity(0.3)),
                        ),
                        child: Row(
                          children: [
                            Text(widget.destination.weatherIcon, style: const TextStyle(fontSize: 14)),
                            const SizedBox(width: 4),
                            Text(
                              widget.destination.temperature,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Card Content
                Positioned(
                  left: 20,
                  right: 20,
                  bottom: 20,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Hero(
                        tag: 'seasonal_${widget.destination.city.name}',
                        child: Material(
                          color: Colors.transparent,
                          child: Text(
                            widget.destination.city.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 26,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -1,
                            ),
                          ),
                        ),
                      ),
                      Text(
                        widget.destination.city.country,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 12),
                      AnimatedOpacity(
                        opacity: _isHovered ? 1.0 : 0.8,
                        duration: const Duration(milliseconds: 300),
                        child: Text(
                          widget.destination.seasonalOffer,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      
                      // Animated Book Now Button (Matches Screenshot)
                      GestureDetector(
                        onTap: widget.onBookNow,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            color: _isHovered ? Colors.white : Colors.white.withOpacity(0.95),
                            borderRadius: BorderRadius.circular(18),
                            boxShadow: _isHovered ? [
                              BoxShadow(color: Colors.white.withOpacity(0.3), blurRadius: 15, spreadRadius: 2),
                            ] : [],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.flight_takeoff_rounded, size: 20, color: widget.seasonColor),
                              const SizedBox(width: 10),
                              Text(
                                "Book Now",
                                style: TextStyle(
                                  color: widget.seasonColor,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                        ),
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
}
