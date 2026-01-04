import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/itinerary_item.dart';
import '../repositories/trip_repository.dart';

abstract class ItineraryEvent {}
class LoadItinerary extends ItineraryEvent {
  final int tripId;
  LoadItinerary(this.tripId);
}
class ReorderItinerary extends ItineraryEvent {
  final int tripId;
  final List<int> itemIds;
  ReorderItinerary(this.tripId, this.itemIds);
}
class AddItineraryItem extends ItineraryEvent {
  final int tripId;
  final String title;
  final String? location;
  AddItineraryItem(this.tripId, this.title, this.location);
}

abstract class ItineraryState {}
class ItineraryInitial extends ItineraryState {}
class ItineraryLoading extends ItineraryState {}
class ItineraryLoaded extends ItineraryState {
  final List<ItineraryItem> items;
  ItineraryLoaded(this.items);
}
class ItineraryError extends ItineraryState {
  final String message;
  ItineraryError(this.message);
}

class ItineraryBloc extends Bloc<ItineraryEvent, ItineraryState> {
  final TripRepository tripRepository;

  ItineraryBloc(this.tripRepository) : super(ItineraryInitial()) {
    on<LoadItinerary>((event, emit) async {
      emit(ItineraryLoading());
      try {
        final items = await tripRepository.getItinerary(event.tripId);
        emit(ItineraryLoaded(items));
      } catch (e) {
        emit(ItineraryError(e.toString()));
      }
    });

    on<ReorderItinerary>((event, emit) async {
      try {
        await tripRepository.reorderItinerary(event.tripId, event.itemIds);
        final items = await tripRepository.getItinerary(event.tripId);
        emit(ItineraryLoaded(items));
      } catch (e) {
        emit(ItineraryError(e.toString()));
      }
    });
    on<AddItineraryItem>((event, emit) async {
      try {
        await tripRepository.addItineraryItem(event.tripId, event.title, event.location);
        final items = await tripRepository.getItinerary(event.tripId);
        emit(ItineraryLoaded(items));
      } catch (e) {
        emit(ItineraryError(e.toString()));
      }
    });
  }
}
