import 'dart:async';
import 'package:bagdja_wallet/core/utils/widget_extensions.dart';
import 'package:bagdja_wallet/features/auth/bloc/auth_bloc.dart';
import 'package:bagdja_wallet/features/escrow/bloc/escrow_bloc.dart';
import 'package:bagdja_wallet/features/escrow/bloc/escrow_event.dart';
import 'package:bagdja_wallet/features/escrow/bloc/escrow_state.dart';
import 'package:bagdja_wallet/features/escrow/models/create_escrow_invoice_dto.dart';
import 'package:bagdja_wallet/features/escrow/view/widgets/index.dart';
import 'package:bagdja_wallet/features/wallet/bloc/wallet_bloc.dart';
import 'package:bagdja_wallet/features/wallet/bloc/wallet_event.dart' as wallet_event;
import 'package:bagdja_wallet/features/wallet/bloc/wallet_state.dart';
import 'package:bagdja_wallet/localization/main.dart';
import 'package:bagdja_wallet/shared/models/wallet_model.dart';
import 'package:bagdja_wallet/shared/models/organization_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

final sl = GetIt.instance;

class CreateEscrowInvoiceView extends StatelessWidget {
  const CreateEscrowInvoiceView({super.key});

  @override
  Widget build(BuildContext context) {
    // ✨ Provide EscrowBloc from service locator
    return BlocProvider(
      create: (context) => sl<EscrowBloc>(),
      child: const _CreateEscrowInvoiceContent(),
    );
  }
}

class _CreateEscrowInvoiceContent extends StatefulWidget {
  const _CreateEscrowInvoiceContent();

  @override
  State<_CreateEscrowInvoiceContent> createState() =>
      _CreateEscrowInvoiceContentState();
}

class _CreateEscrowInvoiceContentState
    extends State<_CreateEscrowInvoiceContent> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _partnerIdentifierController = TextEditingController();

  // ✨ REMOVED: All local state (_selectedWallet, _userPosition, _partnerType, _isValidating, etc.)
  // Everything is now managed by BLoC
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final walletBloc = context.read<WalletBloc>();
        if (walletBloc.state is WalletInitial) {
          walletBloc.add(const wallet_event.FetchWalletBalance());
        }
        // ✨ Initialize EscrowBloc with EscrowFormState
        // Will set initial wallet when WalletLoaded state arrives
      }
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    _partnerIdentifierController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onIdentifierChanged() {
    _debounceTimer?.cancel();
    final escrowBloc = context.read<EscrowBloc>();

    if (_partnerIdentifierController.text.isEmpty) {
      // ✨ Dispatch clear event
      escrowBloc.add(ClearValidation());
      return;
    }

    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      _validateIdentifier();
    });
  }

  Future<void> _validateIdentifier() async {
    final escrowBloc = context.read<EscrowBloc>();
    final escrowState = escrowBloc.state;
    
    if (escrowState is EscrowFormState) {
      escrowBloc.add(
        ValidatePartnerIdentifier(
          identifier: _partnerIdentifierController.text,
          partnerType: escrowState.partnerType,
          currency: escrowState.selectedWallet?.currencyCode ?? 'IDR',
        ),
      );
    }
  }

  void _submitForm() {
    if (!_formKey.currentState!.validate()) return;

    // ✨ Get state from BLoC
    final escrowState = context.read<EscrowBloc>().state;
    final authState = context.read<AuthBloc>().state;
    
    if (escrowState is! EscrowFormState || authState is! AuthAuthenticated) return;
    
    final isValidIdentifier = escrowState.validationState is ValidationSuccess;
    if (!isValidIdentifier) return;

    final amountText = _amountController.text.replaceAll(
      RegExp(r'[^0-9]'),
      '',
    );
    final amount = double.tryParse(amountText) ?? 0;

    // Gunakan username atau email sebagai identifier untuk current user
    final myIdentifier = authState.user.username ?? authState.user.email ?? authState.user.userId;

    final dto = CreateEscrowInvoiceDto(
      buyerType: escrowState.userPosition == 'buyer'
          ? 'personal'
          : escrowState.partnerType,
      buyerIdentifier: escrowState.userPosition == 'buyer'
          ? myIdentifier
          : _partnerIdentifierController.text,
      sellerType: escrowState.userPosition == 'seller'
          ? 'personal'
          : escrowState.partnerType,
      sellerIdentifier: escrowState.userPosition == 'seller'
          ? myIdentifier
          : _partnerIdentifierController.text,
      buyerWalletId:
          escrowState.userPosition == 'buyer' ? escrowState.selectedWallet?.id : escrowState.partnerWallet?.id,
      sellerWalletId:
          escrowState.userPosition == 'seller' ? escrowState.selectedWallet?.id : escrowState.partnerWallet?.id,
      amount: amount,
      currency: escrowState.partnerWallet?.currencyCode ?? 'IDR',
    );

    context.read<EscrowBloc>().add(CreateEscrowInvoice(dto: dto));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MultiBlocListener(
        listeners: [
          BlocListener<EscrowBloc, EscrowState>(
            listener: (context, state) {
              // ✨ Only handle side effects (snackbars, navigation)
              // State UI updates are handled by BlocBuilder
              if (state is EscrowCreated) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(context.tr('escrow.created'))),
                );
                Navigator.pop(context);
              } else if (state is EscrowError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
          ),
        ],
        child: SafeArea(
          child: Stack(
            children: [
              Align(
                alignment: AlignmentGeometry.topStart,
                child: Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back, size: 24),
                            onPressed: () => Navigator.pop(context),
                          ),
                          Text(context.tr('escrow.create')),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: 150,
                      child: BlocBuilder<WalletBloc, WalletState>(
                        builder: (context, walletState) {
                          if (walletState is WalletLoaded) {
                            return SizedBox(
                              width: 200,
                              child: _WalletOwnerSelector(
                                walletOwners: walletState.walletOwners,
                                selectedOwner: walletState.selectedWalletOwner,
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 50),
                child: BlocBuilder<WalletBloc, WalletState>(
                  builder: (context, walletState) {
                    switch (walletState) {
                      case WalletLoading():
                        return const _LoadingEscrowView();
                      case WalletError(message: final error):
                        return _ErrorEscrowView(message: error);
                      case WalletLoaded():
                        return _LoadedEscrowView(
                          formKey: _formKey,
                          walletState: walletState,
                          partnerIdentifierController:
                              _partnerIdentifierController,
                          amountController: _amountController,
                          onIdentifierChanged: _onIdentifierChanged,
                        );
                      default:
                        return const SizedBox.shrink();
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BlocBuilder<EscrowBloc, EscrowState>(
        builder: (context, escrowState) {
          final isCreating = escrowState is EscrowFormState && escrowState.isCreating;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
            child: EscrowCreateButton(
              isLoading: isCreating,
              onPressed: _submitForm,
            ),
          );
        },
      ),
    );
  }
}

class _LoadingEscrowView extends StatelessWidget {
  const _LoadingEscrowView();

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }
}

class _ErrorEscrowView extends StatelessWidget {
  final String message;

  const _ErrorEscrowView({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 48),
          Text(message, style: const TextStyle(color: Colors.red)),
          ElevatedButton.icon(
            onPressed: () =>
                context.read<WalletBloc>().add(const wallet_event.FetchWalletBalance()),
            icon: const Icon(Icons.refresh),
            label: Text(context.tr('common.tryAgain')),
          ),
        ],
      ),
    );
  }
}

class _LoadedEscrowView extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final WalletLoaded walletState;
  final TextEditingController partnerIdentifierController;
  final TextEditingController amountController;
  final VoidCallback onIdentifierChanged;

  const _LoadedEscrowView({
    required this.formKey,
    required this.walletState,
    required this.partnerIdentifierController,
    required this.amountController,
    required this.onIdentifierChanged,
  });

  @override
  Widget build(BuildContext context) {
    // ✨ Read all form state from BLoC
    return BlocBuilder<EscrowBloc, EscrowState>(
      builder: (context, escrowState) {
        if (escrowState is! EscrowFormState) {
          return const SizedBox.shrink();
        }

        final activeWallets =
            walletState.wallets.where((w) => w.isActive).toList();
        WalletModel? currentWallet = escrowState.selectedWallet;

        if (currentWallet == null ||
            !activeWallets.any((w) => w.id == currentWallet!.id)) {
          currentWallet = activeWallets.isNotEmpty
              ? activeWallets.firstWhere(
                  (w) => w.isActive,
                  orElse: () => activeWallets.first,
                )
              : null;

          // Update BLoC state with the selected wallet AFTER the build phase
          if (currentWallet != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              context.read<EscrowBloc>().add(SelectWallet(wallet: currentWallet!));
            });
          }
        }

        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  EscrowPositionSelector(
                    selectedPosition: escrowState.userPosition,
                    onPositionSelected: (position) {
                      context
                          .read<EscrowBloc>()
                          .add(SelectUserPosition(position: position));
                    },
                  ),
                  EscrowWalletSelector(
                    wallets: activeWallets,
                    selectedWallet: currentWallet,
                    walletOwner: walletState.selectedWalletOwner,
                    onWalletSelected: (wallet) {
                      context.read<EscrowBloc>().add(SelectWallet(wallet: wallet));
                    },
                  ),
                  EscrowPartnerPositionSelector(
                    selectedPartnerType: escrowState.partnerType,
                    onPartnerTypeSelected: (type) {
                      context.read<EscrowBloc>().add(SelectPartnerType(type: type));
                      if (partnerIdentifierController.text.isNotEmpty) {
                        // Trigger validation with new partner type
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          context.read<EscrowBloc>().add(
                            ValidatePartnerIdentifier(
                              identifier: partnerIdentifierController.text,
                              partnerType: type,
                              currency: currentWallet?.currencyCode ?? 'IDR',
                            ),
                          );
                        });
                      }
                    },
                  ),
                  _PartnerIdentifierInput(
                    controller: partnerIdentifierController,
                    labelText: escrowState.partnerType == 'personal'
                        ? 'Username'
                        : 'Org ID',
                    validationState: escrowState.validationState,
                    onChanged: onIdentifierChanged,
                  ),
                  EscrowAmountInput(
                    controller: amountController,
                    currencyCode: currentWallet?.currencyCode ?? 'IDR',
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter amount';
                      }
                      final amountText = value.replaceAll(RegExp(r'[^0-9]'), '');
                      final amount = double.tryParse(amountText) ?? 0;
                      if (amount <= 0) {
                        return 'Amount must be greater than 0';
                      }
                      return null;
                    },
                  ),
                ].withGap(15),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _WalletOwnerSelector extends StatelessWidget {
  final List<WalletOwner> walletOwners;
  final WalletOwner? selectedOwner;

  const _WalletOwnerSelector({
    required this.walletOwners,
    required this.selectedOwner,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<WalletOwner>(
          value: selectedOwner,
          isDense: true,
          isExpanded: true,
          items: walletOwners.map((owner) {
            return DropdownMenuItem<WalletOwner>(
              value: owner,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(owner.name),
                  const SizedBox(width: 8),
                  Icon(
                    owner.isPersonal ? Icons.person : Icons.business,
                    size: 18,
                  ),
                ],
              ),
            );
          }).toList(),
          onChanged: (owner) {
            if (owner != null) {
              context.read<WalletBloc>().add(wallet_event.SelectWalletOwner(owner));
            }
          },
        ),
      ),
    );
  }
}

class _PartnerIdentifierInput extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final IdentifierValidationState validationState;
  final VoidCallback onChanged;

  const _PartnerIdentifierInput({
    required this.controller,
    required this.labelText,
    required this.validationState,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isValidating = validationState is ValidationLoading;
    final isValid = validationState is ValidationSuccess;
    final validationMessage = switch (validationState) {
      ValidationSuccess(message: final msg) => msg,
      ValidationFailure(message: final msg) => msg,
      _ => null,
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.tr('escrow.findUserOrOrgId'),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 12),
        EscrowPartnerIdentifierInput(
          controller: controller,
          labelText: labelText,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter partner identifier';
            }
            if (isValid != true) {
              return 'Partner identifier not valid';
            }
            return null;
          },
          isValidating: isValidating,
          isValid: isValid ? true : (validationMessage == null ? null : false),
          validationMessage: validationMessage,
          onChanged: onChanged,
        ),
      ],
    );
  }
}
