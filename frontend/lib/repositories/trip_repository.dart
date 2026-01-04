import 'package:hive/hive.dart';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import '../models/trip.dart';
import '../models/itinerary_item.dart';
import '../models/expense.dart';
import '../services/api_client.dart';

class TripRepository {
  final ApiClient apiClient;
  final Box<Trip> tripBox;
  final Box<ItineraryItem> itineraryBox;

  TripRepository(this.apiClient, this.tripBox, this.itineraryBox);

  Future<List<Trip>> getTrips() async {
    print("TripRepository: Fetching trips...");
    try {
      final response = await apiClient.dio.get('trips/trips/');
      print("TripRepository: Successfully fetched trips.");
      
      if (response.data is! List) {
        print("TripRepository: Expected List but got something else. Check backend.");
        return [];
      }
      
      final List<Trip> trips = (response.data as List).map((json) => Trip.fromJson(json)).toList();
      
      // Cache trips
      await tripBox.clear();
      await tripBox.addAll(trips);
      
      return trips;
    } catch (e) {
      // Return cached data on error (offline mode)
      if (tripBox.isNotEmpty) {
        return tripBox.values.toList();
      }
      rethrow;
    }
  }

  Future<Trip> createTrip(Trip trip) async {
    try {
      final Map<String, dynamic> data = {
        'title': trip.title,
        'description': trip.description ?? '',
        'destination': trip.destination,
        'start_date': trip.startDate.toIso8601String().split('T')[0],
        'end_date': trip.endDate.toIso8601String().split('T')[0],
        'budget': (trip.budget ?? 0.0).toString(),
      };
      
      // Handle image upload if it's base64
      if (trip.imageUrl != null && trip.imageUrl!.startsWith('data:image')) {
        final commaIndex = trip.imageUrl!.indexOf(',');
        if (commaIndex != -1) {
          final base64Content = trip.imageUrl!.substring(commaIndex + 1);
          final bytes = base64.decode(base64Content);
          data['image'] = MultipartFile.fromBytes(
            bytes,
            filename: 'trip_cover.jpg',
            contentType: DioMediaType.parse('image/jpeg'),
          );
        }
      }

      final response = await apiClient.dio.post(
        'trips/trips/', 
        data: FormData.fromMap(data),
      );
      final newTrip = Trip.fromJson(response.data);
      await tripBox.add(newTrip);
      return newTrip;
    } catch (e) {
      rethrow;
    }
  }

  Future<Trip> updateTrip(Trip trip) async {
    try {
      final Map<String, dynamic> data = {
        'title': trip.title,
        'description': trip.description ?? '',
        'destination': trip.destination,
        'start_date': trip.startDate.toIso8601String().split('T')[0],
        'end_date': trip.endDate.toIso8601String().split('T')[0],
        'budget': (trip.budget ?? 0.0).toString(),
      };

      // Handle image upload if it's base64
      if (trip.imageUrl != null && trip.imageUrl!.startsWith('data:image')) {
        final commaIndex = trip.imageUrl!.indexOf(',');
        if (commaIndex != -1) {
          final base64Content = trip.imageUrl!.substring(commaIndex + 1);
          final bytes = base64.decode(base64Content);
          data['image'] = MultipartFile.fromBytes(
            bytes,
            filename: 'trip_cover.jpg',
            contentType: DioMediaType.parse('image/jpeg'),
          );
        }
      }

      final response = await apiClient.dio.put(
        'trips/trips/${trip.id}/', 
        data: FormData.fromMap(data),
      );
      final updatedTrip = Trip.fromJson(response.data);
      
      // Update cache
      final index = tripBox.values.toList().indexWhere((t) => t.id == trip.id);
      if (index != -1) {
        await tripBox.putAt(index, updatedTrip);
      }
      
      return updatedTrip;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteTrip(int id) async {
    try {
      await apiClient.dio.delete('trips/trips/$id/');
      
      final index = tripBox.values.toList().indexWhere((t) => t.id == id);
      if (index != -1) {
        await tripBox.deleteAt(index);
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<ItineraryItem> addItineraryItem(int tripId, String title, String? location) async {
    final response = await apiClient.dio.post('trips/itinerary/', data: {
      'trip': tripId,
      'title': title,
      'location': location,
    });
    return ItineraryItem.fromJson(response.data);
  }

  Future<List<ItineraryItem>> getItinerary(int tripId) async {
    final response = await apiClient.dio.get('trips/itinerary/', queryParameters: {'trip_id': tripId});
    final List items = response.data;
    final itinerary = items.map((json) => ItineraryItem.fromJson(json)).toList();
    
    for (var item in itinerary) {
      await itineraryBox.put(item.id, item);
    }
    return itinerary;
  }

  Future<void> reorderItinerary(int tripId, List<int> itemIds) async {
    await apiClient.dio.post('trips/itinerary/reorder/', data: {
      'trip_id': tripId,
      'item_ids': itemIds,
    });
  }

  Future<void> inviteCollaborator(int tripId, String email) async {
    await apiClient.dio.post('trips/trips/$tripId/invite/', data: {'email': email});
  }

  Future<void> removeCollaborator(int tripId, int userId) async {
    await apiClient.dio.post('trips/trips/$tripId/remove_collaborator/', data: {'user_id': userId});
  }

  // --- Expense & Budget Methods ---

  Future<List<Expense>> getExpenses(int tripId) async {
    final response = await apiClient.dio.get('trips/expenses/', queryParameters: {'trip_id': tripId});
    final List items = response.data;
    return items.map((json) => Expense.fromJson(json)).toList();
  }

  Future<Expense> addExpense(int tripId, String name, double amount, String category) async {
    final response = await apiClient.dio.post('trips/expenses/', data: {
      'trip': tripId,
      'name': name,
      'amount': amount,
      'category': category,
    });
    return Expense.fromJson(response.data);
  }

  Future<void> deleteExpense(int expenseId) async {
    await apiClient.dio.delete('trips/expenses/$expenseId/');
  }

  Future<void> updateTripBudget(int tripId, double budget) async {
    await apiClient.dio.patch('trips/trips/$tripId/', data: {'budget': budget});
  }

  // --- Booking Methods ---
  Future<List<Booking>> getBookings(int tripId) async {
    final response = await apiClient.dio.get('trips/bookings/', queryParameters: {'trip_id': tripId});
    final List items = response.data;
    return items.map((json) => Booking.fromJson(json)).toList();
  }

  Future<Booking> createBooking(int tripId, String destination, int adults, int children, double totalAmount) async {
    final response = await apiClient.dio.post('trips/bookings/', data: {
      'trip': tripId,
      'destination': destination,
      'adults': adults,
      'children': children,
      'total_amount': totalAmount.toStringAsFixed(2),
    });
    return Booking.fromJson(response.data);
  }

  Future<void> acceptBooking(int bookingId) async {
    await apiClient.dio.post('trips/bookings/$bookingId/accept/');
  }

  Future<void> cancelBooking(int bookingId) async {
    await apiClient.dio.delete('trips/bookings/$bookingId/');
  }
}
