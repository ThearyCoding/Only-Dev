import 'package:flutter/material.dart';
import 'package:badges/badges.dart' as badges;

class TabItem extends StatelessWidget {
  final String title;
  final int count;

  const TabItem({super.key, required this.title, required this.count});

  @override
  Widget build(BuildContext context) {
    return Tab(
      child: Row(
        children: [
          Text(
            title,
            overflow: TextOverflow.ellipsis,
          ),
          if (count > 0)
            badges.Badge(
              badgeContent: Text(
                count > 9 ? "9+" : count.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                ),
              ),
              badgeStyle: const badges.BadgeStyle(
                badgeColor: Colors.red,
                elevation: 0,
                padding: EdgeInsets.all(4),
                shape: badges.BadgeShape.circle,
              ),
              position: badges.BadgePosition.topEnd(top: -5, end: -10),
            ),
        ],
      ),
    );
  }
}
