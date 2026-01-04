import 'package:flutter/material.dart';

class NavButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final Color? color;

  const NavButton({
    super.key, 
    required this.icon, 
    required this.onPressed, 
    this.color
  });

  @override
  State<NavButton> createState() => _NavButtonState();
}

class _NavButtonState extends State<NavButton> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: _isHovering ? Colors.white.withOpacity(0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: IconButton(
          icon: Icon(widget.icon, color: widget.color ?? Theme.of(context).colorScheme.onSurface, size: 22),
          onPressed: widget.onPressed,
          splashRadius: 24,
        ),
      ),
    );
  }
}
