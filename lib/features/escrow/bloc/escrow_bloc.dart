import 'package:bloc/bloc.dart';
import 'package:bagdja_wallet/features/escrow/bloc/escrow_event.dart';
import 'package:bagdja_wallet/features/escrow/bloc/escrow_state.dart';
import 'package:bagdja_wallet/features/escrow/repositories/escrow_repository.dart';

class EscrowBloc extends Bloc<EscrowEvent, EscrowState> {
  final EscrowRepository escrowRepository;

  EscrowBloc({required this.escrowRepository}) 
      : super(EscrowFormState()) {  // ✨ Initialize with EscrowFormState
    on<CreateEscrowInvoice>(_onCreateEscrowInvoice);
    on<ValidatePartnerIdentifier>(_onValidatePartnerIdentifier);
    on<SelectWallet>(_onSelectWallet);
    on<SelectUserPosition>(_onSelectUserPosition);
    on<SelectPartnerType>(_onSelectPartnerType);
    on<ClearValidation>(_onClearValidation);
  }

  Future<void> _onCreateEscrowInvoice(
    CreateEscrowInvoice event,
    Emitter<EscrowState> emit,
  ) async {
    // Get current form state
    final currentState = state;
    final formState = currentState is EscrowFormState
        ? currentState
        : EscrowFormState();

    // Update to creating state
    emit(formState.copyWith(isCreating: true, creationError: null));

    try {
      final escrowRecord = await escrowRepository.createEscrowInvoice(event.dto);
      emit(EscrowCreated(escrowRecord: escrowRecord));
    } catch (e) {
      emit(formState.copyWith(isCreating: false, creationError: e.toString()));
    }
  }

  // ✨ Handler untuk validation
  Future<void> _onValidatePartnerIdentifier(
    ValidatePartnerIdentifier event,
    Emitter<EscrowState> emit,
  ) async {
    // Get current form state
    final currentState = state;
    final formState = currentState is EscrowFormState
        ? currentState
        : EscrowFormState();

    emit(formState.copyWith(
      validationState: const ValidationLoading(),
    ));

    try {
      if (event.partnerType == 'personal') {
        final user = await escrowRepository.validateUserByIdentifier(event.identifier);
        emit(formState.copyWith(
          validationState: const ValidationSuccess(message: 'Username found!'),
        ));
        //get wallet by userid and currency
        final wallet = await escrowRepository.getUserWallet(user['id'], event.currency);
        emit(formState.copyWith(
          validationState: const ValidationSuccess(message: 'Wallet found!'),
          partnerWallet: wallet,
        ));
      } else {
        final org = await escrowRepository.validateOrgByIdentifier(event.identifier);
        //get wallet by orgid and currency
        final wallet = await escrowRepository.getOrganizationWallet(org['id'], event.currency);
        emit(formState.copyWith(
          validationState: const ValidationSuccess(message: 'Organization found!'),
          partnerWallet: wallet,
        ));
      }
    } catch (e) {
      emit(formState.copyWith(
        validationState: ValidationFailure(message: e.toString()),
      ));
    }
  }

  // ✨ NEW: Handler untuk select wallet
  Future<void> _onSelectWallet(
    SelectWallet event,
    Emitter<EscrowState> emit,
  ) async {
    final currentState = state;
    final formState = currentState is EscrowFormState
        ? currentState
        : EscrowFormState();

    emit(formState.copyWith(selectedWallet: event.wallet));
  }

  // ✨ NEW: Handler untuk select user position
  Future<void> _onSelectUserPosition(
    SelectUserPosition event,
    Emitter<EscrowState> emit,
  ) async {
    final currentState = state;
    final formState = currentState is EscrowFormState
        ? currentState
        : EscrowFormState();

    emit(formState.copyWith(userPosition: event.position));
  }

  // ✨ NEW: Handler untuk select partner type
  Future<void> _onSelectPartnerType(
    SelectPartnerType event,
    Emitter<EscrowState> emit,
  ) async {
    final currentState = state;
    final formState = currentState is EscrowFormState
        ? currentState
        : EscrowFormState();

    emit(formState.copyWith(partnerType: event.type));
  }

  // ✨ NEW: Handler untuk clear validation
  Future<void> _onClearValidation(
    ClearValidation event,
    Emitter<EscrowState> emit,
  ) async {
    final currentState = state;
    final formState = currentState is EscrowFormState
        ? currentState
        : EscrowFormState();

    emit(formState.copyWith(
      validationState: const ValidationIdle(),
    ));
  }
}
