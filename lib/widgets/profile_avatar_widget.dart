import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProfileAvatar extends ConsumerWidget {
  final String avatarUrl;
  final bool isEditing;
  final Function(String)? onAvatarChanged;
  const ProfileAvatar({
    super.key,
    required this.avatarUrl,
    this.isEditing = false,
    this.onAvatarChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: GestureDetector(
        onTap: () => _showEditAvatarDialog(context),
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: Theme.of(context).scaffoldBackgroundColor,
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color:
                    isDarkMode
                        ? const Color.fromARGB(82, 255, 255, 255)
                        : const Color.fromRGBO(0, 0, 0, 0.2),
                blurRadius: 8,
                spreadRadius: 2,
              ),
            ],
          ),
          child: CircleAvatar(
            radius: 70,
            backgroundImage: NetworkImage(avatarUrl),
            child:
                avatarUrl.isEmpty
                    ? const Icon(Icons.add_a_photo, size: 40)
                    : null,
          ),
        ),
      ),
    );
  }

  Future<void> _showEditAvatarDialog(BuildContext context) async {
    if (!isEditing) return;

    final controller = TextEditingController(text: avatarUrl);

    final newUrl = await showDialog<String>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Editar Foto de Perfil'),
            content: TextField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: 'URL da imagem',
                hintText: 'https://exemplo.com/foto.jpg',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.url,
            ),
            actions: [
              TextButton(
                style: TextButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                ),
                onPressed: () {
                  if (controller.text.trim().isNotEmpty) {
                    Navigator.pop(context, controller.text.trim());
                  }
                },
                child: const Text('Salvar'),
              ),
            ],
          ),
    );

    if (newUrl != null && onAvatarChanged != null) {
      onAvatarChanged!(newUrl);
    }
  }
}
