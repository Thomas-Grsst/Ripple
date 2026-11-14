import '../entities/app_customization.dart';

abstract interface class AppCustomizationGateway {
  Future<AppCustomization> load();

  Future<void> save(AppCustomization customization);
}
