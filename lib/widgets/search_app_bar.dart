import 'package:flutter/material.dart';
import 'package:academia_unifor/screens.dart';

class SearchAppBar extends StatelessWidget implements PreferredSizeWidget {
  final ValueChanged<String>? onSearchChanged;
  final bool showChatIcon;
  final VoidCallback? onBack;

  const SearchAppBar({
    super.key,
    this.onSearchChanged,
    this.showChatIcon = true,
    this.onBack,
  });

  @override
  Size get preferredSize => const Size.fromHeight(56.0);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppBar(
      leading:
          onBack != null
              ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: onBack,
              )
              : null,
      backgroundColor: theme.colorScheme.primary,
      foregroundColor: theme.colorScheme.onPrimary,
      elevation: 1,
      centerTitle: false,
      title: SizedBox(
        height: 40,
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
            contentPadding: EdgeInsets.zero,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: BorderSide.none,
            ),
          ),
          style: TextStyle(color: theme.colorScheme.onPrimary),
        ),
      ),
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
}
