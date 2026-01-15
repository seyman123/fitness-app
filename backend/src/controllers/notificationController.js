const { PrismaClient } = require('@prisma/client');
const Joi = require('joi');

const prisma = new PrismaClient();

// Validation schema
const notificationSettingsSchema = Joi.object({
  workoutReminders: Joi.boolean(),
  workoutTime: Joi.string().pattern(/^([01]\d|2[0-3]):([0-5]\d)$/), // HH:mm format
  waterReminders: Joi.boolean(),
  waterInterval: Joi.number().integer().min(30).max(480), // 30 min - 8 saat
  dailySummary: Joi.boolean(),
  dailySummaryTime: Joi.string().pattern(/^([01]\d|2[0-3]):([0-5]\d)$/),
});

// Get notification settings
const getNotificationSettings = async (req, res) => {
  try {
    let settings = await prisma.notificationSettings.findUnique({
      where: { userId: req.userId },
    });

    // If no settings exist, create default settings
    if (!settings) {
      settings = await prisma.notificationSettings.create({
        data: { userId: req.userId },
      });
    }

    res.json(settings);
  } catch (error) {
    console.error('Get notification settings error:', error);
    res.status(500).json({ error: 'Bildirim ayarları alınamadı' });
  }
};

// Update notification settings
const updateNotificationSettings = async (req, res) => {
  try {
    console.log('🔔 Notification Settings Update Request:', JSON.stringify(req.body, null, 2));

    // Validate request body
    const { error, value } = notificationSettingsSchema.validate(req.body, {
      stripUnknown: true,
    });
    if (error) {
      console.error('❌ Notification Validation Error:', error.details);
      return res.status(400).json({ error: error.details[0].message });
    }

    // Check if settings exist
    const existingSettings = await prisma.notificationSettings.findUnique({
      where: { userId: req.userId },
    });

    let settings;
    if (existingSettings) {
      // Update existing settings
      settings = await prisma.notificationSettings.update({
        where: { userId: req.userId },
        data: value,
      });
    } else {
      // Create new settings
      settings = await prisma.notificationSettings.create({
        data: {
          userId: req.userId,
          ...value,
        },
      });
    }

    console.log('✅ Notification settings saved for user:', req.userId);
    res.json(settings);
  } catch (error) {
    console.error('❌ Update notification settings error:', error);
    res.status(500).json({ error: 'Bildirim ayarları güncellenemedi' });
  }
};

// Reset to default settings
const resetNotificationSettings = async (req, res) => {
  try {
    const settings = await prisma.notificationSettings.upsert({
      where: { userId: req.userId },
      update: {
        workoutReminders: true,
        workoutTime: '09:00',
        waterReminders: true,
        waterInterval: 120,
        dailySummary: true,
        dailySummaryTime: '20:00',
      },
      create: {
        userId: req.userId,
        workoutReminders: true,
        workoutTime: '09:00',
        waterReminders: true,
        waterInterval: 120,
        dailySummary: true,
        dailySummaryTime: '20:00',
      },
    });

    res.json(settings);
  } catch (error) {
    console.error('Reset notification settings error:', error);
    res.status(500).json({ error: 'Bildirim ayarları sıfırlanamadı' });
  }
};

module.exports = {
  getNotificationSettings,
  updateNotificationSettings,
  resetNotificationSettings,
};
