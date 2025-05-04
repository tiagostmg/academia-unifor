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
    final categories = await EquipmentService().loadCategories();
    final items = categories.expand((c) => c.items).toList();
    final counts = {for (var c in categories) c.category: c.total};

    setState(() {
      allItems = items;
      categoryCounts = counts;
    });
  }

  void _loadCategory(String category) async {
    final categories = await EquipmentService().loadCategories();
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
                  ),
        ),
      ),
    );
  }
}

