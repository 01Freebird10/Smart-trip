import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/memory.dart';
import '../widgets/glass_container.dart';
import '../widgets/nav_button.dart';
import '../widgets/universal_image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';

class TripMemoriesScreen extends StatefulWidget {
  const TripMemoriesScreen({super.key});

  @override
  State<TripMemoriesScreen> createState() => _TripMemoriesScreenState();
}

class _TripMemoriesScreenState extends State<TripMemoriesScreen> {
  late Box _memoryBox;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initHive();
  }

  Future<void> _initHive() async {
    _memoryBox = await Hive.openBox('memories_box');
    setState(() => _isInitialized = true);
  }

  void _addMemory() {
    _showMemoryDialog();
  }

  void _showMemoryDialog({Memory? memory, int? index}) {
    final titleController = TextEditingController(text: memory?.title);
    final contentController = TextEditingController(text: memory?.content);
    String selectedImage = memory?.imageUrl ?? "";

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.transparent,
        contentPadding: EdgeInsets.zero,
        content: GlassContainer(
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(memory == null ? "Capture Memory" : "Edit Memory", style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 24),
                UniversalImagePicker(
                  initialImage: selectedImage,
                  onImageSelected: (base64) => selectedImage = base64,
                ),
                const SizedBox(height: 16),
                _buildField(titleController, "Title", Icons.title),
                const SizedBox(height: 16),
                _buildField(contentController, "Note", Icons.note_alt_outlined, maxLines: 3),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel", style: TextStyle(color: Colors.white70))),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: () {
                        if (titleController.text.isNotEmpty) {
                          if (memory == null) {
                            final newMemory = Memory(
                              id: DateTime.now().millisecondsSinceEpoch.toString(),
                              tripId: "general",
                              title: titleController.text,
                              content: contentController.text,
                              imageUrl: selectedImage,
                              createdAt: DateTime.now(),
                            );
                            _memoryBox.add(newMemory.toMap());
                          } else if (index != null) {
                            final updated = memory.copyWith(
                              title: titleController.text,
                              content: contentController.text,
                              imageUrl: selectedImage,
                            );
                            _memoryBox.putAt(index, updated.toMap());
                          }
                          setState(() {});
                          Navigator.pop(context);
                        }
                      },
                      child: Text(memory == null ? "Save" : "Update"),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField(TextEditingController controller, String label, IconData icon, {int maxLines = 1}) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        prefixIcon: Icon(icon, color: Colors.white70),
        filled: true,
        fillColor: Colors.white.withOpacity(0.05),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    final memoryMaps = _memoryBox.values.toList();
    final memories = memoryMaps.map((m) => Memory.fromMap(m as Map)).toList().reversed.toList();

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        leading: NavButton(icon: Icons.arrow_back, onPressed: () => Navigator.pop(context)),
        title: const Text("Trip Memories", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Theme.of(context).colorScheme.primary, Theme.of(context).colorScheme.secondary],
          ),
        ),
        child: memories.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.photo_library_outlined, size: 80, color: Colors.white.withOpacity(0.2)),
                    const SizedBox(height: 16),
                    const Text("No memories yet.", style: TextStyle(color: Colors.white70, fontSize: 18)),
                    const Text("Start capturing your journey!", style: TextStyle(color: Colors.white38)),
                  ],
                ),
              )
            : LayoutBuilder(
                builder: (context, constraints) {
                  final crossAxisCount = constraints.maxWidth > 1200 ? 5 : constraints.maxWidth > 800 ? 3 : 2;
                  return GridView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 120, 20, 20),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      childAspectRatio: 0.85,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: memories.length,
                    itemBuilder: (context, index) {
                      final originalIndex = _memoryBox.length - 1 - index;
                      final memory = memories[index];
                      return _MemoryCard(
                        memory: memory,
                        onEdit: () => _showMemoryDialog(memory: memory, index: originalIndex),
                        onDelete: () {
                          _memoryBox.deleteAt(originalIndex);
                          setState(() {});
                        },
                      );
                    },
                  );
                },
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addMemory,
        backgroundColor: Colors.white,
        foregroundColor: Theme.of(context).colorScheme.primary,
        child: const Icon(Icons.add_a_photo_rounded),
      ),
    );
  }
}

class _MemoryCard extends StatelessWidget {
  final Memory memory;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _MemoryCard({required this.memory, required this.onEdit, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    ImageProvider? imageProvider;
    if (memory.imageUrl != null && memory.imageUrl!.isNotEmpty) {
      if (memory.imageUrl!.startsWith('data:image')) {
        final commaIndex = memory.imageUrl!.indexOf(',');
        if (commaIndex != -1) {
          imageProvider = MemoryImage(base64Decode(memory.imageUrl!.substring(commaIndex + 1)));
        }
      } else {
        imageProvider = CachedNetworkImageProvider(memory.imageUrl!);
      }
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.15)),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 10, offset: const Offset(0, 5)),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AspectRatio(
                aspectRatio: 16 / 9,
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    image: imageProvider != null ? DecorationImage(image: imageProvider, fit: BoxFit.cover) : null,
                  ),
                  child: imageProvider == null ? Icon(Icons.image_outlined, color: Colors.white.withOpacity(0.2), size: 32) : null,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(memory.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16), maxLines: 1, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 4),
                    if (memory.content != null && memory.content!.isNotEmpty)
                      Text(memory.content!, style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 11), maxLines: 2, overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
            ],
          ),
          Positioned(
            top: 10,
            right: 10,
            child: Row(
              children: [
                _actionBtn(Icons.edit_rounded, onEdit),
                const SizedBox(width: 6),
                _actionBtn(Icons.delete_forever_rounded, onDelete, color: Colors.redAccent.withOpacity(0.8)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionBtn(IconData icon, VoidCallback onTap, {Color color = Colors.white}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.4),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white10),
        ),
        child: Icon(icon, color: color, size: 16),
      ),
    );
  }
}
