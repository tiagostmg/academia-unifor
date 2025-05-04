import 'package:academia_unifor/services.dart';
import 'package:flutter/material.dart';
import 'package:academia_unifor/models.dart';

Future<dynamic> editEquipmentDisplay(
  BuildContext context,
  EquipmentItem item,
) async {

  TextEditingController nameController = TextEditingController(
    text: item.name,
    );
  TextEditingController brandController = TextEditingController(
    text: item.brand,
  );
  TextEditingController modelController = TextEditingController(
    text: item.model,
  );
  TextEditingController quantityController = TextEditingController(
    text: item.quantity.toString(),
  );
  TextEditingController imageController = TextEditingController(
    text: item.image,
  );
  bool operationalValue = item.operational;

  return showDialog(
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
                          item.quantity =
                              int.tryParse(quantityController.text) ??
                              item.quantity;
                          item.image = imageController.text;
                          item.operational = operationalValue;

                          EquipmentService().putEquipment(item);

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
}
