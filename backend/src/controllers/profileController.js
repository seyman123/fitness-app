const prisma = require('../config/database');
const Joi = require('joi');
const { calculateBMI, calculateDailyCalories, getBMICategory } = require('../utils/fitnessCalculator');

const profileSchema = Joi.object({
  age: Joi.number().integer().min(1).max(120).required(),
  gender: Joi.string().valid('male', 'female', 'erkek', 'kadın').required(),
  height: Joi.number().min(50).max(300).required(),
  weight: Joi.number().min(20).max(500).required(),
  goalWeight: Joi.number().min(20).max(500).optional(),
  goalType: Joi.string().valid('LOSE_WEIGHT', 'GAIN_WEIGHT', 'BUILD_MUSCLE', 'MAINTAIN', 'GET_FIT').optional(),
  // Backward/alternate client naming support
  goal_weight: Joi.number().min(20).max(500).optional(),
  goal_type: Joi.string().valid('LOSE_WEIGHT', 'GAIN_WEIGHT', 'BUILD_MUSCLE', 'MAINTAIN', 'GET_FIT').optional(),
  activity_level: Joi.number().min(1.2).max(2.5).optional(),
  activityLevel: Joi.number().min(1.2).max(2.5).optional().default(1.2),
}).unknown(true);

const createOrUpdateProfile = async (req, res) => {
  try {
    // Log incoming request for debugging
    console.log('📥 Profile Request Body:', JSON.stringify(req.body, null, 2));

    const { error, value } = profileSchema.validate(req.body, {
      stripUnknown: true, // Bilinmeyen alanları kaldır
      abortEarly: false,  // Tüm hataları göster
    });

    if (error) {
      console.error('❌ Validation Error:', error.details);
      return res.status(400).json({ error: error.details[0].message });
    }

    console.log('✅ Validated Profile Data:', JSON.stringify(value, null, 2));

    const {
      age,
      gender,
      height,
      weight,
      activityLevel,
    } = value;

    const goalWeight = value.goalWeight ?? value.goal_weight;
    const goalType = value.goalType ?? value.goal_type;
    const activityLevelFinal = activityLevel ?? value.activity_level;

    const existingProfile = await prisma.userProfile.findUnique({
      where: { userId: req.userId },
    });

    let profile;
    if (existingProfile) {
      profile = await prisma.userProfile.update({
        where: { userId: req.userId },
        data: {
          age,
          gender,
          height,
          weight,
          goalWeight,
          goalType,
          activityLevel: activityLevelFinal,
        },
      });
    } else {
      profile = await prisma.userProfile.create({
        data: {
          userId: req.userId,
          age,
          gender,
          height,
          weight,
          goalWeight,
          goalType,
          activityLevel: activityLevelFinal,
        },
      });
    }

    const bmi = calculateBMI(weight, height);
    const dailyCalories = calculateDailyCalories({
      gender,
      age,
      weightKg: weight,
      heightCm: height,
      activityFactor: activityLevelFinal,
    });
    const bmiCategory = getBMICategory(bmi);

    console.log('✅ Profile saved successfully:', profile.id);

    res.json({
      profile,
      calculations: {
        bmi,
        bmiCategory,
        dailyCalories,
      },
    });
  } catch (error) {
    console.error('❌ Profile error:', error);
    res.status(500).json({ error: 'Profil işlemi sırasında hata oluştu' });
  }
};

const getProfile = async (req, res) => {
  try {
    console.log('📖 Getting profile for user:', req.userId);

    const profile = await prisma.userProfile.findUnique({
      where: { userId: req.userId },
    });

    if (!profile) {
      console.log('⚠️ Profile not found for user:', req.userId);
      return res.status(404).json({ error: 'Profil bulunamadı' });
    }

    console.log('✅ Profile found:', profile.id);

    const bmi = calculateBMI(profile.weight, profile.height);
    const dailyCalories = calculateDailyCalories({
      gender: profile.gender,
      age: profile.age,
      weightKg: profile.weight,
      heightCm: profile.height,
      activityFactor: profile.activityLevel,
    });
    const bmiCategory = getBMICategory(bmi);

    res.json({
      profile,
      calculations: {
        bmi,
        bmiCategory,
        dailyCalories,
      },
    });
  } catch (error) {
    console.error('GetProfile error:', error);
    res.status(500).json({ error: 'Profil bilgisi alınamadı' });
  }
};

module.exports = {
  createOrUpdateProfile,
  getProfile,
};
