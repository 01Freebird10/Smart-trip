import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/trip.dart';
import '../models/city.dart';
import '../widgets/nav_button.dart';
import '../blocs/trip_bloc.dart';
import '../widgets/glass_container.dart';
import '../utils/currency_utils.dart';

class MyBookingsScreen extends StatelessWidget {
  const MyBookingsScreen({super.key});

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
        title: const Text("My Confirm Bookings", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 24)),
        backgroundColor: Colors.transparent,
        elevation: 0,
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
              // Collect all bookings from all trips
              final allBookings = state.trips.expand((trip) => trip.bookings ?? []).toList();
              
              if (allBookings.isEmpty) {
                return const Center(child: Text("No bookings found", style: TextStyle(color: Colors.white70, fontSize: 18)));
              }

              return ListView.builder(
                padding: EdgeInsets.fromLTRB(isDesktop ? 120 : 20, 140, isDesktop ? 120 : 20, 40),
                itemCount: allBookings.length,
                itemBuilder: (context, index) {
                  final booking = allBookings[index];
                  return _BookingCard(booking: booking);
                },
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}

class _BookingCard extends StatefulWidget {
  final Booking booking;
  const _BookingCard({required this.booking});

  @override
  State<_BookingCard> createState() => _BookingCardState();
}

class _BookingCardState extends State<_BookingCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // Find city data for image
    String? imageUrl;
    try {
      final city = CityData.cities.firstWhere(
        (c) => c.name.toLowerCase() == widget.booking.destination.toLowerCase()
      );
      imageUrl = city.imageUrl;
    } catch (_) {}

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () => setState(() => _isExpanded = !_isExpanded),
          child: GlassContainer(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.confirmation_number_rounded, color: theme.colorScheme.primary, size: 32),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.booking.destination,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              _buildChip(theme, Icons.person, "${widget.booking.adults} Adults"),
                              const SizedBox(width: 12),
                              _buildChip(theme, Icons.child_care, "${widget.booking.children} Children"),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            "Total Amount Paid: ${CurrencyUtils.format(widget.booking.totalAmount, widget.booking.destination)}",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.green.withOpacity(0.5)),
                          ),
                          child: const Text(
                            "CONFIRMED",
                            style: TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold, fontSize: 12),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextButton.icon(
                          onPressed: () {
                            context.read<TripBloc>().add(CancelBooking(widget.booking.id));
                          },
                          icon: const Icon(Icons.cancel_outlined, size: 16, color: Colors.white70),
                          label: const Text("Cancel", style: TextStyle(color: Colors.white70, fontSize: 13)),
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 12),
                    Icon(
                      _isExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                      color: Colors.white70,
                    ),
                  ],
                ),
                
                // Expandable Section
                AnimatedCrossFade(
                  firstChild: const SizedBox(width: double.infinity),
                  secondChild: Padding(
                    padding: const EdgeInsets.only(top: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Divider(color: Colors.white24, height: 1),
                        const SizedBox(height: 24),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (imageUrl != null)
                              ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: Image.network(
                                  imageUrl,
                                  width: 150,
                                  height: 100,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            const SizedBox(width: 24),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Booking Summary",
                                    style: TextStyle(
                                      color: theme.colorScheme.primary,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  _buildDetailRow("Destination", widget.booking.destination),
                                  _buildDetailRow("Adults", "${widget.booking.adults}"),
                                  _buildDetailRow("Children", "${widget.booking.children}"),
                                  const Divider(color: Colors.white12),
                                  _buildDetailRow("Total Paid", CurrencyUtils.format(widget.booking.totalAmount, widget.booking.destination), isLast: true),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  crossFadeState: _isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                  duration: const Duration(milliseconds: 300),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isLast = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 14)),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildChip(ThemeData theme, IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.white70),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 14),
        ),
      ],
    );
  }
}
