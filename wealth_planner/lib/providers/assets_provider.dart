import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/asset.dart';
import '../core/constants.dart';

class AssetsNotifier extends StateNotifier<AsyncValue<List<Asset>>> {
  AssetsNotifier() : super(const AsyncValue.loading()) {
    loadAssets();
  }

  Future<void> loadAssets() async {
    try {
      state = const AsyncValue.loading();
      final box = Hive.box(AppConstants.assetsBox);
      final assets = <Asset>[];
      for (final key in box.keys) {
        final data = box.get(key);
        if (data != null) {
          try {
            assets.add(Asset.fromMap(data as Map));
          } catch (_) {}
        }
      }
      state = AsyncValue.data(assets);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> addAsset(Asset asset) async {
    try {
      final box = Hive.box(AppConstants.assetsBox);
      await box.put(asset.id, asset.toMap());
      final current = state.valueOrNull ?? [];
      state = AsyncValue.data([...current, asset]);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updateAsset(Asset asset) async {
    try {
      final box = Hive.box(AppConstants.assetsBox);
      await box.put(asset.id, asset.toMap());
      final current = state.valueOrNull ?? [];
      final updated = current.map((a) => a.id == asset.id ? asset : a).toList();
      state = AsyncValue.data(updated);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> deleteAsset(String id) async {
    try {
      final box = Hive.box(AppConstants.assetsBox);
      await box.delete(id);
      final current = state.valueOrNull ?? [];
      state = AsyncValue.data(current.where((a) => a.id != id).toList());
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  double getTotalPatrimony() {
    final assets = state.valueOrNull ?? [];
    return assets.fold(0.0, (sum, a) => sum + a.currentValue);
  }

  Map<String, double> getTotalByCategory() {
    final assets = state.valueOrNull ?? [];
    final Map<String, double> totals = {};
    for (final asset in assets) {
      final key = asset.category.displayName;
      totals[key] = (totals[key] ?? 0) + asset.currentValue;
    }
    return totals;
  }

  Map<String, double> getAllocationByCategory() {
    final totals = getTotalByCategory();
    final total = totals.values.fold(0.0, (a, b) => a + b);
    if (total == 0) return {};
    return totals.map((k, v) => MapEntry(k, v / total));
  }

  double getTotalOffshore() {
    final assets = state.valueOrNull ?? [];
    return assets
        .where((a) => a.isOffshore)
        .fold(0.0, (sum, a) => sum + a.currentValue);
  }
}

final assetsProvider =
    StateNotifierProvider<AssetsNotifier, AsyncValue<List<Asset>>>(
  (ref) => AssetsNotifier(),
);

final totalPatrimonyProvider = Provider<double>((ref) {
  final assetsAsync = ref.watch(assetsProvider);
  return assetsAsync.valueOrNull?.fold(0.0, (sum, a) => sum! + a.currentValue) ?? 0.0;
});

final allocationByCategoryProvider = Provider<Map<String, double>>((ref) {
  final notifier = ref.watch(assetsProvider.notifier);
  ref.watch(assetsProvider);
  return notifier.getAllocationByCategory();
});
