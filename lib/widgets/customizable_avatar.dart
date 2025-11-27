import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CustomizableAvatar extends StatelessWidget {
  final String hairStyle;
  final Color hairColor;
  final bool hasBeard;
  final double radius;

  const CustomizableAvatar({
    super.key,
    required this.hairStyle,
    required this.hairColor,
    required this.hasBeard,
    this.radius = 40,
  });

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: Colors.grey[200],
      child: ClipOval(
        child: Stack(
          children: [
            SvgPicture.asset(
              'assets/avatar_layers/base/base.svg',
              width: radius * 2,
              height: radius * 2,
            ),
            ColorFiltered(
              colorFilter: ColorFilter.mode(hairColor, BlendMode.srcIn),
              child: SvgPicture.asset(
                'assets/avatar_layers/hair/$hairStyle.svg',
                width: radius * 2,
                height: radius * 2,
              ),
            ),
            if (hasBeard)
              ColorFiltered(
                colorFilter: ColorFilter.mode(hairColor, BlendMode.srcIn),
                child: SvgPicture.asset(
                  'assets/avatar_layers/beard/beard.svg',
                  width: radius * 2,
                  height: radius * 2,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
