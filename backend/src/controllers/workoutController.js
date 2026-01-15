const prisma = require('../config/database');
const Joi = require('joi');

// Validation schemas
const workoutSchema = Joi.object({
  name: Joi.string().min(1).max(200).required(),
  description: Joi.string().max(1000).optional().allow('', null),
  isTemplate: Joi.boolean().optional().default(false),
  exercises: Joi.array().items(
    Joi.object({
      name: Joi.string().min(1).max(200).required(),
      sets: Joi.number().integer().min(1).max(20).required(),
      reps: Joi.number().integer().min(1).max(200).required(),
      restSeconds: Joi.number().integer().min(0).max(600).optional(),
      notes: Joi.string().max(500).optional().allow('', null),
      order: Joi.number().integer().min(0).optional().default(0),
    })
  ).optional().default([]),
});

const workoutLogSchema = Joi.object({
  workoutId: Joi.string().uuid().required(),
  date: Joi.date().iso().optional(),
  duration: Joi.number().integer().min(1).max(600).optional(),
  notes: Joi.string().max(500).optional().allow('', null),
  completed: Joi.boolean().optional().default(true),
});

// Tüm workoutları getir (template + kullanıcı özel)
const getWorkouts = async (req, res) => {
  try {
    const workouts = await prisma.workout.findMany({
      where: {
        userId: req.userId,
      },
      include: {
        exercises: {
          orderBy: { order: 'asc' },
        },
        _count: {
          select: { logs: true },
        },
      },
      orderBy: {
        createdAt: 'desc',
      },
    });

    res.json({
      workouts: workouts.map((w) => ({
        id: w.id,
        userId: w.userId,
        name: w.name,
        description: w.description,
        isTemplate: w.isTemplate,
        exerciseCount: w.exercises.length,
        completedCount: w._count.logs,
        exercises: w.exercises,
        createdAt: w.createdAt,
        updatedAt: w.updatedAt,
      })),
    });
  } catch (error) {
    console.error('Get workouts error:', error);
    res.status(500).json({ error: 'Antrenman programları alınamadı' });
  }
};

// Tek workout detayı getir
const getWorkoutById = async (req, res) => {
  try {
    const { id } = req.params;

    const workout = await prisma.workout.findFirst({
      where: {
        id,
        userId: req.userId,
      },
      include: {
        exercises: {
          orderBy: { order: 'asc' },
        },
      },
    });

    if (!workout) {
      return res.status(404).json({ error: 'Antrenman programı bulunamadı' });
    }

    res.json(workout);
  } catch (error) {
    console.error('Get workout by id error:', error);
    res.status(500).json({ error: 'Antrenman programı alınamadı' });
  }
};

// Yeni workout oluştur
const createWorkout = async (req, res) => {
  console.log('=== CREATE WORKOUT REQUEST ===');
  console.log('User ID:', req.userId);
  console.log('Request body:', JSON.stringify(req.body, null, 2));
  try {
    const { error, value } = workoutSchema.validate(req.body);
    if (error) {
      console.log('Validation error:', error.details[0].message);
      return res.status(400).json({ error: error.details[0].message });
    }

    console.log('Validated data:', JSON.stringify(value, null, 2));
    const { name, description, isTemplate, exercises } = value;

    const workout = await prisma.workout.create({
      data: {
        userId: req.userId,
        name,
        description,
        isTemplate,
        exercises: {
          create: exercises.map((ex, index) => ({
            name: ex.name,
            sets: ex.sets,
            reps: ex.reps,
            restSeconds: ex.restSeconds,
            notes: ex.notes,
            order: ex.order !== undefined ? ex.order : index,
          })),
        },
      },
      include: {
        exercises: {
          orderBy: { order: 'asc' },
        },
      },
    });

    console.log('Workout created successfully:', workout.id);
    res.status(201).json({
      message: 'Antrenman programı başarıyla oluşturuldu',
      workout,
    });
  } catch (error) {
    console.error('Create workout error:', error);
    console.error('Error stack:', error.stack);
    res.status(500).json({ error: 'Antrenman programı oluşturulamadı' });
  }
};

// Workout güncelle
const updateWorkout = async (req, res) => {
  try {
    const { id } = req.params;
    const { error, value } = workoutSchema.validate(req.body);
    if (error) {
      return res.status(400).json({ error: error.details[0].message });
    }

    const { name, description, isTemplate, exercises } = value;

    // Check ownership
    const existingWorkout = await prisma.workout.findFirst({
      where: { id, userId: req.userId },
    });

    if (!existingWorkout) {
      return res.status(404).json({ error: 'Antrenman programı bulunamadı' });
    }

    // Delete old exercises and create new ones
    await prisma.workoutExercise.deleteMany({
      where: { workoutId: id },
    });

    const workout = await prisma.workout.update({
      where: { id },
      data: {
        name,
        description,
        isTemplate,
        exercises: {
          create: exercises.map((ex, index) => ({
            name: ex.name,
            sets: ex.sets,
            reps: ex.reps,
            restSeconds: ex.restSeconds,
            notes: ex.notes,
            order: ex.order !== undefined ? ex.order : index,
          })),
        },
      },
      include: {
        exercises: {
          orderBy: { order: 'asc' },
        },
      },
    });

    res.json({
      message: 'Antrenman programı başarıyla güncellendi',
      workout,
    });
  } catch (error) {
    console.error('Update workout error:', error);
    res.status(500).json({ error: 'Antrenman programı güncellenemedi' });
  }
};

// Workout sil
const deleteWorkout = async (req, res) => {
  try {
    const { id } = req.params;

    const workout = await prisma.workout.findFirst({
      where: { id, userId: req.userId },
    });

    if (!workout) {
      return res.status(404).json({ error: 'Antrenman programı bulunamadı' });
    }

    await prisma.workout.delete({
      where: { id },
    });

    res.json({ message: 'Antrenman programı başarıyla silindi' });
  } catch (error) {
    console.error('Delete workout error:', error);
    res.status(500).json({ error: 'Antrenman programı silinemedi' });
  }
};

// Workout logları getir
const getWorkoutLogs = async (req, res) => {
  try {
    const { startDate, endDate, workoutId } = req.query;

    const where = {
      userId: req.userId,
    };

    if (workoutId) {
      where.workoutId = workoutId;
    }

    if (startDate || endDate) {
      where.date = {};
      if (startDate) where.date.gte = new Date(startDate);
      if (endDate) where.date.lte = new Date(endDate);
    }

    const logs = await prisma.workoutLog.findMany({
      where,
      include: {
        workout: {
          include: {
            exercises: true,
          },
        },
      },
      orderBy: {
        date: 'desc',
      },
    });

    res.json({ logs });
  } catch (error) {
    console.error('Get workout logs error:', error);
    res.status(500).json({ error: 'Antrenman kayıtları alınamadı' });
  }
};

// Bugünkü workout loglarını getir
const getTodayWorkoutLogs = async (req, res) => {
  try {
    const today = new Date();
    today.setHours(0, 0, 0, 0);
    const tomorrow = new Date(today);
    tomorrow.setDate(tomorrow.getDate() + 1);

    const logs = await prisma.workoutLog.findMany({
      where: {
        userId: req.userId,
        date: {
          gte: today,
          lt: tomorrow,
        },
      },
      include: {
        workout: {
          select: {
            name: true,
          },
        },
      },
      orderBy: {
        date: 'desc',
      },
    });

    const totalDuration = logs.reduce((sum, log) => sum + (log.duration || 0), 0);

    res.json({
      logs,
      totalDuration,
      count: logs.length,
    });
  } catch (error) {
    console.error('Get today workout logs error:', error);
    res.status(500).json({ error: 'Bugünkü antrenman kayıtları alınamadı' });
  }
};

// Yeni workout log oluştur (antrenman tamamlandı)
const createWorkoutLog = async (req, res) => {
  try {
    const { error, value } = workoutLogSchema.validate(req.body);
    if (error) {
      return res.status(400).json({ error: error.details[0].message });
    }

    const { workoutId, date, duration, notes, completed } = value;

    // Workout'un kullanıcıya ait olup olmadığını kontrol et
    const workout = await prisma.workout.findFirst({
      where: {
        id: workoutId,
        userId: req.userId,
      },
    });

    if (!workout) {
      return res.status(404).json({ error: 'Antrenman programı bulunamadı' });
    }

    const log = await prisma.workoutLog.create({
      data: {
        userId: req.userId,
        workoutId,
        date: date ? new Date(date) : new Date(),
        duration,
        notes,
        completed,
      },
      include: {
        workout: true,
      },
    });

    res.status(201).json({
      message: 'Antrenman kaydı başarıyla oluşturuldu',
      log,
    });
  } catch (error) {
    console.error('Create workout log error:', error);
    res.status(500).json({ error: 'Antrenman kaydı oluşturulamadı' });
  }
};

// Workout log sil
const deleteWorkoutLog = async (req, res) => {
  try {
    const { id } = req.params;

    const log = await prisma.workoutLog.findFirst({
      where: { id, userId: req.userId },
    });

    if (!log) {
      return res.status(404).json({ error: 'Antrenman kaydı bulunamadı' });
    }

    await prisma.workoutLog.delete({
      where: { id },
    });

    res.json({ message: 'Antrenman kaydı başarıyla silindi' });
  } catch (error) {
    console.error('Delete workout log error:', error);
    res.status(500).json({ error: 'Antrenman kaydı silinemedi' });
  }
};

module.exports = {
  getWorkouts,
  getWorkoutById,
  createWorkout,
  updateWorkout,
  deleteWorkout,
  getWorkoutLogs,
  getTodayWorkoutLogs,
  createWorkoutLog,
  deleteWorkoutLog,
};
