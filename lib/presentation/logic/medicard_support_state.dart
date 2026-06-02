
import '../../data/card_support_contact_response_model.dart';

abstract class MedicardSupportState {
  const MedicardSupportState();
}

class MedicardSupportInitial extends MedicardSupportState {
  const MedicardSupportInitial();
}

class MedicardSupportLoading extends MedicardSupportState {
  const MedicardSupportLoading();
}

class MedicardSupportSuccess extends MedicardSupportState {
  final CardSupportContactResponseModel response;

  const MedicardSupportSuccess(this.response);
}

class MedicardSupportFailed extends MedicardSupportState {
  final String error;

  const MedicardSupportFailed(this.error);
}
