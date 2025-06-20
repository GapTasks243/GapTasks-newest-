class EditDNDScreen extends StatefulWidget {
  final Map<String, dynamic>? onboardingData;
  const EditDNDScreen({super.key, required this.onboardingData});

  @override
  State<EditDNDScreen> createState() => _EditDNDScreenState();
}

class _EditDNDScreenState extends State<EditDNDScreen> {
  late TimeOfDay _bedTime;
  late TimeOfDay _wakeTime;

  @override
  void initState() {
    super.initState();
    _loadTimes();
  }

  void _loadTimes() {
    if (widget.onboardingData != null) {
      final bedStr = widget.onboardingData!['bed'] as String?;
      final wakeStr = widget.onboardingData!['wake'] as String?;
      if (bedStr != null) {
        final parts = bedStr.split(':');
        if (parts.length == 2) {
          _bedTime = TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
        } else {
          _bedTime = const TimeOfDay(hour: 23, minute: 0);
        }
      } else {
        _bedTime = const TimeOfDay(hour: 23, minute: 0);
      }
      if (wakeStr != null) {
        final parts = wakeStr.split(':');
        if (parts.length == 2) {
          _wakeTime = TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
        } else {
          _wakeTime = const TimeOfDay(hour: 7, minute: 0);
        }
      } else {
        _wakeTime = const TimeOfDay(hour: 7, minute: 0);
      }
    } else {
      _bedTime = const TimeOfDay(hour: 23, minute: 0);
      _wakeTime = const TimeOfDay(hour: 7, minute: 0);
    }
  }

  Future<void> _pickTime(bool isBedTime) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: isBedTime ? _bedTime : _wakeTime,
    );
    if (picked != null) {
      setState(() {
        if (isBedTime) {
          _bedTime = picked;
        } else {
          _wakeTime = picked;
        }
      });
    }
  }

  String _formatTime(TimeOfDay t) {
    final localizations = MaterialLocalizations.of(context);
    return localizations.formatTimeOfDay(t, alwaysUse24HourFormat: false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Do Not Disturb', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF232B36),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              const Text(
                'Sleep Schedule',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Color(0xFF232B36)),
              ),
              const SizedBox(height: 8),
              const Text(
                'Set your daily bedtime and wake-up times to pause notifications during your sleep cycle.',
                style: TextStyle(fontSize: 15, color: Color(0xFF757B84)),
              ),
              const SizedBox(height: 24),
              GestureDetector(
                onTap: () => _pickTime(true),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F5F9),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.nightlight_round, color: Color(0xFF232B36), size: 28),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Bedtime',
                            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18, color: Color(0xFF232B36)),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _formatTime(_bedTime),
                            style: const TextStyle(fontSize: 15, color: Color(0xFF7B8BB2)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () => _pickTime(false),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F5F9),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.wb_sunny_rounded, color: Color(0xFF232B36), size: 28),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Wake Up',
                            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18, color: Color(0xFF232B36)),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _formatTime(_wakeTime),
                            style: const TextStyle(fontSize: 15, color: Color(0xFF7B8BB2)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () async {
                    await OnboardingPrefs.saveSleep(_bedTime, _wakeTime);
                    if (mounted) Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3398F6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(32),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Save',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class EditBlockoutScreen extends StatefulWidget {
  final Map<String, dynamic>? onboardingData;
  const EditBlockoutScreen({super.key, required this.onboardingData});

  @override
  State<EditBlockoutScreen> createState() => _EditBlockoutScreenState();
}

class _EditBlockoutScreenState extends State<EditBlockoutScreen> {
  final List<String> days = [
    'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'
  ];
  late Map<String, TimeOfDay> startTimes;
  late Map<String, TimeOfDay> endTimes;
  late Map<String, bool> enabledDays;

  @override
  void initState() {
    super.initState();
    _loadBlockoutTimes();
  }

  void _loadBlockoutTimes() {
    startTimes = {};
    endTimes = {};
    enabledDays = {};

    if (widget.onboardingData != null && widget.onboardingData!['blockout'] != null) {
      final blockout = widget.onboardingData!['blockout'] as Map<String, dynamic>;
      for (final day in days) {
        final dayData = blockout[day] as Map<String, dynamic>?;
        enabledDays[day] = dayData?['enabled'] == true;
        
        if (dayData?['start'] != null) {
          final parts = (dayData!['start'] as String).split(':');
          if (parts.length == 2) {
            startTimes[day] = TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
          } else {
            startTimes[day] = const TimeOfDay(hour: 8, minute: 0);
          }
        } else {
          startTimes[day] = const TimeOfDay(hour: 8, minute: 0);
        }

        if (dayData?['end'] != null) {
          final parts = (dayData!['end'] as String).split(':');
          if (parts.length == 2) {
            endTimes[day] = TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
          } else {
            endTimes[day] = const TimeOfDay(hour: 9, minute: 0);
          }
        } else {
          endTimes[day] = const TimeOfDay(hour: 9, minute: 0);
        }
      }
    } else {
      for (final day in days) {
        startTimes[day] = const TimeOfDay(hour: 8, minute: 0);
        endTimes[day] = const TimeOfDay(hour: 9, minute: 0);
        enabledDays[day] = false;
      }
    }
  }

  Future<TimeOfDay?> _pickTime(String day, bool isStart) async {
    final initialTime = isStart ? startTimes[day]! : endTimes[day]!;
    return await showTimePicker(
      context: context,
      initialTime: initialTime,
    );
  }

  String _formatTimeRange(TimeOfDay start, TimeOfDay end) {
    final localizations = MaterialLocalizations.of(context);
    return '${localizations.formatTimeOfDay(start, alwaysUse24HourFormat: false)} - '
           '${localizations.formatTimeOfDay(end, alwaysUse24HourFormat: false)}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Daily Blockout', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF232B36),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              const Text(
                'Daily Schedule',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Color(0xFF232B36)),
              ),
              const SizedBox(height: 8),
              const Text(
                'Set your daily blocked times when you have recurring commitments or personal activities.',
                style: TextStyle(fontSize: 15, color: Color(0xFF757B84)),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: ListView.separated(
                  itemCount: days.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, i) {
                    final day = days[i];
                    final enabled = enabledDays[day]!;
                    return Opacity(
                      opacity: enabled ? 1.0 : 0.5,
                      child: Stack(
                        children: [
                          GestureDetector(
                            onTap: () async {
                              if (!enabled) {
                                // Prompt for time range and enable if set
                                final pickedStart = await _pickTime(day, true);
                                if (pickedStart != null) {
                                  setState(() {
                                    startTimes[day] = pickedStart;
                                  });
                                  final pickedEnd = await _pickTime(day, false);
                                  if (pickedEnd != null) {
                                    setState(() {
                                      endTimes[day] = pickedEnd;
                                      enabledDays[day] = true;
                                    });
                                  }
                                }
                              } else {
                                // Edit time range
                                final pickedStart = await _pickTime(day, true);
                                if (pickedStart != null) {
                                  setState(() {
                                    startTimes[day] = pickedStart;
                                  });
                                }
                                final pickedEnd = await _pickTime(day, false);
                                if (pickedEnd != null) {
                                  setState(() {
                                    endTimes[day] = pickedEnd;
                                  });
                                }
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF3F5F9),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          day,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 18,
                                            color: Color(0xFF232B36),
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        enabled
                                            ? Text(
                                                _formatTimeRange(startTimes[day]!, endTimes[day]!),
                                                style: const TextStyle(
                                                  fontSize: 15,
                                                  color: Color(0xFF7B8BB2),
                                                ),
                                              )
                                            : const Text(
                                                'Not set',
                                                style: TextStyle(
                                                  fontSize: 15,
                                                  color: Color(0xFFBFC5D2),
                                                ),
                                              ),
                                      ],
                                    ),
                                  ),
                                  if (enabled)
                                    IconButton(
                                      icon: const Icon(Icons.close, color: Color(0xFFBFC5D2)),
                                      onPressed: () {
                                        setState(() {
                                          enabledDays[day] = false;
                                          startTimes[day] = const TimeOfDay(hour: 8, minute: 0);
                                          endTimes[day] = const TimeOfDay(hour: 9, minute: 0);
                                        });
                                      },
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () async {
                    await OnboardingPrefs.saveBlockout(enabledDays, startTimes, endTimes);
                    if (mounted) Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3398F6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(32),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Save',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class SettingsScreen extends StatefulWidget {
  final Map<String, dynamic>? onboardingData;
  const SettingsScreen({super.key, required this.onboardingData});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final onboardingData = widget.onboardingData;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Settings', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF232B36),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              const Text(
                'Settings',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Color(0xFF232B36)),
              ),
              const SizedBox(height: 8),
              const Text(
                'Manage your notification settings and preferences.',
                style: TextStyle(fontSize: 15, color: Color(0xFF757B84)),
              ),
              const SizedBox(height: 24),
              const Divider(height: 0),
              ListTile(
                title: const Text('Do Not Disturb', style: TextStyle(fontWeight: FontWeight.w500)),
                subtitle: Text(
                  onboardingData != null && onboardingData!['bed'] != null && onboardingData!['wake'] != null
                    ? 'Sleep: ${onboardingData!['bed']} - ${onboardingData!['wake']}'
                    : 'Set a time period to disable notifications',
                  style: const TextStyle(color: Color(0xFF7B8BB2)),
                ),
                trailing: const Icon(Icons.chevron_right_rounded, color: Color(0xFFBFC5D2)),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => EditDNDScreen(onboardingData: onboardingData)),
                  ).then((_) => _loadOnboarding());
                },
              ),
              const Divider(height: 0),
              ListTile(
                title: const Text('Daily Blockout', style: TextStyle(fontWeight: FontWeight.w500)),
                subtitle: Text(
                  onboardingData != null && onboardingData!['blockout'] != null
                    ? 'Tap to edit your daily blocked times'
                    : 'Set recurring blocked times for each day',
                  style: const TextStyle(color: Color(0xFF7B8BB2)),
                ),
                trailing: const Icon(Icons.chevron_right_rounded, color: Color(0xFFBFC5D2)),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => EditBlockoutScreen(onboardingData: onboardingData)),
                  ).then((_) => _loadOnboarding());
                },
              ),
              const Divider(height: 0),
              ListTile(
                title: const Text('Smart Notifications', style: TextStyle(fontWeight: FontWeight.w500)),
                subtitle: const Text('Let the app optimize notification timing for you', style: TextStyle(color: Color(0xFF7B8BB2))),
                trailing: const Icon(Icons.chevron_right_rounded, color: Color(0xFFBFC5D2)),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => SmartNotificationsScreen(onboardingData: onboardingData)),
                  );
                },
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  void _loadOnboarding() {
    // Implementation of _loadOnboarding method
  }
} 