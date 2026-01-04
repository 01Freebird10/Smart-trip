import 'package:dio/dio.dart';
import '../models/city.dart';
import '../models/seasonal_destination.dart';
import 'api_client.dart';

/// Service to fetch destinations from backend with season-aware filtering
class DestinationService {
  final ApiClient apiClient;
  
  DestinationService(this.apiClient);
  
  /// Get current season based on month
  static String getCurrentSeason() {
    final month = DateTime.now().month;
    if (month >= 3 && month <= 5) return "spring";
    if (month >= 6 && month <= 8) return "summer";
    if (month >= 9 && month <= 11) return "autumn";
    return "winter";
  }
  
  /// Get friendly season name
  static String getSeasonDisplayName() {
    final month = DateTime.now().month;
    if (month >= 3 && month <= 5) return "Spring";
    if (month >= 6 && month <= 8) return "Summer";
    if (month >= 9 && month <= 11) return "Autumn";
    return "Winter";
  }
  
  /// Get season-themed vacation title
  static String getSeasonalTitle() {
    final season = getCurrentSeason();
    switch (season) {
      case "winter":
        return "❄️ Winter Wonderland Escapes";
      case "spring":
        return "🌸 Spring Blossom Getaways";
      case "summer":
        return "☀️ Summer Beach Paradises";
      case "autumn":
        return "🍂 Autumn Foliage Adventures";
      default:
        return "✨ Seasonal Picks";
    }
  }
  
  /// Get season-specific destinations with special offers
  List<SeasonalDestination> getSeasonalDestinations() {
    final season = getCurrentSeason();
    
    switch (season) {
      case "winter":
        return _getWinterDestinations();
      case "spring":
        return _getSpringDestinations();
      case "summer":
        return _getSummerDestinations();
      case "autumn":
        return _getAutumnDestinations();
      default:
        return _getWinterDestinations();
    }
  }
  
  List<SeasonalDestination> _getWinterDestinations() {
    return [
      SeasonalDestination(
        city: CityData.cities.firstWhere((c) => c.name == "Reykjavik"),
        seasonalOffer: "Northern Lights Special",
        discount: 20,
        specialActivity: "Aurora Borealis Tours",
        bestFor: "Snow & Ice Adventures",
        temperature: "-2°C",
        weatherIcon: "❄️",
      ),
      SeasonalDestination(
        city: CityData.cities.firstWhere((c) => c.name == "Dubai"),
        seasonalOffer: "Winter Sun Escape",
        discount: 15,
        specialActivity: "Desert Safari & Beach",
        bestFor: "Warm Weather Getaway",
        temperature: "25°C",
        weatherIcon: "☀️",
      ),
      SeasonalDestination(
        city: CityData.cities.firstWhere((c) => c.name == "Kyoto"),
        seasonalOffer: "Winter Zen Package",
        discount: 18,
        specialActivity: "Hot Springs & Temples",
        bestFor: "Cultural Experience",
        temperature: "5°C",
        weatherIcon: "🌤️",
      ),
      SeasonalDestination(
        city: CityData.cities.firstWhere((c) => c.name == "Bangkok"),
        seasonalOffer: "Tropical Winter",
        discount: 25,
        specialActivity: "Food & Temple Tours",
        bestFor: "Exotic Escape",
        temperature: "30°C",
        weatherIcon: "🌴",
      ),
      SeasonalDestination(
        city: CityData.cities.firstWhere((c) => c.name == "Sydney"),
        seasonalOffer: "Summer in Winter",
        discount: 12,
        specialActivity: "Beach & Nature",
        bestFor: "Southern Hemisphere Summer",
        temperature: "28°C",
        weatherIcon: "🏖️",
      ),
    ];
  }
  
  List<SeasonalDestination> _getSpringDestinations() {
    return [
      SeasonalDestination(
        city: CityData.cities.firstWhere((c) => c.name == "Kyoto"),
        seasonalOffer: "Cherry Blossom Special",
        discount: 10,
        specialActivity: "Sakura Viewing Tours",
        bestFor: "Flower Festivals",
        temperature: "18°C",
        weatherIcon: "🌸",
      ),
      SeasonalDestination(
        city: CityData.cities.firstWhere((c) => c.name == "Paris"),
        seasonalOffer: "Springtime in Paris",
        discount: 15,
        specialActivity: "Seine River Cruises",
        bestFor: "Romantic Escape",
        temperature: "16°C",
        weatherIcon: "🌷",
      ),
      SeasonalDestination(
        city: CityData.cities.firstWhere((c) => c.name == "Amsterdam"),
        seasonalOffer: "Tulip Season",
        discount: 20,
        specialActivity: "Keukenhof Gardens",
        bestFor: "Flower Gardens",
        temperature: "14°C",
        weatherIcon: "🌺",
      ),
      SeasonalDestination(
        city: CityData.cities.firstWhere((c) => c.name == "Seoul"),
        seasonalOffer: "K-Spring Festival",
        discount: 18,
        specialActivity: "Palace Garden Tours",
        bestFor: "Culture & Nature",
        temperature: "15°C",
        weatherIcon: "🌼",
      ),
      SeasonalDestination(
        city: CityData.cities.firstWhere((c) => c.name == "London"),
        seasonalOffer: "Royal Gardens",
        discount: 12,
        specialActivity: "Hyde Park Blooms",
        bestFor: "Historic Gardens",
        temperature: "14°C",
        weatherIcon: "🌿",
      ),
    ];
  }
  
  List<SeasonalDestination> _getSummerDestinations() {
    return [
      SeasonalDestination(
        city: CityData.cities.firstWhere((c) => c.name == "Santorini"),
        seasonalOffer: "Greek Summer Dream",
        discount: 15,
        specialActivity: "Island Hopping",
        bestFor: "Beach & Sunsets",
        temperature: "30°C",
        weatherIcon: "🏝️",
      ),
      SeasonalDestination(
        city: CityData.cities.firstWhere((c) => c.name == "Barcelona"),
        seasonalOffer: "Mediterranean Magic",
        discount: 20,
        specialActivity: "Beach & Tapas Tours",
        bestFor: "Nightlife & Beach",
        temperature: "28°C",
        weatherIcon: "☀️",
      ),
      SeasonalDestination(
        city: CityData.cities.firstWhere((c) => c.name == "Bali"),
        seasonalOffer: "Paradise Package",
        discount: 25,
        specialActivity: "Temple & Beach Combo",
        bestFor: "Tropical Adventure",
        temperature: "27°C",
        weatherIcon: "🌴",
      ),
      SeasonalDestination(
        city: CityData.cities.firstWhere((c) => c.name == "Cape Town"),
        seasonalOffer: "Winter Wine Tour",
        discount: 30,
        specialActivity: "Wine Country Escape",
        bestFor: "Wine & Wildlife",
        temperature: "18°C",
        weatherIcon: "🍷",
      ),
      SeasonalDestination(
        city: CityData.cities.firstWhere((c) => c.name == "Lisbon"),
        seasonalOffer: "Atlantic Summer",
        discount: 18,
        specialActivity: "Beach & City Tours",
        bestFor: "Coastal Adventure",
        temperature: "26°C",
        weatherIcon: "🌊",
      ),
    ];
  }
  
  List<SeasonalDestination> _getAutumnDestinations() {
    return [
      SeasonalDestination(
        city: CityData.cities.firstWhere((c) => c.name == "New York"),
        seasonalOffer: "Fall Foliage Special",
        discount: 15,
        specialActivity: "Central Park Tours",
        bestFor: "Autumn Colors",
        temperature: "15°C",
        weatherIcon: "🍁",
      ),
      SeasonalDestination(
        city: CityData.cities.firstWhere((c) => c.name == "Prague"),
        seasonalOffer: "Golden Autumn",
        discount: 22,
        specialActivity: "Castle & Beer Tours",
        bestFor: "Historic Beauty",
        temperature: "12°C",
        weatherIcon: "🍂",
      ),
      SeasonalDestination(
        city: CityData.cities.firstWhere((c) => c.name == "Berlin"),
        seasonalOffer: "Oktoberfest Season",
        discount: 18,
        specialActivity: "Cultural Festivals",
        bestFor: "Festivals & History",
        temperature: "14°C",
        weatherIcon: "🎭",
      ),
      SeasonalDestination(
        city: CityData.cities.firstWhere((c) => c.name == "Edinburgh"),
        seasonalOffer: "Scottish Highlands",
        discount: 20,
        specialActivity: "Whisky Tours",
        bestFor: "Scenic Drives",
        temperature: "10°C",
        weatherIcon: "🏴󠁧󠁢󠁳󠁣󠁴󠁿",
      ),
      SeasonalDestination(
        city: CityData.cities.firstWhere((c) => c.name == "Montreal"),
        seasonalOffer: "Maple Season",
        discount: 25,
        specialActivity: "Quebec Countryside",
        bestFor: "Fall Colors",
        temperature: "8°C",
        weatherIcon: "🍁",
      ),
    ];
  }
  
  /// Try to fetch destinations from API, fallback to local data
  Future<List<SeasonalDestination>> fetchSeasonalDestinations() async {
    try {
      final response = await apiClient.dio.get(
        'trips/seasonal-destinations/',
        queryParameters: {'season': getCurrentSeason()},
      );
      
      if (response.statusCode == 200 && response.data != null) {
        final List data = response.data;
        return data.map((json) => SeasonalDestination.fromJson(json)).toList();
      }
    } catch (e) {
      // Fallback to local data if API fails
      print('API fetch failed, using local seasonal data: $e');
    }
    
    return getSeasonalDestinations();
  }
  
  /// Get featured destinations based on popularity
  Future<List<City>> fetchFeaturedDestinations() async {
    try {
      final response = await apiClient.dio.get('trips/featured-destinations/');
      
      if (response.statusCode == 200 && response.data != null) {
        final List data = response.data;
        return data.map((json) => City(
          name: json['name'],
          country: json['country'],
          countryCode: json['country_code'] ?? '',
          imageUrl: json['image_url'] ?? "https://picsum.photos/seed/${json['name']}/600/400",
          description: json['description'] ?? "",
          mustVisit: List<String>.from(json['must_visit'] ?? []),
          averageDailyCost: (json['average_daily_cost'] ?? 100).toDouble(),
        )).toList();
      }
    } catch (e) {
      print('Featured destinations API failed: $e');
    }
    
    // Fallback to predefined featured cities
    return [
      CityData.cities.firstWhere((c) => c.name == "Paris"),
      CityData.cities.firstWhere((c) => c.name == "Kyoto"),
      CityData.cities.firstWhere((c) => c.name == "Santorini"),
      CityData.cities.firstWhere((c) => c.name == "Dubai"),
      CityData.cities.firstWhere((c) => c.name == "New York"),
      CityData.cities.firstWhere((c) => c.name == "Bali"),
    ];
  }
  
  /// Get quick stats from backend
  Future<Map<String, dynamic>> fetchUserStats() async {
    try {
      final response = await apiClient.dio.get('trips/user-stats/');
      
      if (response.statusCode == 200 && response.data != null) {
        return response.data;
      }
    } catch (e) {
      print('User stats API failed: $e');
    }
    
    return {
      'trips_count': 0,
      'cities_explored': 0,
      'countries_visited': 0,
      'total_saved': 0.0,
    };
  }
}
