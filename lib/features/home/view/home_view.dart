import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bagdja_wallet/features/auth/bloc/auth_bloc.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
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
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: const Padding(
                  padding: EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      Text(
                        'Total Balance',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Rp 1.500.000',
                        style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Recent Transactions',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView(
                  children: const [
                    ListTile(
                      leading: CircleAvatar(child: Icon(Icons.arrow_downward, color: Colors.green)),
                      title: Text('Top Up'),
                      subtitle: Text('Bank Transfer'),
                      trailing: Text('+ Rp 500.000', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                    ),
                    ListTile(
                      leading: CircleAvatar(child: Icon(Icons.arrow_upward, color: Colors.red)),
                      title: Text('Payment'),
                      subtitle: Text('Merchant QRIS'),
                      trailing: Text('- Rp 150.000', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
