import 'package:flutter_bloc/flutter_bloc.dart';
import '../repositories/poll_repository.dart';

abstract class PollEvent {}
class LoadPolls extends PollEvent {
  final int tripId;
  LoadPolls(this.tripId);
}
class VoteRequested extends PollEvent {
  final int tripId;
  final int pollId;
  final int optionId;
  VoteRequested(this.tripId, this.pollId, this.optionId);
}
class CreatePoll extends PollEvent {
  final int tripId;
  final String question;
  final List<String> options;
  CreatePoll(this.tripId, this.question, this.options);
}

abstract class PollState {}
class PollInitial extends PollState {}
class PollLoading extends PollState {}
class PollsLoaded extends PollState {
  final List<dynamic> polls;
  PollsLoaded(this.polls);
}
class PollError extends PollState {
  final String message;
  PollError(this.message);
}

class PollBloc extends Bloc<PollEvent, PollState> {
  final PollRepository repository;

  PollBloc(this.repository) : super(PollInitial()) {
    on<LoadPolls>((event, emit) async {
      emit(PollLoading());
      try {
        final polls = await repository.getPolls(event.tripId);
        emit(PollsLoaded(polls));
      } catch (e) {
        emit(PollError(e.toString()));
      }
    });

    on<VoteRequested>((event, emit) async {
      try {
        await repository.vote(event.pollId, event.optionId);
        final polls = await repository.getPolls(event.tripId);
        emit(PollsLoaded(polls));
      } catch (e) {
        emit(PollError(e.toString()));
      }
    });
    on<CreatePoll>((event, emit) async {
      try {
        await repository.createPoll(event.tripId, event.question, event.options);
        final polls = await repository.getPolls(event.tripId);
        emit(PollsLoaded(polls));
      } catch (e) {
        emit(PollError(e.toString()));
      }
    });
  }
}
