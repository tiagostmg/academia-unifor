import 'package:academia_unifor/models/equipment.dart';
import 'package:academia_unifor/widgets/validator/validator_equipment_widget.dart';
import 'package:flutter/material.dart';
import 'package:academia_unifor/services.dart';

class SelectedCategoryList extends StatelessWidget {
  final String selectedCategory;
  final List<EquipmentItem> items;
  final VoidCallback onBack;
  final Widget Function() fallbackImage;
  final bool isEditMode;
  final void Function(EquipmentItem)? onItemTap;
  final VoidCallback onDataUpdated;

  const SelectedCategoryList({
    super.key,
    required this.selectedCategory,
    required this.items,
    required this.onBack,
    required this.fallbackImage,
    this.isEditMode = true,
    this.onItemTap,
    required this.onDataUpdated,
  });

  Future<void> _showDeleteConfirmation(
    BuildContext context,
    EquipmentItem item,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Confirmar Exclusão'),
            content: const Text(
              'Tem certeza que deseja excluir este equipamento?',
            ),
            actions: [
              TextButton(
                style: TextButton.styleFrom(
                  backgroundColor:
                      Theme.of(context).colorScheme.primary, // Cor de fundo
                  foregroundColor:
                      Theme.of(context).colorScheme.onPrimary, // Cor do texto
                ),
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancelar'),
              ),
              TextButton(
                style: TextButton.styleFrom(
                  backgroundColor: Colors.red, // Cor de fundo
                  foregroundColor:
                      Theme.of(context).colorScheme.onPrimary, // Cor do texto
                ),
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Excluir'),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      try {
        await EquipmentService().deleteEquipment(item.id);
        onDataUpdated();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Equipamento excluído com sucesso')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao excluir equipamento: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final equipmentService = EquipmentService();
    final validator = EquipmentValidator();

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

                TextEditingController nameController = TextEditingController(
                  text: item.name,
                );
                TextEditingController brandController = TextEditingController(
                  text: item.brand,
                );
                TextEditingController modelController = TextEditingController(
                  text: item.model,
                );
                TextEditingController quantityController =
                    TextEditingController(text: item.quantity.toString());
                TextEditingController imageController = TextEditingController(
                  text: item.image,
                );
                bool operationalValue = item.operational;

                final Map<String, String?> fieldErrors = {
                  'name': null,
                  'brand': null,
                  'model': null,
                  'quantity': null,
                  'image': null,
                };

                showDialog(
                  context: context,
                  builder: (context) {
                    return StatefulBuilder(
                      builder: (context, setState) {
                        void validateField(String field, String value) {
                          String? error;
                          switch (field) {
                            case 'name':
                              error =
                                  validator.validateName(value)
                                      ? null
                                      : value.isEmpty
                                      ? 'O nome é obrigatório'
                                      : 'Nome deve ter 2-50 caracteres';
                              break;
                            case 'brand':
                              error =
                                  validator.validateBrand(value)
                                      ? null
                                      : value.isEmpty
                                      ? 'A marca é obrigatória'
                                      : 'Marca deve ter 2-30 caracteres';
                              break;
                            case 'model':
                              error =
                                  validator.validateModel(value)
                                      ? null
                                      : value.isEmpty
                                      ? 'O modelo é obrigatório'
                                      : 'Modelo deve ter 2-30 caracteres';
                              break;
                            case 'quantity':
                              final quantity = int.tryParse(value) ?? 0;
                              error =
                                  validator.validateQuantity(quantity)
                                      ? null
                                      : 'Quantidade deve ser entre 0 e 999';
                              break;
                            case 'image':
                              if (value.isNotEmpty) {
                                error =
                                    validator.validateImageUrl(value)
                                        ? null
                                        : 'URL da imagem inválida';
                              }
                              break;
                          }
                          setState(() {
                            fieldErrors[field] = error;
                          });
                        }

                        bool validateAllFields() {
                          validateField('name', nameController.text);
                          validateField('brand', brandController.text);
                          validateField('model', modelController.text);
                          validateField('quantity', quantityController.text);
                          validateField('image', imageController.text);

                          return !fieldErrors.values.any(
                            (error) => error != null,
                          );
                        }

                        InputDecoration customInputDecoration({
                          required BuildContext context,
                          required String labelText,
                          String? errorText,
                        }) {
                          final colorScheme = Theme.of(context).colorScheme;
                          return InputDecoration(
                            labelText: labelText,
                            errorText: errorText,
                            errorStyle: TextStyle(color: colorScheme.error),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: colorScheme.onPrimary.withAlpha(77),
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: colorScheme.onPrimary.withAlpha(77),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: colorScheme.onPrimary,
                                width: 2,
                              ),
                            ),
                            filled: true,
                            fillColor: colorScheme.primary,
                            labelStyle: TextStyle(
                              color: colorScheme.onPrimary.withAlpha(200),
                            ),
                          );
                        }

                        return Dialog(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.save),
                                      onPressed: () async {
                                        if (!validateAllFields()) {
                                          return;
                                        }

                                        final quantity =
                                            int.tryParse(
                                              quantityController.text,
                                            ) ??
                                            item.quantity;
                                        final updatedItem = EquipmentItem(
                                          id: item.id,
                                          categoryId: item.categoryId,
                                          name: nameController.text,
                                          brand: brandController.text,
                                          model: modelController.text,
                                          quantity: quantity,
                                          image: imageController.text,
                                          operational: operationalValue,
                                          quantityInUse: item.quantityInUse,
                                        );

                                        try {
                                          await equipmentService.putEquipment(
                                            updatedItem,
                                          );
                                          onDataUpdated();
                                          Navigator.pop(context);
                                        } catch (e) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                'Erro ao atualizar: $e',
                                              ),
                                            ),
                                          );
                                        }
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.close),
                                      onPressed: () => Navigator.pop(context),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                TextField(
                                  controller: nameController,
                                  cursorColor:
                                      Theme.of(context).colorScheme.onPrimary,
                                  decoration: customInputDecoration(
                                    context: context,
                                    labelText: 'Nome',
                                    errorText: fieldErrors['name'],
                                  ),
                                  onChanged:
                                      (value) => validateField('name', value),
                                ),
                                const SizedBox(height: 12),
                                TextField(
                                  controller: brandController,
                                  cursorColor:
                                      Theme.of(context).colorScheme.onPrimary,
                                  decoration: customInputDecoration(
                                    context: context,
                                    labelText: 'Marca',
                                    errorText: fieldErrors['brand'],
                                  ),
                                  onChanged:
                                      (value) => validateField('brand', value),
                                ),
                                const SizedBox(height: 12),
                                TextField(
                                  controller: modelController,
                                  cursorColor:
                                      Theme.of(context).colorScheme.onPrimary,
                                  decoration: customInputDecoration(
                                    context: context,
                                    labelText: 'Modelo',
                                    errorText: fieldErrors['model'],
                                  ),
                                  onChanged:
                                      (value) => validateField('model', value),
                                ),
                                const SizedBox(height: 12),
                                TextField(
                                  controller: quantityController,
                                  cursorColor:
                                      Theme.of(context).colorScheme.onPrimary,
                                  decoration: customInputDecoration(
                                    context: context,
                                    labelText: 'Quantidade',
                                    errorText: fieldErrors['quantity'],
                                  ),
                                  keyboardType: TextInputType.number,
                                  onChanged:
                                      (value) =>
                                          validateField('quantity', value),
                                ),
                                const SizedBox(height: 12),
                                TextField(
                                  controller: imageController,
                                  cursorColor:
                                      Theme.of(context).colorScheme.onPrimary,
                                  decoration: customInputDecoration(
                                    context: context,
                                    labelText: 'URL da Imagem',
                                    errorText: fieldErrors['image'],
                                  ),
                                  onChanged:
                                      (value) => validateField('image', value),
                                ),
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
                                const SizedBox(height: 20),
                                ElevatedButton.icon(
                                  onPressed: () {
                                    Navigator.pop(context);
                                    _showDeleteConfirmation(context, item);
                                  },
                                  icon: Icon(
                                    Icons.delete,
                                    color:
                                        Theme.of(context).colorScheme.onPrimary,
                                  ),
                                  label: Text(
                                    'Excluir Equipamento',
                                    style: TextStyle(
                                      color:
                                          Theme.of(
                                            context,
                                          ).colorScheme.onPrimary,
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        Colors.red, // Ou Colors.red
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 12,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
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
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                clipBehavior: Clip.antiAlias,
                child: SizedBox(
                  height: 180,
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
                                  color:
                                      Theme.of(context).colorScheme.onPrimary,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                item.brand,
                                style: TextStyle(
                                  fontSize: 14,
                                  color:
                                      Theme.of(context).colorScheme.onPrimary,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Text(
                                item.model,
                                style: TextStyle(
                                  fontSize: 14,
                                  color:
                                      Theme.of(context).colorScheme.onPrimary,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Text(
                                'Quantidade: ${item.quantity}',
                                style: TextStyle(
                                  fontSize: 14,
                                  color:
                                      Theme.of(context).colorScheme.onPrimary,
                                ),
                              ),
                              Text(
                                'Exercícios usando: ${item.quantityInUse}',
                                style: TextStyle(
                                  fontSize: 14,
                                  color:
                                      Theme.of(context).colorScheme.onPrimary,
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
                          child:
                              item.image.isNotEmpty &&
                                      item.image != 'null' &&
                                      item.image.startsWith('http')
                                  ? Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: Colors.white,
                                        width: 4,
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.network(
                                        item.image,
                                        height: double.infinity,
                                        width: double.infinity,
                                        fit: BoxFit.cover,
                                        errorBuilder: (
                                          context,
                                          error,
                                          stackTrace,
                                        ) {
                                          return fallbackImage();
                                        },
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
