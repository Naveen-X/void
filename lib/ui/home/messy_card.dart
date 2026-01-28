import 'dart:math';
import 'package:flutter/material.dart';
import '../../data/models/void_item.dart';

class MessyCard extends StatelessWidget {
  final VoidItem item;

  const MessyCard({
    super.key,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    final rnd = Random(item.id.hashCode);
    final offset = rnd.nextDouble() * 14 - 7;
    final padding = 12 + rnd.nextDouble() * 6;

    return Transform.translate(
      offset: Offset(0, offset),
      child: Container(
        padding: EdgeInsets.all(padding),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.6),
              blurRadius: 18,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: _content(),
      ),
    );
  }

  Widget _content() {
    // Future-proof: different layouts per type
    switch (item.type) {
      case 'link':
        return Text(
          item.title,
          maxLines: 4,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Colors.white70,
            fontWeight: FontWeight.w500,
            height: 1.3,
          ),
        );

      default:
        return Text(
          item.content,
          maxLines: 6,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Colors.white60,
            height: 1.4,
          ),
        );
    }
  }
}
