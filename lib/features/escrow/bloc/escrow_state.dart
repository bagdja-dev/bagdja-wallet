import 'package:bagdja_wallet/features/escrow/models/escrow_record_model.dart';
import 'package:bagdja_wallet/shared/models/wallet_model.dart';

abstract class EscrowState {}

class EscrowInitial extends EscrowState {}

// ✨ Main form state - manages all UI and validation state
class EscrowFormState extends EscrowState {
  final WalletModel? selectedWallet;
  final WalletModel? partnerWallet;
  final String userPosition; // 'buyer' or 'seller'
  final String partnerType; // 'personal' or 'organization'
  final IdentifierValidationState validationState;
  final bool isCreating;
  final String? creationError;

  EscrowFormState({
    this.selectedWallet,
    this.partnerWallet,
    this.userPosition = 'buyer',
    this.partnerType = 'personal',
    this.validationState = const ValidationIdle(),
    this.isCreating = false,
    this.creationError,
  });

  EscrowFormState copyWith({
    WalletModel? selectedWallet,
    WalletModel? partnerWallet,
    String? userPosition,
    String? partnerType,
    IdentifierValidationState? validationState,
    bool? isCreating,
    String? creationError,
  }) =>
      EscrowFormState(
        selectedWallet: selectedWallet ?? this.selectedWallet,
        partnerWallet: partnerWallet ?? this.partnerWallet,
        userPosition: userPosition ?? this.userPosition,
        partnerType: partnerType ?? this.partnerType,
        validationState: validationState ?? this.validationState,
        isCreating: isCreating ?? this.isCreating,
        creationError: creationError ?? this.creationError,
      );
}

class EscrowCreated extends EscrowState {
  final EscrowRecordModel escrowRecord;

  EscrowCreated({required this.escrowRecord});
}

class EscrowError extends EscrowState {
  final String message;

  EscrowError({required this.message});
}

// ✨ Validation state hierarchy
abstract class IdentifierValidationState {
  const IdentifierValidationState();
}

class ValidationIdle extends IdentifierValidationState {
  const ValidationIdle();
}

class ValidationLoading extends IdentifierValidationState {
  const ValidationLoading();
}

class ValidationSuccess extends IdentifierValidationState {
  final String message;

  const ValidationSuccess({required this.message});
}

class ValidationFailure extends IdentifierValidationState {
  final String message;

  const ValidationFailure({required this.message});
}
