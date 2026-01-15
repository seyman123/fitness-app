import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/service_locator.dart';
import '../../domain/entities/workout.dart';
import '../../domain/entities/workout_exercise.dart';
import '../bloc/workout_bloc.dart';
import '../bloc/workout_event.dart';
import '../bloc/workout_state.dart';

class WorkoutFormPage extends StatelessWidget {
  final Workout? workout;

  const WorkoutFormPage({super.key, this.workout});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<WorkoutBloc>(),
      child: _WorkoutFormPageContent(workout: workout),
    );
  }
}

class _WorkoutFormPageContent extends StatefulWidget {
  final Workout? workout;

  const _WorkoutFormPageContent({this.workout});

  @override
  State<_WorkoutFormPageContent> createState() => _WorkoutFormPageContentState();
}

class _WorkoutFormPageContentState extends State<_WorkoutFormPageContent> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  final List<_ExerciseForm> _exercises = [];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.workout?.name ?? '');
    _descriptionController =
        TextEditingController(text: widget.workout?.description ?? '');

    if (widget.workout != null) {
      for (final exercise in widget.workout!.exercises) {
        _exercises.add(_ExerciseForm.fromExercise(exercise));
      }
    }

    if (_exercises.isEmpty) {
      _exercises.add(_ExerciseForm());
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    for (final exercise in _exercises) {
      exercise.dispose();
    }
    super.dispose();
  }

  void _addExercise() {
    setState(() {
      _exercises.add(_ExerciseForm());
    });
  }

  void _removeExercise(int index) {
    setState(() {
      _exercises[index].dispose();
      _exercises.removeAt(index);
    });
  }

  void _saveWorkout() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_exercises.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('En az bir egzersiz eklemelisiniz'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final exercises = _exercises
        .asMap()
        .entries
        .map((entry) => WorkoutExercise(
              id: entry.value.id ?? '',
              workoutId: widget.workout?.id ?? '',
              name: entry.value.nameController.text.trim(),
              sets: int.parse(entry.value.setsController.text),
              reps: int.parse(entry.value.repsController.text),
              restSeconds: entry.value.restController.text.isEmpty
                  ? null
                  : int.parse(entry.value.restController.text),
              notes: entry.value.notesController.text.trim().isEmpty
                  ? null
                  : entry.value.notesController.text.trim(),
              order: entry.key,
              createdAt: entry.value.createdAt ?? DateTime.now(),
            ))
        .toList();

    final workout = Workout(
      id: widget.workout?.id ?? '',
      userId: widget.workout?.userId ?? '',
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      isTemplate: false,
      exercises: exercises,
      createdAt: widget.workout?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );

    if (widget.workout == null) {
      context.read<WorkoutBloc>().add(CreateWorkout(workout));
    } else {
      context.read<WorkoutBloc>().add(UpdateWorkout(workout.id, workout));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<WorkoutBloc, WorkoutState>(
      listener: (context, state) {
        if (state is WorkoutOperationSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
          Navigator.pop(context, true);
        } else if (state is WorkoutError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            widget.workout == null
                ? 'Yeni Antrenman'
                : 'Programı Düzenle',
          ),
        ),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Program Adı
              TextFormField(
                controller: _nameController,
                style: const TextStyle(fontSize: 15),
                decoration: InputDecoration(
                  labelText: 'Program Adı',
                  hintText: 'Push Day, Leg Day',
                  hintStyle: TextStyle(color: Colors.grey[400]),
                  prefixIcon: const Icon(Icons.fitness_center, size: 20),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: Theme.of(context).primaryColor,
                      width: 2,
                    ),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Program adı gerekli';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),

              // Açıklama
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                style: const TextStyle(fontSize: 15),
                decoration: InputDecoration(
                  labelText: 'Açıklama (Opsiyonel)',
                  hintText: 'Program hakkında notlar',
                  hintStyle: TextStyle(color: Colors.grey[400]),
                  prefixIcon: const Icon(Icons.description_outlined, size: 20),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: Theme.of(context).primaryColor,
                      width: 2,
                    ),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
              ),
              const SizedBox(height: 20),

              // Egzersizler Başlık
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.format_list_numbered, size: 20, color: Colors.grey[700]),
                      const SizedBox(width: 8),
                      Text(
                        'Egzersizler',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                    ],
                  ),
                  ElevatedButton.icon(
                    onPressed: _addExercise,
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Ekle'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Egzersiz Listesi
              ..._exercises.asMap().entries.map((entry) {
                final index = entry.key;
                final exercise = entry.value;
                return _buildExerciseCard(index, exercise);
              }),
              const SizedBox(height: 20),

              // Kaydet Butonu
              ElevatedButton.icon(
                onPressed: _saveWorkout,
                icon: const Icon(Icons.save_outlined, size: 20),
                label: Text(
                  widget.workout == null ? 'Programı Oluştur' : 'Değişiklikleri Kaydet',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExerciseCard(int index, _ExerciseForm exercise) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey[200]!,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    '${index + 1}',
                    style: const TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Egzersiz ${index + 1}',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (_exercises.length > 1)
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                  onPressed: () => _removeExercise(index),
                  tooltip: 'Sil',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
            ],
          ),
          const SizedBox(height: 14),

          // Egzersiz Adı
          TextFormField(
            controller: exercise.nameController,
            style: const TextStyle(fontSize: 15),
            decoration: InputDecoration(
              labelText: 'Egzersiz Adı',
              hintText: 'Bench Press, Squat',
              hintStyle: TextStyle(color: Colors.grey[400]),
              prefixIcon: const Icon(Icons.fitness_center, size: 20),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: Theme.of(context).primaryColor,
                  width: 2,
                ),
              ),
              filled: true,
              fillColor: Colors.grey[50],
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Egzersiz adı gerekli';
              }
              return null;
            },
          ),
          const SizedBox(height: 12),

          // Set, Tekrar, Dinlenme
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: exercise.setsController,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(fontSize: 15),
                  decoration: InputDecoration(
                    labelText: 'Set',
                    hintText: '3',
                    hintStyle: TextStyle(color: Colors.grey[400]),
                    prefixIcon: const Icon(Icons.repeat, size: 18),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Theme.of(context).primaryColor,
                        width: 2,
                      ),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Gerekli';
                    }
                    if (int.tryParse(value) == null || int.parse(value) < 1) {
                      return 'Geçersiz';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextFormField(
                  controller: exercise.repsController,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(fontSize: 15),
                  decoration: InputDecoration(
                    labelText: 'Tekrar',
                    hintText: '10',
                    hintStyle: TextStyle(color: Colors.grey[400]),
                    prefixIcon: const Icon(Icons.fitness_center, size: 18),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Theme.of(context).primaryColor,
                        width: 2,
                      ),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Gerekli';
                    }
                    if (int.tryParse(value) == null || int.parse(value) < 1) {
                      return 'Geçersiz';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextFormField(
                  controller: exercise.restController,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(fontSize: 15),
                  decoration: InputDecoration(
                    labelText: 'Dinlenme',
                    hintText: '60s',
                    hintStyle: TextStyle(color: Colors.grey[400]),
                    prefixIcon: const Icon(Icons.timer_outlined, size: 18),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Theme.of(context).primaryColor,
                        width: 2,
                      ),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                  ),
                  validator: (value) {
                    if (value != null &&
                        value.isNotEmpty &&
                        int.tryParse(value) == null) {
                      return 'Geçersiz';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Notlar
          TextFormField(
            controller: exercise.notesController,
            maxLines: 2,
            style: const TextStyle(fontSize: 15),
            decoration: InputDecoration(
              labelText: 'Notlar (Opsiyonel)',
              hintText: 'Teknik ipuçları, ağırlık',
              hintStyle: TextStyle(color: Colors.grey[400]),
              prefixIcon: const Icon(Icons.notes_rounded, size: 20),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: Theme.of(context).primaryColor,
                  width: 2,
                ),
              ),
              filled: true,
              fillColor: Colors.grey[50],
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }
}

class _ExerciseForm {
  final String? id;
  final TextEditingController nameController;
  final TextEditingController setsController;
  final TextEditingController repsController;
  final TextEditingController restController;
  final TextEditingController notesController;
  final DateTime? createdAt;

  _ExerciseForm({
    this.id,
    String? name,
    int? sets,
    int? reps,
    int? restSeconds,
    String? notes,
    this.createdAt,
  })  : nameController = TextEditingController(text: name ?? ''),
        setsController = TextEditingController(text: sets?.toString() ?? ''),
        repsController = TextEditingController(text: reps?.toString() ?? ''),
        restController =
            TextEditingController(text: restSeconds?.toString() ?? ''),
        notesController = TextEditingController(text: notes ?? '');

  factory _ExerciseForm.fromExercise(WorkoutExercise exercise) {
    return _ExerciseForm(
      id: exercise.id,
      name: exercise.name,
      sets: exercise.sets,
      reps: exercise.reps,
      restSeconds: exercise.restSeconds,
      notes: exercise.notes,
      createdAt: exercise.createdAt,
    );
  }

  void dispose() {
    nameController.dispose();
    setsController.dispose();
    repsController.dispose();
    restController.dispose();
    notesController.dispose();
  }
}
