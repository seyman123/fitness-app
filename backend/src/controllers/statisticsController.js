const prisma = require('../config/database');

// Genel özet istatistikler
const getOverviewStats = async (req, res) => {
  try {
    const { days = 7 } = req.query;
    const daysInt = parseInt(days);

    const startDate = new Date();
    startDate.setDate(startDate.getDate() - daysInt);
    startDate.setHours(0, 0, 0, 0);

    // Paralel olarak tüm istatistikleri çek
    const [
      weightStats,
      workoutStats,
      waterStats,
      nutritionStats,
      stepsStats,
    ] = await Promise.all([
      // Kilo istatistikleri
      prisma.weightHistory.findMany({
        where: {
          userId: req.userId,
          date: { gte: startDate },
        },
        orderBy: { date: 'asc' },
        select: { date: true, weight: true, bmi: true },
      }),

      // Antrenman istatistikleri
      prisma.workoutLog.findMany({
        where: {
          userId: req.userId,
          date: { gte: startDate },
        },
        select: { date: true, duration: true, completed: true },
      }),

      // Su tüketimi istatistikleri
      prisma.waterTracking.findMany({
        where: {
          userId: req.userId,
          date: { gte: startDate },
        },
        select: { date: true, amount: true },
      }),

      // Beslenme istatistikleri
      prisma.nutritionLog.findMany({
        where: {
          userId: req.userId,
          date: { gte: startDate },
        },
        select: { date: true, calories: true, protein: true, carbs: true, fat: true },
      }),

      // Adım istatistikleri
      prisma.stepTracking.findMany({
        where: {
          userId: req.userId,
          date: { gte: startDate },
        },
        select: { date: true, steps: true },
      }),
    ]);

    // Günlük bazda gruplama
    const dailyStats = {};

    for (let i = 0; i < daysInt; i++) {
      const date = new Date();
      date.setDate(date.getDate() - i);
      const dateKey = date.toISOString().split('T')[0];

      dailyStats[dateKey] = {
        date: dateKey,
        weight: null,
        bmi: null,
        workoutDuration: 0,
        workoutCount: 0,
        water: 0,
        calories: 0,
        protein: 0,
        carbs: 0,
        fat: 0,
        steps: 0,
      };
    }

    // Verileri günlük istatistiklere yerleştir
    weightStats.forEach(w => {
      const dateKey = w.date.toISOString().split('T')[0];
      if (dailyStats[dateKey]) {
        dailyStats[dateKey].weight = w.weight;
        dailyStats[dateKey].bmi = w.bmi;
      }
    });

    workoutStats.forEach(w => {
      const dateKey = w.date.toISOString().split('T')[0];
      if (dailyStats[dateKey] && w.completed) {
        dailyStats[dateKey].workoutDuration += w.duration || 0;
        dailyStats[dateKey].workoutCount += 1;
      }
    });

    waterStats.forEach(w => {
      const dateKey = w.date.toISOString().split('T')[0];
      if (dailyStats[dateKey]) {
        dailyStats[dateKey].water += w.amount;
      }
    });

    nutritionStats.forEach(n => {
      const dateKey = n.date.toISOString().split('T')[0];
      if (dailyStats[dateKey]) {
        dailyStats[dateKey].calories += n.calories;
        dailyStats[dateKey].protein += n.protein || 0;
        dailyStats[dateKey].carbs += n.carbs || 0;
        dailyStats[dateKey].fat += n.fat || 0;
      }
    });

    stepsStats.forEach(s => {
      const dateKey = s.date.toISOString().split('T')[0];
      if (dailyStats[dateKey]) {
        dailyStats[dateKey].steps += s.steps;
      }
    });

    // Diziye çevir ve sırala
    const statsArray = Object.values(dailyStats).sort((a, b) =>
      new Date(a.date) - new Date(b.date)
    );

    // Özet metrikler
    const summary = {
      avgWeight: weightStats.length > 0
        ? weightStats.reduce((sum, w) => sum + w.weight, 0) / weightStats.length
        : null,
      totalWorkouts: workoutStats.filter(w => w.completed).length,
      totalWorkoutMinutes: workoutStats.reduce((sum, w) => sum + (w.duration || 0), 0),
      avgWater: waterStats.length > 0
        ? Math.round(waterStats.reduce((sum, w) => sum + w.amount, 0) / daysInt)
        : 0,
      avgCalories: nutritionStats.length > 0
        ? Math.round(nutritionStats.reduce((sum, n) => sum + n.calories, 0) / daysInt)
        : 0,
      avgSteps: stepsStats.length > 0
        ? Math.round(stepsStats.reduce((sum, s) => sum + s.steps, 0) / daysInt)
        : 0,
    };

    res.json({
      period: `${daysInt} gün`,
      summary,
      dailyStats: statsArray,
    });
  } catch (error) {
    console.error('Get overview stats error:', error);
    res.status(500).json({ error: 'İstatistikler alınamadı' });
  }
};

// Haftalık karşılaştırma
const getWeeklyComparison = async (req, res) => {
  try {
    const thisWeekStart = new Date();
    thisWeekStart.setDate(thisWeekStart.getDate() - thisWeekStart.getDay());
    thisWeekStart.setHours(0, 0, 0, 0);

    const lastWeekStart = new Date(thisWeekStart);
    lastWeekStart.setDate(lastWeekStart.getDate() - 7);

    const lastWeekEnd = new Date(thisWeekStart);
    lastWeekEnd.setMilliseconds(-1);

    const [thisWeekWorkouts, lastWeekWorkouts, thisWeekWater, lastWeekWater, thisWeekSteps, lastWeekSteps] = await Promise.all([
      prisma.workoutLog.count({
        where: { userId: req.userId, date: { gte: thisWeekStart }, completed: true },
      }),
      prisma.workoutLog.count({
        where: { userId: req.userId, date: { gte: lastWeekStart, lt: thisWeekStart }, completed: true },
      }),
      prisma.waterTracking.aggregate({
        where: { userId: req.userId, date: { gte: thisWeekStart } },
        _sum: { amount: true },
      }),
      prisma.waterTracking.aggregate({
        where: { userId: req.userId, date: { gte: lastWeekStart, lt: thisWeekStart } },
        _sum: { amount: true },
      }),
      prisma.stepTracking.aggregate({
        where: { userId: req.userId, date: { gte: thisWeekStart } },
        _sum: { steps: true },
      }),
      prisma.stepTracking.aggregate({
        where: { userId: req.userId, date: { gte: lastWeekStart, lt: thisWeekStart } },
        _sum: { steps: true },
      }),
    ]);

    res.json({
      thisWeek: {
        workouts: thisWeekWorkouts,
        water: thisWeekWater._sum.amount || 0,
        steps: thisWeekSteps._sum.steps || 0,
      },
      lastWeek: {
        workouts: lastWeekWorkouts,
        water: lastWeekWater._sum.amount || 0,
        steps: lastWeekSteps._sum.steps || 0,
      },
      change: {
        workouts: thisWeekWorkouts - lastWeekWorkouts,
        water: (thisWeekWater._sum.amount || 0) - (lastWeekWater._sum.amount || 0),
        steps: (thisWeekSteps._sum.steps || 0) - (lastWeekSteps._sum.steps || 0),
      },
    });
  } catch (error) {
    console.error('Get weekly comparison error:', error);
    res.status(500).json({ error: 'Haftalık karşılaştırma alınamadı' });
  }
};

module.exports = {
  getOverviewStats,
  getWeeklyComparison,
};
