import 'package:get_it/get_it.dart';
import 'package:giftginnie_ui/services/auth_service.dart';
import '../api/api_client.dart';
import '../api/auth_api_service.dart';
// import 'api/user_api_service.dart';
// import 'api/product_api_service.dart';


final GetIt serviceLocator = GetIt.instance;

void setupServiceLocator() {
  // Core
  serviceLocator.registerLazySingleton(() => ApiClient());
  
  // API Services
  serviceLocator.registerLazySingleton(() => AuthApiService(
    client: serviceLocator<ApiClient>(),
  ));
  
  // Business Logic Services
  serviceLocator.registerLazySingleton(() => AuthService(
    apiService: serviceLocator<AuthApiService>(),
  ));
}