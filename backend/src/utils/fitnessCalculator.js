const calculateBMI = (weightKg, heightCm) => {
  const heightM = heightCm / 100;
  if (heightM <= 0) return 0;
  return parseFloat((weightKg / (heightM * heightM)).toFixed(1));
};

const calculateDailyCalories = ({
  gender,
  age,
  weightKg,
  heightCm,
  activityFactor = 1.2,
  goalFactor = 0,
}) => {
  const isMale = gender.toLowerCase().startsWith('m') || gender.toLowerCase().startsWith('e');
  const bmr = isMale
    ? 10 * weightKg + 6.25 * heightCm - 5 * age + 5
    : 10 * weightKg + 6.25 * heightCm - 5 * age - 161;

  const maintenance = bmr * activityFactor;
  const result = maintenance + goalFactor;
  return parseFloat(result.toFixed(0));
};

const getBMICategory = (bmi) => {
  if (bmi === 0) return '';
  if (bmi < 18.5) return 'Zayıf';
  if (bmi < 25) return 'Normal';
  if (bmi < 30) return 'Fazla kilolu';
  return 'Obez';
};

module.exports = {
  calculateBMI,
  calculateDailyCalories,
  getBMICategory,
};
