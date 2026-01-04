import 'package:flutter/material.dart';
import '../widgets/glass_container.dart';
import '../widgets/nav_button.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  late Box _walletBox;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initHive();
  }

  Future<void> _initHive() async {
    _walletBox = await Hive.openBox('wallet');
    setState(() {
      _isInitialized = true;
    });
  }

  double get _totalBalance {
    double total = 0;
    for (var entry in _walletBox.values) {
      if (entry is Map) {
        final amount = entry['amount'] as double;
        final type = entry['type'] as String;
        if (type == 'Income') {
          total += amount;
        } else {
          total -= amount;
        }
      }
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    final theme = Theme.of(context);
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [theme.colorScheme.primary, theme.colorScheme.secondary],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(context),
              _buildBalanceCard(theme),
              Expanded(child: _buildTransactionList(theme)),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTransactionDialog(context),
        backgroundColor: Colors.white,
        child: const Icon(Icons.add, color: Colors.blue),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          NavButton(icon: Icons.arrow_back, onPressed: () => Navigator.pop(context)),
          const SizedBox(width: 16),
          const Text("My Wallet", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
        ],
      ),
    );
  }

  Widget _buildBalanceCard(ThemeData theme) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.all(32),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 20, offset: const Offset(0, 10))
        ],
      ),
      child: Column(
        children: [
          const Text("Total Balance", style: TextStyle(color: Colors.white70, fontSize: 16)),
          const SizedBox(height: 8),
          Text("\$${_totalBalance.toStringAsFixed(2)}", 
            style: const TextStyle(color: Colors.white, fontSize: 48, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildTransactionList(ThemeData theme) {
    return ValueListenableBuilder(
      valueListenable: _walletBox.listenable(),
      builder: (context, Box box, _) {
        final entries = box.values.toList().reversed.toList();
        if (entries.isEmpty) {
          return const Center(child: Text("No transactions yet", style: TextStyle(color: Colors.white60)));
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          itemCount: entries.length,
          itemBuilder: (context, index) {
            final entry = entries[index] as Map;
            final isIncome = entry['type'] == 'Income';
            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              child: GlassContainer(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: (isIncome ? Colors.greenAccent : Colors.orangeAccent).withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isIncome ? Icons.arrow_upward : Icons.arrow_downward,
                        color: isIncome ? Colors.greenAccent : Colors.orangeAccent,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(entry['title'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                          Text(entry['date'], style: const TextStyle(color: Colors.white60, fontSize: 12)),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          "${isIncome ? '+' : '-'}\$${(entry['amount'] as double).toStringAsFixed(2)}",
                          style: TextStyle(
                            color: isIncome ? Colors.greenAccent : Colors.orangeAccent,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.white24, size: 20),
                          onPressed: () => _walletBox.deleteAt(box.length - 1 - index),
                        ),
                      ],
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

  void _showAddTransactionDialog(BuildContext context) {
    final titleController = TextEditingController();
    final amountController = TextEditingController();
    String type = 'Expense';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: Colors.transparent,
          contentPadding: EdgeInsets.zero,
          content: GlassContainer(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text("Add Transaction", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 24),
                TextField(
                  controller: titleController,
                  style: const TextStyle(color: Colors.white),
                  decoration: _inputDecoration("Title", Icons.title),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: Colors.white),
                  decoration: _inputDecoration("Amount", Icons.attach_money),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _typeButton("Expense", type == "Expense", () => setState(() => type = "Expense")),
                    const SizedBox(width: 12),
                    _typeButton("Income", type == "Income", () => setState(() => type = "Income")),
                  ],
                ),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: () {
                        if (titleController.text.isNotEmpty && amountController.text.isNotEmpty) {
                          _walletBox.add({
                            'title': titleController.text,
                            'amount': double.tryParse(amountController.text) ?? 0.0,
                            'type': type,
                            'date': "${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}",
                          });
                          Navigator.pop(context);
                        }
                      },
                      child: const Text("Add"),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _typeButton(String label, bool isSelected, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white.withOpacity(0.2) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isSelected ? Colors.white : Colors.white24),
          ),
          child: Center(
            child: Text(label, style: TextStyle(color: isSelected ? Colors.white : Colors.white60, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white70),
      prefixIcon: Icon(icon, color: Colors.white70),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.white24)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.white)),
    );
  }
}
