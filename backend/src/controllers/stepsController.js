const prisma = require('../config/database');
const Joi = require('joi');

const stepsSchema = Joi.object({
  steps: Joi.number().integer().min(0).max(100000).required(),
  date: Joi.date().optional(),
});

const addSteps = async (req, res) => {
  try {
    const { error, value } = stepsSchema.validate(req.body);
    if (error) {
      return res.status(400).json({ error: error.details[0].message });
    }

    const { steps, date } = value;

    // Check if entry exists for today
    const targetDate = date ? new Date(date) : new Date();
    targetDate.setHours(0, 0, 0, 0);
    const tomorrow = new Date(targetDate);
    tomorrow.setDate(tomorrow.getDate() + 1);

    const existingEntry = await prisma.stepTracking.findFirst({
      where: {
        userId: req.userId,
        date: {
          gte: targetDate,
          lt: tomorrow,
        },
      },
    });

    let stepsEntry;
    if (existingEntry) {
      // Update existing
      stepsEntry = await prisma.stepTracking.update({
        where: { id: existingEntry.id },
        data: { steps },
      });
    } else {
      // Create new
      stepsEntry = await prisma.stepTracking.create({
        data: {
          userId: req.userId,
          steps,
          date: targetDate,
        },
      });
    }

    res.status(201).json(stepsEntry);
  } catch (error) {
    console.error('AddSteps error:', error);
    res.status(500).json({ error: 'Adım kaydı eklenirken hata oluştu' });
  }
};

const getTodaySteps = async (req, res) => {
  try {
    const today = new Date();
    today.setHours(0, 0, 0, 0);
    const tomorrow = new Date(today);
    tomorrow.setDate(tomorrow.getDate() + 1);

    const entry = await prisma.stepTracking.findFirst({
      where: {
        userId: req.userId,
        date: {
          gte: today,
          lt: tomorrow,
        },
      },
    });

    res.json({
      steps: entry ? entry.steps : 0,
      date: entry ? entry.date : new Date(),
    });
  } catch (error) {
    console.error('GetTodaySteps error:', error);
    res.status(500).json({ error: 'Günlük adım kaydı alınamadı' });
  }
};

const getStepsHistory = async (req, res) => {
  try {
    const { startDate, endDate } = req.query;

    const where = {
      userId: req.userId,
    };

    if (startDate || endDate) {
      where.date = {};
      if (startDate) where.date.gte = new Date(startDate);
      if (endDate) where.date.lte = new Date(endDate);
    }

    const entries = await prisma.stepTracking.findMany({
      where,
      orderBy: { date: 'desc' },
    });

    const total = entries.reduce((sum, entry) => sum + entry.steps, 0);

    res.json({
      entries,
      total,
      count: entries.length,
    });
  } catch (error) {
    console.error('GetStepsHistory error:', error);
    res.status(500).json({ error: 'Adım geçmişi alınamadı' });
  }
};

module.exports = {
  addSteps,
  getTodaySteps,
  getStepsHistory,
};
