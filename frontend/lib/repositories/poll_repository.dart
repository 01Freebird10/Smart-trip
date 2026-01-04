import '../services/api_client.dart';

class PollRepository {
  final ApiClient apiClient;

  PollRepository(this.apiClient);

  Future<List<dynamic>> getPolls(int tripId) async {
    final response = await apiClient.dio.get('trips/polls/', queryParameters: {'trip_id': tripId});
    return response.data;
  }

  Future<void> vote(int pollId, int optionId) async {
    await apiClient.dio.post('trips/polls/$pollId/vote/', data: {'option_id': optionId});
  }

  Future<void> createPoll(int tripId, String question, List<String> options) async {
    await apiClient.dio.post('trips/polls/', data: {
      'trip': tripId,
      'question': question,
      'option_texts': options,
    });
  }
}
