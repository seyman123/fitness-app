class FitnessCalculator {
  /// BMI = kilo(kg) / (boy(m) ^ 2)
  static double calculateBmi({required double weightKg, required double heightCm}) {
    final heightM = heightCm / 100;
    if (heightM <= 0) return 0;
    return double.parse((weightKg / (heightM * heightM)).toStringAsFixed(1));
  }

  /// Basit Mifflin-St Jeor formülü ile BMR ve aktivite katsayısına göre günlük kalori.
  static double calculateDailyCalories({
    required String gender, // 'male' veya 'female'
    required int age,
    required double weightKg,
    required double heightCm,
    double activityFactor = 1.2,
    double goalFactor = 0, // kilo verme için negatif, alma için pozitif kalori farkı
  }) {
    final isMale = gender.toLowerCase().startsWith('e');
    final bmr = isMale
        ? 10 * weightKg + 6.25 * heightCm - 5 * age + 5
        : 10 * weightKg + 6.25 * heightCm - 5 * age - 161;

    final maintenance = bmr * activityFactor;
    final result = maintenance + goalFactor;
    return double.parse(result.toStringAsFixed(0));
  }

  static String bmiCategory(double bmi) {
    if (bmi == 0) return '';
    if (bmi < 18.5) return 'Zayıf';
    if (bmi < 25) return 'Normal';
    if (bmi < 30) return 'Fazla kilolu';
    return 'Obez';
  }
}
