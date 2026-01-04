import 'package:flutter/material.dart';
import '../widgets/glass_container.dart';
import '../widgets/nav_button.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  late Box _notifBox;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initHive();
  }

  Future<void> _initHive() async {
    _notifBox = await Hive.openBox('notifications');
    // No dummy notifications here, only real ones from backend
    if (_notifBox.isEmpty) {
      // Leave empty
    }
    setState(() => _isInitialized = true);
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
              Expanded(child: _buildNotifList(theme)),
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              NavButton(icon: Icons.arrow_back, onPressed: () => Navigator.pop(context)),
              const SizedBox(width: 16),
              const Text("Notifications", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
            ],
          ),
          TextButton(
            onPressed: () => _notifBox.clear(),
            child: const Text("Clear All", style: TextStyle(color: Colors.white70)),
          ),
        ],
      ),
    );
  }

  Widget _buildNotifList(ThemeData theme) {
    return ValueListenableBuilder(
      valueListenable: _notifBox.listenable(),
      builder: (context, Box box, _) {
        final entries = box.values.toList().reversed.toList();
        if (entries.isEmpty) {
          return const Center(child: Text("All caught up!", style: TextStyle(color: Colors.white60)));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: entries.length,
          itemBuilder: (context, index) {
            final entry = entries[index] as Map;
            final isRead = entry['read'] as bool;
            
            return GestureDetector(
              onTap: () {
                // Mark as read
                final updated = Map.from(entry);
                updated['read'] = true;
                box.putAt(box.length - 1 - index, updated);
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                child: GlassContainer(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(isRead ? 0.05 : 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          IconData(entry['icon'] as int, fontFamily: 'MaterialIcons'),
                          color: isRead ? Colors.white54 : Colors.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(entry['title'], 
                              style: TextStyle(
                                color: isRead ? Colors.white60 : Colors.white, 
                                fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
                                fontSize: 16
                              )),
                            Text(entry['message'], 
                              style: TextStyle(color: Colors.white54, fontSize: 13)),
                            const SizedBox(height: 4),
                            Text(entry['time'], style: const TextStyle(color: Colors.white24, fontSize: 11)),
                          ],
                        ),
                      ),
                      if (!isRead)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(color: Colors.blueAccent, shape: BoxShape.circle),
                        ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white12, size: 16),
                        onPressed: () => box.deleteAt(box.length - 1 - index),
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
}
