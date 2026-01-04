import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/city.dart';
import '../models/trip.dart';
import '../blocs/trip_bloc.dart';
import '../widgets/nav_button.dart';
import 'all_trips_screen.dart';
import '../utils/booking_utils.dart';

class CityDetailScreen extends StatefulWidget {
  final City city;

  const CityDetailScreen({
    super.key,
    required this.city,
  });

  @override
  State<CityDetailScreen> createState() => _CityDetailScreenState();
}

class _CityDetailScreenState extends State<CityDetailScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  bool _canPop = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    
    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeOut);

    // Start animation immediately for faster feel
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleBack() {
    if (_canPop && mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return PopScope(
      canPop: _canPop,
      child: Scaffold(
        backgroundColor: theme.colorScheme.surface,
        body: LayoutBuilder(
          builder: (context, constraints) {
            final isDesktop = constraints.maxWidth > 900;
            

          if (isDesktop) {
            // Desktop Split View (Image Left, Content Right)
            return Row(
              children: [
                // Left Panel: Image
                Expanded(
                  flex: 5, // 45%ish
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Hero(
                        tag: 'discovery_${widget.city.name}',
                        child: Image.network(
                          widget.city.imageUrl, 
                          fit: BoxFit.cover,
                          // No cacheWidth for Full HD quality
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [Colors.black.withOpacity(0.4), Colors.transparent],
                          ),
                        ),
                      ),
                      Positioned( // Back button for desktop (on image)
                        top: 24,
                        left: 24,
                        child: SafeArea(
                          child: NavButton(
                            icon: Icons.arrow_back,
                            onPressed: () => Navigator.pop(context),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 48,
                        left: 48,
                        right: 48,
                        child: FadeTransition(
                          opacity: _fadeAnimation,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.city.name,
                                style: TextStyle(fontSize: 72, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface, letterSpacing: -2),
                              ),
                              Row(
                                children: [
                                  Icon(Icons.location_on, color: theme.colorScheme.onSurface, size: 28),
                                  const SizedBox(width: 8),
                                  Text(
                                    widget.city.country,
                                    style: TextStyle(fontSize: 28, color: theme.colorScheme.onSurface, fontWeight: FontWeight.w500),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),

                    ],
                  ),
                ),
                
                // Right Panel: Content
                Expanded(
                  flex: 6, // 55%ish
                  child: Column(
                    children: [
                      // Desktop Right Header Actions
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                             NavButton(icon: Icons.favorite_border, onPressed: (){}, color: theme.colorScheme.onSurface),
                             NavButton(icon: Icons.share_outlined, onPressed: (){}, color: theme.colorScheme.onSurface),
                          ],
                        ),
                      ),
                      Expanded(
                        child: SingleChildScrollView(
                           physics: const BouncingScrollPhysics(),
                           padding: const EdgeInsets.all(48),
                           child: Column(
                             crossAxisAlignment: CrossAxisAlignment.start,
                             children: [
                               _buildContent(theme),
                               const SizedBox(height: 100),
                             ],
                           ),
                        ),
                      ),
                      _buildBottomBar(theme, isDesktop: true),
                    ],
                  ),
                ),
              ],
            );
          } else {
            // Mobile View (Refined "Not Full Zoom" feel)
            // We use a SafeArea and padding to make the image look like a card 3/4 layout instead of edge-to-edge
            return Column(
              children: [
                Expanded(
                  child: CustomScrollView(
                    physics: const BouncingScrollPhysics(),
                    slivers: [
                      SliverAppBar(
                        expandedHeight: 320,
                        backgroundColor: theme.colorScheme.surface,
                        elevation: 0,
                        pinned: true,
                        leading: Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: NavButton(
                            icon: Icons.arrow_back,
                            onPressed: () => Navigator.pop(context),
                          ),
                        ),
                        flexibleSpace: FlexibleSpaceBar(
                          background: Stack(
                            fit: StackFit.expand,
                            children: [
                              Hero(
                                tag: 'discovery_${widget.city.name}',
                                child: Image.network(widget.city.imageUrl, fit: BoxFit.cover),
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: 24,
                                left: 24,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(widget.city.name, style: TextStyle(fontSize: 42, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface)),
                                    Text(widget.city.country, style: TextStyle(fontSize: 18, color: theme.colorScheme.onSurface.withOpacity(0.7))),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: _buildContent(theme),
                        ),
                      ),
                    ],
                  ),
                ),
                _buildBottomBar(theme, isDesktop: false),
              ],
            );
          }
        },
      ),
      ),
    );
  }



  Widget _buildContent(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildAnimatedSection(
          delay: 200,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.city.description,
                style: TextStyle(fontSize: 18, color: theme.colorScheme.onSurface.withOpacity(0.9), height: 1.6, fontWeight: FontWeight.w400),
              ),
            ],
          ),
        ),
        const SizedBox(height: 48),
        
        _buildAnimatedSection(
          delay: 400,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Must Visit Places", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: widget.city.mustVisitWithDescriptions.length,
                separatorBuilder: (context, index) => const SizedBox(height: 20),
                itemBuilder: (context, index) {
                  final placeData = widget.city.mustVisitWithDescriptions[index];
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(Icons.place, size: 24, color: theme.colorScheme.primary),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              placeData['name']!,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              placeData['description']!,
                              style: TextStyle(
                                fontSize: 15,
                                color: theme.colorScheme.onSurface.withOpacity(0.6),
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBottomBar(ThemeData theme, {required bool isDesktop}) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        bottom: true,
        top: false,
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Package Available", style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.6), fontSize: 12, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text("All Inclusive Deals", style: TextStyle(color: theme.colorScheme.primary, fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            Expanded(
              child: SizedBox(
                height: 56,
                child: BlocBuilder<TripBloc, TripState>(
                  builder: (context, state) {
                    return ElevatedButton.icon(
                      onPressed: () {
                        BookingDialogUtils.showBookingDialog(
                          context: context,
                          cityName: widget.city.name,
                          seasonalOffer: "Adventure Package",
                          primaryColor: theme.colorScheme.primary,
                          icon: Icons.flight_takeoff_rounded,
                        );
                      },
                      icon: const Icon(Icons.flight_takeoff),
                      label: const Text("Plan This Trip", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 4,
                        shadowColor: theme.colorScheme.primary.withOpacity(0.4),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedSection({required int delay, required Widget child}) {
    // A simple way to do this without complex intervals for each child is using a FutureBuilder or just relying on the main controller 
    // But since we want "one by one", let's use the main controller with specific Intervals.
    // However, creating many Intervals is tedious. Let's use an AnimatedBuilder with a transform based on controller value.
    
    // Actually, simpler approach for "PowerPoint" feel: 
    // Trigger animations sequentially.
    
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        // Use Intervals for staggered entrance.
        double begin = delay / 1500.0;
        double end = begin + 0.5;
        
        final curve = CurvedAnimation(
          parent: _controller, 
          curve: Interval(begin.clamp(0.0, 1.0), end.clamp(0.0, 1.0), curve: Curves.easeOutCubic)
        );
        
        return FadeTransition(
          opacity: curve,
          child: SlideTransition(
            position: Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(curve),
            child: child,
          ),
        );
      }, 
      child: child,
    );
  }

  Widget _buildPlaceChip(BuildContext context, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4, offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.place, size: 16, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
