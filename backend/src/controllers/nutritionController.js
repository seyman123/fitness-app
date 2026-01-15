const prisma = require('../config/database');
const Joi = require('joi');

const nutritionSchema = Joi.object({
  mealType: Joi.string().valid('breakfast', 'lunch', 'dinner', 'snack').required(),
  foodName: Joi.string().required(),
  calories: Joi.number().min(0).required(),
  protein: Joi.number().min(0).optional(),
  carbs: Joi.number().min(0).optional(),
  fat: Joi.number().min(0).optional(),
  date: Joi.date().optional(),
});

const addNutritionLog = async (req, res) => {
  try {
    console.log('🍽️ Nutrition Log Request:', JSON.stringify(req.body, null, 2));

    const { error, value } = nutritionSchema.validate(req.body, {
      stripUnknown: true,
    });
    if (error) {
      console.error('❌ Nutrition Validation Error:', error.details);
      return res.status(400).json({ error: error.details[0].message });
    }

    const { mealType, foodName, calories, protein, carbs, fat, date } = value;

    const nutritionLog = await prisma.nutritionLog.create({
      data: {
        userId: req.userId,
        mealType,
        foodName,
        calories,
        protein,
        carbs,
        fat,
        date: date ? new Date(date) : new Date(),
      },
    });

    console.log('✅ Nutrition log saved:', nutritionLog.id);
    res.status(201).json(nutritionLog);
  } catch (error) {
    console.error('❌ AddNutrition error:', error);
    res.status(500).json({ error: 'Beslenme kaydı eklenirken hata oluştu' });
  }
};

const getNutritionLogs = async (req, res) => {
  try {
    const { startDate, endDate, mealType } = req.query;

    const where = {
      userId: req.userId,
    };

    if (mealType) {
      where.mealType = mealType;
    }

    if (startDate || endDate) {
      where.date = {};
      if (startDate) where.date.gte = new Date(startDate);
      if (endDate) where.date.lte = new Date(endDate);
    }

    const logs = await prisma.nutritionLog.findMany({
      where,
      orderBy: { date: 'desc' },
    });

    const totals = logs.reduce(
      (acc, log) => ({
        calories: acc.calories + log.calories,
        protein: acc.protein + (log.protein || 0),
        carbs: acc.carbs + (log.carbs || 0),
        fat: acc.fat + (log.fat || 0),
      }),
      { calories: 0, protein: 0, carbs: 0, fat: 0 }
    );

    res.json({
      logs,
      totals,
      count: logs.length,
    });
  } catch (error) {
    console.error('GetNutrition error:', error);
    res.status(500).json({ error: 'Beslenme kayıtları alınamadı' });
  }
};

const getTodayNutrition = async (req, res) => {
  try {
    const today = new Date();
    today.setHours(0, 0, 0, 0);
    const tomorrow = new Date(today);
    tomorrow.setDate(tomorrow.getDate() + 1);

    const logs = await prisma.nutritionLog.findMany({
      where: {
        userId: req.userId,
        date: {
          gte: today,
          lt: tomorrow,
        },
      },
      orderBy: { date: 'desc' },
    });

    const totals = logs.reduce(
      (acc, log) => ({
        calories: acc.calories + log.calories,
        protein: acc.protein + (log.protein || 0),
        carbs: acc.carbs + (log.carbs || 0),
        fat: acc.fat + (log.fat || 0),
      }),
      { calories: 0, protein: 0, carbs: 0, fat: 0 }
    );

    const byMealType = {
      breakfast: logs.filter((l) => l.mealType === 'breakfast'),
      lunch: logs.filter((l) => l.mealType === 'lunch'),
      dinner: logs.filter((l) => l.mealType === 'dinner'),
      snack: logs.filter((l) => l.mealType === 'snack'),
    };

    res.json({
      logs,
      totals,
      byMealType,
      count: logs.length,
    });
  } catch (error) {
    console.error('GetTodayNutrition error:', error);
    res.status(500).json({ error: 'Günlük beslenme kayıtları alınamadı' });
  }
};

const deleteNutritionLog = async (req, res) => {
  try {
    const { id } = req.params;

    const log = await prisma.nutritionLog.findUnique({
      where: { id },
    });

    if (!log) {
      return res.status(404).json({ error: 'Kayıt bulunamadı' });
    }

    if (log.userId !== req.userId) {
      return res.status(403).json({ error: 'Bu kaydı silme yetkiniz yok' });
    }

    await prisma.nutritionLog.delete({
      where: { id },
    });

    res.json({ message: 'Kayıt silindi' });
  } catch (error) {
    console.error('DeleteNutrition error:', error);
    res.status(500).json({ error: 'Kayıt silinirken hata oluştu' });
  }
};

module.exports = {
  addNutritionLog,
  getNutritionLogs,
  getTodayNutrition,
  deleteNutritionLog,
};
