import 'package:academia_unifor/models/equipment.dart';
import 'package:flutter/material.dart';

class SelectedCategoryList extends StatelessWidget {
  final String selectedCategory;
  final List<EquipmentItem> items;
  final VoidCallback onBack;
  final Widget Function() fallbackImage;
  final bool isEditMode;
  final void Function(EquipmentItem)? onItemTap; 

  const SelectedCategoryList({
    required this.selectedCategory,
    required this.items,
    required this.onBack,
    required this.fallbackImage,
    this.isEditMode = true,
    this.onItemTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: items.length,
          separatorBuilder: (_, __) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            final item = items[index];
            return GestureDetector(
              onTap: () {
                if (!isEditMode) {
                  if (onItemTap != null) {
                    onItemTap!(item);
                  }
                  return;
                }

                
                TextEditingController nameController = TextEditingController(text: item.name);
                TextEditingController brandController = TextEditingController(text: item.brand);
                TextEditingController modelController = TextEditingController(text: item.model);
                TextEditingController quantityController = TextEditingController(text: item.quantity.toString());
                TextEditingController imageController = TextEditingController(text: item.image);
                bool operationalValue = item.operational;

                showDialog(
                  context: context,
                  builder: (context) {
                    return StatefulBuilder(
                      builder: (context, setState) {
                        return Dialog(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.save),
                                      onPressed: () {
                                        item.name = nameController.text;
                                        item.brand = brandController.text;
                                        item.model = modelController.text;
                                        item.quantity = int.tryParse(quantityController.text) ?? item.quantity;
                                        item.image = imageController.text;
                                        item.operational = operationalValue;

                                        Navigator.pop(context);
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.close),
                                      onPressed: () => Navigator.pop(context),
                                    ),
                                  ],
                                ),
                                TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Nome')),
                                TextField(controller: brandController, decoration: const InputDecoration(labelText: 'Marca')),
                                TextField(controller: modelController, decoration: const InputDecoration(labelText: 'Modelo')),
                                TextField(
                                  controller: quantityController,
                                  decoration: const InputDecoration(labelText: 'Quantidade'),
                                  keyboardType: TextInputType.number,
                                ),
                                TextField(controller: imageController, decoration: const InputDecoration(labelText: 'URL da Imagem')),
                                const SizedBox(height: 12),
                                CheckboxListTile(
                                  title: const Text('Operacional'),
                                  value: operationalValue,
                                  onChanged: (value) {
                                    if (value != null) {
                                      setState(() {
                                        operationalValue = value;
                                      });
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
              child: Card(
                elevation: 0,
                color: Theme.of(context).colorScheme.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                clipBehavior: Clip.antiAlias,
                child: SizedBox(
                  height: 150,
                  child: Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                item.name,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Theme.of(context).colorScheme.onPrimary,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                item.brand,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Theme.of(context).colorScheme.onPrimary,
                                ),
                              ),
                              Text(
                                item.model,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Theme.of(context).colorScheme.onPrimary,
                                ),
                              ),
                              Text(
                                'Qtd: ${item.quantity}',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Theme.of(context).colorScheme.onPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: item.image.isNotEmpty
                              ? Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.white, width: 4),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      item.image,
                                      height: double.infinity,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                )
                              : fallbackImage(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
