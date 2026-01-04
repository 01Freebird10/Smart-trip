import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/blocs/trip_bloc.dart';
import 'package:frontend/models/trip.dart';

void main() {
  group('TripBloc State Tests', () {
    test('TripInitial is the correct initial state type', () {
      final state = TripInitial();
      expect(state, isA<TripState>());
    });

    test('TripLoading state can be instantiated', () {
      final state = TripLoading();
      expect(state, isA<TripState>());
    });

    test('TripsLoaded state holds trip list', () {
      final trip = Trip(
        id: 1,
        title: 'Paris Getaway',
        destination: 'Paris',
        startDate: DateTime.now(),
        endDate: DateTime.now().add(const Duration(days: 5)),
        ownerId: 1,
      );
      final state = TripsLoaded([trip]);
      expect(state.trips.length, 1);
      expect(state.trips.first.title, 'Paris Getaway');
    });

    test('TripError state holds error message', () {
      final state = TripError('Failed to load trips');
      expect(state.message, 'Failed to load trips');
    });
  });

  group('TripBloc Event Tests', () {
    test('LoadTrips event can be instantiated', () {
      final event = LoadTrips();
      expect(event, isA<TripEvent>());
    });

    test('CreateTrip event holds trip data', () {
      final event = CreateTrip('Paris Trip', 'Paris', DateTime.now(), DateTime.now().add(const Duration(days: 5)));
      expect(event.title, 'Paris Trip');
      expect(event.destination, 'Paris');
    });
  });

  group('Trip Model Tests', () {
    test('Trip model can be created', () {
      final trip = Trip(
        id: 1,
        title: 'Test Trip',
        destination: 'Test City',
        startDate: DateTime(2024, 1, 1),
        endDate: DateTime(2024, 1, 5),
        ownerId: 1,
      );
      expect(trip.title, 'Test Trip');
      expect(trip.destination, 'Test City');
    });
  });
}
