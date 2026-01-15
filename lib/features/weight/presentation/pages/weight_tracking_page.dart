import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/utils/fitness_calculator.dart';
import '../../../profile/presentation/bloc/profile_bloc.dart';
import '../../../profile/presentation/bloc/profile_state.dart';
import '../bloc/weight_bloc.dart';
import '../bloc/weight_event.dart';
import '../bloc/weight_state.dart';
import 'package:intl/intl.dart';

class WeightTrackingPage extends StatefulWidget {
  const WeightTrackingPage({super.key});

  @override
  State<WeightTrackingPage> createState() => _WeightTrackingPageState();
}

class _WeightTrackingPageState extends State<WeightTrackingPage> {
  final _weightController = TextEditingController();
  final _notesController = TextEditingController();

  @override
  void dispose() {
    _weightController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _showAddWeightDialog(double? height) {
    _weightController.clear();
    _notesController.clear();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Kilo Girişi'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _weightController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Kilo (kg)',
                  hintText: '70.5',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _notesController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Notlar (opsiyonel)',
                  hintText: 'Bugün kendimi iyi hissediyorum',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              final weightText = _weightController.text.trim();
              if (weightText.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Lütfen kilo değeri girin')),
                );
                return;
              }

              final weight = double.tryParse(weightText);
              if (weight == null || weight < 20 || weight > 300) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Geçerli bir kilo değeri girin (20-300 kg)')),
                );
                return;
              }

              double? bmi;
              if (height != null && height > 0) {
                bmi = FitnessCalculator.calculateBmi(
                  weightKg: weight,
                  heightCm: height,
                );
              }

              context.read<WeightBloc>().add(
                    AddWeightEntry(
                      weight: weight,
                      bmi: bmi,
                      notes: _notesController.text.trim().isEmpty
                          ? null
                          : _notesController.text.trim(),
                    ),
                  );

              Navigator.pop(dialogContext);
            },
            child: const Text('Kaydet'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kilo Takibi'),
      ),
      body: BlocConsumer<WeightBloc, WeightState>(
        listener: (context, state) {
          if (state is WeightOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
              ),
            );
            context.read<WeightBloc>().add(const LoadWeightHistory(limit: 30));
          } else if (state is WeightError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is WeightLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is WeightHistoryLoaded) {
            if (state.history.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.monitor_weight, size: 80, color: Colors.grey[400]),
                    const SizedBox(height: 16),
                    Text(
                      'Henüz kilo kaydı yok',
                      style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'İlerlemenizi takip etmek için kilo ekleyin',
                      style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                context.read<WeightBloc>().add(const RefreshWeight());
              },
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: state.history.length,
                itemBuilder: (context, index) {
                  final entry = state.history[index];
                  final dateFormat = DateFormat('dd MMM yyyy', 'tr_TR');

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.monitor_weight, color: Colors.blue),
                      ),
                      title: Text(
                        '${entry.weight.toStringAsFixed(1)} kg',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Text(dateFormat.format(entry.date)),
                          if (entry.bmi != null) ...[
                            const SizedBox(height: 2),
                            Text(
                              'BMI: ${entry.bmi!.toStringAsFixed(1)} - ${FitnessCalculator.bmiCategory(entry.bmi!)}',
                              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                            ),
                          ],
                          if (entry.notes != null && entry.notes!.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              entry.notes!,
                              style: TextStyle(
                                fontSize: 12,
                                fontStyle: FontStyle.italic,
                                color: Colors.grey[700],
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.red),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (dialogContext) => AlertDialog(
                              title: const Text('Kaydı Sil'),
                              content: const Text('Bu kilo kaydını silmek istediğinize emin misiniz?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(dialogContext),
                                  child: const Text('İptal'),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    context.read<WeightBloc>().add(DeleteWeightEntry(entry.id));
                                    Navigator.pop(dialogContext);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                  ),
                                  child: const Text('Sil'),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  );
                },
              ),
            );
          }

          return const Center(child: Text('Bir hata oluştu'));
        },
      ),
      floatingActionButton: BlocBuilder<ProfileBloc, ProfileState>(
        builder: (context, profileState) {
          double? height;
          if (profileState is ProfileLoaded) {
            height = profileState.profile.height;
          }

          return FloatingActionButton.extended(
            onPressed: () => _showAddWeightDialog(height),
            icon: const Icon(Icons.add),
            label: const Text('Kilo Ekle'),
          );
        },
      ),
    );
  }
}
