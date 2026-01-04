import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:frontend/blocs/trip_bloc.dart';
import 'package:frontend/repositories/trip_repository.dart';
import 'package:frontend/models/trip.dart';

class MockTripRepository extends Mock implements TripRepository {}

void main() {
  late TripBloc tripBloc;
  late MockTripRepository mockTripRepository;

  setUp(() {
    mockTripRepository = MockTripRepository();
    tripBloc = TripBloc(mockTripRepository);
  });

  tearDown(() {
    tripBloc.close();
  });

  group('TripBloc Tests', () {
    final tTrip = Trip(
      id: 1,
      title: 'Paris Getaway',
      destination: 'Paris',
      startDate: DateTime.now(),
      endDate: DateTime.now().add(const Duration(days: 5)),
      ownerId: 1,
    );

    test('initial state should be TripInitial', () {
      expect(tripBloc.state, isA<TripInitial>());
    });

    blocTest<TripBloc, TripState>(
      'emits [TripLoading, TripsLoaded] when LoadTrips is successful',
      build: () {
        when(() => mockTripRepository.getTrips())
            .thenAnswer((_) async => [tTrip]);
        return tripBloc;
      },
      act: (bloc) => bloc.add(LoadTrips()),
      expect: () => [
        isA<TripLoading>(),
        isA<TripsLoaded>(),
      ],
      verify: (_) {
        verify(() => mockTripRepository.getTrips()).called(1);
      },
    );

    blocTest<TripBloc, TripState>(
      'emits [TripError] when LoadTrips fails',
      build: () {
        when(() => mockTripRepository.getTrips())
            .thenThrow(Exception('Backend unreachable'));
        return tripBloc;
      },
      act: (bloc) => bloc.add(LoadTrips()),
      expect: () => [
        isA<TripLoading>(),
        isA<TripError>(),
      ],
    );
  });
}
