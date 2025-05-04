import 'package:flutter/material.dart';
import 'package:academia_unifor/models.dart';
import 'package:academia_unifor/widgets.dart';


class ChooseEquipmentScreen extends StatefulWidget {
  final EquipmentCategory categoria;
  final Widget Function() fallbackImage;

  const ChooseEquipmentScreen({
    Key? key,
    required this.categoria,
    required this.fallbackImage,
  }) : super(key: key);

  @override
  State<ChooseEquipmentScreen> createState() => _ChooseEquipmentScreenState();
}

class _ChooseEquipmentScreenState extends State<ChooseEquipmentScreen> {
  late List<EquipmentItem> filteredItems;

  @override
  void initState() {
    super.initState();
    filteredItems = widget.categoria.items;
  }

  void _onSearchChanged(String query) {
    if (query.isEmpty) {
      setState(() {
        filteredItems = widget.categoria.items;
      });
    } else {
      final lower = query.toLowerCase();
      setState(() {
        filteredItems = widget.categoria.items.where((item) =>
          item.name.toLowerCase().contains(lower) ||
          item.brand.toLowerCase().contains(lower) ||
          item.model.toLowerCase().contains(lower)
        ).toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SearchAppBar(
        onSearchChanged: _onSearchChanged,
        showChatIcon: false,
        onBack: () => Navigator.pop(context),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: SelectedCategoryList(
          selectedCategory: widget.categoria.category,
          items: filteredItems,
          isEditMode: false,
          fallbackImage: widget.fallbackImage,
          onBack: () => Navigator.pop(context),
          onItemTap: (equipmentSelecionado) {
            Navigator.pop(context, equipmentSelecionado);
          },
        ),
      ),
    );
  }
}
