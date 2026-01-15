import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/config/api_config.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../core/di/injection_container.dart' as di;
import '../../../../core/network/api_client.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _notificationService = NotificationService();
  late final ApiClient _apiClient;

  bool _isLoading = true;
  bool _isSaving = false;

  // Notification settings
  bool _workoutReminders = true;
  TimeOfDay _workoutTime = const TimeOfDay(hour: 9, minute: 0);
  bool _waterReminders = true;
  int _waterInterval = 120; // minutes
  bool _dailySummary = true;
  TimeOfDay _dailySummaryTime = const TimeOfDay(hour: 20, minute: 0);

  @override
  void initState() {
    super.initState();
    _apiClient = di.sl<ApiClient>();
    _loadSettings();
    _notificationService.requestPermissions();
  }

  Future<void> _loadSettings() async {
    try {
      print('[SETTINGS] Settings yükleniyor...');
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) {
        print('[SETTINGS] Token bulunamadı!');
        setState(() => _isLoading = false);
        _showError('Oturum bulunamadı');
        return;
      }

      print('[SETTINGS] API isteği yapılıyor: /notifications');
      final data = await _apiClient.get(
        '/notifications',
        token: token,
      );

      print('[SETTINGS] Response alındı: $data');
      print('[SETTINGS] workoutReminders: ${data['workoutReminders']}');
      print('[SETTINGS] workoutTime: ${data['workoutTime']}');

      setState(() {
        _workoutReminders = data['workoutReminders'] ?? true;
        _workoutTime = _parseTime(data['workoutTime'] ?? '09:00');
        _waterReminders = data['waterReminders'] ?? true;
        _waterInterval = data['waterInterval'] ?? 120;
        _dailySummary = data['dailySummary'] ?? true;
        _dailySummaryTime = _parseTime(data['dailySummaryTime'] ?? '20:00');
        _isLoading = false;
      });

      print('[SETTINGS] State güncellendi, notification schedule uygulanıyor...');
      // Apply notification schedules
      await _applyNotificationSchedules();
      print('[SETTINGS] Settings başarıyla yüklendi!');
    } catch (e, stackTrace) {
      print('[SETTINGS] HATA: $e');
      print('[SETTINGS] Stack trace: $stackTrace');
      setState(() => _isLoading = false);
      _showError('Bağlantı hatası: ${e.toString()}');
    }
  }

  Future<void> _saveSettings() async {
    setState(() => _isSaving = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) {
        setState(() => _isSaving = false);
        _showError('Oturum bulunamadı');
        return;
      }

      await _apiClient.put(
        '/notifications',
        body: {
          'workoutReminders': _workoutReminders,
          'workoutTime': _formatTime(_workoutTime),
          'waterReminders': _waterReminders,
          'waterInterval': _waterInterval,
          'dailySummary': _dailySummary,
          'dailySummaryTime': _formatTime(_dailySummaryTime),
        },
        token: token,
      );

      // Apply notification schedules
      await _applyNotificationSchedules();

      setState(() => _isSaving = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ayarlar kaydedildi'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() => _isSaving = false);
      _showError('Bağlantı hatası: ${e.toString()}');
    }
  }

  Future<void> _applyNotificationSchedules() async {
    // Workout reminders
    await _notificationService.scheduleWorkoutReminder(
      time: _formatTime(_workoutTime),
      enabled: _workoutReminders,
    );

    // Water reminders
    await _notificationService.scheduleWaterReminders(
      intervalMinutes: _waterInterval,
      enabled: _waterReminders,
    );

    // Daily summary
    await _notificationService.scheduleDailySummary(
      time: _formatTime(_dailySummaryTime),
      enabled: _dailySummary,
    );
  }

  TimeOfDay _parseTime(String time) {
    final parts = time.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  String _formatTime(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _selectTime(BuildContext context, TimeOfDay initialTime,
      Function(TimeOfDay) onTimeSelected) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );
    if (picked != null) {
      onTimeSelected(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ayarlar'),
        actions: [
          if (_isSaving)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _saveSettings,
              tooltip: 'Kaydet',
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Workout Reminders Section
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.fitness_center, color: Colors.green),
                            const SizedBox(width: 12),
                            const Text(
                              'Antrenman Hatırlatıcıları',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        SwitchListTile(
                          title: const Text('Antrenman hatırlatıcıları'),
                          subtitle: const Text('Günlük antrenman hatırlatması al'),
                          value: _workoutReminders,
                          onChanged: (value) {
                            setState(() => _workoutReminders = value);
                          },
                        ),
                        if (_workoutReminders)
                          ListTile(
                            title: const Text('Hatırlatma saati'),
                            subtitle: Text(_formatTime(_workoutTime)),
                            trailing: const Icon(Icons.access_time),
                            onTap: () => _selectTime(
                              context,
                              _workoutTime,
                              (time) => setState(() => _workoutTime = time),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Water Reminders Section
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.water_drop, color: Colors.blue),
                            const SizedBox(width: 12),
                            const Text(
                              'Su Hatırlatıcıları',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        SwitchListTile(
                          title: const Text('Su hatırlatıcıları'),
                          subtitle: const Text('Düzenli su içme hatırlatması'),
                          value: _waterReminders,
                          onChanged: (value) {
                            setState(() => _waterReminders = value);
                          },
                        ),
                        if (_waterReminders)
                          ListTile(
                            title: const Text('Hatırlatma aralığı'),
                            subtitle: Text('$_waterInterval dakika'),
                            trailing: DropdownButton<int>(
                              value: _waterInterval,
                              items: const [
                                DropdownMenuItem(value: 60, child: Text('1 saat')),
                                DropdownMenuItem(value: 120, child: Text('2 saat')),
                                DropdownMenuItem(value: 180, child: Text('3 saat')),
                                DropdownMenuItem(value: 240, child: Text('4 saat')),
                              ],
                              onChanged: (value) {
                                if (value != null) {
                                  setState(() => _waterInterval = value);
                                }
                              },
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Daily Summary Section
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.summarize, color: Colors.purple),
                            const SizedBox(width: 12),
                            const Text(
                              'Günlük Özet',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        SwitchListTile(
                          title: const Text('Günlük özet bildirimi'),
                          subtitle: const Text('Günlük aktivite özetini al'),
                          value: _dailySummary,
                          onChanged: (value) {
                            setState(() => _dailySummary = value);
                          },
                        ),
                        if (_dailySummary)
                          ListTile(
                            title: const Text('Özet saati'),
                            subtitle: Text(_formatTime(_dailySummaryTime)),
                            trailing: const Icon(Icons.access_time),
                            onTap: () => _selectTime(
                              context,
                              _dailySummaryTime,
                              (time) => setState(() => _dailySummaryTime = time),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
