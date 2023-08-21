import 'package:flutter/material.dart';

import 'menu_items.dart';

class GameEndWidget extends StatelessWidget {
  final Widget? onMenuTap;
  final VoidCallback? onPlayTap;
  const GameEndWidget({super.key, this.onMenuTap, this.onPlayTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withOpacity(0.6),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MenuItems(
            icon: Icons.restart_alt_rounded,
            text: 'Restart Again',
            function: onPlayTap,
          ),
          MenuItems(
            icon: Icons.menu,
            text: 'Main Menu',
            function: () => Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => onMenuTap!),
                (route) => false),
          ),
        ],
      ),
    );
  }
}
