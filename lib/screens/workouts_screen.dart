import 'package:flutter/material.dart';
import 'package:academia_unifor/widgets.dart';
import 'package:academia_unifor/services/gym_data_service.dart';
import 'package:academia_unifor/models/gym_equipment.dart';

Map<String, int> suggestions = {
  "Máquinas para treinamento de força": 40,
  "Aparelhos ergométricos (cárdio)": 24,
  "Esteiras": 12,
  "Bikes para atividades de spinning": 11,
};

class WorkoutsScreen extends StatelessWidget {
  const WorkoutsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(color: theme.colorScheme.primary),
      child: SafeArea(
        child: CustomConvexBottomBar(
          currentIndex: 1, // Índice correspondente ao botão "Treinos"
          child: Scaffold(
            backgroundColor: theme.scaffoldBackgroundColor,
            appBar: SearchAppBar(),
            body: const WorkoutsBody(),
          ),
        ),
      ),
    );
  }
}

class WorkoutsBody extends StatefulWidget {
  const WorkoutsBody({super.key});

  @override
  State<WorkoutsBody> createState() => _WorkoutsBodyState();
}

class _WorkoutsBodyState extends State<WorkoutsBody> {
  String? selectedCategory;
  List<EquipmentItem> selectedItems = [];

  void _loadCategory(String category) async {
    final categories = await loadGymEquipment();
    final selected = categories.firstWhere((c) => c.category == category);
    setState(() {
      selectedCategory = category;
      selectedItems = selected.items;
    });
  }

  Widget _fallbackImage() {
    return Container(
      color: Colors.grey[200],
      height: double.infinity,
      width: double.infinity,
      child: const Center(
        child: Icon(Icons.image_not_supported, size: 40, color: Colors.grey),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final chipColor = isDarkMode ? Colors.grey[800]! : Colors.grey[200]!;
    final textColor = isDarkMode ? Colors.white : Colors.black;

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (selectedCategory == null) ...[
              const Icon(Icons.search, size: 80, color: Colors.grey),
              const SizedBox(height: 16),
              const Text(
                "Pesquise por um aparelho...",
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
              const SizedBox(height: 20),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 10,
                runSpacing: 10,
                children:
                    suggestions.keys
                        .map(
                          (equipamento) => ActionChip(
                            label: Text(equipamento),
                            backgroundColor: chipColor,
                            labelStyle: TextStyle(color: textColor),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                              side: BorderSide(color: Colors.transparent),
                            ),
                            onPressed: () => _loadCategory(equipamento),
                          ),
                        )
                        .toList(),
              ),
            ] else ...[
              Row(
                children: [
                  IconButton(
                    onPressed: () {
                      setState(() {
                        selectedCategory = null;
                        selectedItems = [];
                      });
                    },
                    icon: const Icon(Icons.arrow_back),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      selectedCategory!,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: selectedItems.length,
                separatorBuilder: (_, __) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final item = selectedItems[index];
                  return Card(
                    clipBehavior: Clip.antiAlias,
                    child: SizedBox(
                      height: 120,
                      child: Row(
                        children: [
                          // Informações
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
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    item.brand,
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                  Text(
                                    item.model,
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                  Text(
                                    'Qtd: ${item.quantity}',
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          // Imagem
                          Expanded(
                            flex: 1,
                            child:
                                item.image.isNotEmpty
                                    ? Image.network(
                                      item.image,
                                      height: double.infinity,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (_, __, ___) => _fallbackImage(),
                                    )
                                    : _fallbackImage(),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}
