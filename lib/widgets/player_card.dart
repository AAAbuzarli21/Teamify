import 'package:flutter/material.dart';
import '../models/player.dart';
import '../theme/theme.dart';
import './customizable_avatar.dart';

class PlayerCard extends StatefulWidget {
  final Player player;
  final bool isSelected;

  const PlayerCard(
      {super.key,
      required this.player,
      this.isSelected = false,
      void Function()? onTap});

  @override
  State<PlayerCard> createState() => _PlayerCardState();
}

class _PlayerCardState extends State<PlayerCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0.0, 0.5), end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CustomizableAvatar(
                  hairStyle: widget.player.hairStyle,
                  hairColor: widget.player.hairColor,
                  hasBeard: widget.player.hasBeard,
                  radius: 30,
                ),
                const SizedBox(height: 8),
                Text(
                  '${widget.player.name} ${widget.player.surname}',
                  style: theme.textTheme.titleLarge?.copyWith(fontSize: 18),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                _buildSkillStars(widget.player.skillLevel),
                const SizedBox(height: 10),
                _buildPositionTag(theme),
                const SizedBox(height: 12),
                _buildAttributesRow(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPositionTag(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: accentNeonGreen.withAlpha(51), // 20% opacity
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: accentNeonGreen, width: 1),
      ),
      child: Text(
        widget.player.preferredPositions.isNotEmpty
            ? widget.player.preferredPositions.first.toUpperCase()
            : 'N/A',
        style: theme.textTheme.bodyMedium?.copyWith(
          color: accentNeonGreen,
          fontWeight: FontWeight.bold,
          fontSize: 10,
        ),
      ),
    );
  }

  Widget _buildSkillStars(SkillLevel skillLevel) {
    int starCount;
    switch (skillLevel) {
      case SkillLevel.intermediate:
        starCount = 2;
        break;
      case SkillLevel.pro:
        starCount = 3;
        break;
      case SkillLevel.beginner:
        starCount = 1;
        break;
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        3,
        (index) => Icon(
          index < starCount ? Icons.star_rounded : Icons.star_border_rounded,
          color: index < starCount
              ? accentOrange
              : Colors.grey.withAlpha(128), // 50% opacity
          size: 18,
        ),
      ),
    );
  }

  Widget _buildAttributesRow() {
    return IntrinsicHeight(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildAttribute('ATT', widget.player.attributes.attack),
          const VerticalDivider(color: Colors.white24, indent: 4, endIndent: 4),
          _buildAttribute('DEF', widget.player.attributes.defense),
          const VerticalDivider(color: Colors.white24, indent: 4, endIndent: 4),
          _buildAttribute('SPD', widget.player.attributes.speed),
        ],
      ),
    );
  }

  Widget _buildAttribute(String label, int value) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: Colors.white.withAlpha(153), // 60% opacity
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value.toString(),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: accentTurquoise,
          ),
        ),
      ],
    );
  }
}
