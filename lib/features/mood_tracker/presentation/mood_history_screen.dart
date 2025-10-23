import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../app/theme.dart';
import '../models/mood_entry.dart';
import '../providers/mood_entries_provider.dart';

class MoodHistoryScreen extends ConsumerStatefulWidget {
  const MoodHistoryScreen({super.key});

  @override
  ConsumerState<MoodHistoryScreen> createState() => _MoodHistoryScreenState();
}

class _MoodHistoryScreenState extends ConsumerState<MoodHistoryScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  List<MoodEntry> _filteredEntries = [];

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay, List<MoodEntry> allEntries) {
    setState(() {
      _selectedDay = selectedDay;
      _focusedDay = focusedDay;

      _filteredEntries = allEntries.where((entry) {
        if (entry.date == null) return false;
        return isSameDay(entry.date, selectedDay);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final entriesAsync = ref.watch(moodEntriesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mood History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(moodEntriesProvider.notifier).refresh(),
          ),
        ],
      ),
      body: entriesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error: ${error.toString()}'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.read(moodEntriesProvider.notifier).refresh(),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (allEntries) => Column(
              children: [
                Card(
                  margin: const EdgeInsets.all(16),
                  child: TableCalendar(
                    firstDay: DateTime.utc(2020, 1, 1),
                    lastDay: DateTime.now(),
                    focusedDay: _focusedDay,
                    selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                    calendarFormat: _calendarFormat,
                    onFormatChanged: (format) {
                      setState(() => _calendarFormat = format);
                    },
                    onDaySelected: (selectedDay, focusedDay) => _onDaySelected(selectedDay, focusedDay, allEntries),
                    calendarStyle: CalendarStyle(
                      todayDecoration: BoxDecoration(
                        color: AppTheme.primaryLight.withOpacity(0.5),
                        shape: BoxShape.circle,
                      ),
                      selectedDecoration: BoxDecoration(
                        color: AppTheme.primaryLight,
                        shape: BoxShape.circle,
                      ),
                      markerDecoration: BoxDecoration(
                        color: AppTheme.primaryLight,
                        shape: BoxShape.circle,
                      ),
                    ),
                    eventLoader: (day) {
                      final hasEntries = allEntries.any((entry) {
                        if (entry.date == null) return false;
                        return isSameDay(entry.date, day);
                      });
                      return hasEntries ? [day] : [];
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _selectedDay != null
                            ? DateFormat('MMMM d, yyyy').format(_selectedDay!)
                            : 'All Entries',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      Text(
                        '${(_selectedDay == null ? allEntries : _filteredEntries).length} entries',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: (_selectedDay == null ? allEntries : _filteredEntries).isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '📝',
                                style: const TextStyle(fontSize: 64),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No mood entries yet',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Start logging your mood today!',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: (_selectedDay == null ? allEntries : _filteredEntries).length,
                          itemBuilder: (context, index) {
                            final entries = _selectedDay == null ? allEntries : _filteredEntries;
                            final entry = entries[index];
                            return _buildMoodEntryCard(entry);
                          },
                        ),
                ),
              ],
            ),
      ),
    );
  }

  Widget _buildMoodEntryCard(MoodEntry entry) {
    final color = _getMoodColor(entry.moodType);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.2),
          child: Text(
            entry.emoji ?? entry.moodType?.emoji ?? '😐',
            style: const TextStyle(fontSize: 24),
          ),
        ),
        title: Text(entry.moodType?.label ?? 'Unknown'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (entry.date != null)
              Text(DateFormat('MMM d, yyyy - h:mm a').format(entry.date!)),
            if (entry.note != null && entry.note!.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                entry.note!,
                style: Theme.of(context).textTheme.bodyMedium,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
        trailing: Container(
          width: 8,
          height: 40,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }

  Color _getMoodColor(MoodType? mood) {
    if (mood == null) return Colors.grey;

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
