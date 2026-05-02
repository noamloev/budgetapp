import 'package:flutter/material.dart';

import '../../../app/app_localizations.dart';
import '../../../models/budget_models.dart';
import '../../shared/widgets/app_sheet.dart';

class StockFormSheet extends StatefulWidget {
  const StockFormSheet({super.key, this.initialHolding});

  final StockHolding? initialHolding;

  @override
  State<StockFormSheet> createState() => _StockFormSheetState();
}

class _StockFormSheetState extends State<StockFormSheet> {
  late final TextEditingController symbolController;
  late final TextEditingController nameController;
  late final TextEditingController quantityController;
  late final TextEditingController buyPriceController;
  late final TextEditingController currentPriceController;

  @override
  void initState() {
    super.initState();
    final initial = widget.initialHolding;
    symbolController = TextEditingController(text: initial?.symbol ?? '');
    nameController = TextEditingController(text: initial?.companyName ?? '');
    quantityController = TextEditingController(
      text: initial == null ? '' : initial.quantity.toStringAsFixed(2),
    );
    buyPriceController = TextEditingController(
      text: initial == null ? '' : initial.buyPrice.toStringAsFixed(2),
    );
    currentPriceController = TextEditingController(
      text: initial == null ? '' : initial.currentPrice.toStringAsFixed(2),
    );
  }

  @override
  void dispose() {
    symbolController.dispose();
    nameController.dispose();
    quantityController.dispose();
    buyPriceController.dispose();
    currentPriceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final isEditing = widget.initialHolding != null;

    return AppSheet(
      title: isEditing ? t.text('edit_stock') : t.text('add_stock'),
      helpTitle: t.text('stocks'),
      helpLines: [
        t.isHebrew
            ? 'שמור את הסימול, הכמות, מחיר הקניה והמחיר הנוכחי כדי לראות את הרווח או ההפסד.'
            : 'Save the symbol, quantity, buy price, and current price to see profit or loss.',
      ],
      child: Column(
        children: [
          TextField(
            controller: symbolController,
            textCapitalization: TextCapitalization.characters,
            decoration: InputDecoration(labelText: t.text('symbol')),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: nameController,
            decoration: InputDecoration(labelText: t.text('company_name')),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: quantityController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(labelText: t.text('quantity')),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: buyPriceController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(labelText: t.text('buy_price')),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: currentPriceController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(labelText: t.text('current_price')),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () {
                final quantity = double.tryParse(quantityController.text);
                final buyPrice = double.tryParse(buyPriceController.text);
                final currentPrice = double.tryParse(
                  currentPriceController.text,
                );
                if (symbolController.text.trim().isEmpty ||
                    quantity == null ||
                    quantity <= 0 ||
                    buyPrice == null ||
                    buyPrice <= 0 ||
                    currentPrice == null ||
                    currentPrice <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        t.isHebrew
                            ? 'הכנס סימול, כמות, מחיר קניה ומחיר נוכחי תקינים.'
                            : 'Enter a valid symbol, quantity, buy price, and current price.',
                      ),
                    ),
                  );
                  return;
                }

                Navigator.pop(
                  context,
                  StockHolding(
                    id: widget.initialHolding?.id ?? makeId(),
                    symbol: symbolController.text.trim().toUpperCase(),
                    companyName: nameController.text.trim(),
                    quantity: quantity,
                    buyPrice: buyPrice,
                    currentPrice: currentPrice,
                  ),
                );
              },
              child: Text(isEditing ? t.saveChanges : t.text('save_stock')),
            ),
          ),
        ],
      ),
    );
  }
}
