import 'package:flutter/material.dart';
import 'package:academia_unifor/widgets.dart';
import 'package:academia_unifor/services.dart';
import 'package:academia_unifor/models.dart';

class EquipmentsScreen extends StatelessWidget {
  const EquipmentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.primary,
      body: SafeArea(
        child: AdminConvexBottomBar(
          currentIndex: 1,
          child: const EquipmentsBody(),
        ),
      ),
    );
  }
}

class EquipmentsBody extends StatefulWidget {
  const EquipmentsBody({super.key});

  @override
  State<EquipmentsBody> createState() => _EquipmentsBodyState();
}

class _EquipmentsBodyState extends State<EquipmentsBody> {
  String? selectedCategory;
  List<EquipmentItem> allItems = [];
  List<EquipmentItem> selectedItems = [];
  Map<String, int> categoryCounts = {};
  final EquipmentService _equipmentService = EquipmentService();

  Future<void> _refreshData() async {
    try {
      final categories = await _equipmentService.loadCategories();
      final items =
          await _equipmentService.loadEquipment()
            ..sort((a, b) => a.name.compareTo(b.name));
      final counts = {
        for (var c in categories) c.category: c.items.length,
      }; // Mudei para aparecer a quantidade de itens por categoria

      setState(() {
        allItems = items;
        categoryCounts = counts;
        if (selectedCategory != null) {
          _loadCategory(selectedCategory!);
        }
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro ao carregar dados: $e')));
    }
  }

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  void _loadCategory(String category) async {
    try {
      final categories = await _equipmentService.loadCategories();
      final selected = categories.firstWhere((c) => c.category == category);
      setState(() {
        selectedCategory = category;
        selectedItems =
            allItems.where((item) => item.categoryId == selected.id).toList();
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro ao carregar categoria: $e')));
    }
  }

  void _onSearchChanged(String query) {
    if (query.isEmpty) {
      setState(() {
        selectedCategory = null;
        selectedItems = [];
      });
      return;
    }

    final filtered =
        allItems.where((item) {
          final lower = query.toLowerCase();
          return item.name.toLowerCase().contains(lower) ||
              item.brand.toLowerCase().contains(lower) ||
              item.model.toLowerCase().contains(lower);
        }).toList();

    setState(() {
      selectedCategory = 'Resultados da busca';
      selectedItems = filtered;
    });
  }

  Widget fallbackImageWithBorder() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white, width: 4),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Container(
          color: Colors.white,
          child: const Center(
            child: Icon(
              Icons.image_not_supported,
              size: 40,
              color: Colors.grey,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showAddEquipmentDialog() async {
    final categories = await _equipmentService.loadCategories();
    final validator = EquipmentValidator();

    String? selectedCategory;
    final nameController = TextEditingController();
    final brandController = TextEditingController();
    final modelController = TextEditingController();
    final quantityController = TextEditingController(text: '1');
    final imageController = TextEditingController();
    bool operationalValue = true;

    // Variáveis para controlar os erros
    final Map<String, String?> fieldErrors = {
      'category': null,
      'name': null,
      'brand': null,
      'model': null,
      'quantity': null,
      'image': null,
    };

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            void validateField(String field, String value) {
              String? error;
              switch (field) {
                case 'category':
                  error =
                      selectedCategory == null
                          ? 'Selecione uma categoria'
                          : null;
                  break;
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
              validateField('category', '');
              validateField('name', nameController.text);
              validateField('brand', brandController.text);
              validateField('model', modelController.text);
              validateField('quantity', quantityController.text);
              validateField('image', imageController.text);

              return !fieldErrors.values.any((error) => error != null);
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

            return AlertDialog(
              title: const Text('Adicionar Novo Equipamento'),
              content: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.8,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      DropdownButtonFormField<String>(
                        isExpanded: true,
                        decoration: customInputDecoration(
                          context: context,
                          labelText: 'Categoria*',
                          errorText: fieldErrors['category'],
                        ),
                        items:
                            categories.map((category) {
                              return DropdownMenuItem(
                                value: category.category,
                                child: Text(
                                  category.category,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              );
                            }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedCategory = value;
                            validateField('category', '');
                          });
                        },
                        hint: const Text('Selecione uma categoria'),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: nameController,
                        cursorColor: Theme.of(context).colorScheme.onPrimary,
                        decoration: customInputDecoration(
                          context: context,
                          labelText: 'Nome*',
                          errorText: fieldErrors['name'],
                        ),
                        onChanged: (value) => validateField('name', value),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: brandController,
                        cursorColor: Theme.of(context).colorScheme.onPrimary,
                        decoration: customInputDecoration(
                          context: context,
                          labelText: 'Marca*',
                          errorText: fieldErrors['brand'],
                        ),
                        onChanged: (value) => validateField('brand', value),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: modelController,
                        cursorColor: Theme.of(context).colorScheme.onPrimary,
                        decoration: customInputDecoration(
                          context: context,
                          labelText: 'Modelo*',
                          errorText: fieldErrors['model'],
                        ),
                        onChanged: (value) => validateField('model', value),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: quantityController,
                        cursorColor: Theme.of(context).colorScheme.onPrimary,
                        decoration: customInputDecoration(
                          context: context,
                          labelText: 'Quantidade*',
                          errorText: fieldErrors['quantity'],
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (value) => validateField('quantity', value),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: imageController,
                        cursorColor: Theme.of(context).colorScheme.onPrimary,
                        decoration: customInputDecoration(
                          context: context,
                          labelText: 'URL da Imagem',
                          errorText: fieldErrors['image'],
                        ),
                        onChanged: (value) => validateField('image', value),
                      ),
                      const SizedBox(height: 16),
                      CheckboxListTile(
                        title: const Text('Operacional'),
                        value: operationalValue,
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => operationalValue = value);
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  style: TextButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    backgroundColor: Theme.of(context).colorScheme.primary,
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        Theme.of(context).colorScheme.primary, // Cor de fundo
                    foregroundColor:
                        Theme.of(context).colorScheme.onPrimary, // Cor do texto
                  ),
                  onPressed: () async {
                    if (!validateAllFields()) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Corrija os erros antes de salvar'),
                        ),
                      );
                      return;
                    }

                    final category = categories.firstWhere(
                      (c) => c.category == selectedCategory,
                    );
                    final newEquipment = EquipmentItem(
                      id: 0,
                      categoryId: category.id,
                      name: nameController.text,
                      brand: brandController.text,
                      model: modelController.text,
                      quantity: int.tryParse(quantityController.text) ?? 1,
                      image: imageController.text,
                      operational: operationalValue,
                      quantityInUse: 0,
                    );

                    try {
                      await _equipmentService.postEquipment(newEquipment);
                      Navigator.pop(context);
                      await _refreshData();
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Erro ao adicionar equipamento: $e'),
                        ),
                      );
                    }
                  },
                  child: const Text('Salvar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final chipColor = isDarkMode ? Colors.grey[800]! : Colors.grey[200]!;
    final textColor = isDarkMode ? Colors.white : Colors.black;

    return Scaffold(
      appBar: SearchAppBar(
        onSearchChanged: _onSearchChanged,
        showChatIcon: false,
        onBack:
            selectedCategory != null
                ? () {
                  setState(() {
                    selectedCategory = null;
                    selectedItems = [];
                  });
                }
                : null,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddEquipmentDialog,
        child: const Icon(Icons.add),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child:
              selectedCategory == null
                  ? ListCategories(
                    categoryCounts: categoryCounts,
                    chipColor: chipColor,
                    textColor: textColor,
                    onChipTap: _loadCategory,
                  )
                  : SelectedCategoryList(
                    selectedCategory: selectedCategory!,
                    items: selectedItems,
                    onBack: () {
                      setState(() {
                        selectedCategory = null;
                        selectedItems = [];
                      });
                    },
                    fallbackImage: fallbackImageWithBorder,
                    isEditMode: true,
                    onDataUpdated: _refreshData,
                  ),
        ),
      ),
    );
  }
}
