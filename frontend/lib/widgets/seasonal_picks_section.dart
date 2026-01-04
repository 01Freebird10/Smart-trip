import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/city.dart';

/// Seasonal picks based on current month
class SeasonalPicksSection extends StatelessWidget {
  final VoidCallback? onCityTap;

  const SeasonalPicksSection({super.key, this.onCityTap});

  String get _currentSeason {
    final month = DateTime.now().month;
    if (month >= 3 && month <= 5) return "Spring";
    if (month >= 6 && month <= 8) return "Summer";
    if (month >= 9 && month <= 11) return "Autumn";
    return "Winter";
  }

  IconData get _seasonIcon {
    final month = DateTime.now().month;
    if (month >= 3 && month <= 5) return Icons.local_florist;
    if (month >= 6 && month <= 8) return Icons.wb_sunny;
    if (month >= 9 && month <= 11) return Icons.eco;
    return Icons.ac_unit;
  }

  Color get _seasonColor {
    final month = DateTime.now().month;
    if (month >= 3 && month <= 5) return const Color(0xFFE91E63);
    if (month >= 6 && month <= 8) return const Color(0xFFFF9800);
    if (month >= 9 && month <= 11) return const Color(0xFFE65100);
    return const Color(0xFF2196F3);
  }

  List<City> get _seasonalCities {
    final month = DateTime.now().month;
    final allCities = CityData.cities;
    
    // Winter picks (Dec-Feb)
    if (month == 12 || month <= 2) {
      return allCities.where((c) => 
        ["Reykjavik", "Kyoto", "Dubai", "Sydney", "Bangkok"].contains(c.name)
      ).toList();
    }
    // Spring picks (Mar-May)
    if (month >= 3 && month <= 5) {
      return allCities.where((c) => 
        ["Kyoto", "Paris", "Amsterdam", "Seoul", "London"].contains(c.name)
      ).toList();
    }
    // Summer picks (Jun-Aug)
    if (month >= 6 && month <= 8) {
      return allCities.where((c) => 
        ["Santorini", "Barcelona", "Bali", "Cape Town", "Lisbon"].contains(c.name)
      ).toList();
    }
    // Autumn picks (Sep-Nov)
    return allCities.where((c) => 
      ["New York", "Prague", "Berlin", "Edinburgh", "Montreal"].contains(c.name)
    ).toList();
  }

  @override
  Widget build(BuildContext context) {
    final cities = _seasonalCities;
    if (cities.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _seasonColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(_seasonIcon, color: _seasonColor, size: 20),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "$_currentSeason Picks",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    "Best destinations this season",
                    style: TextStyle(
                      fontSize: 13,
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 160,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: cities.length,
            itemBuilder: (context, index) {
              return _SeasonalCityCard(
                city: cities[index],
                seasonColor: _seasonColor,
                onTap: onCityTap,
              );
            },
          ),
        ),
      ],
    );
  }
}

class _SeasonalCityCard extends StatefulWidget {
  final City city;
  final Color seasonColor;
  final VoidCallback? onTap;

  const _SeasonalCityCard({
    required this.city,
    required this.seasonColor,
    this.onTap,
  });

  @override
  State<_SeasonalCityCard> createState() => _SeasonalCityCardState();
}

class _SeasonalCityCardState extends State<_SeasonalCityCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 180,
          margin: const EdgeInsets.only(right: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: widget.seasonColor.withOpacity(_isHovered ? 0.3 : 0.15),
                blurRadius: _isHovered ? 16 : 10,
                offset: Offset(0, _isHovered ? 8 : 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Stack(
              fit: StackFit.expand,
              children: [
                CachedNetworkImage(
                  imageUrl: widget.city.imageUrl,
                  fit: BoxFit.cover,
                  memCacheHeight: 320,
                  placeholder: (context, url) => Container(
                    color: widget.seasonColor.withOpacity(0.1),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: widget.seasonColor.withOpacity(0.1),
                    child: const Icon(Icons.landscape, color: Colors.white38),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.7),
                      ],
                    ),
                  ),
                ),
                // Season badge
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: widget.seasonColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      "HOT",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 14,
                  right: 14,
                  bottom: 14,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.city.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        widget.city.country,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 12,
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
