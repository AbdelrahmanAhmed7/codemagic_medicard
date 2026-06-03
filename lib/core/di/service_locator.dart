import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

import '../../domain/medicard_repository.dart';
import '../../domain/usecases/activate_card_usecase.dart';
import '../../domain/usecases/get_home_info_usecase.dart';
import '../../domain/usecases/get_personal_info_usecase.dart';
import '../../domain/usecases/get_support_contacts_usecase.dart';
import '../../domain/usecases/get_top_providers_slider_usecase.dart';
import '../../domain/usecases/login_card_usecase.dart';
import '../../domain/usecases/update_profile_usecase.dart';
import '../../medicard_network/logic/medicard_network_cubit.dart';
import '../../medicard_network/repository/medicard_network_repository.dart';
import '../../medicard_network/service/medicard_network_api_service.dart';
import '../../presentation/logic/medicard_activation_cubit.dart';
import '../../presentation/logic/medicard_edit_profile_cubit.dart';
import '../../presentation/logic/medicard_home_cubit.dart';
import '../../presentation/logic/medicard_login_cubit.dart';
import '../../presentation/logic/medicard_support_cubit.dart';
import '../../repository/medicard_repository_impl.dart';
import '../../service/medicard_api_service.dart';
import '../network/dio_factory.dart';
import '../services/location_service.dart';
import '../services/url_launcher_service.dart';

final GetIt sl = GetIt.instance;

Future<void> setupServiceLocator() async {
  final Dio medicardDio = await DioFactory.getDioForMedicard();

  sl.registerLazySingleton<MedicardApiService>(
    () => MedicardApiService(medicardDio),
  );
  sl.registerLazySingleton<MedicardNetworkApiService>(
    () => MedicardNetworkApiService(medicardDio),
  );

  sl.registerLazySingleton<MedicardRepository>(
    () => MedicardRepositoryImpl(sl()),
  );
  sl.registerLazySingleton<MedicardNetworkRepository>(
    () => MedicardNetworkRepository(sl()),
  );
  sl.registerLazySingleton<LocationService>(() => LocationService());
  sl.registerLazySingleton<UrlLauncherService>(() => UrlLauncherService());

  // UseCases
  sl.registerFactory<ActivateCardUseCase>(() => ActivateCardUseCase(sl()));
  sl.registerFactory<LoginCardUseCase>(() => LoginCardUseCase(sl()));
  sl.registerFactory<GetHomeInfoUseCase>(() => GetHomeInfoUseCase(sl()));
  sl.registerFactory<GetPersonalInfoUseCase>(() => GetPersonalInfoUseCase(sl()));
  sl.registerFactory<GetSupportContactsUseCase>(
    () => GetSupportContactsUseCase(sl()),
  );
  sl.registerFactory<UpdateProfileUseCase>(() => UpdateProfileUseCase(sl()));
  sl.registerFactory<GetTopProvidersForSliderUseCase>(
    () => GetTopProvidersForSliderUseCase(sl()),
  );

  // Cubits
  sl.registerFactory<MedicardActivationCubit>(
    () => MedicardActivationCubit(sl()),
  );
  sl.registerFactory<MedicardLoginCubit>(() => MedicardLoginCubit(sl()));
  sl.registerFactory<MedicardHomeCubit>(
    () => MedicardHomeCubit(sl(), sl(), sl()),
  );
  sl.registerFactory<MedicardSupportCubit>(() => MedicardSupportCubit(sl()));
  sl.registerFactory<MedicardEditProfileCubit>(
    () => MedicardEditProfileCubit(sl()),
  );
  sl.registerFactory<MedicardNetworkCubit>(() => MedicardNetworkCubit(sl()));
}
