import 'package:bagdja_wallet/core/theme/app_colors.dart';
import 'package:bagdja_wallet/features/auth/bloc/auth_bloc.dart';
import 'package:bagdja_wallet/features/escrow/models/escrow_record_model.dart';
import 'package:bagdja_wallet/features/escrow/repositories/escrow_repository.dart';
import 'package:bagdja_wallet/injection.dart';
import 'package:bagdja_wallet/localization/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';

class EscrowDetailView extends StatefulWidget {
  final EscrowRecordModel escrow;

  const EscrowDetailView({super.key, required this.escrow});

  @override
  State<EscrowDetailView> createState() => _EscrowDetailViewState();
}

class _EscrowDetailViewState extends State<EscrowDetailView> with WidgetsBindingObserver {
  late EscrowRecordModel _escrow;
  bool _isLoading = false;
  bool _isInitializingPayment = false;
  bool _isReleasing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _escrow = widget.escrow;
    _loadEscrowDetail();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      // Refresh data ketika app kembali ke foreground (selesai bayar)
      _loadEscrowDetail();
    }
  }

  Future<void> _loadEscrowDetail() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final repo = sl<EscrowRepository>();
      final escrow = await repo.getEscrowById(_escrow.id);
      if (mounted) {
        setState(() {
          _escrow = escrow;
        });
      }
    } catch (e) {
      debugPrint('Error loading escrow detail: $e');
      // If fetch fails, we still use the initial data
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _initializeAndLaunchPayment() async {
    debugPrint('Initializing payment for escrow: ${_escrow.id}');
    setState(() {
      _isInitializingPayment = true;
    });
    try {
      final repo = sl<EscrowRepository>();
      final updatedEscrow = await repo.initializePayment(_escrow.id);
      debugPrint('Updated escrow with checkout URL: ${updatedEscrow.checkoutUrl}');
      setState(() {
        _escrow = updatedEscrow;
      });
      await _launchCheckoutUrl(updatedEscrow.checkoutUrl);
    } catch (e, stackTrace) {
      debugPrint('Error initializing payment: $e');
      debugPrintStack(stackTrace: stackTrace);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menginisialisasi pembayaran: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isInitializingPayment = false;
        });
      }
    }
  }

  Future<bool> _confirmReleaseEscrow() async {
    if (!mounted) return false;

    return await showDialog<bool>(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text(context.tr('escrow.releaseFunds')),
              content: Text(context.tr('escrow.releaseConfirmMessage')),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text(context.tr('common.tryAgain')),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: Text(context.tr('common.success')),
                ),
              ],
            );
          },
        ) ??
        false;
  }

  Future<void> _releaseEscrow() async {
    final confirm = await _confirmReleaseEscrow();
    if (!confirm) return;

    debugPrint('Releasing escrow: ${_escrow.id}');
    setState(() {
      _isReleasing = true;
    });
    try {
      final repo = sl<EscrowRepository>();
      final updatedEscrow = await repo.releaseEscrow(_escrow.id);
      if (mounted) {
        setState(() {
          _escrow = updatedEscrow;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.tr('escrow.releaseSuccess')),
            backgroundColor: AppColors.success,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e, stackTrace) {
      debugPrint('Error releasing escrow: $e');
      debugPrintStack(stackTrace: stackTrace);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal merilis escrow: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isReleasing = false;
        });
      }
    }
  }

  Future<void> _launchCheckoutUrl(String? url) async {
    debugPrint('Attempting to launch URL: $url');
    if (url == null || url.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('URL pembayaran tidak tersedia'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }
    try {
      final uri = Uri.parse(url);
      debugPrint('Parsed URI: $uri');
      bool canLaunch = await canLaunchUrl(uri);
      debugPrint('Can launch URL: $canLaunch');
      if (canLaunch) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Tidak dapat membuka URL pembayaran'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e, stackTrace) {
      debugPrint('Error launching URL: $e');
      debugPrintStack(stackTrace: stackTrace);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error membuka URL: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    bool isBuyer = false;
    bool isSeller = false;

    if (authState is AuthAuthenticated) {
      // Check if user is buyer (with username or email)
      if (authState.user.username != null &&
          authState.user.username!.toLowerCase() == _escrow.buyerIdentifier.toLowerCase()) {
        isBuyer = true;
      }
      if (authState.user.email != null &&
          authState.user.email!.toLowerCase() == _escrow.buyerIdentifier.toLowerCase()) {
        isBuyer = true;
      }

      // Check if user is seller (with username or email)
      if (authState.user.username != null &&
          authState.user.username!.toLowerCase() == _escrow.sellerIdentifier.toLowerCase()) {
        isSeller = true;
      }
      if (authState.user.email != null &&
          authState.user.email!.toLowerCase() == _escrow.sellerIdentifier.toLowerCase()) {
        isSeller = true;
      }
    }

    final canPay = isBuyer && _escrow.status.toLowerCase() == 'pending';
    final canRelease = isBuyer && _escrow.status.toLowerCase() == 'success';

    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('escrow.detailTitle')),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadEscrowDetail,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoSection(
                    context,
                    icon: Icons.shield,
                    title: context.tr('escrow.status'),
                    value: _escrow.status,
                    isStatus: true,
                  ),
                  const SizedBox(height: 24),
                  _buildInfoSection(
                    context,
                    icon: Icons.receipt,
                    title: context.tr('escrow.escrowId'),
                    value: _escrow.id,
                  ),
                  const SizedBox(height: 24),
                  _buildPartySection(
                    context,
                    label: context.tr('escrow.buyer'),
                    type: _escrow.buyerType,
                    identifier: _escrow.buyerIdentifier,
                    isCurrentUser: isBuyer,
                  ),
                  const SizedBox(height: 24),
                  _buildPartySection(
                    context,
                    label: context.tr('escrow.seller'),
                    type: _escrow.sellerType,
                    identifier: _escrow.sellerIdentifier,
                    isCurrentUser: isSeller,
                  ),
                  const SizedBox(height: 24),
                  _buildInfoSection(
                    context,
                    icon: Icons.attach_money,
                    title: context.tr('escrow.amount'),
                    value: NumberFormat.currency(locale: 'id_ID', symbol: '${_escrow.currency} ').format(_escrow.amount),
                  ),
                  const SizedBox(height: 24),
                  _buildInfoSection(
                    context,
                    icon: Icons.schedule,
                    title: context.tr('escrow.createdAt'),
                    value: DateFormat('dd MMM yyyy, HH:mm').format(_escrow.createdAt.toLocal()),
                  ),
                  if (_escrow.notes != null && _escrow.notes!.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    _buildInfoSection(
                      context,
                      icon: Icons.notes,
                      title: context.tr('escrow.notes'),
                      value: _escrow.notes!,
                    ),
                  ],
                  const SizedBox(height: 40),
                  if (canPay)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _isInitializingPayment
                            ? null
                            : (_escrow.checkoutUrl != null
                                ? () => _launchCheckoutUrl(_escrow.checkoutUrl)
                                : _initializeAndLaunchPayment),
                        icon: _isInitializingPayment
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : const Icon(Icons.payment),
                        label: Text(context.tr('escrow.payNow')),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.secondary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  if (canRelease) ...[
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _isReleasing ? null : _releaseEscrow,
                        icon: _isReleasing
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : const Icon(Icons.lock_open),
                        label: Text(context.tr('escrow.releaseFunds')),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
    );
  }

  Widget _buildInfoSection(BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
    bool isStatus = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isStatus ? _getStatusColor(_escrow.status).withOpacity(0.2) : AppColors.primary.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              size: 24,
              color: isStatus ? _getStatusColor(_escrow.status) : AppColors.primary,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    color: isStatus ? _getStatusColor(_escrow.status) : Colors.black87,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPartySection(BuildContext context, {
    required String label,
    required String type,
    required String identifier,
    required bool isCurrentUser,
  }) {

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: isCurrentUser ? Border.all(color: AppColors.primary, width: 2) : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
              if (isCurrentUser) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    context.tr('escrow.you'),
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
          Text(
            identifier,
            style: const TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            type,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'paid':
      case 'success':
      case 'completed':
        return Colors.green;
      case 'cancelled':
      case 'failed':
      case 'rejected':
      case 'refunded':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
