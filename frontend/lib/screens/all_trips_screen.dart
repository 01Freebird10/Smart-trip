import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/trip.dart';
import '../widgets/nav_button.dart';
import '../blocs/trip_bloc.dart';
import '../blocs/auth_bloc.dart';
import 'trip_detail_screen.dart';

class AllTripsScreen extends StatelessWidget {
  const AllTripsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 900;
    final theme = Theme.of(context);
    
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        leading: NavButton(
          icon: Icons.arrow_back,
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("All Your Adventures", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 24)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
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
                    // Use a more aggressive cache buster that changes when the user data does
                    final buster = user.hashCode;
                    imageProvider = NetworkImage("$url?v=$buster");
                  }
                }
                
                return Padding(
                  padding: const EdgeInsets.only(right: 20),
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white24),
                      ),
                      child: CircleAvatar(
                        radius: 18,
                        backgroundImage: imageProvider,
                        child: imageProvider == null ? const Icon(Icons.person, color: Colors.white, size: 20) : null,
                      ),
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [theme.colorScheme.primary, theme.colorScheme.secondary],
          ),
        ),
        child: BlocBuilder<TripBloc, TripState>(
          builder: (context, state) {
            if (state is TripLoading) {
              return const Center(child: CircularProgressIndicator(color: Colors.white));
            }
            if (state is TripError) {
              return Center(child: Text("Error: ${state.message}", style: const TextStyle(color: Colors.white70)));
            }
            if (state is TripsLoaded) {
              final trips = state.trips;
              if (trips.isEmpty) {
                return const Center(child: Text("No trips found", style: TextStyle(color: Colors.white70, fontSize: 18)));
              }
              return GridView.builder(
                padding: EdgeInsets.fromLTRB(isDesktop ? 60 : 20, 140, isDesktop ? 60 : 20, 40),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: isDesktop ? 3 : 2,
                  childAspectRatio: 0.85,
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 20,
                ),
                itemCount: trips.length,
                itemBuilder: (context, index) => _TripCardFull(trip: trips[index]),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}

class _TripCardFull extends StatelessWidget {
  final Trip trip;
  const _TripCardFull({required this.trip});

  @override
  Widget build(BuildContext context) {
    ImageProvider? imageProvider;
    if (trip.imageUrl != null && trip.imageUrl!.isNotEmpty) {
      String url = trip.imageUrl!;
      if (url.startsWith('data:image')) {
        final commaIndex = url.indexOf(',');
        if (commaIndex != -1) {
          imageProvider = MemoryImage(base64Decode(url.substring(commaIndex + 1)));
        }
      } else {
        if (url.startsWith('/')) {
          url = "http://127.0.0.1:8000$url";
        } else if (!url.startsWith('http')) {
          url = "http://127.0.0.1:8000/media/$url";
        }
        imageProvider = NetworkImage(url);
      }
    }

    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => TripDetailScreen(trip: trip))),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.12),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withOpacity(0.2)),
          boxShadow: [
            BoxShadow(color: Colors.black26, blurRadius: 15, offset: const Offset(0, 8)),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  image: imageProvider != null ? DecorationImage(image: imageProvider, fit: BoxFit.cover) : null,
                ),
                child: imageProvider == null 
                  ? const Icon(Icons.terrain_rounded, color: Colors.white24, size: 50)
                  : null,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(trip.title, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on, color: Colors.white70, size: 14),
                      const SizedBox(width: 4),
                      Text(trip.destination, style: TextStyle(color: Colors.white.withOpacity(0.6))),
                    ],
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
