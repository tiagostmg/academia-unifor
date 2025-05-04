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
      final items = await _equipmentService.loadEquipment()..sort((a, b) => a.name.compareTo(b.name));
      final counts = {for (var c in categories) c.category: c.total};

      setState(() {
        allItems = items;
        categoryCounts = counts;
        if (selectedCategory != null) {
          _loadCategory(selectedCategory!);
        }
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao carregar dados: $e')),
      );
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
        selectedItems = allItems.where((item) => item.categoryId == selected.id).toList();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao carregar categoria: $e')),
      );
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

    final filtered = allItems.where((item) {
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
    
    String? selectedCategory;
    final nameController = TextEditingController();
    final brandController = TextEditingController();
    final modelController = TextEditingController();
    final quantityController = TextEditingController(text: '1');
    final imageController = TextEditingController();
    bool operationalValue = true;

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Adicionar Novo Equipamento'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(labelText: 'Categoria'),
                      items: categories.map((category) {
                        return DropdownMenuItem(
                          value: category.category,
                          child: Text(category.category),
                        );
                      }).toList(),
                      onChanged: (value) => setState(() => selectedCategory = value),
                      hint: const Text('Selecione uma categoria'),
                    ),
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(labelText: 'Nome'),
                    ),
                    TextField(
                      controller: brandController,
                      decoration: const InputDecoration(labelText: 'Marca'),
                    ),
                    TextField(
                      controller: modelController,
                      decoration: const InputDecoration(labelText: 'Modelo'),
                    ),
                    TextField(
                      controller: quantityController,
                      decoration: const InputDecoration(labelText: 'Quantidade'),
                      keyboardType: TextInputType.number,
                    ),
                    TextField(
                      controller: imageController,
                      decoration: const InputDecoration(labelText: 'URL da Imagem'),
                    ),
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
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (selectedCategory == null || nameController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Preencha pelo menos a categoria e o nome')),
                      );
                      return;
                    }

                    final category = categories.firstWhere((c) => c.category == selectedCategory);
                    final newEquipment = EquipmentItem(
                      id: 0, // ID será gerado pelo servidor
                      categoryId: category.id,
                      name: nameController.text,
                      brand: brandController.text,
                      model: modelController.text,
                      quantity: int.tryParse(quantityController.text) ?? 1,
                      image: imageController.text,
                      operational: operationalValue,
                    );

                    try {
                      await _equipmentService.postEquipment(newEquipment);
                      Navigator.pop(context);
                      await _refreshData(); // Atualiza a lista após adicionar
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Erro ao adicionar equipamento: $e')),
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
        onBack: selectedCategory != null
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
          child: selectedCategory == null
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