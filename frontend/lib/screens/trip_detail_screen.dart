import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:hive/hive.dart';
import '../models/trip.dart';
import '../models/city.dart';
import '../models/expense.dart';
import 'chat_screen.dart';
import '../utils/responsive_layout.dart';
import '../blocs/poll_bloc.dart';
import '../blocs/itinerary_bloc.dart';
import '../blocs/auth_bloc.dart';
import '../models/itinerary_item.dart';
import '../repositories/trip_repository.dart';
import '../blocs/trip_bloc.dart';
import '../utils/currency_utils.dart';

class TripDetailScreen extends StatefulWidget {
  final Trip trip;
  const TripDetailScreen({super.key, required this.trip});

  @override
  State<TripDetailScreen> createState() => _TripDetailScreenState();
}

class _TripDetailScreenState extends State<TripDetailScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _entranceController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    
    // Slower, more elegant entrance animation (800ms -> 1200ms)
    _entranceController = AnimationController(
       vsync: this,
       duration: const Duration(milliseconds: 1200),
    );
    
    _fadeAnimation = CurvedAnimation(parent: _entranceController, curve: Curves.easeOut);
    _slideAnimation = Tween<Offset>(begin: const Offset(0.05, 0), end: Offset.zero).animate(
      CurvedAnimation(parent: _entranceController, curve: Curves.easeOutCubic),
    );

    // Fetch initial data
    context.read<ItineraryBloc>().add(LoadItinerary(widget.trip.id));
    context.read<PollBloc>().add(LoadPolls(widget.trip.id));
    
    // Slight delay to allow the hero transition to settle before sliding in content
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) _entranceController.forward();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _entranceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isDesktop = constraints.maxWidth > 900;
          
          if (isDesktop) {
            return _buildDesktopLayout(theme);
          } else {
            return _buildMobileLayout(theme);
          }
        },
      ),
      floatingActionButton: ResponsiveLayout(
        mobile: FloatingActionButton(
          onPressed: () {
            final authState = context.read<AuthBloc>().state;
            final selfEmail = authState is Authenticated ? authState.user.email : null;
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => ChatScreen(trip: widget.trip, currentUserEmail: selfEmail)),
            );
          },
          backgroundColor: theme.colorScheme.primary,
          child: const Icon(Icons.chat_bubble_outline),
        ),
        desktop: const SizedBox.shrink(),
      ),
    );
  }

  Widget _buildDesktopLayout(ThemeData theme) {
    return Row(
      children: [
        // Left Panel: Immersive Hero Image
        Expanded(
          flex: 5,
          child: AnimatedBuilder(
            animation: _tabController,
            builder: (context, _) {
              final isFriendsTab = _tabController.index == 2;
              
              return Stack(
                fit: StackFit.expand,
                children: [
                  // 1. Background (Image or Friends Themed)
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 500),
                    child: isFriendsTab 
                      ? Container(
                          key: const ValueKey("friends_bg"),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [theme.colorScheme.primary.withOpacity(0.8), theme.colorScheme.secondary.withOpacity(0.9)],
                            ),
                          ),
                          child: Center(
                            child: Icon(Icons.people_rounded, size: 200, color: Colors.white.withOpacity(0.1)),
                          ),
                        )
                      : CachedNetworkImage(
                          key: const ValueKey("trip_bg"),
                          imageUrl: 'https://picsum.photos/seed/${widget.trip.id}/1200/800',
                          fit: BoxFit.cover,
                          memCacheWidth: 1200,
                        ),
                  ),

                  // 2. Gradient Overlay
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.1),
                          Colors.transparent,
                          Colors.black.withOpacity(0.6),
                          Colors.black.withOpacity(0.9),
                        ],
                        stops: const [0.0, 0.4, 0.8, 1.0],
                      ),
                    ),
                  ),

                  // 3. Back Button
                  Positioned(
                    top: 24,
                    left: 24,
                    child: SafeArea(
                      child: FloatingActionButton.small(
                        heroTag: 'back_btn_desktop',
                        backgroundColor: Colors.black26,
                        elevation: 0,
                        onPressed: () => Navigator.pop(context),
                        child: const Icon(Icons.arrow_back, color: Colors.white),
                      ),
                    ),
                  ),

                  // 4. Trip Title or Friends Label
                  Positioned(
                    bottom: 48,
                    left: 48,
                    right: 48,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          isFriendsTab ? "Travel Companions" : widget.trip.title,
                          style: TextStyle(
                            fontFamily: 'Outfit',
                            fontSize: 48, 
                            fontWeight: FontWeight.bold, 
                            color: Colors.white,
                            letterSpacing: -1.0,
                            shadows: [Shadow(color: Colors.black45, blurRadius: 12, offset: const Offset(0, 4))],
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Icon(isFriendsTab ? Icons.group_outlined : Icons.location_on, color: Colors.white70, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              isFriendsTab ? "Planning together" : widget.trip.destination,
                              style: const TextStyle(fontSize: 18, color: Colors.white70, letterSpacing: 0.5),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),

        // Right Panel: Content Dashboard
        Expanded(
          flex: 6,
          child: Container(
            color: theme.colorScheme.surface, // Solid background to fix black void
            child: Column(
              children: [
                // Top Bar: Actions & Tabs
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    border: Border(bottom: BorderSide(color: theme.dividerColor.withOpacity(0.05))),
                  ),
                  child: Row(
                    children: [
                      // Premium Pill TabBar
                      Container(
                        width: 280,
                        height: 56,
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.black87,
                          borderRadius: BorderRadius.circular(28),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            )
                          ],
                        ),
                        child: TabBar(
                          controller: _tabController,
                          isScrollable: false,
                          tabAlignment: TabAlignment.fill,
                          indicator: BoxDecoration(
                            color: theme.colorScheme.primary,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: theme.colorScheme.primary.withOpacity(0.4),
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              )
                            ],
                          ),
                          labelColor: Colors.white,
                          unselectedLabelColor: Colors.white60,
                          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
                          indicatorSize: TabBarIndicatorSize.tab,
                          dividerColor: Colors.transparent,
                          padding: EdgeInsets.zero,
                          indicatorPadding: const EdgeInsets.all(2),
                          tabs: const [
                            Tab(text: "Places"),
                            Tab(text: "Budget"),
                            Tab(text: "Friends"),
                          ],
                        ),
                      ),

                      const Spacer(),
                      // Action Icons
                      _buildHeaderAction(Icons.person_add_outlined, _showAddCollaboratorDialog),
                      const SizedBox(width: 16),
                      BlocBuilder<AuthBloc, AuthState>(
                        builder: (context, state) {
                          if (state is Authenticated) {
                            final user = state.user;
                            ImageProvider? imageProvider;
                            final pic = user.profilePicture;
                            if (pic != null && pic.isNotEmpty) {
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
                                imageProvider = NetworkImage("$url?v=${user.hashCode}");
                              }
                            }
                            
                            return Container(
                              padding: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: theme.colorScheme.primary.withOpacity(0.3)),
                              ),
                              child: CircleAvatar(
                                radius: 20,
                                backgroundImage: imageProvider,
                                backgroundColor: theme.colorScheme.surface,
                                child: imageProvider == null ? Icon(Icons.person, color: theme.colorScheme.onSurface) : null,
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ],
                  ),
                ),
                
                // Main Content Area
                Expanded(
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: TabBarView(
                        controller: _tabController,
                        physics: const BouncingScrollPhysics(),
                        children: [
                          _DestinationTab(trip: widget.trip),
                          _BudgetTab(trip: widget.trip),
                          _FriendsTab(trip: widget.trip),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(ThemeData theme) {
    return NestedScrollView(
      headerSliverBuilder: (context, innerBoxIsScrolled) {
        return [
          SliverAppBar(
            expandedHeight: 280,
            floating: false,
            pinned: true,
            backgroundColor: theme.colorScheme.surface,
            elevation: 0,
            leading: Container(
              margin: const EdgeInsets.all(8),
              decoration: const BoxDecoration(color: Colors.black26, shape: BoxShape.circle),
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white), 
                onPressed: () => Navigator.pop(context),
              ),
            ),
            actions: [
              IconButton(icon: const Icon(Icons.share, color: Colors.white), onPressed: (){}),
              BlocBuilder<AuthBloc, AuthState>(
                builder: (context, state) {
                  if (state is Authenticated) {
                    final user = state.user;
                    ImageProvider? imageProvider;
                    final pic = user.profilePicture;
                    if (pic != null && pic.isNotEmpty) {
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
                        imageProvider = NetworkImage("$url?v=${user.hashCode}");
                      }
                    }
                    
                    return Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: Center(
                        child: CircleAvatar(
                          radius: 16,
                          backgroundImage: imageProvider,
                          child: imageProvider == null ? const Icon(Icons.person, color: Colors.white, size: 18) : null,
                        ),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                widget.trip.title,
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                    CachedNetworkImage(
                    imageUrl: 'https://picsum.photos/seed/${widget.trip.id}/800/800',
                    fit: BoxFit.cover,
                    memCacheHeight: 800,
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
                ],
              ),
            ),
          ),
          SliverPersistentHeader(
            delegate: _SliverInternalTabBarDelegate(
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.circular(28),
                ),
                child: TabBar(
                  controller: _tabController,
                  isScrollable: false,
                  tabAlignment: TabAlignment.fill,
                  indicator: BoxDecoration(
                    color: theme.colorScheme.primary,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: theme.colorScheme.primary.withOpacity(0.4),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      )
                    ],
                  ),
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.white60,
                  labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  dividerColor: Colors.transparent,
                  tabs: const [
                    Tab(text: "Places"),
                    Tab(text: "Budget"),
                    Tab(text: "Friends"),
                  ],
                ),

              ),
              theme.colorScheme.surface,
            ),
            pinned: true,
          ),
        ];
      },
      body: TabBarView(
        controller: _tabController,
        children: [
          _DestinationTab(trip: widget.trip),
          _BudgetTab(trip: widget.trip),
          _FriendsTab(trip: widget.trip),
        ],
      ),
    );
  }

  String _getMonth(DateTime date) {
    const months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
    if (date.month < 1 || date.month > 12) return "";
    return months[date.month - 1];
  }

  Widget _buildHeaderAction(IconData icon, Function(BuildContext) onTap) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        onPressed: () => onTap(context),
        icon: Icon(icon, color: Colors.white70, size: 22),
        splashRadius: 24,
      ),
    );
  }

  void _showAddCollaboratorDialog(BuildContext context) {
    // Basic dialog placeholder
    showDialog(context: context, builder: (_) => const AlertDialog(title: Text("Add Collaborator placeholder")));
  }

  void _showEditTripDialog(BuildContext context) {
     // Basic dialog placeholder
     showDialog(context: context, builder: (_) => const AlertDialog(title: Text("Edit Trip placeholder")));
  }
}

class _SliverInternalTabBarDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  final Color backgroundColor;

  _SliverInternalTabBarDelegate(this.child, this.backgroundColor);

  @override
  double get minExtent => 64;
  @override
  double get maxExtent => 64;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: backgroundColor,
      child: child,
    );
  }

  @override
  bool shouldRebuild(_SliverInternalTabBarDelegate oldDelegate) {
    return false;
  }
}


class _ItineraryTab extends StatelessWidget {
  final Trip trip;
  const _ItineraryTab({required this.trip});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ItineraryBloc, ItineraryState>(
      builder: (context, state) {
        if (state is ItineraryLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is ItineraryError) {
          return Center(child: Text("Error: ${state.message}", style: const TextStyle(color: Colors.redAccent)));
        }
        if (state is ItineraryLoaded) {
          final items = state.items;
          if (items.isEmpty) {
            return _buildEmptyState(
              context,
              icon: Icons.map_outlined,
              title: "Plan Your Adventure",
              subtitle: "Add activities, places to visit, and experiences to your itinerary.",
              buttonLabel: "Add First Activity",
              onPressed: () => _showAddItemDialog(context),
            );
          }
          return ReorderableListView.builder(
            padding: const EdgeInsets.all(24),
            itemCount: items.length,
            onReorder: (oldIndex, newIndex) {
              if (oldIndex < newIndex) newIndex -= 1;
              final reorderedItems = List<ItineraryItem>.from(items);
              final item = reorderedItems.removeAt(oldIndex);
              reorderedItems.insert(newIndex, item);
              context.read<ItineraryBloc>().add(ReorderItinerary(trip.id, reorderedItems.map((e) => e.id).toList()));
            },
            itemBuilder: (context, index) {
              final item = items[index];
              return TweenAnimationBuilder(
                duration: Duration(milliseconds: 600 + (index.clamp(0, 10) * 80)),
                tween: Tween<double>(begin: 0, end: 1),
                curve: Curves.easeOutCubic,
                builder: (context, value, child) => Opacity(
                  opacity: value,
                  child: Transform.translate(
                    offset: Offset(0, 30 * (1 - value)),
                    child: child,
                  ),
                ),
                child: Padding(
                  key: ValueKey(item.id),
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _buildItem(context, item, index),
                ),
              );
            },
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildItem(BuildContext context, ItineraryItem item, int index) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
        border: Border.all(color: theme.dividerColor.withOpacity(0.1)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        title: Text(item.title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: theme.colorScheme.onSurface)),
        subtitle: Text(item.location ?? '', style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.6))),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              '${index + 1}',
              style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        trailing: Icon(Icons.drag_indicator, color: theme.disabledColor),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required String buttonLabel,
    required VoidCallback onPressed,
  }) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 64, color: theme.colorScheme.primary),
            ),
            const SizedBox(height: 32),
            Text(
              title,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 16,
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: onPressed,
              icon: const Icon(Icons.add),
              label: Text(buttonLabel),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddItemDialog(BuildContext context) {
    final titleController = TextEditingController();
    final locationController = TextEditingController();
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text("Add Activity", style: TextStyle(color: theme.colorScheme.onSurface, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              style: TextStyle(color: theme.colorScheme.onSurface),
              decoration: InputDecoration(
                labelText: "Activity Name",
                labelStyle: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.6)),
                prefixIcon: Icon(Icons.event, color: theme.colorScheme.primary),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: locationController,
              style: TextStyle(color: theme.colorScheme.onSurface),
              decoration: InputDecoration(
                labelText: "Location",
                labelStyle: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.6)),
                prefixIcon: Icon(Icons.location_on, color: theme.colorScheme.primary),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel", style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.6))),
          ),
          ElevatedButton(
            onPressed: () {
              if (titleController.text.isNotEmpty) {
                context.read<ItineraryBloc>().add(AddItineraryItem(
                  trip.id, 
                  titleController.text, 
                  locationController.text
                ));
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text("Add"),
          ),
        ],
      ),
    );
  }
}

class _PollsTab extends StatelessWidget {
  final Trip trip;
  const _PollsTab({required this.trip});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PollBloc, PollState>(
      builder: (context, state) {
        if (state is PollLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is PollError) {
          return Center(child: Text("Error: ${state.message}", style: const TextStyle(color: Colors.redAccent)));
        }
        if (state is PollsLoaded) {
          if (state.polls.isEmpty) {
            return _buildEmptyState(
              context,
              icon: Icons.poll_outlined,
              title: "Create a Poll",
              subtitle: "Ask your travel companions what they'd like to do.",
              buttonLabel: "Create Poll",
              onPressed: () => _showCreatePollDialog(context),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(24),
            itemCount: state.polls.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                 return const SizedBox(height: 0); // Header handled by parent now
              }
              final poll = state.polls[index - 1];
              return TweenAnimationBuilder(
                duration: Duration(milliseconds: 600 + (index * 100)),
                tween: Tween<double>(begin: 0, end: 1),
                curve: Curves.easeOutCubic,
                builder: (context, value, child) => Opacity(
                  opacity: value,
                  child: Transform.translate(
                    offset: Offset(0, 30 * (1 - value)),
                    child: child,
                  ),
                ),
                child: _buildPollCard(context, poll),
              );
            },
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildPollCard(BuildContext context, dynamic poll) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4)),
        ],
        border: Border.all(color: theme.dividerColor.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(poll['question'], style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: theme.colorScheme.onSurface)),
          const SizedBox(height: 20),
          ... (poll['options'] as List).map((opt) {
            bool hasVoted = opt['has_voted'] ?? false;
            int votes = opt['vote_count'] ?? 0;
            
            return Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: InkWell(
                onTap: () {
                    context.read<PollBloc>().add(VoteRequested(trip.id, poll['id'], opt['id']));
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: hasVoted ? theme.colorScheme.primary : theme.dividerColor.withOpacity(0.2), 
                      width: hasVoted ? 2 : 1
                    ),
                    color: hasVoted ? theme.colorScheme.primary.withOpacity(0.05) : Colors.transparent,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(opt['text'], style: TextStyle(color: hasVoted ? theme.colorScheme.primary : theme.colorScheme.onSurface)),
                      Text("$votes votes", style: TextStyle(color: theme.disabledColor, fontSize: 12)),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required String buttonLabel,
    required VoidCallback onPressed,
  }) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 64, color: theme.colorScheme.primary),
            ),
            const SizedBox(height: 32),
            Text(title, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface), textAlign: TextAlign.center),
            const SizedBox(height: 12),
            Text(subtitle, style: TextStyle(fontSize: 16, color: theme.colorScheme.onSurface.withOpacity(0.6)), textAlign: TextAlign.center),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: onPressed,
              icon: const Icon(Icons.add),
              label: Text(buttonLabel),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCreatePollDialog(BuildContext context) {
    final questionController = TextEditingController();
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text("Create Poll", style: TextStyle(color: theme.colorScheme.onSurface, fontWeight: FontWeight.bold)),
        content: TextField(
          controller: questionController,
          style: TextStyle(color: theme.colorScheme.onSurface),
          decoration: InputDecoration(
            labelText: "Poll Question",
            hintText: "e.g., Where should we eat tonight?",
            labelStyle: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.6)),
            prefixIcon: Icon(Icons.help_outline, color: theme.colorScheme.primary),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text("Cancel", style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.6)))),
          ElevatedButton(
            onPressed: () {
              if (questionController.text.isNotEmpty) {
                context.read<PollBloc>().add(CreatePoll(
                  trip.id, 
                  questionController.text, 
                  ["Yes", "No", "Maybe"]
                ));
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: theme.colorScheme.primary, foregroundColor: Colors.white),
            child: const Text("Create"),
          ),
        ],
      ),
    );
  }
}

class _CollaboratorsTab extends StatelessWidget {
  final Trip trip;
  const _CollaboratorsTab({required this.trip});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(24.0),
          child: SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: () => _showInviteDialog(context),
              icon: const Icon(Icons.person_add_outlined),
              label: const Text("Invite Collaborator"),
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
                elevation: 0,
              ),
            ),
          ),
        ),
        Expanded(
          child: (trip.collaborators?.isEmpty ?? true)
            ? _buildEmptyState(context)
            : ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                itemCount: trip.collaborators?.length ?? 0,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final collaborator = trip.collaborators![index];
                  return _buildPersonTile(
                    context,
                    collaborator.user?.firstName ?? 'Unknown', 
                    collaborator.user?.email ?? '', 
                    collaborator.role == 'owner'
                  );
                },
              ),
        ),
      ],
    );
  }

  void _showInviteDialog(BuildContext context) {
    final emailController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Invite Collaborator"),
        content: TextField(
          controller: emailController,
          decoration: const InputDecoration(hintText: "Enter email address"),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              if (emailController.text.isNotEmpty) {
                context.read<TripRepository>().inviteCollaborator(trip.id, emailController.text);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Invite sent!")));
              }
            },
            child: const Text("Invite"),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonTile(BuildContext context, String name, String email, bool isOwner) {
    final theme = Theme.of(context);
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 8),
      leading: CircleAvatar(
        backgroundColor: theme.colorScheme.primary,
        child: Text(
          (name.isNotEmpty) ? name[0].toUpperCase() : '?', 
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)
        ),
      ),
      title: Text(name, style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface)),
      subtitle: Text(email, style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.6))),
      trailing: isOwner 
        ? Chip(
            label: const Text("Owner", style: TextStyle(fontSize: 10, color: Colors.white)),
            backgroundColor: theme.colorScheme.secondary,
            visualDensity: VisualDensity.compact,
            padding: EdgeInsets.zero,
          ) 
        : const Icon(Icons.more_vert),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.group_outlined, size: 64, color: theme.colorScheme.primary),
            ),
            const SizedBox(height: 32),
            Text(
              "Travel Together",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              "Invite friends and family to collaborate on this trip.",
              style: TextStyle(fontSize: 16, color: theme.colorScheme.onSurface.withOpacity(0.6)),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => _showInviteDialog(context),
              icon: const Icon(Icons.person_add),
              label: const Text("Invite Someone"),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============== NEW DESTINATION TAB ==============
class _DestinationTab extends StatefulWidget {
  final Trip trip;
  const _DestinationTab({required this.trip});

  @override
  State<_DestinationTab> createState() => _DestinationTabState();
}

class _DestinationTabState extends State<_DestinationTab> {
  late City? _matchedCity;
  final Set<String> _bucketList = {};

  @override
  void initState() {
    super.initState();
    _matchedCity = _findMatchingCity(widget.trip.destination);
    _loadBucketList();
  }

  City? _findMatchingCity(String destination) {
    final lowercaseDest = destination.toLowerCase();
    try {
      return CityData.cities.firstWhere(
        (city) => city.name.toLowerCase().contains(lowercaseDest) || 
                  lowercaseDest.contains(city.name.toLowerCase()),
      );
    } catch (e) {
      return null;
    }
  }

  Future<void> _loadBucketList() async {
    final box = await Hive.openBox<String>('trip_bucketlist_${widget.trip.id}');
    setState(() {
      _bucketList.addAll(box.values);
    });
  }

  Future<void> _toggleBucketItem(String place) async {
    final box = await Hive.openBox<String>('trip_bucketlist_${widget.trip.id}');
    setState(() {
      if (_bucketList.contains(place)) {
        _bucketList.remove(place);
        final key = box.keys.firstWhere((k) => box.get(k) == place, orElse: () => null);
        if (key != null) box.delete(key);
      } else {
        _bucketList.add(place);
        box.add(place);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Destination Header
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [theme.colorScheme.primary.withOpacity(0.2), theme.colorScheme.primary.withOpacity(0.05)],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: theme.colorScheme.primary.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    image: DecorationImage(
                      image: NetworkImage(_matchedCity?.imageUrl ?? 'https://picsum.photos/seed/${widget.trip.destination}/200'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.trip.destination,
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface),
                      ),
                      if (_matchedCity != null) ...[
                        const SizedBox(height: 4),
                        Text(_matchedCity!.country, style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.6))),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.attach_money, size: 16, color: theme.colorScheme.primary),
                            Text("\$${_matchedCity!.averageDailyCost}/day avg", style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Description
          if (_matchedCity != null) ...[
            Text("About", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface)),
            const SizedBox(height: 12),
            Text(_matchedCity!.description, style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.7), height: 1.6)),
            const SizedBox(height: 32),
          ],
          
          // Tourist Attractions
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Must Visit Places", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface)),
              Text("${_bucketList.length} in bucket list", style: TextStyle(color: theme.colorScheme.primary)),
            ],
          ),
          const SizedBox(height: 16),
          
          if (_matchedCity != null && _matchedCity!.mustVisit.isNotEmpty)
            ...(_matchedCity!.mustVisit.map((place) => _buildPlaceCard(context, place, theme)))
          else
            _buildGenericPlaces(theme),
        ],
      ),
    );
  }

  Widget _buildPlaceCard(BuildContext context, String place, ThemeData theme) {
    final isInBucket = _bucketList.contains(place);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isInBucket ? theme.colorScheme.primary.withOpacity(0.1) : theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isInBucket ? theme.colorScheme.primary : theme.dividerColor.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              image: DecorationImage(
                image: NetworkImage('https://picsum.photos/seed/$place/100'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(place, style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface)),
                Text("Famous attraction", style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.5), fontSize: 12)),
              ],
            ),
          ),
          IconButton(
            onPressed: () => _toggleBucketItem(place),
            icon: Icon(
              isInBucket ? Icons.bookmark : Icons.bookmark_border,
              color: isInBucket ? theme.colorScheme.primary : theme.colorScheme.onSurface.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGenericPlaces(ThemeData theme) {
    final genericPlaces = ["City Center", "Local Market", "Historic District", "Scenic Viewpoint", "Cultural Museum"];
    return Column(
      children: genericPlaces.map((place) => _buildPlaceCard(context, place, theme)).toList(),
    );
  }
}

// ============== NEW BUDGET TAB ==============
class _BudgetTab extends StatefulWidget {
  final Trip trip;
  const _BudgetTab({required this.trip});

  @override
  State<_BudgetTab> createState() => _BudgetTabState();
}

class _BudgetTabState extends State<_BudgetTab> {
  double _totalBudget = 0;
  List<Expense> _expenses = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _totalBudget = widget.trip.budget ?? 0;
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    setState(() => _isLoading = true);
    try {
      final repo = context.read<TripRepository>();
      final expenses = await repo.getExpenses(widget.trip.id);
      setState(() {
        _expenses = expenses;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _saveBudget() async {
    try {
      await context.read<TripRepository>().updateTripBudget(widget.trip.id, _totalBudget);
    } catch (e) {
       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to sync budget: $e")));
    }
  }

  double get _totalSpent => _expenses.fold(0, (sum, e) => sum + e.amount);
  double get _remaining => _totalBudget - _totalSpent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Budget Overview Card
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [const Color(0xFF6200EA), const Color(0xFF00D2FF)],
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Trip Budget", style: TextStyle(color: Colors.white70)),
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.white70, size: 20),
                      onPressed: () => _showSetBudgetDialog(context),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(CurrencyUtils.format(_totalBudget, widget.trip.destination), style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildBudgetStat("Spent", CurrencyUtils.format(_totalSpent, widget.trip.destination), Colors.orangeAccent),
                    Container(width: 1, height: 40, color: Colors.white24),
                    _buildBudgetStat("Remaining", CurrencyUtils.format(_remaining, widget.trip.destination), Colors.greenAccent),
                  ],
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Add Expense Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _showAddExpenseDialog(context),
              icon: const Icon(Icons.add),
              label: const Text("Add Expense"),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Expenses List
          Text("Expenses", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface)),
          const SizedBox(height: 16),
          
          if (_isLoading)
            const Center(child: CircularProgressIndicator())
          else if (_expenses.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(40),
                child: Column(
                  children: [
                    Icon(Icons.receipt_long_outlined, size: 48, color: theme.colorScheme.onSurface.withOpacity(0.3)),
                    const SizedBox(height: 16),
                    Text("No expenses yet", style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.5))),
                  ],
                ),
              ),
            )
          else
            ...(_expenses.asMap().entries.map((entry) => _buildExpenseItem(context, entry.key, entry.value, theme))),
        ],
      ),
    );
  }

  Widget _buildBudgetStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
        Text(label, style: const TextStyle(color: Colors.white60, fontSize: 12)),
      ],
    );
  }

  Widget _buildExpenseItem(BuildContext context, int index, Expense expense, ThemeData theme) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(_getExpenseIcon(expense.category), color: theme.colorScheme.primary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(expense.name, style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface)),
                Text(expense.category, style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.5), fontSize: 12)),
              ],
            ),
          ),
            Text(CurrencyUtils.format(expense.amount, widget.trip.destination), 
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.orangeAccent)),
          IconButton(
            icon: Icon(Icons.delete_outline, color: theme.colorScheme.onSurface.withOpacity(0.3)),
            onPressed: () async {
              try {
                await context.read<TripRepository>().deleteExpense(expense.id);
                setState(() => _expenses.removeAt(index));
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to delete: $e")));
              }
            },
          ),
        ],
      ),
    );
  }

  IconData _getExpenseIcon(String category) {
    switch (category.toLowerCase()) {
      case 'food': return Icons.restaurant;
      case 'transport': return Icons.directions_car;
      case 'hotel': return Icons.hotel;
      case 'activity': return Icons.local_activity;
      default: return Icons.receipt;
    }
  }

  void _showSetBudgetDialog(BuildContext context) {
    final controller = TextEditingController(text: _totalBudget.toString());
    final theme = Theme.of(context);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text("Set Budget", style: TextStyle(color: theme.colorScheme.onSurface)),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          style: TextStyle(color: theme.colorScheme.onSurface),
          decoration: InputDecoration(
            labelText: "Total Budget (${CurrencyUtils.getSymbol(widget.trip.destination)})",
            prefixIcon: Icon(Icons.account_balance_wallet, color: theme.colorScheme.primary),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              setState(() => _totalBudget = double.tryParse(controller.text) ?? 0);
              _saveBudget();
              Navigator.pop(context);
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  void _showAddExpenseDialog(BuildContext context) {
    final nameController = TextEditingController();
    final amountController = TextEditingController();
    String category = 'Food';
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: theme.colorScheme.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Text("Add Expense", style: TextStyle(color: theme.colorScheme.onSurface)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                style: TextStyle(color: theme.colorScheme.onSurface),
                decoration: InputDecoration(labelText: "Expense Name", border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                style: TextStyle(color: theme.colorScheme.onSurface),
                decoration: InputDecoration(labelText: "Amount (${CurrencyUtils.getSymbol(widget.trip.destination)})", border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: category,
                dropdownColor: theme.colorScheme.surface,
                style: TextStyle(color: theme.colorScheme.onSurface),
                decoration: InputDecoration(labelText: "Category", border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                items: ['Food', 'Transport', 'Hotel', 'Activity', 'Other'].map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: (v) => setDialogState(() => category = v!),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.isNotEmpty && amountController.text.isNotEmpty) {
                  try {
                    final newExpense = await context.read<TripRepository>().addExpense(
                      widget.trip.id, 
                      nameController.text, 
                      double.tryParse(amountController.text) ?? 0, 
                      category
                    );
                    setState(() {
                      _expenses.add(newExpense);
                    });
                    Navigator.pop(context);
                  } catch (e) {
                     ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to add expense: $e")));
                  }
                }
              },
              child: const Text("Add"),
            ),
          ],
        ),
      ),
    );
  }
}

// ============== NEW FRIENDS TAB ==============
class _FriendsTab extends StatefulWidget {
  final Trip trip;
  const _FriendsTab({required this.trip});

  @override
  State<_FriendsTab> createState() => _FriendsTabState();
}

class _FriendsTabState extends State<_FriendsTab> {
  List<Collaborator> _friends = [];
  List<Booking> _bookings = [];
  bool _isLoadingBookings = false;

  @override
  void initState() {
    super.initState();
    _friends = widget.trip.collaborators ?? [];
    _fetchBookings();
  }

  Future<void> _fetchBookings() async {
    if (!mounted) return;
    setState(() => _isLoadingBookings = true);
    try {
      final repo = context.read<TripRepository>();
      final bookings = await repo.getBookings(widget.trip.id);
      if (mounted) {
        setState(() {
          _bookings = bookings;
          _isLoadingBookings = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingBookings = false);
    }
  }

  Future<void> _acceptBooking(int bookingId, String destination) async {
    try {
      await context.read<TripRepository>().acceptBooking(bookingId);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Booking for $destination successfully accepted!"),
          backgroundColor: Colors.green,
        ),
      );
      _fetchBookings();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  Future<void> _inviteFriend(String email) async {
    try {
      await context.read<TripRepository>().inviteCollaborator(widget.trip.id, email);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Invitation sent to $email")));
      
      if (mounted) {
        context.read<TripBloc>().add(LoadTrips());
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    }
  }

  Future<void> _removeFriend(int userId) async {
    try {
      await context.read<TripRepository>().removeCollaborator(widget.trip.id, userId);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Friend removed from trip")));
      if (mounted) {
        context.read<TripBloc>().add(LoadTrips());
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return BlocBuilder<TripBloc, TripState>(
      builder: (context, state) {
        if (state is TripsLoaded) {
          try {
            final updatedTrip = state.trips.firstWhere((t) => t.id == widget.trip.id);
            _friends = updatedTrip.collaborators ?? [];
          } catch (_) {}
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: theme.colorScheme.primary.withOpacity(0.3)),
                ),
                child: Column(
                  children: [
                    Icon(Icons.group_add, size: 48, color: theme.colorScheme.primary),
                    const SizedBox(height: 12),
                    Text("Invite Friends", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface)),
                    const SizedBox(height: 8),
                    Text("Add travel companions to plan together", style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.6)), textAlign: TextAlign.center),
                    const SizedBox(height: 20),
                     SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => _showAddFriendDialog(context),
                        icon: const Icon(Icons.person_add),
                        label: const Text("Friends"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 32),
              
              Text("Travel Companions (${_friends.length})", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface)),
              const SizedBox(height: 16),
              
              if (_friends.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(40),
                    child: Column(
                      children: [
                        Icon(Icons.people_outline, size: 48, color: theme.colorScheme.onSurface.withOpacity(0.3)),
                        const SizedBox(height: 16),
                        Text("No friends added yet", style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.5))),
                      ],
                    ),
                  ),
                )
              else
                ...(_friends.asMap().entries.map((entry) => _buildFriendCard(context, entry.key, entry.value, theme))),

              const SizedBox(height: 48),
              BlocBuilder<AuthBloc, AuthState>(
                builder: (context, authState) {
                  final isOwner = authState is Authenticated && authState.user.id == widget.trip.owner?.id;
                  final pendingBookings = _bookings.where((b) => b.status == 'pending').toList();
                  final acceptedBookings = _bookings.where((b) => b.status == 'accepted').toList();

                  if (pendingBookings.isEmpty && acceptedBookings.isEmpty) return const SizedBox.shrink();

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.bookmark_added_rounded, color: theme.colorScheme.primary, size: 24),
                          const SizedBox(width: 12),
                          Text("Destination Bookings", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      if (isOwner && pendingBookings.isNotEmpty) ...[
                        Text("Pending Approvals", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: theme.colorScheme.primary.withOpacity(0.8))),
                        const SizedBox(height: 12),
                        ...pendingBookings.map((booking) => _buildBookingCard(booking, true, theme)),
                        const SizedBox(height: 24),
                      ],

                      if (acceptedBookings.isNotEmpty) ...[
                        Text("Accepted & Confirmed", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.green[400])),
                        const SizedBox(height: 12),
                        ...acceptedBookings.map((booking) => _buildBookingCard(booking, false, theme)),
                      ],
                    ],
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBookingCard(Booking booking, bool canAccept, ThemeData theme) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: booking.status == 'accepted' ? Colors.green.withOpacity(0.3) : theme.dividerColor.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: (booking.status == 'accepted' ? Colors.green : theme.colorScheme.primary).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              booking.status == 'accepted' ? Icons.check_circle_rounded : Icons.pending_actions_rounded,
              color: booking.status == 'accepted' ? Colors.green : theme.colorScheme.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  booking.destination,
                  style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface, fontSize: 16),
                ),
                Text(
                  "${booking.adults} Adults, ${booking.children} Children • Total: \$${booking.totalAmount.toStringAsFixed(0)}",
                  style: TextStyle(color: theme.colorScheme.onSurface, fontWeight: FontWeight.w500, fontSize: 13),
                ),
                Text(
                  "By: ${booking.user.email}",
                  style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.5), fontSize: 11),
                ),
              ],
            ),
          ),
          if (canAccept)
            ElevatedButton(
              onPressed: () => _acceptBooking(booking.id, booking.destination),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                elevation: 0,
              ),
              child: const Text("Accept", style: TextStyle(fontWeight: FontWeight.bold)),
            )
          else if (booking.status == 'accepted')
             Container(
               padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
               decoration: BoxDecoration(
                 color: Colors.green.withOpacity(0.1),
                 borderRadius: BorderRadius.circular(12),
               ),
               child: const Row(
                 mainAxisSize: MainAxisSize.min,
                 children: [
                   Icon(Icons.check_circle, color: Colors.green, size: 14),
                   SizedBox(width: 6),
                   Text("Confirmed", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 12)),
                 ],
               ),
             ),
        ],
      ),
    );
  }

  Widget _buildFriendCard(BuildContext context, int index, Collaborator collaborator, ThemeData theme) {
    final user = collaborator.user;
    final name = user?.email.split('@').first ?? 'Guest';
    final email = user?.email ?? '';

    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        ImageProvider? imageProvider;
        String? pic = user?.profilePicture;
        
        if (authState is Authenticated && user != null && user.id == authState.user.id) {
          pic = authState.user.profilePicture;
        }

        if (pic != null && pic.isNotEmpty) {
          final String picPath = pic; // Local variable to help with type promotion
          if (picPath.startsWith('data:image')) {
            final commaIndex = picPath.indexOf(',');
            if (commaIndex != -1) {
              imageProvider = MemoryImage(base64Decode(picPath.substring(commaIndex + 1)));
            }
          } else {
            String url = picPath;
            if (url.startsWith('/')) {
              url = "http://127.0.0.1:8000$url";
            } else if (!url.startsWith('http')) {
              url = "http://127.0.0.1:8000/media/$url";
            }
            imageProvider = NetworkImage("$url?v=${user?.hashCode ?? picPath.length}");
          }
        }

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: theme.dividerColor.withOpacity(0.1)),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                backgroundImage: imageProvider,
                child: imageProvider == null 
                  ? Text(
                      name[0].toUpperCase(),
                      style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold, fontSize: 18),
                    )
                  : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface)),
                    if (email.isNotEmpty)
                      Text(email, style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.4), fontSize: 11)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  collaborator.role.toUpperCase(),
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: theme.colorScheme.primary),
                ),
              ),
              if (authState is Authenticated && widget.trip.owner?.id == authState.user.id && user?.id != authState.user.id)
                IconButton(
                  icon: const Icon(Icons.person_remove_outlined, color: Colors.redAccent, size: 20),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text("Remove Friend?"),
                        content: Text("Are you sure you want to remove $name from this trip?"),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pop(ctx);
                              _removeFriend(user!.id);
                            },
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                            child: const Text("Remove"),
                          ),
                        ],
                      ),
                    );
                  },
                ),
            ],
          ),
        );
      },
    );
  }
  void _showAddFriendDialog(BuildContext context) {
    _showInviteEmailDialog(context);
  }
  void _showInviteEmailDialog(BuildContext context) {
    final emailController = TextEditingController();
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text("Invite Collaborator", style: TextStyle(color: theme.colorScheme.onSurface)),
        content: TextField(
          controller: emailController,
          keyboardType: TextInputType.emailAddress,
          style: TextStyle(color: theme.colorScheme.onSurface),
          decoration: InputDecoration(
            labelText: "Email Address",
            prefixIcon: Icon(Icons.email, color: theme.colorScheme.primary),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              if (emailController.text.isNotEmpty) {
                final Uri emailUri = Uri(
                  scheme: 'mailto',
                  path: emailController.text,
                  query: 'subject=Join my trip: ${widget.trip.title}&body=Hey! I want to invite you to collaborate on my upcoming trip to ${widget.trip.destination}. Download Smart Trip Planner and join me!',
                );
                try {
                  if (await canLaunchUrl(emailUri)) {
                    await launchUrl(emailUri);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Could not launch email client")));
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
                }
                Navigator.pop(context);
              }
            },
            child: const Text("Invite & Open Mail"),
          ),
        ],
      ),
    );
  }
}
