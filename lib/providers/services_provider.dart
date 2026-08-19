import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:readflow/main.dart';
import 'package:readflow/services/notification_services.dart';

final notificationServicesProviders = Provider<NotificationServices>((ref){
  return notificationServices;
});