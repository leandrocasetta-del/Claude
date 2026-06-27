import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/investor_profile.dart';
import '../core/constants.dart';

class ProfileNotifier extends StateNotifier<AsyncValue<InvestorProfile?>> {
  ProfileNotifier() : super(const AsyncValue.loading()) {
    loadProfile();
  }

  Future<void> loadProfile() async {
    try {
      state = const AsyncValue.loading();
      final box = Hive.box(AppConstants.profilesBox);
      final data = box.get('current');
      if (data != null) {
        final profile = InvestorProfile.fromMap(data as Map);
        state = AsyncValue.data(profile);
      } else {
        state = const AsyncValue.data(null);
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> saveProfile(InvestorProfile profile) async {
    try {
      final box = Hive.box(AppConstants.profilesBox);
      await box.put('current', profile.toMap());
      state = AsyncValue.data(profile);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updateProfile(InvestorProfile profile) async {
    await saveProfile(profile.copyWith(updatedAt: DateTime.now()));
  }

  Future<void> clearProfile() async {
    try {
      final box = Hive.box(AppConstants.profilesBox);
      await box.delete('current');
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final profileProvider =
    StateNotifierProvider<ProfileNotifier, AsyncValue<InvestorProfile?>>(
  (ref) => ProfileNotifier(),
);
