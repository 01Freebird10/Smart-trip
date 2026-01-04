import '../models/city.dart';

class CurrencyUtils {
  static String getSymbol(String cityName) {
    final city = CityData.cities.firstWhere(
      (c) => c.name.toLowerCase() == cityName.toLowerCase(),
      orElse: () => const City(
        name: '',
        country: '',
        countryCode: 'US',
        imageUrl: '',
        description: '',
        mustVisit: [],
        averageDailyCost: 0,
      ),
    );
    return city.currencySymbol;
  }

  static double convert(double usdAmount, String cityName) {
    final city = CityData.cities.firstWhere(
      (c) => c.name.toLowerCase() == cityName.toLowerCase(),
      orElse: () => const City(
        name: '',
        country: '',
        countryCode: 'US',
        imageUrl: '',
        description: '',
        mustVisit: [],
        averageDailyCost: 0,
      ),
    );
    
    // Using the same logic as in City model but adapted for arbitrary amounts
    switch (city.countryCode.toUpperCase()) {
      case 'IN': return usdAmount * 83.0;
      case 'JP': return usdAmount * 150.0;
      case 'AE': return usdAmount * 3.67;
      case 'TH': return usdAmount * 35.0;
      case 'ID': return usdAmount * 15600.0;
      case 'GB': return usdAmount * 0.79;
      case 'TR': return usdAmount * 31.0;
      case 'KR': return usdAmount * 1330.0;
      case 'VN': return usdAmount * 24500.0;
      case 'PH': return usdAmount * 56.0;
      case 'BR': return usdAmount * 5.0;
      case 'FR':
      case 'IT':
      case 'ES':
      case 'NL':
      case 'GR':
      case 'AT':
      case 'DE':
      case 'PT':
      case 'IE':
      case 'FI': return usdAmount * 0.92;
      default: return usdAmount;
    }
  }

  static String format(double usdAmount, String cityName) {
    final symbol = getSymbol(cityName);
    final amount = convert(usdAmount, cityName);
    
    // Different formatting for high value currencies vs low value
    if (amount > 1000) {
      return "$symbol${amount.toStringAsFixed(0)}";
    } else {
      return "$symbol${amount.toStringAsFixed(0)}";
    }
  }
}
