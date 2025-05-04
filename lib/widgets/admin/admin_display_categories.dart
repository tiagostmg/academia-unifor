import 'package:flutter/material.dart';
import 'package:academia_unifor/widgets.dart';


void display_categories(
    BuildContext context,
    String titulo,
    Color chipColor,
    Color textColor,
    Map<String, int> categoryCounts, 
    Function(String?) onCategoriaSelecionada) {
  showDialog(
  context: context,
  builder: (BuildContext context) {
    return AlertDialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
      contentPadding: const EdgeInsets.all(16),
      title: Row(
        children: <Widget>[
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          Expanded(
            child: Center(
              child: Text(titulo),
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListCategories(
              categoryCounts: categoryCounts,
              chipColor: chipColor,
              textColor: textColor,
              onChipTap: (categoria) {
                onCategoriaSelecionada(categoria);
                Navigator.of(context).pop();
              },
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                onCategoriaSelecionada(null);
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Nenhum Equipamento'),
            ),
          ],
        ),
      ),
    );
  },
);

}

