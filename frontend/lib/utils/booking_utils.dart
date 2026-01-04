import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/city.dart';
import '../models/trip.dart';
import '../repositories/trip_repository.dart';
import '../blocs/trip_bloc.dart';
import 'currency_utils.dart';

class BookingDialogUtils {
  static void showBookingDialog({
    required BuildContext context,
    required String cityName,
    required String seasonalOffer,
    required Color primaryColor,
    required IconData icon,
    int initialAdults = 1,
    int initialChildren = 0,
  }) async {
    final theme = Theme.of(context);
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final repo = context.read<TripRepository>();

    const double adultPrice = 149.0;
    const double childPrice = 79.0;
    int adults = initialAdults;
    int children = initialChildren;

    // 1. Get trips to find a trip to book for
    List<Trip> trips = await repo.getTrips();
    
    if (trips.isEmpty) {
      // Auto-create a trip if none exists
      final newTrip = Trip(
        id: 0,
        title: "Adventure to $cityName",
        destination: cityName,
        startDate: DateTime.now(),
        endDate: DateTime.now().add(const Duration(days: 7)),
        createdAt: DateTime.now(),
        imageUrl: null,
      );
      
      try {
        final savedTrip = await repo.createTrip(newTrip);
        // Add to bloc so UI stays in sync
        if (context.mounted) {
          context.read<TripBloc>().add(CreateTrip(savedTrip));
        }
        trips = [savedTrip];
      } catch (e) {
        scaffoldMessenger.showSnackBar(SnackBar(content: Text("Failed to auto-create trip: $e")));
        return;
      }
    }

    final targetTrip = trips.firstWhere(
      (t) => t.destination.toLowerCase() == cityName.toLowerCase(),
      orElse: () => trips.first,
    );

    if (!context.mounted) return;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          final totalAmount = (adults * adultPrice) + (children * childPrice);

          return AlertDialog(
            backgroundColor: theme.colorScheme.surface,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
            title: Row(
              children: [
                Icon(icon, color: primaryColor, size: 28),
                const SizedBox(width: 12),
                Expanded(child: Text("Book $cityName", style: TextStyle(color: theme.colorScheme.onSurface))),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(seasonalOffer, style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.7), fontSize: 14)),
                  const SizedBox(height: 20),
                  
                  // Adult Counter
                  _buildCounterRow("Adults", "${CurrencyUtils.format(adultPrice, cityName)}/each", adults, (val) {
                    if (val >= 1) setDialogState(() => adults = val);
                  }, theme),
                  
                  const SizedBox(height: 12),
                  
                  // Child Counter
                  _buildCounterRow("Children", "${CurrencyUtils.format(childPrice, cityName)}/each", children, (val) {
                    if (val >= 0) setDialogState(() => children = val);
                  }, theme),

                  const Divider(height: 32),
                  
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Total Amount:", style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface)),
                      Text("\$${totalAmount.toStringAsFixed(0)}", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: primaryColor)),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  Text(
                    "Selected Trip: ${targetTrip.title}",
                    style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurface.withOpacity(0.5), fontStyle: FontStyle.italic),
                  ),
                ],
              ),
            ),
            actionsPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text("Cancel", style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.5))),
              ),
              ElevatedButton(
                onPressed: () async {
                  // Final Confirmation Process
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      title: const Text("Final Confirmation"),
                      content: Text("Are you sure for booking $cityName for ${CurrencyUtils.format(totalAmount, cityName)}?"),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("Wait, Go Back")),
                        ElevatedButton(
                          onPressed: () => Navigator.pop(ctx, true),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                          child: const Text("Yes, Confirm"),
                        ),
                      ],
                    ),
                  );

                  if (confirmed == true) {
                    try {
                      await repo.createBooking(targetTrip.id, cityName, adults, children, totalAmount);
                      if (context.mounted) {
                        context.read<TripBloc>().add(LoadTrips());
                        Navigator.pop(context);
                      }
                      scaffoldMessenger.showSnackBar(
                        SnackBar(
                          content: const Row(
                            children: [
                              Icon(Icons.check_circle, color: Colors.white),
                              SizedBox(width: 12),
                              Text("Booking confirmed! Request sent to owner."),
                            ],
                          ),
                          backgroundColor: Colors.green,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      );
                    } catch (e) {
                      if (context.mounted) Navigator.pop(context);
                      scaffoldMessenger.showSnackBar(SnackBar(content: Text("Error: $e")));
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: Text("Confirm Booking • ${CurrencyUtils.format(totalAmount, cityName)}"),
              ),
            ],
          );
        }
      ),
    );
  }

  static Widget _buildCounterRow(String label, String sublabel, int value, Function(int) onChanged, ThemeData theme) {
    return Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
            Text(sublabel, style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurface.withOpacity(0.5))),
          ],
        ),
        const Spacer(),
        Row(
          children: [
            _counterButton(Icons.remove, () => onChanged(value - 1), theme),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text("$value", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
            _counterButton(Icons.add, () => onChanged(value + 1), theme),
          ],
        ),
      ],
    );
  }

  static Widget _counterButton(IconData icon, VoidCallback onTap, ThemeData theme) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            border: Border.all(color: theme.dividerColor.withOpacity(0.2)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 20),
        ),
      ),
    );
  }
}
