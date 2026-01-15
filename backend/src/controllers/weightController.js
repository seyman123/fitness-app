const prisma = require('../config/database');
const Joi = require('joi');

// Validation schema
const weightEntrySchema = Joi.object({
  weight: Joi.number().min(20).max(300).required(),
  bmi: Joi.number().min(10).max(60).optional(),
  notes: Joi.string().max(500).optional().allow('', null),
  date: Joi.date().iso().optional(),
});

// Kilo geçmişi kaydı oluştur
const createWeightEntry = async (req, res) => {
  try {
    const { error, value } = weightEntrySchema.validate(req.body);
    if (error) {
      return res.status(400).json({ error: error.details[0].message });
    }

    const { weight, bmi, notes, date } = value;

    const entry = await prisma.weightHistory.create({
      data: {
        userId: req.userId,
        weight,
        bmi,
        notes,
        date: date ? new Date(date) : new Date(),
      },
    });

    // Profildeki güncel kiloyu da güncelle
    await prisma.userProfile.update({
      where: { userId: req.userId },
      data: { weight },
    });

    res.status(201).json({
      message: 'Kilo kaydı başarıyla oluşturuldu',
      entry,
    });
  } catch (error) {
    console.error('Create weight entry error:', error);
    res.status(500).json({ error: 'Kilo kaydı oluşturulamadı' });
  }
};

// Kilo geçmişini getir
const getWeightHistory = async (req, res) => {
  try {
    const { startDate, endDate, limit = 30 } = req.query;

    const where = {
      userId: req.userId,
    };

    if (startDate || endDate) {
      where.date = {};
      if (startDate) where.date.gte = new Date(startDate);
      if (endDate) where.date.lte = new Date(endDate);
    }

    const history = await prisma.weightHistory.findMany({
      where,
      orderBy: {
        date: 'desc',
      },
      take: parseInt(limit),
    });

    res.json({ history });
  } catch (error) {
    console.error('Get weight history error:', error);
    res.status(500).json({ error: 'Kilo geçmişi alınamadı' });
  }
};

// Tek kilo kaydını getir
const getWeightEntry = async (req, res) => {
  try {
    const { id } = req.params;

    const entry = await prisma.weightHistory.findFirst({
      where: {
        id,
        userId: req.userId,
      },
    });

    if (!entry) {
      return res.status(404).json({ error: 'Kilo kaydı bulunamadı' });
    }

    res.json(entry);
  } catch (error) {
    console.error('Get weight entry error:', error);
    res.status(500).json({ error: 'Kilo kaydı alınamadı' });
  }
};

// Kilo kaydını güncelle
const updateWeightEntry = async (req, res) => {
  try {
    const { id } = req.params;
    const { error, value } = weightEntrySchema.validate(req.body);
    if (error) {
      return res.status(400).json({ error: error.details[0].message });
    }

    const { weight, bmi, notes, date } = value;

    // Check ownership
    const existingEntry = await prisma.weightHistory.findFirst({
      where: { id, userId: req.userId },
    });

    if (!existingEntry) {
      return res.status(404).json({ error: 'Kilo kaydı bulunamadı' });
    }

    const entry = await prisma.weightHistory.update({
      where: { id },
      data: {
        weight,
        bmi,
        notes,
        date: date ? new Date(date) : undefined,
      },
    });

    res.json({
      message: 'Kilo kaydı başarıyla güncellendi',
      entry,
    });
  } catch (error) {
    console.error('Update weight entry error:', error);
    res.status(500).json({ error: 'Kilo kaydı güncellenemedi' });
  }
};

// Kilo kaydını sil
const deleteWeightEntry = async (req, res) => {
  try {
    const { id } = req.params;

    const entry = await prisma.weightHistory.findFirst({
      where: { id, userId: req.userId },
    });

    if (!entry) {
      return res.status(404).json({ error: 'Kilo kaydı bulunamadı' });
    }

    await prisma.weightHistory.delete({
      where: { id },
    });

    res.json({ message: 'Kilo kaydı başarıyla silindi' });
  } catch (error) {
    console.error('Delete weight entry error:', error);
    res.status(500).json({ error: 'Kilo kaydı silinemedi' });
  }
};

// Kilo istatistikleri
const getWeightStats = async (req, res) => {
  try {
    const { days = 30 } = req.query;

    const startDate = new Date();
    startDate.setDate(startDate.getDate() - parseInt(days));

    const history = await prisma.weightHistory.findMany({
      where: {
        userId: req.userId,
        date: {
          gte: startDate,
        },
      },
      orderBy: {
        date: 'asc',
      },
    });

    if (history.length === 0) {
      return res.json({
        currentWeight: null,
        startWeight: null,
        weightChange: 0,
        trend: 'STABLE',
        history: [],
      });
    }

    const currentWeight = history[history.length - 1].weight;
    const startWeight = history[0].weight;
    const weightChange = currentWeight - startWeight;

    let trend = 'STABLE';
    if (weightChange > 0.5) trend = 'GAINING';
    else if (weightChange < -0.5) trend = 'LOSING';

    res.json({
      currentWeight,
      startWeight,
      weightChange: parseFloat(weightChange.toFixed(2)),
      trend,
      history: history.map(h => ({
        date: h.date,
        weight: h.weight,
        bmi: h.bmi,
      })),
    });
  } catch (error) {
    console.error('Get weight stats error:', error);
    res.status(500).json({ error: 'Kilo istatistikleri alınamadı' });
  }
};

module.exports = {
  createWeightEntry,
  getWeightHistory,
  getWeightEntry,
  updateWeightEntry,
  deleteWeightEntry,
  getWeightStats,
};
