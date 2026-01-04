import 'package:flutter/material.dart';

/// Travel tips carousel with animated cards
class TravelTipsSection extends StatelessWidget {
  const TravelTipsSection({super.key});

  static const List<Map<String, dynamic>> _tips = [
    {
      "icon": Icons.currency_exchange,
      "title": "Currency Tip",
      "tip": "Use local ATMs for better exchange rates than airport exchanges",
      "color": Color(0xFF00D2FF),
    },
    {
      "icon": Icons.flight_class,
      "title": "Booking Hack",
      "tip": "Clear cookies or use incognito mode when booking flights",
      "color": Color(0xFFFF6B6B),
    },
    {
      "icon": Icons.backpack,
      "title": "Packing Pro",
      "tip": "Roll clothes instead of folding to save 30% more space",
      "color": Color(0xFF9B59B6),
    },
    {
      "icon": Icons.restaurant_menu,
      "title": "Foodie Secret",
      "tip": "Eat where locals eat - avoid restaurants with English menus only",
      "color": Color(0xFF2ECC71),
    },
    {
      "icon": Icons.sim_card,
      "title": "Stay Connected",
      "tip": "Buy a local SIM card at the airport for cheaper data",
      "color": Color(0xFFE67E22),
    },
    {
      "icon": Icons.photo_camera,
      "title": "Photo Tip",
      "tip": "Visit popular spots during 'golden hour' for amazing photos",
      "color": Color(0xFFF39C12),
    },
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 140,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _tips.length,
        itemBuilder: (context, index) {
          final tip = _tips[index];
          return _TipCard(
            icon: tip["icon"] as IconData,
            title: tip["title"] as String,
            tip: tip["tip"] as String,
            color: tip["color"] as Color,
          );
        },
      ),
    );
  }
}

class _TipCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final String tip;
  final Color color;

  const _TipCard({
    required this.icon,
    required this.title,
    required this.tip,
    required this.color,
  });

  @override
  State<_TipCard> createState() => _TipCardState();
}

class _TipCardState extends State<_TipCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 260,
        margin: const EdgeInsets.only(right: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: widget.color.withOpacity(_isHovered ? 0.2 : 0.1),
          border: Border.all(
            color: widget.color.withOpacity(_isHovered ? 0.5 : 0.25),
            width: 1.5,
          ),
          boxShadow: _isHovered
              ? [
                  BoxShadow(
                    color: widget.color.withOpacity(0.2),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ]
              : [],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: widget.color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(widget.icon, color: widget.color, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    widget.title,
                    style: TextStyle(
                      color: widget.color,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    widget.tip,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
                      fontSize: 13,
                      height: 1.3,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
