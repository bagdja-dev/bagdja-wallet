import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:bagdja_wallet/features/auth/bloc/auth_bloc.dart';
import 'package:bagdja_wallet/features/wallet/bloc/wallet_bloc.dart';
import 'package:bagdja_wallet/features/wallet/bloc/wallet_state.dart';
import 'package:bagdja_wallet/features/wallet/bloc/wallet_event.dart';
import 'package:bagdja_wallet/features/wallet/models/wallet_model.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              context.read<AuthBloc>().add(const LogoutRequested());
            },
          )
        ],
      ),
      body: SafeArea(
        child: BlocBuilder<WalletBloc, WalletState>(
          builder: (context, state) {
            if (state is WalletLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is WalletError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, color: Colors.red, size: 48),
                      const SizedBox(height: 16),
                      Text(
                        state.message,
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () =>
                            context.read<WalletBloc>().add(const FetchWalletBalance()),
                        icon: const Icon(Icons.refresh),
                        label: const Text('Coba Lagi'),
                      ),
                    ],
                  ),
                ),
              );
            }

            if (state is WalletLoaded) {
              final wallets = state.wallets;
              final totalBalance = wallets.fold<double>(
                0,
                (sum, w) => sum + w.balance,
              );

              return RefreshIndicator(
                onRefresh: () async {
                  context.read<WalletBloc>().add(const FetchWalletBalance());
                },
                child: ListView(
                  padding: const EdgeInsets.all(16.0),
                  children: [
                    // Total Balance Summary Card
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 24.0, horizontal: 20.0),
                        child: Column(
                          children: [
                            const Text(
                              'Total Saldo',
                              style:
                                  TextStyle(fontSize: 14, color: Colors.grey),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              formatter.format(totalBalance),
                              style: const TextStyle(
                                  fontSize: 32, fontWeight: FontWeight.bold),
                            ),
                            if (wallets.length > 1)
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(
                                  'dari ${wallets.length} dompet',
                                  style: const TextStyle(
                                      fontSize: 12, color: Colors.grey),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Per-Wallet Cards
                    const Text(
                      'Dompet Saya',
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),

                    ...wallets.map((wallet) => _WalletCard(
                          wallet: wallet,
                          formatter: formatter,
                        )),

                    const SizedBox(height: 24),

                    // Recent Transactions (placeholder)
                    const Text(
                      'Transaksi Terbaru',
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const ListTile(
                      leading: CircleAvatar(
                          child: Icon(Icons.arrow_downward,
                              color: Colors.green)),
                      title: Text('Top Up'),
                      subtitle: Text('Bank Transfer'),
                      trailing: Text('+ Rp 500.000',
                          style: TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold)),
                    ),
                    const ListTile(
                      leading: CircleAvatar(
                          child: Icon(Icons.arrow_upward,
                              color: Colors.red)),
                      title: Text('Payment'),
                      subtitle: Text('Merchant QRIS'),
                      trailing: Text('- Rp 150.000',
                          style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              );
            }

            // WalletInitial — empty state
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}

class _WalletCard extends StatelessWidget {
  final WalletModel wallet;
  final NumberFormat formatter;

  const _WalletCard({required this.wallet, required this.formatter});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor:
              wallet.isActive ? Colors.green.shade100 : Colors.grey.shade200,
          child: Text(
            wallet.currencyCode,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: wallet.isActive ? Colors.green.shade800 : Colors.grey,
            ),
          ),
        ),
        title: Text(
          formatter.format(wallet.balance),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Provider: ${wallet.provider}'),
            if (wallet.heldBalance > 0)
              Text(
                'Ditahan: ${formatter.format(wallet.heldBalance)}',
                style: const TextStyle(color: Colors.orange, fontSize: 12),
              ),
          ],
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: wallet.isActive
                ? Colors.green.shade50
                : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            wallet.isActive ? 'Aktif' : 'Nonaktif',
            style: TextStyle(
              fontSize: 12,
              color:
                  wallet.isActive ? Colors.green.shade700 : Colors.grey,
            ),
          ),
        ),
      ),
    );
  }
}
