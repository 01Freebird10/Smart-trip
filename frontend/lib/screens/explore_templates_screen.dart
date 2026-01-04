import 'package:flutter/material.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/trip_bloc.dart';
import '../widgets/glass_container.dart';
import '../models/city.dart';

class ExploreTemplatesScreen extends StatefulWidget {
  const ExploreTemplatesScreen({super.key});

  @override
  State<ExploreTemplatesScreen> createState() => _ExploreTemplatesScreenState();
}

class _ExploreTemplatesScreenState extends State<ExploreTemplatesScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";
  String _selectedCategory = "All";

  final List<String> _categories = ["All", "Romantic", "Tech", "Cruise", "Nature", "Relaxation", "City"];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() => _searchQuery = _searchController.text.toLowerCase());
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDesktop = MediaQuery.of(context).size.width > 900;
    
    final allTemplates = [
      {
        "title": "Romantic Paris",
        "desc": "A 5-day guide to the city of love.",
        "image": "https://picsum.photos/seed/paris_template/600/400",
        "duration": "5 Days",
        "budget": r"$$$",
        "category": "Romantic"
      },
      {
        "title": "Techie Tokyo",
        "desc": "Explore neon lights and hidden shrines.",
        "image": "https://picsum.photos/seed/tokyo_template/600/400",
        "duration": "7 Days",
        "budget": "\$\$",
        "category": "Tech"
      },
      {
        "title": "Mediterranean Cruise",
        "desc": "The best of Greece and Italy.",
        "image": "https://picsum.photos/seed/cruise_template/600/400",
        "duration": "10 Days",
        "budget": "\$\$\$\$",
        "category": "Cruise"
      },
      {
        "title": "Swiss Alps Escape",
        "desc": "Winter wonderland and mountain trekking.",
        "image": "https://picsum.photos/seed/swiss_template/600/400",
        "duration": "6 Days",
        "budget": "\$\$\$",
        "category": "Nature"
      },
      {
        "title": "Bali Retreat",
        "desc": "Yoga, beaches, and spiritual journeys.",
        "image": "https://picsum.photos/seed/bali_template/600/400",
        "duration": "8 Days",
        "budget": "\$\$",
        "category": "Relaxation"
      },
      {
        "title": "New York Vibe",
        "desc": "The ultimate Big Apple experience.",
        "image": "https://picsum.photos/seed/nyc_template/600/400",
        "duration": "4 Days",
        "budget": r"$$$",
        "category": "City"
      },
    ];

    final filteredTemplates = allTemplates.where((t) {
      final matchesSearch = t["title"]!.toLowerCase().contains(_searchQuery) ||
                           t["desc"]!.toLowerCase().contains(_searchQuery);
      final matchesCategory = _selectedCategory == "All" || t["category"] == _selectedCategory;
      return matchesSearch && matchesCategory;
    }).toList();

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text('Trip Templates', style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: theme.colorScheme.onSurface),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              theme.colorScheme.primary,
              theme.colorScheme.secondary.withOpacity(0.8),
            ],
          ),
        ),
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 120, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Start with a blueprint",
                      style: TextStyle(
                        fontSize: isDesktop ? 34 : 26,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: -1.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Choose a hand-crafted itinerary to get started quickly",
                      style: TextStyle(fontSize: 15, color: Colors.white.withOpacity(0.8)),
                    ),
                    const SizedBox(height: 32),
                    // Search Bar
                    Container(
                      height: 54,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: Colors.white.withOpacity(0.12)),
                      ),
                      child: TextField(
                        controller: _searchController,
                        style: TextStyle(color: theme.colorScheme.onSurface, fontSize: 16),
                        decoration: InputDecoration(
                          hintText: "Search templates...",
                          hintStyle: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.4)),
                          prefixIcon: Icon(Icons.search, color: theme.colorScheme.onSurface.withOpacity(0.7), size: 22),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Categories
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: _categories.map((cat) {
                          final isSelected = _selectedCategory == cat;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: FilterChip(
                              label: Text(cat),
                              selected: isSelected,
                              onSelected: (val) => setState(() => _selectedCategory = cat),
                              backgroundColor: Colors.white.withOpacity(0.1),
                              selectedColor: Colors.white.withOpacity(0.3),
                              labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.white70),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                              side: BorderSide.none,
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: isDesktop ? 60 : 20, vertical: 20),
              sliver: SliverGrid(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: isDesktop ? 4 : 2,
                  childAspectRatio: 0.58, // Generous ratio to avoid bottom overflows on any device
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final template = filteredTemplates[index];
                    return _HoverTemplateCard(
                      title: template["title"]!,
                      desc: template["desc"]!,
                      imageUrl: template["image"]!,
                      duration: template["duration"]!,
                      budget: template["budget"]!,
                    );
                  },
                  childCount: filteredTemplates.length,
                ),
              ),
            ),
            if (_searchQuery.isNotEmpty && CityData.cities.any((c) => c.name.toLowerCase().contains(_searchQuery)))
               SliverToBoxAdapter(
                 child: Padding(
                   padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
                   child: Center(
                     child: Text(
                       "Showing results for \"$_searchQuery\"",
                       style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.5), fontSize: 14),
                     ),
                   ),
                 ),
               ),
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }
}

class _HoverTemplateCard extends StatefulWidget {
  final String title;
  final String desc;
  final String imageUrl;
  final String duration;
  final String budget;

  const _HoverTemplateCard({
    required this.title,
    required this.desc,
    required this.imageUrl,
    required this.duration,
    required this.budget,
  });

  @override
  State<_HoverTemplateCard> createState() => _HoverTemplateCardState();
}

class _HoverTemplateCardState extends State<_HoverTemplateCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _elevationAnimation;
  
  static final Map<String, Color> _colorCache = {};
  Color? _dominantColor;
  bool _isHovering = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 200));
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _elevationAnimation = Tween<double>(begin: 4.0, end: 12.0).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _updatePalette();
  }

  Future<void> _updatePalette() async {
    if (_colorCache.containsKey(widget.imageUrl)) {
      if (mounted) {
        setState(() {
          _dominantColor = _colorCache[widget.imageUrl];
        });
      }
      return;
    }
    
    try {
      final PaletteGenerator generator = await PaletteGenerator.fromImageProvider(
        CachedNetworkImageProvider(widget.imageUrl),
        size: const Size(40, 40),
      );
      if (mounted) {
        final extracted = generator.dominantColor?.color ?? generator.vibrantColor?.color;
        if (extracted != null) {
          _colorCache[widget.imageUrl] = extracted;
        }
        setState(() {
          _dominantColor = extracted;
        });
      }
    } catch (e) {
      // Fallback
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    final backgroundColor = (_isHovering && _dominantColor != null) 
        ? _dominantColor!.withOpacity(0.15) 
        : theme.colorScheme.surface;
        
    final borderColor = (_isHovering && _dominantColor != null)
        ? _dominantColor!.withOpacity(0.5)
        : theme.colorScheme.onSurface.withOpacity(0.1);

    return MouseRegion(
      onEnter: (_) {
        setState(() => _isHovering = true);
        _controller.forward();
      },
      onExit: (_) {
        setState(() => _isHovering = false);
        _controller.reverse();
      },
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Material(
              color: Colors.transparent,
              elevation: _elevationAnimation.value,
              shadowColor: _dominantColor?.withOpacity(0.5) ?? Colors.black45,
              borderRadius: BorderRadius.circular(24),
              child: child,
            ),
          );
        },
        child: InkWell(
          onTap: () {
            _showTemplatePreview(context);
          },
          borderRadius: BorderRadius.circular(24),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              color: backgroundColor,
              border: Border.all(color: borderColor),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 140, // Fixed height for image
                  width: double.infinity,
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        CachedNetworkImage(
                          imageUrl: widget.imageUrl,
                          fit: BoxFit.cover,
                          memCacheHeight: 400,
                          placeholder: (context, url) => Container(color: Colors.white10),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [Colors.transparent, Colors.black.withOpacity(0.4)],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              widget.title,
                              style: TextStyle(
                                color: theme.colorScheme.onSurface,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            widget.duration,
                            style: TextStyle(
                              color: theme.colorScheme.onSurface.withOpacity(0.6),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.desc,
                        style: TextStyle(
                          color: theme.colorScheme.onSurface.withOpacity(0.7),
                          fontSize: 13,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => _handleUseTemplate(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: (_dominantColor ?? theme.colorScheme.primary).withOpacity(0.1),
                          foregroundColor: _dominantColor ?? theme.colorScheme.primary,
                          elevation: 0,
                          minimumSize: const Size(double.infinity, 40),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text("Use Template", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
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

  void _showTemplatePreview(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        final theme = Theme.of(context);
        return AlertDialog(
          backgroundColor: Colors.transparent,
          contentPadding: EdgeInsets.zero,
          insetPadding: const EdgeInsets.symmetric(horizontal: 20),
          content: GlassContainer(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: CachedNetworkImage(imageUrl: widget.imageUrl, height: 200, width: double.infinity, fit: BoxFit.cover),
                ),
                const SizedBox(height: 20),
                Text(widget.title, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface)),
                const SizedBox(height: 12),
                Text(widget.desc, textAlign: TextAlign.center, style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.7), fontSize: 15)),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStat(context, Icons.calendar_today, widget.duration),
                    _buildStat(context, Icons.payments_outlined, widget.budget),
                  ],
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _handleUseTemplate(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.onSurface, 
                    foregroundColor: theme.colorScheme.surface,
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text("Start This Adventure"),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStat(BuildContext context, IconData icon, String label) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Icon(icon, color: theme.colorScheme.onSurface.withOpacity(0.4), size: 20),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(color: theme.colorScheme.onSurface, fontWeight: FontWeight.w600)),
      ],
    );
  }

  void _handleUseTemplate(BuildContext context) {
    context.read<TripBloc>().add(CreateTrip(
      title: widget.title,
      destination: widget.title.split(' ').last, // Simple extraction
      startDate: DateTime.now(),
      endDate: DateTime.now().add(const Duration(days: 7)),
    ));
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Trip '${widget.title}' created successfully!"),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
    
    Navigator.of(context).pop();
  }
}
