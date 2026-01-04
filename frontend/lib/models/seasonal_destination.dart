import 'city.dart';

/// Model for seasonal destination with special offers
class SeasonalDestination {
  final City city;
  final String seasonalOffer;
  final int discount;
  final String specialActivity;
  final String bestFor;
  final String temperature;
  final String weatherIcon;
  
  const SeasonalDestination({
    required this.city,
    required this.seasonalOffer,
    required this.discount,
    required this.specialActivity,
    required this.bestFor,
    required this.temperature,
    required this.weatherIcon,
  });
  
  factory SeasonalDestination.fromJson(Map<String, dynamic> json) {
    return SeasonalDestination(
      city: City(
        name: json['city_name'] ?? '',
        country: json['country'] ?? '',
        countryCode: json['country_code'] ?? '',
        imageUrl: json['image_url'] ?? "https://picsum.photos/seed/${json['city_name']}/600/400",
        description: json['description'] ?? '',
        mustVisit: List<String>.from(json['must_visit'] ?? []),
        averageDailyCost: (json['average_daily_cost'] ?? 100).toDouble(),
      ),
      seasonalOffer: json['seasonal_offer'] ?? '',
      discount: json['discount'] ?? 0,
      specialActivity: json['special_activity'] ?? '',
      bestFor: json['best_for'] ?? '',
      temperature: json['temperature'] ?? '',
      weatherIcon: json['weather_icon'] ?? '🌍',
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'city_name': city.name,
      'country': city.country,
      'image_url': city.imageUrl,
      'description': city.description,
      'must_visit': city.mustVisit,
      'average_daily_cost': city.averageDailyCost,
      'seasonal_offer': seasonalOffer,
      'discount': discount,
      'special_activity': specialActivity,
      'best_for': bestFor,
      'temperature': temperature,
      'weather_icon': weatherIcon,
    };
  }
  
  /// Get the discounted price per day
  double get discountedDailyCost {
    return city.averageDailyCost * (1 - discount / 100);
  }
}
