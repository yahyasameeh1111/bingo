import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/collection_point.dart';
import '../models/collection_schedule.dart';
import '../models/community_post.dart';
import '../models/household.dart';
import '../models/notification_item.dart';
import '../models/support_report.dart';
import '../models/waste_type.dart';
import '../repositories/collection_point_repository.dart';
import '../repositories/community_repository.dart';
import '../repositories/household_repository.dart';
import '../repositories/notification_repository.dart';
import '../repositories/schedule_repository.dart';
import '../repositories/support_repository.dart';
import '../repositories/waste_guide_repository.dart';
import '../services/auth_service.dart';
import '../services/preferences_service.dart';
import '../services/storage_service.dart';
import '../services/verification_service.dart';

// Services
final preferencesServiceProvider = Provider<PreferencesService>((ref) {
  throw UnimplementedError('Initialize via ProviderScope overrides');
});

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

final verificationServiceProvider = Provider<VerificationService>((ref) {
  return VerificationService();
});

final storageServiceProvider = Provider<StorageService>((ref) {
  return StorageService();
});

// Repositories
final householdRepositoryProvider = Provider<HouseholdRepository>((ref) {
  return HouseholdRepository();
});

final scheduleRepositoryProvider = Provider<ScheduleRepository>((ref) {
  return ScheduleRepository();
});

final wasteGuideRepositoryProvider = Provider<WasteGuideRepository>((ref) {
  return WasteGuideRepository();
});

final collectionPointRepositoryProvider = Provider<CollectionPointRepository>((ref) {
  return CollectionPointRepository();
});

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  final prefs = ref.watch(preferencesServiceProvider);
  return NotificationRepository(prefs: prefs);
});

final communityRepositoryProvider = Provider<CommunityRepository>((ref) {
  return CommunityRepository();
});

final supportRepositoryProvider = Provider<SupportRepository>((ref) {
  return SupportRepository();
});

// Auth State
final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(authServiceProvider).authStateChanges();
});

// Current Household Stream
final currentHouseholdProvider = StreamProvider<Household?>((ref) {
  final authUser = ref.watch(authStateProvider).value;
  if (authUser == null) return Stream.value(null);

  final hid = ref.watch(authServiceProvider).currentHouseholdId;
  if (hid == null || hid.isEmpty) return Stream.value(null);

  return ref.watch(householdRepositoryProvider).watchHousehold(hid);
});

// Schedules Stream
final schedulesStreamProvider = StreamProvider<List<CollectionSchedule>>((ref) {
  return ref.watch(scheduleRepositoryProvider).watchSchedules();
});

// Next Collection Provider
final nextCollectionProvider = Provider<ScheduledEvent?>((ref) {
  final schedules = ref.watch(schedulesStreamProvider).value ?? [];
  final household = ref.watch(currentHouseholdProvider).value;
  return ref.watch(scheduleRepositoryProvider).getNextCollection(
        schedules,
        panchayat: household?.panchayat,
      );
});

// Weekly Schedule Map (weekday 1..7 -> list of events)
final weeklyScheduleProvider = Provider<Map<int, List<ScheduledEvent>>>((ref) {
  final schedules = ref.watch(schedulesStreamProvider).value ?? [];
  final household = ref.watch(currentHouseholdProvider).value;
  return ref.watch(scheduleRepositoryProvider).getWeekEvents(
        schedules,
        panchayat: household?.panchayat,
      );
});

// Waste Types Stream
final wasteTypesStreamProvider = StreamProvider<List<WasteType>>((ref) {
  return ref.watch(wasteGuideRepositoryProvider).watchWasteTypes();
});

// Collection Points Stream
final collectionPointsStreamProvider = StreamProvider<List<CollectionPoint>>((ref) {
  return ref.watch(collectionPointRepositoryProvider).watchCollectionPoints();
});

// Assigned Collection Point
final assignedCollectionPointProvider = Provider<CollectionPoint?>((ref) {
  final points = ref.watch(collectionPointsStreamProvider).value ?? [];
  final household = ref.watch(currentHouseholdProvider).value;
  return ref.watch(collectionPointRepositoryProvider).findAssignedPoint(points, household?.point);
});

// Notifications Stream
final notificationsStreamProvider = StreamProvider<List<NotificationItem>>((ref) {
  final household = ref.watch(currentHouseholdProvider).value;
  return ref.watch(notificationRepositoryProvider).watchNotifications(
        householdId: household?.id,
        panchayat: household?.panchayat,
      );
});

// Unread Notifications Count
final unreadNotificationsCountProvider = Provider<int>((ref) {
  final list = ref.watch(notificationsStreamProvider).value ?? [];
  return list.where((n) => !n.isRead).length;
});

// Community Posts Stream
final communityPostsStreamProvider = StreamProvider<List<CommunityPost>>((ref) {
  return ref.watch(communityRepositoryProvider).watchPosts();
});

// Following UIDs Set Stream
final followingUidsStreamProvider = StreamProvider<Set<String>>((ref) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return Stream.value({});
  return ref.watch(communityRepositoryProvider).watchFollowingUids(user.uid);
});

// My Reports Stream
final myReportsStreamProvider = StreamProvider<List<SupportReport>>((ref) {
  final household = ref.watch(currentHouseholdProvider).value;
  if (household == null) return Stream.value([]);
  return ref.watch(supportRepositoryProvider).watchMyReports(household.id);
});

// Theme Mode Notifier
class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  final PreferencesService _prefs;

  ThemeModeNotifier(this._prefs) : super(_loadMode(_prefs));

  static ThemeMode _loadMode(PreferencesService prefs) {
    final mode = prefs.getThemeMode();
    if (mode == 'dark') return ThemeMode.dark;
    if (mode == 'system') return ThemeMode.system;
    return ThemeMode.light;
  }

  void setThemeMode(ThemeMode mode) {
    state = mode;
    String str = 'light';
    if (mode == ThemeMode.dark) str = 'dark';
    if (mode == ThemeMode.system) str = 'system';
    _prefs.setThemeMode(str);
  }

  void toggle() {
    setThemeMode(state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark);
  }
}

final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  final prefs = ref.watch(preferencesServiceProvider);
  return ThemeModeNotifier(prefs);
});
