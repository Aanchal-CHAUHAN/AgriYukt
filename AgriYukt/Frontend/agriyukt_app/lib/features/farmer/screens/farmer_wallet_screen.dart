import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'package:agriyukt_app/features/farmer/screens/bank_details_screen.dart'; // Ensure this import exists
import 'package:agriyukt_app/features/farmer/screens/withdrawal_screen.dart'; // Ensure this import exists

class FarmerWalletScreen extends StatelessWidget {
  const FarmerWalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userId = Supabase.instance.client.auth.currentUser!.id;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text("My Earnings"),
        backgroundColor: Colors.green[800],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const BankDetailsScreen())),
          )
        ],
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        // 🔥 REAL-TIME LISTENER
        stream: Supabase.instance.client
            .from('wallets')
            .stream(primaryKey: ['id']).eq('user_id', userId),
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No wallet active yet."));
          }

          final wallet = snapshot.data!.first;
          final double locked = (wallet['locked_amount'] ?? 0).toDouble();
          final double available = (wallet['available_amount'] ?? 0).toDouble();
          final double total = (wallet['total_earned'] ?? 0).toDouble();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. MAIN BALANCE CARD
                _buildMainCard(context, available, locked),

                const SizedBox(height: 25),

                // 2. STATS ROW
                Row(
                  children: [
                    Expanded(
                        child: _buildStatBox("Lifetime Earnings",
                            "₹${total.toStringAsFixed(0)}", Colors.blue)),
                    const SizedBox(width: 15),
                    Expanded(
                        child: _buildStatBox("In Escrow (Locked)",
                            "₹${locked.toStringAsFixed(0)}", Colors.orange)),
                  ],
                ),

                const SizedBox(height: 30),
                const Text("Transaction History",
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),

                // 3. TRANSACTION LIST
                _buildTransactions(userId),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildMainCard(BuildContext context, double available, double locked) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient:
            LinearGradient(colors: [Colors.green[800]!, Colors.green[600]!]),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.green.withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 5))
        ],
      ),
      child: Column(
        children: [
          const Text("Available to Withdraw",
              style: TextStyle(color: Colors.white70, fontSize: 14)),
          const SizedBox(height: 5),
          Text("₹${available.toStringAsFixed(2)}",
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 36,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: available > 0
                  ? () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) =>
                              WithdrawalScreen(availableBalance: available)))
                  : null,
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.green[800],
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10))),
              child: const Text("REQUEST WITHDRAWAL",
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
          if (locked > 0)
            Padding(
              padding: const EdgeInsets.only(top: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.lock, color: Colors.white70, size: 14),
                  const SizedBox(width: 5),
                  Text(
                      "₹${locked.toStringAsFixed(0)} is currently locked in orders",
                      style:
                          const TextStyle(color: Colors.white70, fontSize: 12)),
                ],
              ),
            )
        ],
      ),
    );
  }

  Widget _buildStatBox(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value,
              style: TextStyle(
                  fontSize: 20, fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        ],
      ),
    );
  }

  Widget _buildTransactions(String userId) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: Supabase.instance.client
          .from('transactions')
          .stream(primaryKey: ['id'])
          .eq('user_id', userId)
          .order('created_at'),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
              child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Text("No transactions yet")));
        }
        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: snapshot.data!.length,
          separatorBuilder: (_, __) => const Divider(),
          itemBuilder: (context, i) {
            final tx = snapshot.data![i];
            final bool isLocked = tx['status'] == 'locked';
            return ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(
                backgroundColor:
                    isLocked ? Colors.orange[50] : Colors.green[50],
                child: Icon(isLocked ? Icons.lock_clock : Icons.check,
                    color: isLocked ? Colors.orange : Colors.green, size: 20),
              ),
              title: Text(tx['description'] ?? "Transfer"),
              subtitle: Text(DateFormat('dd MMM, hh:mm a')
                  .format(DateTime.parse(tx['created_at']))),
              trailing: Text(
                "₹${tx['amount']}",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isLocked ? Colors.grey : Colors.black),
              ),
            );
          },
        );
      },
    );
  }
}
