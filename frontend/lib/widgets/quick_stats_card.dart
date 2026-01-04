import 'package:flutter/material.dart';

/// Displays quick stats with animated counters
class QuickStatsSection extends StatelessWidget {
  final int? tripCount;
  final int? citiesExplored;
  final int? countriesVisited;
  final double? totalBudgetSaved;

  const QuickStatsSection({
    super.key,
    this.tripCount,
    this.citiesExplored,
    this.countriesVisited,
    this.totalBudgetSaved,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 110,
      child: ListView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: [
          _StatCard(
            icon: Icons.flight_takeoff,
            label: "Trips",
            value: "${tripCount ?? 0}",
            gradient: [const Color(0xFF00D2FF), const Color(0xFF00A8CC)],
          ),
          _StatCard(
            icon: Icons.location_city,
            label: "Cities",
            value: "${citiesExplored ?? 12}",
            gradient: [const Color(0xFFFF6B6B), const Color(0xFFFF4757)],
          ),
          _StatCard(
            icon: Icons.public,
            label: "Countries",
            value: "${countriesVisited ?? 5}",
            gradient: [const Color(0xFF9B59B6), const Color(0xFF8E44AD)],
          ),
          _StatCard(
            icon: Icons.savings_outlined,
            label: "Saved",
            value: "\$${(totalBudgetSaved ?? 420).toInt()}",
            gradient: [const Color(0xFF2ECC71), const Color(0xFF27AE60)],
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final List<Color> gradient;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradient,
        ),
        boxShadow: [
          BoxShadow(
            color: gradient.first.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icon, color: Colors.white, size: 24),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.85),
                    fontSize: 12,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
