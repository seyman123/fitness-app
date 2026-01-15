/// Hazır antrenman programları
/// Kullanıcılar bu programları kendi listelerine ekleyebilir

class PresetWorkout {
  final String id;
  final String name;
  final String description;
  final String category;
  final String difficulty; // 'beginner', 'intermediate', 'advanced'
  final String icon;
  final List<PresetExercise> exercises;

  const PresetWorkout({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.difficulty,
    required this.icon,
    required this.exercises,
  });
}

class PresetExercise {
  final String name;
  final int sets;
  final int reps;
  final int? restSeconds;
  final String? notes;

  const PresetExercise({
    required this.name,
    required this.sets,
    required this.reps,
    this.restSeconds,
    this.notes,
  });
}

/// Tüm hazır antrenman programları
class PresetWorkouts {
  static const List<PresetWorkout> all = [
    // === BAŞLANGIÇ SEVİYESİ ===
    PresetWorkout(
      id: 'preset_full_body_beginner',
      name: 'Full Body Başlangıç',
      description: 'Tüm vücut için temel hareketler. Yeni başlayanlar için ideal.',
      category: 'Full Body',
      difficulty: 'beginner',
      icon: '💪',
      exercises: [
        PresetExercise(name: 'Squat (Vücut Ağırlığı)', sets: 3, reps: 12, restSeconds: 60, notes: 'Dizler ayak uçlarını geçmesin'),
        PresetExercise(name: 'Şınav (Dizden)', sets: 3, reps: 10, restSeconds: 60, notes: 'Zorlanırsan dizlerini yere koy'),
        PresetExercise(name: 'Plank', sets: 3, reps: 30, restSeconds: 45, notes: '30 saniye tut'),
        PresetExercise(name: 'Glute Bridge', sets: 3, reps: 15, restSeconds: 45),
        PresetExercise(name: 'Superman', sets: 3, reps: 12, restSeconds: 45, notes: 'Sırt kasları için'),
      ],
    ),
    PresetWorkout(
      id: 'preset_cardio_beginner',
      name: 'Kardiyo Başlangıç',
      description: 'Yağ yakımı ve kondisyon için hafif kardiyo.',
      category: 'Kardiyo',
      difficulty: 'beginner',
      icon: '🏃',
      exercises: [
        PresetExercise(name: 'Jumping Jacks', sets: 3, reps: 20, restSeconds: 30),
        PresetExercise(name: 'High Knees', sets: 3, reps: 20, restSeconds: 30, notes: 'Dizleri göğüse çek'),
        PresetExercise(name: 'Butt Kicks', sets: 3, reps: 20, restSeconds: 30),
        PresetExercise(name: 'Mountain Climbers', sets: 3, reps: 15, restSeconds: 45),
        PresetExercise(name: 'Burpee (Kolay)', sets: 2, reps: 8, restSeconds: 60, notes: 'Şınav kısmını atla'),
      ],
    ),

    // === ORTA SEVİYE ===
    PresetWorkout(
      id: 'preset_push_day',
      name: 'Push Day (İtme)',
      description: 'Göğüs, omuz ve triceps odaklı antrenman.',
      category: 'Split',
      difficulty: 'intermediate',
      icon: '🏋️',
      exercises: [
        PresetExercise(name: 'Bench Press', sets: 4, reps: 10, restSeconds: 90, notes: 'Kontrollü indir'),
        PresetExercise(name: 'Overhead Press', sets: 3, reps: 10, restSeconds: 90),
        PresetExercise(name: 'Incline Dumbbell Press', sets: 3, reps: 12, restSeconds: 75),
        PresetExercise(name: 'Lateral Raise', sets: 3, reps: 15, restSeconds: 60),
        PresetExercise(name: 'Tricep Dips', sets: 3, reps: 12, restSeconds: 60),
        PresetExercise(name: 'Tricep Pushdown', sets: 3, reps: 15, restSeconds: 45),
      ],
    ),
    PresetWorkout(
      id: 'preset_pull_day',
      name: 'Pull Day (Çekme)',
      description: 'Sırt ve biceps odaklı antrenman.',
      category: 'Split',
      difficulty: 'intermediate',
      icon: '🏋️',
      exercises: [
        PresetExercise(name: 'Lat Pulldown', sets: 4, reps: 10, restSeconds: 90),
        PresetExercise(name: 'Barbell Row', sets: 4, reps: 10, restSeconds: 90, notes: 'Sırtı düz tut'),
        PresetExercise(name: 'Seated Cable Row', sets: 3, reps: 12, restSeconds: 75),
        PresetExercise(name: 'Face Pulls', sets: 3, reps: 15, restSeconds: 60, notes: 'Arka omuzlar için'),
        PresetExercise(name: 'Barbell Curl', sets: 3, reps: 12, restSeconds: 60),
        PresetExercise(name: 'Hammer Curl', sets: 3, reps: 12, restSeconds: 45),
      ],
    ),
    PresetWorkout(
      id: 'preset_leg_day',
      name: 'Leg Day (Bacak)',
      description: 'Bacak ve kalça odaklı antrenman.',
      category: 'Split',
      difficulty: 'intermediate',
      icon: '🦵',
      exercises: [
        PresetExercise(name: 'Squat', sets: 4, reps: 10, restSeconds: 120, notes: 'Ana hareket'),
        PresetExercise(name: 'Romanian Deadlift', sets: 4, reps: 10, restSeconds: 90, notes: 'Hamstring odaklı'),
        PresetExercise(name: 'Leg Press', sets: 3, reps: 12, restSeconds: 90),
        PresetExercise(name: 'Walking Lunges', sets: 3, reps: 12, restSeconds: 75, notes: 'Her bacak için'),
        PresetExercise(name: 'Leg Curl', sets: 3, reps: 15, restSeconds: 60),
        PresetExercise(name: 'Calf Raise', sets: 4, reps: 15, restSeconds: 45),
      ],
    ),
    PresetWorkout(
      id: 'preset_hiit',
      name: 'HIIT Kardiyo',
      description: 'Yüksek yoğunluklu interval antrenman. Yağ yakımı için etkili.',
      category: 'Kardiyo',
      difficulty: 'intermediate',
      icon: '🔥',
      exercises: [
        PresetExercise(name: 'Burpees', sets: 4, reps: 10, restSeconds: 30),
        PresetExercise(name: 'Jump Squats', sets: 4, reps: 15, restSeconds: 30),
        PresetExercise(name: 'Mountain Climbers', sets: 4, reps: 20, restSeconds: 30),
        PresetExercise(name: 'Box Jumps', sets: 4, reps: 12, restSeconds: 30),
        PresetExercise(name: 'Battle Ropes', sets: 4, reps: 30, restSeconds: 30, notes: '30 saniye'),
        PresetExercise(name: 'Kettlebell Swings', sets: 4, reps: 15, restSeconds: 30),
      ],
    ),

    // === İLERİ SEVİYE ===
    PresetWorkout(
      id: 'preset_upper_body_advanced',
      name: 'Üst Vücut İleri',
      description: 'Yoğun üst vücut antrenmanı. Deneyimli sporcular için.',
      category: 'Upper Body',
      difficulty: 'advanced',
      icon: '💪',
      exercises: [
        PresetExercise(name: 'Weighted Pull-ups', sets: 4, reps: 8, restSeconds: 120),
        PresetExercise(name: 'Bench Press', sets: 5, reps: 5, restSeconds: 180, notes: 'Ağır yükle'),
        PresetExercise(name: 'Barbell Row', sets: 4, reps: 8, restSeconds: 120),
        PresetExercise(name: 'Overhead Press', sets: 4, reps: 8, restSeconds: 120),
        PresetExercise(name: 'Weighted Dips', sets: 4, reps: 10, restSeconds: 90),
        PresetExercise(name: 'Barbell Curl', sets: 4, reps: 10, restSeconds: 60),
        PresetExercise(name: 'Skull Crushers', sets: 4, reps: 10, restSeconds: 60),
      ],
    ),
    PresetWorkout(
      id: 'preset_lower_body_advanced',
      name: 'Alt Vücut İleri',
      description: 'Yoğun bacak antrenmanı. Güç ve hacim için.',
      category: 'Lower Body',
      difficulty: 'advanced',
      icon: '🦵',
      exercises: [
        PresetExercise(name: 'Back Squat', sets: 5, reps: 5, restSeconds: 180, notes: 'Ana hareket - ağır'),
        PresetExercise(name: 'Deadlift', sets: 5, reps: 5, restSeconds: 180),
        PresetExercise(name: 'Front Squat', sets: 4, reps: 8, restSeconds: 120),
        PresetExercise(name: 'Bulgarian Split Squat', sets: 3, reps: 10, restSeconds: 90, notes: 'Her bacak'),
        PresetExercise(name: 'Leg Press', sets: 4, reps: 12, restSeconds: 90),
        PresetExercise(name: 'Glute Ham Raise', sets: 3, reps: 10, restSeconds: 75),
        PresetExercise(name: 'Standing Calf Raise', sets: 5, reps: 15, restSeconds: 45),
      ],
    ),

    // === ÖZEL PROGRAMLAR ===
    PresetWorkout(
      id: 'preset_core',
      name: 'Core & Karın',
      description: '6 pack için karın ve core antrenmanı.',
      category: 'Core',
      difficulty: 'intermediate',
      icon: '🎯',
      exercises: [
        PresetExercise(name: 'Plank', sets: 3, reps: 60, restSeconds: 45, notes: '60 saniye'),
        PresetExercise(name: 'Bicycle Crunches', sets: 3, reps: 20, restSeconds: 30),
        PresetExercise(name: 'Leg Raises', sets: 3, reps: 15, restSeconds: 45),
        PresetExercise(name: 'Russian Twist', sets: 3, reps: 20, restSeconds: 30),
        PresetExercise(name: 'Dead Bug', sets: 3, reps: 12, restSeconds: 30),
        PresetExercise(name: 'Ab Wheel Rollout', sets: 3, reps: 10, restSeconds: 60),
      ],
    ),
    PresetWorkout(
      id: 'preset_stretch',
      name: 'Esneme & Mobilite',
      description: 'Esneklik ve toparlanma için.',
      category: 'Recovery',
      difficulty: 'beginner',
      icon: '🧘',
      exercises: [
        PresetExercise(name: 'Cat-Cow Stretch', sets: 2, reps: 10, restSeconds: 15),
        PresetExercise(name: 'Hip Flexor Stretch', sets: 2, reps: 30, restSeconds: 15, notes: 'Her taraf 30sn'),
        PresetExercise(name: 'Hamstring Stretch', sets: 2, reps: 30, restSeconds: 15),
        PresetExercise(name: 'Quad Stretch', sets: 2, reps: 30, restSeconds: 15),
        PresetExercise(name: 'Shoulder Stretch', sets: 2, reps: 30, restSeconds: 15),
        PresetExercise(name: 'Pigeon Pose', sets: 2, reps: 45, restSeconds: 15, notes: 'Her taraf 45sn'),
        PresetExercise(name: "Child's Pose", sets: 1, reps: 60, restSeconds: 0, notes: '60 saniye dinlen'),
      ],
    ),
    PresetWorkout(
      id: 'preset_home_no_equipment',
      name: 'Evde (Ekipmansız)',
      description: 'Ekipman gerektirmeyen ev antrenmanı.',
      category: 'Home',
      difficulty: 'beginner',
      icon: '🏠',
      exercises: [
        PresetExercise(name: 'Push-ups', sets: 3, reps: 15, restSeconds: 45),
        PresetExercise(name: 'Bodyweight Squats', sets: 3, reps: 20, restSeconds: 45),
        PresetExercise(name: 'Lunges', sets: 3, reps: 12, restSeconds: 45, notes: 'Her bacak'),
        PresetExercise(name: 'Plank', sets: 3, reps: 45, restSeconds: 30, notes: '45 saniye'),
        PresetExercise(name: 'Glute Bridges', sets: 3, reps: 15, restSeconds: 30),
        PresetExercise(name: 'Tricep Dips (Sandalye)', sets: 3, reps: 12, restSeconds: 45),
        PresetExercise(name: 'Crunches', sets: 3, reps: 20, restSeconds: 30),
      ],
    ),
  ];

  /// Kategoriye göre filtrele
  static List<PresetWorkout> byCategory(String category) {
    return all.where((w) => w.category == category).toList();
  }

  /// Zorluk seviyesine göre filtrele
  static List<PresetWorkout> byDifficulty(String difficulty) {
    return all.where((w) => w.difficulty == difficulty).toList();
  }

  /// Tüm kategoriler
  static List<String> get categories {
    return all.map((w) => w.category).toSet().toList();
  }

  /// Zorluk seviyesi Türkçe
  static String difficultyText(String difficulty) {
    switch (difficulty) {
      case 'beginner':
        return 'Başlangıç';
      case 'intermediate':
        return 'Orta';
      case 'advanced':
        return 'İleri';
      default:
        return difficulty;
    }
  }

  /// Zorluk seviyesi rengi
  static int difficultyColor(String difficulty) {
    switch (difficulty) {
      case 'beginner':
        return 0xFF4CAF50; // Green
      case 'intermediate':
        return 0xFFFF9800; // Orange
      case 'advanced':
        return 0xFFF44336; // Red
      default:
        return 0xFF9E9E9E; // Grey
    }
  }
}
