import 'package:flutter/material.dart';
import '../../../../shared/widgets/cards/app_card.dart';

class SettingsGroupCard extends StatelessWidget {
  final List<Widget> children;

  const SettingsGroupCard({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    List<Widget> divided = [];
    for (int i = 0; i < children.length; i++) {
      divided.add(children[i]);
      if (i < children.length - 1) {
        divided.add(Divider(
          height: 1,
          thickness: 1,
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
          indent: 72,
        ));
      }
    }

    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: divided,
      ),
    );
  }
}
