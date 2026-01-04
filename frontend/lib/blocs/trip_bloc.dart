import 'package:dio/dio.dart' as dio_lib;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../models/trip.dart';
import '../repositories/trip_repository.dart';

abstract class TripEvent {}
class LoadTrips extends TripEvent {}
class CreateTrip extends TripEvent {
  final Trip trip;
  CreateTrip(this.trip);
}

abstract class TripState {}
class TripInitial extends TripState {}
class TripLoading extends TripState {}
class TripsLoaded extends TripState {
  final List<Trip> trips;
  TripsLoaded(this.trips);
}
class TripError extends TripState {
  final String message;
  TripError(this.message);
}

class UpdateTrip extends TripEvent {
  final Trip trip;
  UpdateTrip(this.trip);
}

class DeleteTrip extends TripEvent {
  final int tripId;
  DeleteTrip(this.tripId);
}

class CancelBooking extends TripEvent {
  final int bookingId;
  CancelBooking(this.bookingId);
}

class TripBloc extends Bloc<TripEvent, TripState> {
  final TripRepository tripRepository;

  TripBloc(this.tripRepository) : super(TripInitial()) {
    // Listen for connectivity changes to sync data when back online
    Connectivity().onConnectivityChanged.listen((results) {
      if (results.any((result) => result != ConnectivityResult.none)) {
        add(LoadTrips());
      }
    });

    on<LoadTrips>((event, emit) async {
      if (state is! TripsLoaded) {
        emit(TripLoading());
      }
      try {
        final trips = await tripRepository.getTrips();
        emit(TripsLoaded(trips));
      } catch (e) {
        if (state is! TripsLoaded) {
          emit(TripError("Adventures unavailable: ${_extractError(e)}"));
        }
      }
    });

    on<CreateTrip>((event, emit) async {
      try {
        final savedTrip = await tripRepository.createTrip(event.trip);
        
        if (state is TripsLoaded) {
          final List<Trip> currentTrips = List.from((state as TripsLoaded).trips);
          currentTrips.insert(0, savedTrip);
          emit(TripsLoaded(currentTrips));
        } else {
          emit(TripsLoaded([savedTrip]));
        }
      } catch (e) {
        emit(TripError("Planning failed: ${_extractError(e)}"));
      }
    });

    on<UpdateTrip>((event, emit) async {
       try {
         final updatedTrip = await tripRepository.updateTrip(event.trip);
         if (state is TripsLoaded) {
           final List<Trip> updatedTrips = (state as TripsLoaded).trips.map((t) {
             return t.id == updatedTrip.id ? updatedTrip : t;
           }).toList();
           emit(TripsLoaded(updatedTrips));
         }
       } catch (e) {
         emit(TripError("Update failed: ${_extractError(e)}"));
       }
    });

    on<DeleteTrip>((event, emit) async {
      try {
        await tripRepository.deleteTrip(event.tripId);
        if (state is TripsLoaded) {
          final List<Trip> updatedTrips = (state as TripsLoaded).trips.where((t) => t.id != event.tripId).toList();
          emit(TripsLoaded(updatedTrips));
        }
      } catch (e) {
        emit(TripError("Failed to delete adventure: ${_extractError(e)}"));
      }
    });

    on<CancelBooking>((event, emit) async {
      try {
        await tripRepository.cancelBooking(event.bookingId);
        // Simplest way to refresh everything correctly since bookings are nested in trips
        add(LoadTrips());
      } catch (e) {
        emit(TripError("Failed to cancel booking: ${_extractError(e)}"));
      }
    });
  }

  String _extractError(Object e) {
    if (e is dio_lib.DioException) {
      final res = e.response;
      if (res != null && res.data is Map) {
        final data = res.data as Map;
        return (data['detail'] ?? data['error'] ?? data['message'] ?? e.message).toString();
      }
      return e.message ?? "Connection error.";
    }
    return e.toString();
  }
}
