const express = require('express');
const router = express.Router();
const authMiddleware = require('../middleware/auth');
const {
  getWorkouts,
  getWorkoutById,
  createWorkout,
  updateWorkout,
  deleteWorkout,
  getWorkoutLogs,
  getTodayWorkoutLogs,
  createWorkoutLog,
  deleteWorkoutLog,
} = require('../controllers/workoutController');

// Tüm route'lar auth gerektiriyor
router.use(authMiddleware);

// Workout CRUD
router.get('/', getWorkouts);
router.get('/:id', getWorkoutById);
router.post('/', createWorkout);
router.put('/:id', updateWorkout);
router.delete('/:id', deleteWorkout);

// Workout logs
router.get('/logs/all', getWorkoutLogs);
router.get('/logs/today', getTodayWorkoutLogs);
router.post('/logs', createWorkoutLog);
router.delete('/logs/:id', deleteWorkoutLog);

module.exports = router;
