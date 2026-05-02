import 'package:flutter/material.dart';

import '../../../app/app_localizations.dart';
import '../../../models/budget_models.dart';
import '../../shared/formatters.dart';
import '../../shared/widgets/cards.dart';
import '../../shared/widgets/empty_state_card.dart';
import '../../shared/widgets/help_widgets.dart';
import '../forms/stock_form_sheet.dart';

class StocksScreen extends StatefulWidget {
  const StocksScreen({
    super.key,
    required this.holdings,
    required this.onUpsertStock,
    required this.onDeleteStock,
  });

  final List<StockHolding> holdings;
  final ValueChanged<StockHolding> onUpsertStock;
  final ValueChanged<String> onDeleteStock;

  @override
  State<StocksScreen> createState() => _StocksScreenState();
}

class _StocksScreenState extends State<StocksScreen> {
  final searchController = TextEditingController();

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> _openStockSheet([StockHolding? holding]) async {
    final result = await showModalBottomSheet<StockHolding>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StockFormSheet(initialHolding: holding),
    );
    if (result != null) {
      widget.onUpsertStock(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final query = searchController.text.trim().toLowerCase();
    final filtered = widget.holdings.where((holding) {
      final company = holding.companyName.toLowerCase();
      final symbol = holding.symbol.toLowerCase();
      return query.isEmpty || company.contains(query) || symbol.contains(query);
    }).toList();
    final totalValue = widget.holdings.fold<double>(
      0,
      (sum, item) => sum + item.currentValue,
    );
    final totalGainLoss = widget.holdings.fold<double>(
      0,
      (sum, item) => sum + item.gainLoss,
    );

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          ScreenHeader(
            title: t.text('stocks'),
            subtitle: t.isHebrew
                ? 'נהל את ההחזקות שלך וראה את הרווח או ההפסד לפי מחיר הקניה והמחיר הנוכחי.'
                : 'Manage your holdings and track profit or loss from buy price versus current price.',
            helpTitle: t.text('stocks'),
            helpLines: [
              t.isHebrew
                  ? 'כל שורה שומרת סימול, כמות, מחיר קניה ומחיר נוכחי.'
                  : 'Each row stores a symbol, quantity, buy price, and current price.',
              t.isHebrew
                  ? 'החיפוש עובד לפי סימול או שם חברה.'
                  : 'Search works by symbol or company name.',
            ],
            action: FilledButton.icon(
              onPressed: _openStockSheet,
              icon: const Icon(Icons.add_rounded),
              label: Text(t.text('add_stock')),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: InfoCard(
                  title: t.text('stock_value'),
                  value: money(totalValue),
                  subtitle: t.isHebrew
                      ? 'שווי כולל נוכחי'
                      : 'Current combined value',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: InfoCard(
                  title: t.text('profit_loss'),
                  value: money(totalGainLoss),
                  subtitle: t.isHebrew
                      ? 'ביחס למחיר הקניה'
                      : 'Compared with buy price',
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          TextField(
            controller: searchController,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              labelText: t.text('search_stocks'),
              prefixIcon: const Icon(Icons.search_rounded),
            ),
          ),
          const SizedBox(height: 20),
          if (widget.holdings.isEmpty)
            EmptyStateCard(
              icon: Icons.candlestick_chart_rounded,
              title: t.text('no_stocks'),
              subtitle: t.text('stock_empty_subtitle'),
              actionLabel: t.text('add_first_stock'),
              onTap: _openStockSheet,
            )
          else if (filtered.isEmpty)
            EmptyStateCard(
              icon: Icons.search_off_rounded,
              title: t.isHebrew ? 'לא נמצאו מניות' : 'No matching stocks',
              subtitle: t.isHebrew
                  ? 'נסה חיפוש אחר.'
                  : 'Try a different search.',
              actionLabel: t.close,
              onTap: () {},
            )
          else
            ...filtered.map(
              (holding) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _StockCard(
                  holding: holding,
                  onEdit: () => _openStockSheet(holding),
                  onDelete: () => widget.onDeleteStock(holding.id),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _StockCard extends StatelessWidget {
  const _StockCard({
    required this.holding,
    required this.onEdit,
    required this.onDelete,
  });

  final StockHolding holding;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final gainPositive = holding.gainLoss >= 0;
    final title = holding.companyName.isEmpty
        ? holding.symbol
        : '${holding.symbol} • ${holding.companyName}';

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              Text(
                money(holding.currentValue),
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'edit') {
                    onEdit();
                  }
                  if (value == 'delete') {
                    onDelete();
                  }
                },
                itemBuilder: (_) => [
                  PopupMenuItem(value: 'edit', child: Text(t.edit)),
                  PopupMenuItem(value: 'delete', child: Text(t.delete)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _ValuePill(
                label: t.text('quantity'),
                value: holding.quantity.toStringAsFixed(2),
              ),
              _ValuePill(
                label: t.text('buy_price'),
                value: money(holding.buyPrice),
              ),
              _ValuePill(
                label: t.text('current_price'),
                value: money(holding.currentPrice),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '${t.text('profit_loss')}: ${money(holding.gainLoss)} (${holding.gainLossPercent.toStringAsFixed(1)}%)',
            style: TextStyle(
              color: gainPositive
                  ? const Color(0xFF0F766E)
                  : const Color(0xFFBE123C),
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _ValuePill extends StatelessWidget {
  const _ValuePill({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F1E8),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.black54)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}
