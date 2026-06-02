import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/constants/api_result.dart';
import '../../domain/usecases/get_support_contacts_usecase.dart';
import 'medicard_support_state.dart';

class MedicardSupportCubit extends Cubit<MedicardSupportState> {
  final GetSupportContactsUseCase _getSupportContactsUseCase;

  MedicardSupportCubit(this._getSupportContactsUseCase)
      : super(const MedicardSupportInitial());

  Future<void> load(String lang) async {
    emit(const MedicardSupportLoading());
    final result = await _getSupportContactsUseCase.call(lang);
    result.when(
      success: (data) => emit(MedicardSupportSuccess(data)),
      failure: (message) => emit(MedicardSupportFailed(message)),
    );
  }
}
