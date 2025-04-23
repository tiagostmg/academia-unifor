import 'package:flutter/material.dart';
import 'package:academia_unifor/widgets.dart';
import 'package:academia_unifor/services/gym_data_service.dart';
import 'package:academia_unifor/models/equipment.dart';

class EquipmentsScreen extends StatelessWidget {
  const EquipmentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.primary,
      body: SafeArea(
        child: AdminConvexBottomBar(
          currentIndex: 1, // Índice correspondente ao botão "Aparelhos"
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

  @override
  void initState() {
    super.initState();
    _loadAllItems();
  }

  void _loadAllItems() async {
    final categories = await loadGymEquipment();
    final items = categories.expand((c) => c.items).toList();
    final counts = {for (var c in categories) c.category: c.total};

    setState(() {
      allItems = items;
      categoryCounts = counts;
    });
  }

  void _loadCategory(String category) async {
    final categories = await loadGymEquipment();
    final selected = categories.firstWhere((c) => c.category == category);
    setState(() {
      selectedCategory = category;
      selectedItems = selected.items;
    });
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child:
              selectedCategory == null
                  ? _EmptySearchSection(
                    categoryCounts: categoryCounts,
                    chipColor: chipColor,
                    textColor: textColor,
                    onChipTap: _loadCategory,
                  )
                  : _SelectedCategoryList(
                    selectedCategory: selectedCategory!,
                    items: selectedItems,
                    onBack: () {
                      setState(() {
                        selectedCategory = null;
                        selectedItems = [];
                      });
                    },
                    fallbackImage: fallbackImageWithBorder,
                  ),
        ),
      ),
    );
  }
}

class _EmptySearchSection extends StatelessWidget {
  final Map<String, int> categoryCounts;
  final Color chipColor;
  final Color textColor;
  final void Function(String) onChipTap;

  const _EmptySearchSection({
    required this.categoryCounts,
    required this.chipColor,
    required this.textColor,
    required this.onChipTap,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(Icons.search, size: 80, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              "Pesquise por um aparelho...",
              style: TextStyle(fontSize: 18, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 10,
              runSpacing: 10,
              children:
                  categoryCounts.entries.map((entry) {
                    final name = entry.key;
                    final total = entry.value;
                    return ActionChip(
                      label: Text('$name ($total)'),
                      backgroundColor: chipColor,
                      labelStyle: TextStyle(color: textColor),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(color: Colors.transparent),
                      ),
                      onPressed: () => onChipTap(name),
                    );
                  }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _SelectedCategoryList extends StatelessWidget {
  final String selectedCategory;
  final List<EquipmentItem> items;
  final VoidCallback onBack;
  final Widget Function() fallbackImage;

  const _SelectedCategoryList({
    required this.selectedCategory,
    required this.items,
    required this.onBack,
    required this.fallbackImage,
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
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.save),
                                      onPressed: () {
                                        // Salva as alterações
                                        item.name = nameController.text;
                                        item.brand = brandController.text;
                                        item.model = modelController.text;
                                        item.quantity =
                                            int.tryParse(
                                              quantityController.text,
                                            ) ??
                                            item.quantity;
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
                                TextField(
                                  controller: nameController,
                                  decoration: const InputDecoration(
                                    labelText: 'Nome',
                                  ),
                                ),
                                TextField(
                                  controller: brandController,
                                  decoration: const InputDecoration(
                                    labelText: 'Marca',
                                  ),
                                ),
                                TextField(
                                  controller: modelController,
                                  decoration: const InputDecoration(
                                    labelText: 'Modelo',
                                  ),
                                ),
                                TextField(
                                  controller: quantityController,
                                  decoration: const InputDecoration(
                                    labelText: 'Quantidade',
                                  ),
                                  keyboardType: TextInputType.number,
                                ),
                                TextField(
                                  controller: imageController,
                                  decoration: const InputDecoration(
                                    labelText: 'URL da Imagem',
                                  ),
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
                                ),
                              ),
                              Text(
                                item.model,
                                style: TextStyle(
                                  fontSize: 14,
                                  color:
                                      Theme.of(context).colorScheme.onPrimary,
                                ),
                              ),
                              Text(
                                'Qtd: ${item.quantity}',
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
                              item.image.isNotEmpty
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
                                        
                                        //coloquei esse erroBuilder para evitar o travamento do aplicativo quando não carrega a imagem
                                        errorBuilder: (context, error, stackTrace) {
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
