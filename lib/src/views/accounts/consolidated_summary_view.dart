import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:clarifi_app/src/models/account.dart';
import 'package:clarifi_app/src/viewmodels/account_viewmodel.dart';
import 'package:clarifi_app/src/services/currency_conversion_service.dart';

/// Pantalla que muestra el resumen consolidado de patrimonio
class ConsolidatedSummaryView extends StatefulWidget {
  final List<AccountModel>? accounts;

  const ConsolidatedSummaryView({Key? key, this.accounts}) : super(key: key);

  @override
  State<ConsolidatedSummaryView> createState() => _ConsolidatedSummaryViewState();
}

class _ConsolidatedSummaryViewState extends State<ConsolidatedSummaryView> {
  final CurrencyConversionService _currencyService = CurrencyConversionService();
  String _selectedCurrency = CurrencyConversionService.baseCurrency;

  @override
  void initState() {
    super.initState();
    // Ensure rates are loaded
    _currencyService.updateExchangeRates();
  }

  @override
  Widget build(BuildContext context) {
    final accountViewModel = context.watch<AccountViewModel>();
    final accounts = widget.accounts ?? accountViewModel.accounts;

    // Agrupar saldos por moneda
    final balancesByCurrency = <String, double>{};
    for (final a in accounts) {
      balancesByCurrency[a.currency] = (balancesByCurrency[a.currency] ?? 0.0) + a.balance;
    }

    final total = _currencyService.consolidate(amounts: balancesByCurrency, targetCurrency: _selectedCurrency);

    // Agrupar por tipo y convertir a moneda seleccionada
    final byType = <String, double>{};
    for (final a in accounts) {
      final converted = _currencyService.convert(amount: a.balance, fromCurrency: a.currency, toCurrency: _selectedCurrency);
      byType[a.type] = (byType[a.type] ?? 0.0) + converted;
    }

    final supported = _currencyService.getSupportedCurrencies();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Resumen consolidado'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: DropdownButton<String>(
              value: _selectedCurrency,
              underline: const SizedBox.shrink(),
              items: supported.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
              onChanged: (v) {
                if (v == null) return;
                setState(() => _selectedCurrency = v);
              },
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              Text(
                _currencyService.formatAmount(amount: total, currency: _selectedCurrency),
                style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              Text(
                'Patrimonio total ($_selectedCurrency)',
                style: TextStyle(color: Colors.grey[700]),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.update, size: 16, color: Colors.grey),
                  const SizedBox(width: 6),
                  Text(
                    _currencyService.lastUpdate == null ? 'Última actualización: --' : 'Última actualización: ${_currencyService.lastUpdate}',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              const Text('Desglose por tipo', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),

              // Lista con barras de distribución
              ...byType.entries.map((e) {
                final percent = total == 0 ? 0.0 : (e.value / total);
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(e.key, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                          Text(_currencyService.formatAmount(amount: e.value, currency: _selectedCurrency), style: const TextStyle(fontSize: 14)),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Container(
                        height: 10,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: percent.clamp(0.0, 1.0),
                          child: Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFF984CE6),
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),

              const SizedBox(height: 16),
              const Text('Cuentas', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),

              Expanded(
                child: ListView.builder(
                  itemCount: accounts.length,
                  itemBuilder: (context, idx) {
                    final a = accounts[idx];
                    final converted = _currencyService.convert(amount: a.balance, fromCurrency: a.currency, toCurrency: _selectedCurrency);
                    return ListTile(
                      title: Text(a.name),
                      subtitle: Text(a.type),
                      trailing: Text(_currencyService.formatAmount(amount: converted, currency: _selectedCurrency)),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
