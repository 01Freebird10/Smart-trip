import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

import 'models/user.dart';
import 'models/trip.dart';
import 'models/itinerary_item.dart';
import 'models/message.dart';
import 'services/api_client.dart';
import 'repositories/auth_repository.dart';
import 'repositories/trip_repository.dart';
import 'repositories/poll_repository.dart';
import 'blocs/auth_bloc.dart';
import 'blocs/trip_bloc.dart';
import 'blocs/poll_bloc.dart';
import 'blocs/itinerary_bloc.dart';
import 'blocs/theme_bloc.dart';
import 'screens/home_screen.dart';
import 'screens/landing_screen.dart';
import 'screens/login_screen.dart';
import 'screens/initial_loading_screen.dart';
import 'screens/saved_places_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Hive.initFlutter();
  Hive.registerAdapter(UserAdapter());
  Hive.registerAdapter(TripAdapter());
  Hive.registerAdapter(ItineraryItemAdapter());
  Hive.registerAdapter(MessageAdapter());
  Hive.registerAdapter(CollaboratorAdapter());
  Hive.registerAdapter(BookingAdapter());
  
  final tripBox = await Hive.openBox<Trip>('trips_v2');
  final itineraryBox = await Hive.openBox<ItineraryItem>('itinerary');
  final settingsBox = await Hive.openBox('settings');
  await Hive.openBox<String>('favorites');
  
  final apiClient = ApiClient(settingsBox);
  final authRepository = AuthRepository(apiClient);
  final tripRepository = TripRepository(apiClient, tripBox, itineraryBox);
  final pollRepository = PollRepository(apiClient);
  final themeRepository = ThemeRepository(settingsBox);

  runApp(SmartTripApp(
    authRepository: authRepository,
    tripRepository: tripRepository,
    pollRepository: pollRepository,
    themeRepository: themeRepository,
  ));
}

class SmartTripApp extends StatefulWidget {
  final AuthRepository authRepository;
  final TripRepository tripRepository;
  final PollRepository pollRepository;
  final ThemeRepository themeRepository;

  const SmartTripApp({
    super.key,
    required this.authRepository,
    required this.tripRepository,
    required this.pollRepository,
    required this.themeRepository,
  });

  @override
  State<SmartTripApp> createState() => _SmartTripAppState();
}

class _SmartTripAppState extends State<SmartTripApp> {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: widget.authRepository),
        RepositoryProvider.value(value: widget.tripRepository),
        RepositoryProvider.value(value: widget.pollRepository),
        RepositoryProvider.value(value: widget.themeRepository),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(create: (context) => AuthBloc(widget.authRepository)..add(AuthCheckRequested())),
          BlocProvider(create: (context) => TripBloc(widget.tripRepository)),
          BlocProvider(create: (context) => PollBloc(widget.pollRepository)),
          BlocProvider(create: (context) => ItineraryBloc(widget.tripRepository)),
          BlocProvider(create: (context) => ThemeBloc(widget.themeRepository)),
        ],
        child: BlocListener<AuthBloc, AuthState>(
          listenWhen: (previous, current) => previous.runtimeType != current.runtimeType,
          listener: (context, state) {
            if (state is Authenticated) {
              _navigatorKey.currentState?.pushNamedAndRemoveUntil('/home', (route) => false);
            } else if (state is Unauthenticated) {
              _navigatorKey.currentState?.pushNamedAndRemoveUntil('/landing', (route) => false);
            }
          },
          child: BlocBuilder<ThemeBloc, ThemeState>(
            builder: (context, themeState) {
              final isDark = themeState.themeMode == ThemeMode.dark;
              final primary = themeState.primaryColor;
              
              return MaterialApp(
                title: 'Smart Trip Planner',
                navigatorKey: _navigatorKey,
                debugShowCheckedModeBanner: false,
                themeMode: themeState.themeMode,
                theme: ThemeData(
                  useMaterial3: true,
                  brightness: Brightness.light,
                  colorScheme: ColorScheme.fromSeed(
                    seedColor: primary,
                    primary: primary,
                    secondary: primary.withOpacity(0.7),
                    surface: const Color(0xFFF8F9FA),
                    onSurface: const Color(0xFF212529),
                    surfaceContainerHighest: const Color(0xFFE9ECEF),
                  ),
                  scaffoldBackgroundColor: const Color(0xFFF8F9FA),
                  fontFamily: GoogleFonts.outfit().fontFamily,
                  appBarTheme: AppBarTheme(
                    centerTitle: true,
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    titleTextStyle: GoogleFonts.outfit(color: const Color(0xFF212529), fontSize: 20, fontWeight: FontWeight.bold),
                    iconTheme: const IconThemeData(color: Color(0xFF212529)),
                  ),
                  textTheme: GoogleFonts.outfitTextTheme().apply(
                    bodyColor: const Color(0xFF212529),
                    displayColor: const Color(0xFF212529),
                  ),
                  elevatedButtonTheme: ElevatedButtonThemeData(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                darkTheme: ThemeData(
                  useMaterial3: true,
                  brightness: Brightness.dark,
                  colorScheme: ColorScheme.fromSeed(
                    seedColor: primary,
                    primary: primary,
                    secondary: primary.withOpacity(0.7),
                    surface: const Color(0xFF121212),
                    onSurface: Colors.white,
                    surfaceContainerHighest: const Color(0xFF1E1E1E),
                    brightness: Brightness.dark,
                  ),
                  scaffoldBackgroundColor: const Color(0xFF121212),
                  fontFamily: GoogleFonts.outfit().fontFamily,
                  appBarTheme: AppBarTheme(
                    centerTitle: true,
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    titleTextStyle: GoogleFonts.outfit(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                    iconTheme: const IconThemeData(color: Colors.white),
                  ),
                  textTheme: GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme).apply(
                    bodyColor: Colors.white,
                    displayColor: Colors.white,
                  ),
                  elevatedButtonTheme: ElevatedButtonThemeData(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                initialRoute: '/',
                routes: {
                  '/': (context) => const InitialLoadingScreen(),
                  '/landing': (context) => const LandingScreen(),
                  '/home': (context) => const HomeScreen(),
                  '/login': (context) => const LoginScreen(),
                  '/liked': (context) => const SavedPlacesScreen(),
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
