
import 'package:bagdja_wallet/core/theme/app_colors.dart';
import 'package:bagdja_wallet/core/utils/currency_input_formatter.dart';
import 'package:bagdja_wallet/shared/repositories/wallet_repository.dart';
import 'package:bagdja_wallet/injection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

const List<int> _topUpPresets = [50000, 100000, 250000, 500000];

class TopUpBottomSheet extends StatefulWidget {
  final String currencyCode;
  final bool isPersonal;
  final String? organizationId;
  final VoidCallback? onClose;

  const TopUpBottomSheet({
    super.key,
    required this.currencyCode,
    required this.isPersonal,
    this.organizationId,
    this.onClose,
  });

  @override
  State<TopUpBottomSheet> createState() => _TopUpBottomSheetState();
}

class _TopUpBottomSheetState extends State<TopUpBottomSheet> {
  final TextEditingController _amountController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
  final storage = const FlutterSecureStorage();
  final WalletRepository walletRepo = sl<WalletRepository>();

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  int? getAmount(String text) {
    if (text.isEmpty) return null;
    String digits = text.replaceAll(RegExp(r'[^0-9]'), '');
    return int.tryParse(digits);
  }

  Future<void> _handleTopUp() async {
    if (_amountController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Masukkan jumlah top up';
      });
      return;
    }

    final amount = getAmount(_amountController.text);
    if (amount == null || amount <= 0) {
      setState(() {
        _errorMessage = 'Masukkan jumlah yang valid';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = widget.isPersonal
          ? await walletRepo.createPersonalTopup(
              amount: amount,
              currency: widget.currencyCode,
              successRedirectUrl: 'com.bagdja.wallet://topup/success',
              failureRedirectUrl: 'com.bagdja.wallet://topup/failure',
            )
          : await walletRepo.createOrganizationTopup(
              amount: amount,
              currency: widget.currencyCode,
              organizationId: widget.organizationId!,
              successRedirectUrl: 'com.bagdja.wallet://topup/success',
              failureRedirectUrl: 'com.bagdja.wallet://topup/failure',
            );

      if (response.checkoutUrl != null) {
        //tutup modal
        
        // ignore: use_build_context_synchronously
        Navigator.pop(context);

        String checkoutUrl = response.checkoutUrl!;

        final Uri url = Uri.parse(checkoutUrl);

        final accessToken = await storage.read(key: 'access_token');
        final Uri finalUrl;
        if (accessToken != null) {
          final params = Map<String, dynamic>.from(url.queryParameters);
          params['auth_token'] = accessToken;
          finalUrl = url.replace(queryParameters: params);
        } else {
          finalUrl = url;
        }
        final launched = await launchUrl(
          finalUrl,
          mode: LaunchMode.platformDefault,
        );
        
        if (launched) {
        } else {
          setState(() {
            _errorMessage = 'Tidak dapat membuka halaman pembayaran';
          });
        }
      } else {
        setState(() {
          _errorMessage = 'URL pembayaran tidak tersedia';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
              const Text(
                'Top Up Wallet',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: widget.onClose,
              ),
            ],
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _amountController,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              CurrencyInputFormatter(),
            ],
            decoration: InputDecoration(
              labelText: 'Jumlah (${widget.currencyCode})',
              border: const OutlineInputBorder(),
              errorText: _errorMessage,
              prefixText: '${widget.currencyCode} ',
            ),
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _topUpPresets.map((preset) {
              return ElevatedButton(
                onPressed: () {
                  setState(() {
                    _amountController.text = CurrencyInputFormatter.format(preset);
                    _errorMessage = null;
                  });
                },
                style: ElevatedButton.styleFrom(
                  // ignore: deprecated_member_use
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                  foregroundColor: AppColors.primary,
                ),
                child: Text(CurrencyInputFormatter.format(preset)),
              );
            }).toList(),
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: _isLoading ? null : _handleTopUp,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 50),
            ),
            child: _isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text('Lanjutkan Pembayaran'),
          ),
        ],
      ),
    ));
  }
}
