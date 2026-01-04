import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/trip.dart';

class ChatScreen extends StatefulWidget {
  final Trip trip;
  final bool showAppBar;
  final String? currentUserEmail;
  
  const ChatScreen({
    super.key, 
    required this.trip,
    this.showAppBar = true,
    this.currentUserEmail,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  WebSocketChannel? _channel;
  final List<Map<String, dynamic>> _messages = [];

  @override
  void initState() {
    super.initState();
    _initChat();
  }

  void _initChat() async {
    final settingsBox = await Hive.openBox('settings');
    final token = settingsBox.get('auth_token');
    
    // In a real app, you'd get the current user's email from a BLoC or repository
    // For now, we'll try to identify "me" by the presence of our own messages if the backend sends it
    // Or we could pass it in. Let's assume we can get it from the settings/profile.
    
    final String wsUrl = 'ws://127.0.0.1:8000/ws/chat/${widget.trip.id}/?token=$token';
    _channel = WebSocketChannel.connect(Uri.parse(wsUrl));

    _channel!.stream.listen((data) {
      if (mounted) {
        setState(() {
          _messages.add(json.decode(data));
        });
        _scrollToBottom();
      }
    });
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: widget.showAppBar ? AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Chat: ${widget.trip.title}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text('${widget.trip.destination}', style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurface.withOpacity(0.6))),
          ],
        ),
        backgroundColor: theme.colorScheme.surface.withOpacity(0.8),
      ) : null,
      body: Column(
        children: [
          Expanded(
            child: _messages.isEmpty 
              ? _buildEmptyState()
              : ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
                    final msg = _messages[index];
                    bool isMe = msg['user'] == widget.currentUserEmail;
                    
                    return _buildMessageBubble(msg, isMe, theme);
                  },
                ),
          ),
          _buildInputArea(theme),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.chat_bubble_outline, size: 64, color: Colors.white24),
          const SizedBox(height: 16),
          Text(
            "No messages yet.\nStart the conversation!",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white38),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(Map<String, dynamic> msg, bool isMe, ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          gradient: isMe ? LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.colorScheme.primary,
              theme.colorScheme.primary.withAlpha(200),
            ],
          ) : null,
          color: isMe ? null : (isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.05)),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: Radius.circular(isMe ? 20 : 4),
            bottomRight: Radius.circular(isMe ? 4 : 20),
          ),
          boxShadow: isMe ? [
            BoxShadow(
              color: theme.colorScheme.primary.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            )
          ] : [],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isMe)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  msg['user'] ?? 'Anonymous',
                  style: TextStyle(
                    fontWeight: FontWeight.bold, 
                    fontSize: 11,
                    color: theme.colorScheme.secondary,
                  ),
                ),
              ),
            Text(
              msg['message'] ?? '',
              style: TextStyle(
                color: isMe ? Colors.white : Colors.white.withOpacity(0.9),
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputArea(ThemeData theme) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: Row(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(28),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: TextField(
                      controller: _controller,
                      style: const TextStyle(color: Colors.white, fontSize: 15),
                      decoration: const InputDecoration(
                        hintText: 'Share your thoughts...',
                        hintStyle: TextStyle(color: Colors.white38),
                        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        border: InputBorder.none,
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            TweenAnimationBuilder(
              duration: const Duration(milliseconds: 200),
              tween: Tween<double>(begin: 0.8, end: 1.0),
              builder: (context, value, child) => Transform.scale(
                scale: value,
                child: child,
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: theme.colorScheme.primary.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: IconButton(
                  onPressed: _sendMessage,
                  icon: const Icon(Icons.send_rounded, color: Colors.white, size: 22),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _sendMessage() {
    if (_controller.text.isNotEmpty && _channel != null) {
      _channel!.sink.add(json.encode({
        'message': _controller.text,
      }));
      _controller.clear();
      _scrollToBottom();
    }
  }

  @override
  void dispose() {
    _channel?.sink.close();
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
