import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../app/theme.dart';
import '../models/mood_entry.dart';
import '../providers/mood_entries_provider.dart';

class MoodLogScreen extends ConsumerStatefulWidget {
  const MoodLogScreen({super.key});

  @override
  ConsumerState<MoodLogScreen> createState() => _MoodLogScreenState();
}

class _MoodLogScreenState extends ConsumerState<MoodLogScreen> {
  final _noteController = TextEditingController();
  MoodType? _selectedMood;
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _saveMood() async {
    if (_selectedMood == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a mood')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      String userId = 'guest_user';

      try {
        final authService = ref.read(authServiceProvider);
        final user = await authService.getCurrentUser();
        if (user != null && user.id != null) {
          userId = user.id!;
        }
      } catch (e) {
        // Use guest user if auth service fails
      }

      final now = DateTime.now();
      final entry = MoodEntry(
        id: now.millisecondsSinceEpoch.toString(),
        userId: userId,
        date: _selectedDate,
        moodType: _selectedMood,
        note: _noteController.text.trim().isEmpty ? null : _noteController.text.trim(),
        createdAt: now,
        updatedAt: now,
        deleted: 0,
      );

      debugPrint('Saving mood entry with ID: ${entry.id}, userId: $userId, mood: ${_selectedMood?.name}');

      await ref.read(moodEntriesProvider.notifier).addEntry(entry);

      debugPrint('Mood entry saved successfully!');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Mood saved successfully!'),
            duration: Duration(seconds: 1),
            backgroundColor: Colors.green,
          ),
        );

        setState(() {
          _selectedMood = null;
          _noteController.clear();
        });
      }
    } catch (e) {
      debugPrint('Error saving mood: ${e.toString()}');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save mood: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('How are you feeling?'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  DateFormat('EEEE, MMMM d, yyyy').format(_selectedDate),
                  style: Theme.of(context).textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Select your mood',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 16,
              runSpacing: 16,
              children: MoodType.values.map((mood) {
                final isSelected = _selectedMood == mood;
                final color = _getMoodColor(mood);

                return GestureDetector(
                  onTap: () => setState(() => _selectedMood = mood),
                  child: Column(
                    children: [
                      Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          color: isSelected ? color.withOpacity(0.2) : Colors.transparent,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected ? color : Colors.grey.withOpacity(0.3),
                            width: isSelected ? 3 : 1,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            mood.emoji,
                            style: const TextStyle(fontSize: 40),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        mood.label,
                        style: TextStyle(
                          color: isSelected ? color : null,
                          fontWeight: isSelected ? FontWeight.bold : null,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 32),
            Text(
              'Add a note (optional)',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _noteController,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'What happened today?',
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveMood,
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Save Mood'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getMoodColor(MoodType mood) {
    switch (mood) {
      case MoodType.great:
        return AppTheme.moodGreat;
      case MoodType.good:
        return AppTheme.moodGood;
      case MoodType.okay:
        return AppTheme.moodOkay;
      case MoodType.bad:
        return AppTheme.moodBad;
      case MoodType.terrible:
        return AppTheme.moodTerrible;
    }
  }
}
