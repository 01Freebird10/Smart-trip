import 'package:flutter/material.dart';

/// Simple Travel Tips Section with interactive cards
class InteractiveTravelTipsSection extends StatelessWidget {
  const InteractiveTravelTipsSection({super.key});

  static const List<TravelTip> _tips = [
    TravelTip(
      icon: Icons.currency_exchange,
      title: "Currency Tip",
      shortTip: "Use local ATMs for better exchange rates",
      fullTip: "When traveling abroad, avoid currency exchange at airports as they often charge high fees. Use local bank ATMs which typically offer the best exchange rates. Pro tip: Always choose 'Decline Conversion' at the ATM to let your home bank handle the rate - it's almost always cheaper!",
      color: Color(0xFF00D2FF),
      category: "Money",
    ),
    TravelTip(
      icon: Icons.flight_class,
      title: "Booking Hack",
      shortTip: "Incognito mode for lower flight prices",
      fullTip: "Airlines track your searches using cookies and may raise prices if they see you're interested. Use incognito mode or clear cookies to see the true prices. For the absolute best value, try booking your flights on a Tuesday afternoon about 6-8 weeks before your departure date.",
      color: Color(0xFFFF6B6B),
      category: "Flights",
    ),
    TravelTip(
      icon: Icons.backpack,
      title: "Packing Pro",
      shortTip: "Roll clothes & use packing cubes",
      fullTip: "Rolling your clothes instead of folding them can save up to 30% of luggage space and reduces wrinkles. For maximum efficiency, use packing cubes to organize items by category or daily outfits. Don't forget to pack a small dryer sheet to keep everything smelling fresh throughout your trip!",
      color: Color(0xFF9B59B6),
      category: "Packing",
    ),
    TravelTip(
      icon: Icons.restaurant_menu,
      title: "Foodie Secret",
      shortTip: "Eat where locals eat for authentic food",
      fullTip: "The best food is often found 2-3 streets away from major tourist attractions. Look for restaurants without English menus and watch where locals queue up during lunch hour. Download apps like 'Eatwith' or search locally-written blogs for hidden gems that aren't on typical top-10 lists.",
      color: Color(0xFF2ECC71),
      category: "Food",
    ),
    TravelTip(
      icon: Icons.sim_card,
      title: "Stay Connected",
      shortTip: "Get local SIM or eSIM for cheaper data",
      fullTip: "Avoid expensive international roaming by getting a local SIM card or using an eSIM app like Airalo. You can often get 10-20GB of data for under \$20 in most countries. If you need offline maps, download your destination in Google Maps while on Wi-Fi to navigate without any data usage.",
      color: Color(0xFFE67E22),
      category: "Tech",
    ),
    TravelTip(
      icon: Icons.health_and_safety,
      title: "Safety First",
      shortTip: "Keep digital copies of documents",
      fullTip: "Scan your passport, insurance, and itinerary and save them in a secure cloud folder (like Google Drive) that's accessible offline. Also, email a copy to a family member back home. It's much easier to get a replacement passport at an embassy if you have a clear scanned copy of the original.",
      color: Color(0xFFF1C40F),
      category: "Safety",
    ),
    TravelTip(
      icon: Icons.language,
      title: "Cultural Etiquette",
      shortTip: "Learn basic local phrases",
      fullTip: "A simple 'Hello', 'Please', and 'Thank you' in the local language goes a long way. People appreciate the effort and it often leads to better service and warmer interactions. Research local tipping customs and dress codes for religious sites before you go to avoid unintentional disrespect.",
      color: Color(0xFF1ABC9C),
      category: "Culture",
    ),
    TravelTip(
      icon: Icons.medical_services,
      title: "Travel Health",
      shortTip: "Stay hydrated and pack basics",
      fullTip: "Jet lag and different climates can take a toll on your body. Drink plenty of water (check if local tap water is safe first) and pack a small first-aid kit with essentials like pain relievers, digestive medicine, and plasters. Compression socks are also a lifesaver for long-haul flights to prevent swelling.",
      color: Color(0xFFE74C3C),
      category: "Health",
    ),
    TravelTip(
      icon: Icons.eco,
      title: "Eco-Traveler",
      shortTip: "Reduce your waste on the go",
      fullTip: "Pack a reusable water bottle (ideally one with a built-in filter) and a foldable shopping bag to avoid single-use plastics. Opt for walking, cycling, or public transport over taxis whenever possible. Supporting local artisans and small-scale tour operators also ensures your money benefits the local community directly.",
      color: Color(0xFF27AE60),
      category: "Green",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "💡 Travel Tips",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              TextButton.icon(
                onPressed: () => _showAllTips(context),
                icon: const Icon(Icons.grid_view, size: 16),
                label: const Text("All Tips"),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        
        // Tips Carousel
        SizedBox(
          height: 160,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: _tips.length,
            itemBuilder: (context, index) {
              return _SimpleTipCard(
                tip: _tips[index],
                onTap: () => _showTipDetail(context, _tips[index]),
              );
            },
          ),
        ),
      ],
    );
  }

  void _showTipDetail(BuildContext context, TravelTip tip) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.5,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 12),
                width: 48,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            
            // Header with icon
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: tip.color.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Icon(tip.icon, color: tip.color, size: 32),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tip.title,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.only(top: 4),
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: tip.color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            tip.category,
                            style: TextStyle(
                              color: tip.color,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            // Full tip content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Text(
                    tip.fullTip,
                    style: TextStyle(
                      fontSize: 16,
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
                      height: 1.6,
                    ),
                  ),
                ),
              ),
            ),
            
            // Final confirmation button
            Padding(
              padding: const EdgeInsets.all(24),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.check_circle_outline),
                  label: const Text("Got it, thanks!"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: tip.color,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAllTips(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        builder: (context, scrollController) {
          return Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
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
                      const Icon(Icons.lightbulb, color: Colors.amber, size: 28),
                      const SizedBox(width: 12),
                      const Text(
                        "All Travel Tips",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        "${_tips.length} tips",
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: _tips.length,
                    itemBuilder: (context, index) {
                      final tip = _tips[index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                          _showTipDetail(context, tip);
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: tip.color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: tip.color.withOpacity(0.2)),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: tip.color.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(tip.icon, color: tip.color, size: 24),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      tip.title,
                                      style: TextStyle(
                                        color: tip.color,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      tip.shortTip,
                                      style: TextStyle(
                                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(Icons.chevron_right, color: tip.color),
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

/// Travel Tip model
class TravelTip {
  final IconData icon;
  final String title;
  final String shortTip;
  final String fullTip;
  final Color color;
  final String category;

  const TravelTip({
    required this.icon,
    required this.title,
    required this.shortTip,
    required this.fullTip,
    required this.color,
    required this.category,
  });
}

/// Simple tip card without complex animations
class _SimpleTipCard extends StatefulWidget {
  final TravelTip tip;
  final VoidCallback? onTap;

  const _SimpleTipCard({
    required this.tip,
    this.onTap,
  });

  @override
  State<_SimpleTipCard> createState() => _SimpleTipCardState();
}

class _SimpleTipCardState extends State<_SimpleTipCard> {
  bool _isPressed = false;
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onTap,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: AnimatedScale(
          scale: _isPressed ? 0.95 : (_isHovered ? 1.05 : 1.0),
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 280,
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              color: _isHovered 
                  ? widget.tip.color.withOpacity(0.18) 
                  : widget.tip.color.withOpacity(0.1),
              border: Border.all(
                color: _isHovered 
                    ? widget.tip.color.withOpacity(0.6) 
                    : widget.tip.color.withOpacity(0.25),
                width: _isHovered ? 2.0 : 1.5,
              ),
              boxShadow: _isHovered ? [
                BoxShadow(
                  color: widget.tip.color.withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                )
              ] : [],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            widget.tip.color,
                            _isHovered ? widget.tip.color.withOpacity(0.9) : widget.tip.color.withOpacity(0.7),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: _isHovered ? [
                          BoxShadow(
                            color: widget.tip.color.withOpacity(0.4),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          )
                        ] : [],
                      ),
                      child: Icon(widget.tip.icon, color: Colors.white, size: 24),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.tip.title,
                            style: TextStyle(
                              color: widget.tip.color,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            widget.tip.category,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    AnimatedRotation(
                      turns: _isHovered ? 0.05 : 0,
                      duration: const Duration(milliseconds: 300),
                      child: Icon(
                        Icons.arrow_forward_ios,
                        color: widget.tip.color,
                        size: 16,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Text(
                  widget.tip.shortTip,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
                    fontSize: 14,
                    height: 1.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      _isHovered ? Icons.touch_app : Icons.touch_app_outlined,
                      size: 14,
                      color: widget.tip.color.withOpacity(0.6),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _isHovered ? "View Detailed Tip" : "Tap for more",
                      style: TextStyle(
                        color: widget.tip.color.withOpacity(0.6),
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

