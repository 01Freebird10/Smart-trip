import 'package:flutter/material.dart';

/// Enhanced Interactive Stats Section with hover animations and dynamic detail panels
class InteractiveStatsSection extends StatefulWidget {
  final int tripCount;
  final int citiesExplored;
  final int countriesVisited;
  final double totalBudgetSaved;

  const InteractiveStatsSection({
    super.key,
    this.tripCount = 0,
    this.citiesExplored = 0,
    this.countriesVisited = 0,
    this.totalBudgetSaved = 0,
  });

  @override
  State<InteractiveStatsSection> createState() => _InteractiveStatsSectionState();
}

class _InteractiveStatsSectionState extends State<InteractiveStatsSection> {
  int? _selectedIndex;
  bool _isTransitioning = false;

  void _onCardTap(int index) {
    if (_selectedIndex == index) {
      setState(() => _selectedIndex = null); 
    } else {
      setState(() {
        _isTransitioning = true;
        _selectedIndex = index;
      });
      Future.delayed(const Duration(milliseconds: 600), () {
        if (mounted) setState(() => _isTransitioning = false);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      height: _selectedIndex == null ? 160 : 210,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      color: Colors.transparent, 
      clipBehavior: Clip.antiAlias, 
      child: Stack(
        children: [
          _buildCardsRow(),
          if (_selectedIndex != null) _buildDetailsPanel(),
        ],
      ),
    );
  }

  Widget _buildCardsRow() {
    return AnimatedAlign(
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOutCubic,
      alignment: _selectedIndex == null ? Alignment.center : Alignment.centerLeft,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildAnimatedCard(0, Icons.flight_takeoff, "Trips", "${widget.tripCount}", "adventures", const [Color(0xFF00D2FF), Color(0xFF00A8CC)]),
          _buildAnimatedCard(1, Icons.location_city, "Cities", "${widget.citiesExplored}", "explored", const [Color(0xFFFF6B6B), Color(0xFFFF4757)]),
          _buildAnimatedCard(2, Icons.public, "Countries", "${widget.countriesVisited}", "visited", const [Color(0xFF9B59B6), Color(0xFF8E44AD)]),
          _buildAnimatedCard(3, Icons.savings_outlined, "Saved", "\$${widget.totalBudgetSaved.toInt()}", "this year", const [Color(0xFF2ECC71), Color(0xFF27AE60)]),
        ],
      ),
    );
  }

  Widget _buildAnimatedCard(int index, IconData icon, String label, String value, String subtitle, List<Color> colors) {
    final isSelected = _selectedIndex == index;
    final isHidden = _selectedIndex != null && !isSelected;

    return _HoverableStatCard(
      isHidden: isHidden,
      isSelected: isSelected,
      icon: icon,
      label: label,
      value: value,
      subtitle: subtitle,
      colors: colors,
      onTap: () => _onCardTap(index),
    );
  }

  Widget _buildDetailsPanel() {
    final type = _selectedIndex == 0 ? "trips" : _selectedIndex == 1 ? "cities" : _selectedIndex == 2 ? "countries" : "savings";
    final gradient = _selectedIndex == 0 ? [Color(0xFF00D2FF), Color(0xFF00A8CC)] : _selectedIndex == 1 ? [Color(0xFFFF6B6B), Color(0xFFFF4757)] : _selectedIndex == 2 ? [Color(0xFF9B59B6), Color(0xFF8E44AD)] : [Color(0xFF2ECC71), Color(0xFF27AE60)];
    
    return Positioned(
      left: 130,
      right: 0,
      top: 0,
      bottom: 0,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeOutCubic,
        builder: (context, value, child) {
          return Opacity(
            opacity: value,
            child: Transform.translate(
              offset: Offset(30 * (1 - value), 0),
              child: child,
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.12),
            borderRadius: BorderRadius.circular(32),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child: SingleChildScrollView( 
            physics: const NeverScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                     Text("Detailed Stats", style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1)),
                     Container(
                       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                       decoration: BoxDecoration(color: gradient.first, borderRadius: BorderRadius.circular(10)),
                       child: const Text("LIVE", style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.w900)),
                     ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  _getPanelTitle(type, value: _selectedIndex == 3 ? "\$${widget.totalBudgetSaved.toInt()}" : ""),
                  style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 20),
                const SizedBox(height: 12),
                _buildInfoRow(Icons.auto_graph_rounded, "Top 5% of all users"),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getPanelTitle(String type, {String value = ""}) {
    switch(type) {
      case "trips": return "${widget.tripCount} Adventures Logged";
      case "cities": return "${widget.citiesExplored} Cities Discovered";
      case "countries": return "${widget.countriesVisited} Countries Visited";
      default: return "Total Savings: $value";
    }
  }

  Widget _buildProgressRow(String label, double value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 10)),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(value: value, backgroundColor: Colors.white.withOpacity(0.1), color: color, minHeight: 6),
        ),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: Colors.white.withOpacity(0.5), size: 14),
        const SizedBox(width: 8),
        Text(text, style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 11)),
      ],
    );
  }
}

class _HoverableStatCard extends StatefulWidget {
  final bool isHidden;
  final bool isSelected;
  final IconData icon;
  final String label;
  final String value;
  final String subtitle;
  final List<Color> colors;
  final VoidCallback onTap;

  const _HoverableStatCard({
    required this.isHidden,
    required this.isSelected,
    required this.icon,
    required this.label,
    required this.value,
    required this.subtitle,
    required this.colors,
    required this.onTap,
  });

  @override
  State<_HoverableStatCard> createState() => _HoverableStatCardState();
}

class _HoverableStatCardState extends State<_HoverableStatCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedPadding(
      duration: const Duration(milliseconds: 400),
      padding: EdgeInsets.only(right: widget.isHidden ? 0 : 12),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 400),
        opacity: widget.isHidden ? 0.0 : 1.0,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeOutCubic,
          width: widget.isHidden ? 0 : 110,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            gradient: LinearGradient(
              colors: widget.colors, 
              begin: Alignment.topLeft, 
              end: Alignment.bottomRight
            ),
            boxShadow: [
              BoxShadow(
                color: widget.colors.first.withOpacity(_isHovered ? 0.6 : 0.4),
                blurRadius: _isHovered ? 20 : 15,
                offset: Offset(0, _isHovered ? 12 : 8),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: widget.onTap,
              onHover: (v) => setState(() => _isHovered = v),
              borderRadius: BorderRadius.circular(28),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 400),
                      transform: Matrix4.identity()
                        ..translate(_isHovered ? 5.0 : 0.0, _isHovered ? -5.0 : 0.0, 0.0)
                        ..scale(_isHovered ? 1.25 : 1.0),
                      child: Icon(widget.icon, color: Colors.white, size: 26),
                    ),
                    const Spacer(),
                    Text(widget.value, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900, height: 1)),
                    const SizedBox(height: 2),
                    Text(widget.label, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                    Text(widget.subtitle, style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 10)),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
