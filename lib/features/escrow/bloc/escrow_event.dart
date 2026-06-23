import 'package:bagdja_wallet/features/escrow/models/create_escrow_invoice_dto.dart';
import 'package:bagdja_wallet/shared/models/wallet_model.dart';

abstract class EscrowEvent {}

class CreateEscrowInvoice extends EscrowEvent {
  final CreateEscrowInvoiceDto dto;

  CreateEscrowInvoice({required this.dto});
}

// ✨ NEW: UI state change events
class SelectWallet extends EscrowEvent {
  final WalletModel wallet;

  SelectWallet({required this.wallet});
}

class SelectUserPosition extends EscrowEvent {
  final String position; // 'buyer' or 'seller'

  SelectUserPosition({required this.position});
}

class SelectPartnerType extends EscrowEvent {
  final String type; // 'personal' or 'organization'

  SelectPartnerType({required this.type});
}

class ValidatePartnerIdentifier extends EscrowEvent {
  final String identifier;
  final String partnerType; // 'personal' or 'organization'
  final String currency;

  ValidatePartnerIdentifier({
    required this.identifier,
    required this.partnerType,
    required this.currency,
  });
}

class ClearValidation extends EscrowEvent {
  ClearValidation();
}
