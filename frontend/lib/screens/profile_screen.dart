import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import '../blocs/auth_bloc.dart';
import '../blocs/theme_bloc.dart';
import '../models/user.dart';
import '../models/trip.dart';
import '../blocs/trip_bloc.dart';
import 'trip_detail_screen.dart';
import '../widgets/glass_container.dart';
import '../widgets/nav_button.dart';
import '../widgets/universal_image_picker.dart';
import 'wallet_screen.dart';
import 'change_password_screen.dart';
import 'notifications_screen.dart';
import 'trip_memories_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _showDetails = false;
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        final theme = Theme.of(context);
        return DefaultTabController(
          length: 2,
          child: BlocListener<AuthBloc, AuthState>(
            listener: (context, state) {
              if (state is AuthError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.message), backgroundColor: Colors.redAccent),
                );
              }
            },
            child: Scaffold(
            extendBodyBehindAppBar: true,
            appBar: AppBar(
              title: const Text(
                "Account Settings",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.white),
              ),
              centerTitle: true,
              leading: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: NavButton(
                  icon: Icons.arrow_back,
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              backgroundColor: Colors.transparent,
              elevation: 0,
              actions: [
                MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: NavButton(
                    icon: Icons.wb_sunny_outlined,
                    onPressed: () => _showAppearanceDialog(context),
                  ),
                ),
              ],
              bottom: const TabBar(
                tabs: [
                  Tab(text: "Profile"),
                  Tab(text: "My Adventures"),
                ],
                indicatorColor: Colors.white,
                indicatorWeight: 3,
                labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                unselectedLabelStyle: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white70,
              ),
            ),
            body: BlocBuilder<AuthBloc, AuthState>(
              builder: (context, state) {
                if (state is Authenticated) {
                  return _buildContent(context, state.user, theme);
                } else if (state is AuthLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is AuthError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(state.message, style: const TextStyle(color: Colors.white)),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text("Go Back"),
                        ),
                      ],
                    ),
                  );
                }
                return const Center(child: CircularProgressIndicator());
              },
            ),
          ),
        ),
      );
    },
  );
}

  Widget _buildContent(BuildContext context, User user, ThemeData theme) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [theme.colorScheme.primary, theme.colorScheme.secondary],
        ),
      ),
      child: TabBarView(
        children: [
          // Tab 1: Profile General
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const SizedBox(height: 160),
                _buildAvatar(context, user),
                const SizedBox(height: 24),
                Text(
                  "${user.firstName} ${user.lastName}".trim(),
                  style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 12),
                
                // Dropdown Toggle for User Details
                MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: () => setState(() => _showDetails = !_showDetails),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white.withOpacity(0.2)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            "Show Profile Details",
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                          const SizedBox(width: 8),
                          AnimatedRotation(
                            turns: _showDetails ? 0.5 : 0,
                            duration: const Duration(milliseconds: 300),
                            child: const Icon(Icons.keyboard_arrow_down, color: Colors.white, size: 20),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),
                
                // Expandable Details Section
                AnimatedCrossFade(
                  firstChild: const SizedBox(width: double.infinity),
                  secondChild: Column(
                    children: [
                      if (user.age != null || (user.gender != null && user.gender!.isNotEmpty) || (user.phoneNumber != null && user.phoneNumber!.isNotEmpty))
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Wrap(
                            spacing: 8,
                            alignment: WrapAlignment.center,
                            children: [
                              if (user.age != null)
                                _buildDetailChip(Icons.cake, "${user.age} yrs"),
                              if (user.gender != null && user.gender!.isNotEmpty)
                                _buildDetailChip(user.gender!.toLowerCase() == 'male' ? Icons.male : user.gender!.toLowerCase() == 'female' ? Icons.female : Icons.person, user.gender!),
                              if (user.phoneNumber != null && user.phoneNumber!.isNotEmpty)
                                _buildDetailChip(Icons.phone, user.phoneNumber!),
                            ],
                          ),
                        ),
                      if (user.address != null && user.address!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.location_on, color: Colors.white70, size: 14),
                              const SizedBox(width: 4),
                              Text(
                                user.address!,
                                style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.8)),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  crossFadeState: _showDetails ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                  duration: const Duration(milliseconds: 300),
                ),
                const SizedBox(height: 32),
                _buildStats(context),
                const SizedBox(height: 32),
                _buildSectionTitle(context, 'Account Settings'),
                const SizedBox(height: 16),
                GlassContainer(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Column(
                    children: [
                      _buildProfileItem(context, Icons.person_outline, 'Edit Profile', onTap: () => _showEditProfileDialog(context, user)),
                      _buildProfileItem(context, Icons.wallet_outlined, 'My Wallet', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const WalletScreen()))),
                      _buildProfileItem(context, Icons.auto_awesome_outlined, 'Trip Memories', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TripMemoriesScreen()))),
                      Divider(color: Colors.white.withOpacity(0.1), indent: 20, endIndent: 20),
                      _buildProfileItem(context, Icons.lock_outline, 'Change Password', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ChangePasswordScreen()))),
                      _buildProfileItem(context, Icons.notifications_none, 'Notifications', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsScreen()))),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                _buildLogoutButton(context),
                const SizedBox(height: 60),
              ],
            ),
          ),
          // Tab 2: My Adventures
          Padding(
            padding: const EdgeInsets.only(top: 160),
            child: _buildTripsTab(context),
          ),
        ],
      ),
    );
  }

  Widget _buildTripsTab(BuildContext context) {
    return BlocBuilder<TripBloc, TripState>(
      builder: (context, state) {
        if (state is TripInitial) {
          context.read<TripBloc>().add(LoadTrips());
          return const Center(child: CircularProgressIndicator());
        }
        
        if (state is TripLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is TripError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Colors.redAccent, size: 48),
                const SizedBox(height: 16),
                Text(state.message, style: const TextStyle(color: Colors.white70), textAlign: TextAlign.center),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => context.read<TripBloc>().add(LoadTrips()),
                  child: const Text("Retry"),
                ),
              ],
            ),
          );
        }

        if (state is TripsLoaded) {
          if (state.trips.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.map_outlined, color: Colors.white24, size: 64),
                  const SizedBox(height: 16),
                  Text("No adventures yet!", style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 18)),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => Navigator.pop(context), // Go back home to add trip
                    icon: const Icon(Icons.add),
                    label: const Text("Start Planning"),
                  ),
                ],
              ),
            );
          }
          // ... rest of the list builder
          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            itemCount: state.trips.length,
            itemBuilder: (context, index) {
              final trip = state.trips[index];
              return Container(
                key: ValueKey('profile_trip_${trip.id}_${trip.imageUrl}'),
                margin: const EdgeInsets.only(bottom: 16),
                child: GlassContainer(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Builder(
                          builder: (context) {
                            String? imageUrl = trip.imageUrl;
                            if (imageUrl != null && imageUrl.isNotEmpty) {
                              if (imageUrl.startsWith('/')) {
                                imageUrl = "http://127.0.0.1:8000$imageUrl";
                              } else if (!imageUrl.startsWith('http') && !imageUrl.startsWith('data:image')) {
                                imageUrl = "http://127.0.0.1:8000/media/$imageUrl";
                              }
                              if (imageUrl.startsWith('http')) {
                                imageUrl = "$imageUrl?v=${imageUrl.length}";
                              }
                            }
                            
                            return (imageUrl != null && imageUrl.startsWith('data:image'))
                              ? Image.memory(
                                  base64Decode(imageUrl.split(',').last),
                                  width: 60, height: 60, fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(width: 60, height: 60, color: Colors.white10),
                                )
                              : Image.network(
                                  imageUrl != null && imageUrl.isNotEmpty
                                    ? imageUrl
                                    : "https://picsum.photos/seed/${trip.id}/100/100",
                                  width: 60,
                                  height: 60,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(width: 60, height: 60, color: Colors.white10),
                                );
                          }
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(trip.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                            Text(trip.destination, style: TextStyle(color: Colors.white70, fontSize: 13)),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                        tooltip: "Delete Adventure",
                        onPressed: () => _showDeleteTripDialog(context, trip),
                      ),
                      IconButton(
                        icon: const Icon(Icons.arrow_forward_ios, color: Colors.white24, size: 16),
                        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => TripDetailScreen(trip: trip))),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: ElevatedButton(
        onPressed: () => context.read<AuthBloc>().add(LogoutRequested()),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.redAccent.withOpacity(0.1),
          foregroundColor: Colors.redAccent,
          padding: const EdgeInsets.symmetric(vertical: 16),
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 0,
          side: BorderSide(color: Colors.redAccent.withOpacity(0.3)),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.logout),
            SizedBox(width: 8),
            Text('Log Out', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar(BuildContext context, User user) {
    ImageProvider? imageProvider;
    if (user.profilePicture != null && user.profilePicture!.isNotEmpty) {
      if (user.profilePicture!.startsWith('data:image')) {
        final commaIndex = user.profilePicture!.indexOf(',');
        if (commaIndex != -1) {
          imageProvider = MemoryImage(base64Decode(user.profilePicture!.substring(commaIndex + 1)));
        }
      } else {
        String url = user.profilePicture!;
        if (url.startsWith('/')) {
          url = "http://127.0.0.1:8000$url";
        } else if (!url.startsWith('http')) {
          url = "http://127.0.0.1:8000/media/$url";
        }
        imageProvider = NetworkImage("$url?v=${url.length}");
      }
    }

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => _showEditProfileDialog(context, user),
        child: Stack(
          alignment: Alignment.bottomRight,
          children: [
            Container(
              key: ValueKey('profile_pic_${user.profilePicture?.length ?? 0}_${user.profilePicture.hashCode}'),
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: CircleAvatar(
                radius: 60,
                backgroundColor: Colors.white24,
                backgroundImage: imageProvider,
                child: imageProvider == null
                  ? Text(_getInitials(user.firstName, user.lastName), style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white))
                  : null,
              ),
            ),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
              child: const Icon(Icons.mode_edit_outline_outlined, color: Colors.black, size: 20),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStats(BuildContext context) {
    return BlocBuilder<TripBloc, TripState>(
      builder: (context, state) {
        int tripsCount = 0;
        int placesCount = 0;
        int friendsCount = 0;

        if (state is TripsLoaded) {
          tripsCount = state.trips.length;
          // Count unique destinations
          placesCount = state.trips.map((t) => t.destination).toSet().length;
          
          // Count unique friends (collaborators)
          final friendEmails = <String>{};
          for (var trip in state.trips) {
            if (trip.collaborators != null) {
              for (var c in trip.collaborators!) {
                if (c.user?.email != null) friendEmails.add(c.user!.email);
              }
            }
          }
          friendsCount = friendEmails.length;
        }

        return GlassContainer(
          padding: const EdgeInsets.all(20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _StatItem(value: "$tripsCount", label: "Trips"),
              _StatItem(value: "$placesCount", label: "Places"),
              _StatItem(value: "$friendsCount", label: "Friends"),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title, 
        style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)
      ),
    );
  }

  Widget _buildProfileItem(BuildContext context, IconData icon, String title, {VoidCallback? onTap}) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: ListTile(
        leading: Icon(icon, color: Colors.white70, size: 24),
        title: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
        trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white24, size: 14),
        onTap: onTap,
      ),
    );
  }

  void _showAppearanceDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return BlocBuilder<ThemeBloc, ThemeState>(
          builder: (context, themeState) {
            return AlertDialog(
              backgroundColor: Colors.transparent,
              contentPadding: EdgeInsets.zero,
              content: GlassContainer(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text("App Style", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                    const SizedBox(height: 24),
                    const Text("Choose Primary Color", style: TextStyle(color: Colors.white70)),
                    const SizedBox(height: 16),
                    ColorPicker(
                      pickerColor: themeState.primaryColor,
                      onColorChanged: (color) => context.read<ThemeBloc>().add(ChangePrimaryColor(color)),
                      pickerAreaHeightPercent: 0.8,
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Dark Mode", style: TextStyle(color: Colors.white)),
                        Switch(
                          value: themeState.themeMode == ThemeMode.dark,
                          onChanged: (_) => context.read<ThemeBloc>().add(ToggleTheme()),
                          activeColor: themeState.primaryColor,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () {
                          context.read<ThemeBloc>().add(ChangePrimaryColor(const Color(0xFF0091EA)));
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: Colors.white24),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text("Reset to Default"),
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text("Done"),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showEditProfileDialog(BuildContext context, User user) {
    final firstNameController = TextEditingController(text: user.firstName);
    final lastNameController = TextEditingController(text: user.lastName);
    final bioController = TextEditingController(text: user.bio);
    final ageController = TextEditingController(text: user.age?.toString() ?? "");
    final addressController = TextEditingController(text: user.address ?? "");
    final phoneController = TextEditingController(text: user.phoneNumber ?? "");
    String? selectedGender = user.gender;
    if (selectedGender == null || selectedGender.isEmpty) selectedGender = null;
    
    String currentAvatar = user.profilePicture ?? "";

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: Colors.transparent,
              contentPadding: EdgeInsets.zero,
              content: GlassContainer(
                padding: const EdgeInsets.all(24),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text("Edit Profile", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                      const SizedBox(height: 24),
                      UniversalImagePicker(
                        initialImage: currentAvatar,
                        label: "Choose Profile Photo",
                        onImageSelected: (base64) => setDialogState(() => currentAvatar = base64),
                      ),
                      if (currentAvatar.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        TextButton.icon(
                          onPressed: () => setDialogState(() => currentAvatar = ""),
                          icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 18),
                          label: const Text("Remove Photo", style: TextStyle(color: Colors.redAccent, fontSize: 13)),
                        ),
                      ],
                      const SizedBox(height: 16),
                      _buildField(firstNameController, "First Name", Icons.person),
                      const SizedBox(height: 16),
                      _buildField(lastNameController, "Last Name", Icons.person_outline),
                      const SizedBox(height: 16),
                      _buildField(bioController, "Bio", Icons.article_outlined, maxLines: 2),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(child: _buildField(ageController, "Age", Icons.cake, keyboardType: TextInputType.number)),
                          const SizedBox(width: 16),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: selectedGender,
                              dropdownColor: Colors.grey[900],
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                labelText: "Gender",
                                labelStyle: const TextStyle(color: Colors.white70),
                                prefixIcon: const Icon(Icons.people_outline, color: Colors.white70),
                                filled: true,
                                fillColor: Colors.white.withOpacity(0.05),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                              ),
                              items: ["Male", "Female", "Other"].map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
                              onChanged: (val) => setDialogState(() => selectedGender = val),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildField(phoneController, "Phone Number", Icons.phone, keyboardType: TextInputType.phone),
                      const SizedBox(height: 16),
                      _buildField(addressController, "Address", Icons.location_on, maxLines: 2),
                      const SizedBox(height: 32),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel", style: TextStyle(color: Colors.white70))),
                          const SizedBox(width: 16),
                          MouseRegion(
                            cursor: SystemMouseCursors.click,
                            child: ElevatedButton(
                              onPressed: () {
                                context.read<AuthBloc>().add(UpdateProfileRequested(
                                  firstName: firstNameController.text, 
                                  lastName: lastNameController.text,
                                  bio: bioController.text,
                                  profilePicture: currentAvatar,
                                  age: int.tryParse(ageController.text),
                                  address: addressController.text,
                                  phoneNumber: phoneController.text,
                                  gender: selectedGender,
                                ));
                                Navigator.pop(context);
                              },
                              child: const Text("Apply Changes"),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showDeleteTripDialog(BuildContext context, Trip trip) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text("Delete Adventure", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: Text("Are you sure you want to delete \"${trip.title}\"?", style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel", style: TextStyle(color: Colors.white38)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, foregroundColor: Colors.white),
            onPressed: () {
              context.read<TripBloc>().add(DeleteTrip(trip.id));
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Adventure deleted successfully")),
              );
            },
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }

  Widget _buildField(TextEditingController controller, String label, IconData icon, {int maxLines = 1, TextInputType keyboardType = TextInputType.text}) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        prefixIcon: Icon(icon, color: Colors.white70),
        suffixIcon: const Icon(Icons.edit, color: Colors.white30, size: 16),
        filled: true,
        fillColor: Colors.white.withOpacity(0.05),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      ),
    );
  }

  Widget _buildDetailChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white70, size: 14),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  String _getInitials(String? firstName, String? lastName) {
    String initials = "";
    if (firstName != null && firstName.isNotEmpty) initials += firstName[0].toUpperCase();
    if (lastName != null && lastName.isNotEmpty) initials += lastName[0].toUpperCase();
    return initials.isEmpty ? "?" : initials;
  }
}

class _StatItem extends StatelessWidget {
  final String value;
  final String label;
  const _StatItem({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
        Text(label, style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 13)),
      ],
    );
  }
}
