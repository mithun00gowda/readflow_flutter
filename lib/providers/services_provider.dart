import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:readflow/main.dart';
import 'package:readflow/services/image_picker_service.dart';
import 'package:readflow/services/notification_services.dart';
import 'package:readflow/services/stale_book_checker.dart';

final notificationServicesProviders = Provider<NotificationServices>((ref){
  return notificationServices;
});

final stalBookCheckerProviders = Provider<StaleBookChecker>((ref){
  return StaleBookChecker(ref.watch(notificationServicesProviders));
});

final imagePickerServiceProvider = Provider<ImagePickerService>((ref) => ImagePickerService());