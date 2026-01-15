const prisma = require('../config/database');
const Joi = require('joi');

const waterSchema = Joi.object({
  amount: Joi.number().integer().min(1).max(5000).required(),
  date: Joi.date().optional(),
});

const addWaterEntry = async (req, res) => {
  try {
    const { error, value } = waterSchema.validate(req.body);
    if (error) {
      return res.status(400).json({ error: error.details[0].message });
    }

    const { amount, date } = value;

    const waterEntry = await prisma.waterTracking.create({
      data: {
        userId: req.userId,
        amount,
        date: date ? new Date(date) : new Date(),
      },
    });

    res.status(201).json(waterEntry);
  } catch (error) {
    console.error('AddWater error:', error);
    res.status(500).json({ error: 'Su takibi eklenirken hata oluştu' });
  }
};

const getWaterEntries = async (req, res) => {
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

    const entries = await prisma.waterTracking.findMany({
      where,
      orderBy: { date: 'desc' },
    });

    const total = entries.reduce((sum, entry) => sum + entry.amount, 0);

    res.json({
      entries,
      total,
      count: entries.length,
    });
  } catch (error) {
    console.error('GetWater error:', error);
    res.status(500).json({ error: 'Su takibi alınamadı' });
  }
};

const getTodayWater = async (req, res) => {
  try {
    const today = new Date();
    today.setHours(0, 0, 0, 0);
    const tomorrow = new Date(today);
    tomorrow.setDate(tomorrow.getDate() + 1);

    const entries = await prisma.waterTracking.findMany({
      where: {
        userId: req.userId,
        date: {
          gte: today,
          lt: tomorrow,
        },
      },
      orderBy: { date: 'desc' },
    });

    const total = entries.reduce((sum, entry) => sum + entry.amount, 0);

    res.json({
      entries,
      total,
      count: entries.length,
    });
  } catch (error) {
    console.error('GetTodayWater error:', error);
    res.status(500).json({ error: 'Günlük su takibi alınamadı' });
  }
};

const deleteWaterEntry = async (req, res) => {
  try {
    const { id } = req.params;

    const entry = await prisma.waterTracking.findUnique({
      where: { id },
    });

    if (!entry) {
      return res.status(404).json({ error: 'Kayıt bulunamadı' });
    }

    if (entry.userId !== req.userId) {
      return res.status(403).json({ error: 'Bu kaydı silme yetkiniz yok' });
    }

    await prisma.waterTracking.delete({
      where: { id },
    });

    res.json({ message: 'Kayıt silindi' });
  } catch (error) {
    console.error('DeleteWater error:', error);
    res.status(500).json({ error: 'Kayıt silinirken hata oluştu' });
  }
};

module.exports = {
  addWaterEntry,
  getWaterEntries,
  getTodayWater,
  deleteWaterEntry,
};
