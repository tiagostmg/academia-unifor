import 'package:academia_unifor/screens.dart';
import 'package:flutter/material.dart';

class SearchAppBar extends StatelessWidget implements PreferredSizeWidget {
  final ValueChanged<String>? onSearchChanged;
  final bool showChatIcon;

  const SearchAppBar({
    super.key,
    this.onSearchChanged,
    this.showChatIcon = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppBar(
      backgroundColor: theme.colorScheme.primary,
      foregroundColor: theme.colorScheme.onPrimary,
      surfaceTintColor: theme.colorScheme.primary,
      title: SizedBox(
        height: 45,
        child: TextField(
          onChanged: onSearchChanged,
          decoration: InputDecoration(
            hintText: 'Buscar...',
            hintStyle: TextStyle(
              color: theme.colorScheme.onPrimary.withAlpha(153),
            ),
            prefixIcon: Icon(
              Icons.search,
              color: theme.colorScheme.onPrimary.withAlpha(179),
            ),
            filled: true,
            fillColor: theme.colorScheme.surface,
            contentPadding: const EdgeInsets.symmetric(vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: BorderSide.none,
            ),
          ),
          style: TextStyle(color: theme.colorScheme.onPrimary),
        ),
      ),
      centerTitle: false,
      actions:
          showChatIcon
              ? [
                IconButton(
                  icon: Icon(Icons.chat, color: theme.colorScheme.onPrimary),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ChatScreen()),
                    );
                  },
                ),
              ]
              : null,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
