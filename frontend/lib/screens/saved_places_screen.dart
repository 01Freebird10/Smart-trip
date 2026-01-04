import 'package:flutter/material.dart';
import '../widgets/glass_container.dart';
import '../widgets/nav_button.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/city.dart';
import '../widgets/interactive_featured_card.dart';
import 'city_detail_screen.dart';

class SavedPlacesScreen extends StatefulWidget {
  const SavedPlacesScreen({super.key});

  @override
  State<SavedPlacesScreen> createState() => _SavedPlacesScreenState();
}

class _SavedPlacesScreenState extends State<SavedPlacesScreen> {
  late Box<String> _favoritesBox;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initHive();
  }

  Future<void> _initHive() async {
    _favoritesBox = Hive.box<String>('favorites');
    setState(() {
      _isInitialized = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    final theme = Theme.of(context);
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [theme.colorScheme.primary, theme.colorScheme.secondary],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(context),
              Expanded(child: _buildPlacesList(theme)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          NavButton(icon: Icons.arrow_back, onPressed: () => Navigator.pop(context)),
          const SizedBox(width: 16),
          const Text("Saved Places", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
        ],
      ),
    );
  }

  Widget _buildPlacesList(ThemeData theme) {
    return ValueListenableBuilder<Box<String>>(
      valueListenable: _favoritesBox.listenable(),
      builder: (context, box, _) {
        final savedNames = box.values.toList();
        if (savedNames.isEmpty) {
          return const Center(child: Text("No saved places yet", style: TextStyle(color: Colors.white60)));
        }

        return GridView.builder(
          padding: const EdgeInsets.all(20),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: MediaQuery.of(context).size.width > 1200 ? 4 : MediaQuery.of(context).size.width > 800 ? 3 : 1,
            childAspectRatio: 0.85,
            crossAxisSpacing: 20,
            mainAxisSpacing: 20,
          ),
          itemCount: savedNames.length,
          itemBuilder: (context, index) {
            final cityName = savedNames[index];
            final city = CityData.cities.firstWhere(
              (c) => c.name == cityName, 
              orElse: () => City(
                name: cityName, 
                country: 'Explore', 
                countryCode: '', 
                imageUrl: 'https://images.unsplash.com/photo-1469854523086-cc02fe5d8800?auto=format&fit=crop&w=800&q=80', 
                description: 'A beautiful place you saved for later.', 
                mustVisit: [], 
                averageDailyCost: 150
              )
            );

            return InteractiveFeaturedCard(
              city: city,
              isFavorite: true,
              onFavorite: () {
                final key = box.keys.firstWhere((k) => box.get(k) == cityName, orElse: () => null);
                if (key != null) box.delete(key);
              },
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CityDetailScreen(city: city)),
              ),
            );
          },
        );
      },
    );
  }
}
