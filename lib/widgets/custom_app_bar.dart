import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:academia_unifor/assets/unifor_logo.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  @override
  final Size preferredSize;

  final bool showNotificationIcon;

  const CustomAppBar({super.key, this.showNotificationIcon = true})
    : preferredSize = const Size.fromHeight(56.0);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppBar(
      backgroundColor: theme.colorScheme.primary,
      elevation: 1,
      titleSpacing: 0,
      centerTitle: false,
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 40,
            width: 120,
            child: SvgPicture.string(
              uniforLogoSVG,
              fit: BoxFit.contain,
              colorFilter: ColorFilter.mode(
                theme.colorScheme.onPrimary,
                BlendMode.srcIn,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            "Academia",
            style: TextStyle(
              color: theme.colorScheme.onPrimary,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      actions:
          showNotificationIcon
              ? [
                IconButton(
                  icon: Icon(
                    Icons.notifications,
                    color: theme.colorScheme.onPrimary,
                  ),
                  onPressed: () {},
                ),
              ]
              : null,
    );
  }
}
