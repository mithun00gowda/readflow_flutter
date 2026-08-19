import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:readflow/main.dart';
import 'package:readflow/services/notification_services.dart';
import 'package:readflow/services/stale_book_checker.dart';

final notificationServicesProviders = Provider<NotificationServices>((ref){
  return notificationServices;
});

final stalBookCheckerProviders = Provider<StaleBookChecker>((ref){
  return StaleBookChecker(ref.watch(notificationServicesProviders));
});