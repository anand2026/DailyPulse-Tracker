import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import '../../../app/route_endpoints.dart';
import '../../../app/theme.dart';
import '../../../app/theme_provider.dart';
import '../models/mood_entry.dart';
import '../providers/mood_entries_provider.dart';

class AnalyticsScreen extends ConsumerStatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  ConsumerState<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends ConsumerState<AnalyticsScreen> {

  Future<void> _handleSignOut() async {
    try {
      final authService = ref.read(authServiceProvider);
      await authService.signOut();

      if (mounted) {
        context.go(AppRouteEndpoints.login);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to sign out: ${e.toString()}')),
        );
      }
    }
  }

  void _showThemeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choose Theme'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildThemeOption(ThemeMode.system, 'System', Icons.brightness_auto),
            _buildThemeOption(ThemeMode.light, 'Light', Icons.light_mode),
            _buildThemeOption(ThemeMode.dark, 'Dark', Icons.dark_mode),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeOption(ThemeMode mode, String label, IconData icon) {
    final currentTheme = ref.watch(themeModeProvider);
    final isSelected = currentTheme == mode;

    return ListTile(
      leading: Icon(icon, color: isSelected ? AppTheme.primaryLight : null),
      title: Text(
        label,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? AppTheme.primaryLight : null,
        ),
      ),
      trailing: isSelected ? const Icon(Icons.check, color: AppTheme.primaryLight) : null,
      onTap: () {
        ref.read(themeModeProvider.notifier).setThemeMode(mode);
        Navigator.pop(context);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final entriesAsync = ref.watch(moodEntriesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics'),
        actions: [
          IconButton(
            icon: const Icon(Icons.palette_outlined),
            onPressed: _showThemeDialog,
            tooltip: 'Change Theme',
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _handleSignOut,
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
        data: (entries) => entries.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '📊',
                        style: const TextStyle(fontSize: 64),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No data yet',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Start logging your mood to see analytics',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _buildStatCard(
                              'Total Entries',
                              '${entries.length}',
                              FontAwesomeIcons.clipboardList,
                              AppTheme.primaryLight,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildStatCard(
                              'Positive Days',
                              '${_getPositiveDays(entries)}',
                              FontAwesomeIcons.faceSmile,
                              AppTheme.moodGreat,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _buildStatCard(
                              'Negative Days',
                              '${_getNegativeDays(entries)}',
                              FontAwesomeIcons.faceFrown,
                              AppTheme.moodTerrible,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildStatCard(
                              'Completion Rate',
                              '${_getCompletionRate(entries)}%',
                              FontAwesomeIcons.chartLine,
                              AppTheme.moodGood,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Mood Distribution',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: SizedBox(
                            height: 200,
                            child: PieChart(
                              PieChartData(
                                sections: _getMoodDistribution(entries),
                                centerSpaceRadius: 50,
                                sectionsSpace: 2,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Most Common Mood',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      _buildMostCommonMoodCard(entries),
                    ],
                  ),
                ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            FaIcon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMostCommonMoodCard(List<MoodEntry> entries) {
    final mostCommon = _getMostCommonMood(entries);
    if (mostCommon == null) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text('Not enough data', style: Theme.of(context).textTheme.bodyMedium),
        ),
      );
    }

    final color = _getMoodColor(mostCommon);

    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.2),
          child: Text(
            mostCommon.emoji,
            style: const TextStyle(fontSize: 32),
          ),
        ),
        title: Text(
          mostCommon.label,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        subtitle: Text(
          '${_getMoodCount(mostCommon, entries)} times',
          style: Theme.of(context).textTheme.bodyMedium,
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

  int _getPositiveDays(List<MoodEntry> entries) {
    return entries.where((e) => e.moodType?.isPositive ?? false).length;
  }

  int _getNegativeDays(List<MoodEntry> entries) {
    return entries.where((e) => !(e.moodType?.isPositive ?? true)).length;
  }

  int _getCompletionRate(List<MoodEntry> entries) {
    if (entries.isEmpty) return 0;
    final positiveDays = _getPositiveDays(entries);
    return ((positiveDays / entries.length) * 100).round();
  }

  List<PieChartSectionData> _getMoodDistribution(List<MoodEntry> entries) {
    final moodCounts = <MoodType, int>{};

    for (final entry in entries) {
      if (entry.moodType != null) {
        moodCounts[entry.moodType!] = (moodCounts[entry.moodType] ?? 0) + 1;
      }
    }

    return moodCounts.entries.map((entry) {
      final percentage = (entry.value / entries.length) * 100;
      return PieChartSectionData(
        value: entry.value.toDouble(),
        title: '${percentage.toStringAsFixed(1)}%',
        color: _getMoodColor(entry.key),
        radius: 75,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
  }

  MoodType? _getMostCommonMood(List<MoodEntry> entries) {
    if (entries.isEmpty) return null;

    final moodCounts = <MoodType, int>{};

    for (final entry in entries) {
      if (entry.moodType != null) {
        moodCounts[entry.moodType!] = (moodCounts[entry.moodType] ?? 0) + 1;
      }
    }

    if (moodCounts.isEmpty) return null;

    return moodCounts.entries.reduce((a, b) => a.value > b.value ? a : b).key;
  }

  int _getMoodCount(MoodType mood, List<MoodEntry> entries) {
    return entries.where((e) => e.moodType == mood).length;
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
