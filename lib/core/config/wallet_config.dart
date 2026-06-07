
class WalletConfig {
  static const List<SupportedWallet> supportedWallets = [
    SupportedWallet(
      currencyCode: 'IDR',
      currencyName: 'Indonesian Rupiah',
      symbol: 'Rp',
    ),
    // SupportedWallet(
    //   currencyCode: 'USD',
    //   currencyName: 'US Dollar',
    //   symbol: '\$',
    // ),
  ];
}

class SupportedWallet {
  final String currencyCode;
  final String currencyName;
  final String symbol;

  const SupportedWallet({
    required this.currencyCode,
    required this.currencyName,
    required this.symbol,
  });
}

