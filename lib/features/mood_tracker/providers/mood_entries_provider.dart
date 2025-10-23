import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/mood_entry.dart';
import '../services/mood_service.dart';
import '../../auth/providers/auth_provider.dart';

final moodServiceProvider = Provider((ref) => MoodService());

final moodEntriesProvider = StateNotifierProvider<MoodEntriesNotifier, AsyncValue<List<MoodEntry>>>((ref) {
  return MoodEntriesNotifier(ref);
});

class MoodEntriesNotifier extends StateNotifier<AsyncValue<List<MoodEntry>>> {
  final Ref _ref;

  MoodEntriesNotifier(this._ref) : super(const AsyncValue.loading()) {
    loadEntries();
  }

  Future<void> loadEntries() async {
    state = const AsyncValue.loading();

    try {
      String userId = 'guest_user';

      try {
        final authService = _ref.read(authServiceProvider);
        final user = authService.currentUser;
        if (user != null && user.id != null) {
          userId = user.id!;
        }
      } catch (e) {
        // Use guest user if auth service fails
      }

      final moodService = _ref.read(moodServiceProvider);
      final entries = await moodService.getMoodEntries(userId);
      state = AsyncValue.data(entries);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> addEntry(MoodEntry entry) async {
    try {
      final moodService = _ref.read(moodServiceProvider);
      await moodService.saveMoodEntry(entry);
      await loadEntries();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> deleteEntry(String id) async {
    try {
      final moodService = _ref.read(moodServiceProvider);
      await moodService.deleteMoodEntry(id);
      await loadEntries();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  void refresh() {
    loadEntries();
  }
}
