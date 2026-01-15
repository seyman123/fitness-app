import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection_container.dart';
import '../../../auth/domain/entities/user.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../profile/presentation/bloc/profile_bloc.dart';
import '../../../profile/presentation/bloc/profile_event.dart';
import '../../../profile/presentation/pages/profile_page.dart';
import '../../../water/presentation/bloc/water_bloc.dart';
import '../../../water/presentation/bloc/water_event.dart';
import '../../../water/presentation/bloc/water_state.dart';
import '../../../water/presentation/pages/water_tracking_page.dart';
import '../../../nutrition/presentation/bloc/nutrition_bloc.dart';
import '../../../nutrition/presentation/bloc/nutrition_event.dart';
import '../../../nutrition/presentation/bloc/nutrition_state.dart';
import '../../../nutrition/presentation/pages/nutrition_tracking_page.dart';
import '../../../workout/presentation/pages/workouts_page.dart';
import '../../../workout/data/datasources/workout_remote_data_source.dart';
import '../../../steps/presentation/bloc/steps_bloc.dart';
import '../../../steps/presentation/bloc/steps_event.dart';
import '../../../steps/presentation/bloc/steps_state.dart';
import '../../../steps/presentation/pages/steps_tracking_page.dart';
import '../../../weight/presentation/pages/weight_tracking_page.dart';
import '../../../weight/presentation/bloc/weight_bloc.dart';
import '../../../weight/presentation/bloc/weight_event.dart';
import '../../../statistics/presentation/pages/statistics_page.dart';
import '../../../settings/presentation/pages/settings_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/config/api_config.dart';

class DashboardPage extends StatefulWidget {
  final User user;

  const DashboardPage({
    super.key,
    required this.user,
  });

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  late final WaterBloc _waterBloc;
  late final NutritionBloc _nutritionBloc;
  late final StepsBloc _stepsBloc;
  int _workoutDuration = 0;

  @override
  void initState() {
    super.initState();
    _waterBloc = sl<WaterBloc>()..add(const LoadTodayWater());
    _nutritionBloc = sl<NutritionBloc>()..add(const LoadTodayNutrition());
    _stepsBloc = sl<StepsBloc>()..add(const LoadTodaySteps());
    _loadWorkoutDuration();
  }

  @override
  void dispose() {
    _waterBloc.close();
    _nutritionBloc.close();
    _stepsBloc.close();
    super.dispose();
  }

  Future<void> _loadWorkoutDuration() async {
    try {
      final workoutDataSource = sl<WorkoutRemoteDataSource>();
      final result = await workoutDataSource.getTodayWorkoutLogs();
      if (mounted) {
        setState(() {
          _workoutDuration = result['totalDuration'] as int;
        });
      }
    } catch (e) {
      // Hata durumunda 0 olarak kalır
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sağlık & Fitness'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SettingsPage(),
                ),
              );
            },
            tooltip: 'Ayarlar',
          ),
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => BlocProvider(
                    create: (context) =>
                        sl<ProfileBloc>()..add(const LoadProfile()),
                    child: ProfilePage(user: widget.user),
                  ),
                ),
              );
            },
            tooltip: 'Profil',
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              context.read<AuthBloc>().add(const LogoutRequested());
            },
            tooltip: 'Çıkış Yap',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          _waterBloc.add(const RefreshWater());
          _nutritionBloc.add(const RefreshNutrition());
          _stepsBloc.add(const RefreshSteps());
          await _loadWorkoutDuration();
          await Future.delayed(const Duration(seconds: 1));
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Kompakt Kullanıcı Bilgisi
              Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: Theme.of(context).primaryColor,
                    child: Text(
                      (widget.user.name ?? widget.user.email)
                          .substring(0, 1)
                          .toUpperCase(),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Merhaba, ${widget.user.name ?? 'Kullanıcı'}',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        Text(
                          'Bugünkü hedeflerinizi tamamlayın',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Hızlı İstatistikler
              BlocBuilder<WaterBloc, WaterState>(
                bloc: _waterBloc,
                builder: (context, waterState) {
                  final waterTotal = waterState is WaterLoaded
                      ? waterState.totalAmount
                      : 0;

                  return BlocBuilder<NutritionBloc, NutritionState>(
                    bloc: _nutritionBloc,
                    builder: (context, nutritionState) {
                      final calorieTotal = nutritionState is NutritionLoaded
                          ? nutritionState.totalCalories.toInt()
                          : 0;

                      return BlocBuilder<StepsBloc, StepsState>(
                        bloc: _stepsBloc,
                        builder: (context, stepsState) {
                          final steps = stepsState is StepsLoaded
                              ? stepsState.todaySteps
                              : 0;

                          return Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildStatCard(
                                      context,
                                      icon: Icons.water_drop_outlined,
                                      title: 'Su',
                                      value: '$waterTotal ml',
                                      subtitle: '2000 ml hedef',
                                      color: Colors.blue,
                                      onTap: () => _navigateToWaterPage(context),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: _buildStatCard(
                                      context,
                                      icon: Icons.local_fire_department,
                                      title: 'Kalori',
                                      value: '$calorieTotal kcal',
                                      subtitle: 'Alınan',
                                      color: Colors.orange,
                                      onTap: () => _navigateToNutritionPage(context),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildStatCard(
                                      context,
                                      icon: Icons.fitness_center,
                                      title: 'Antrenman',
                                      value: '$_workoutDuration dk',
                                      subtitle: 'Bugün',
                                      color: Colors.green,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: _buildStatCard(
                                      context,
                                      icon: Icons.show_chart,
                                      title: 'Adım',
                                      value: '$steps',
                                      subtitle: '10000 hedef',
                                      color: Colors.purple,
                                      onTap: () => _navigateToStepsPage(context),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          );
                        },
                      );
                    },
                  );
                },
              ),
              const SizedBox(height: 20),

              // Özellikler Listesi
              Row(
                children: [
                  Icon(Icons.apps_rounded, size: 20, color: Colors.grey[700]),
                  const SizedBox(width: 8),
                  Text(
                    'Hızlı Erişim',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              _buildFeatureTile(
                context,
                icon: Icons.fitness_center,
                title: 'Antrenman Programları',
                subtitle: 'Kişisel ve hazır antrenman planları',
                color: Colors.green,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const WorkoutsPage(),
                    ),
                  );
                },
              ),
              _buildFeatureTile(
                context,
                icon: Icons.water_drop_outlined,
                title: 'Su Takibi',
                subtitle: 'Günlük su tüketimini kaydet',
                color: Colors.blue,
                onTap: () => _navigateToWaterPage(context),
              ),
              _buildFeatureTile(
                context,
                icon: Icons.restaurant,
                title: 'Beslenme Günlüğü',
                subtitle: 'Öğünlerini ve kalorini takip et',
                color: Colors.orange,
                onTap: () => _navigateToNutritionPage(context),
              ),
              _buildFeatureTile(
                context,
                icon: Icons.monitor_weight,
                title: 'Kilo Takibi',
                subtitle: 'Kilonu kaydet ve ilerlemeyi gör',
                color: Colors.indigo,
                onTap: () => _navigateToWeightPage(context),
              ),
              _buildFeatureTile(
                context,
                icon: Icons.show_chart,
                title: 'İstatistikler',
                subtitle: 'Haftalık ve aylık grafiklerle ilerlemen',
                color: Colors.purple,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const StatisticsPage(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _navigateToWaterPage(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BlocProvider(
          create: (context) => sl<WaterBloc>()..add(const LoadTodayWater()),
          child: const WaterTrackingPage(),
        ),
      ),
    );

    // Sayfa geri döndüğünde su verilerini yenile
    if (result == true || mounted) {
      _waterBloc.add(const RefreshWater());
    }
  }

  Future<void> _navigateToNutritionPage(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BlocProvider(
          create: (context) => sl<NutritionBloc>()..add(const LoadTodayNutrition()),
          child: const NutritionTrackingPage(),
        ),
      ),
    );

    // Sayfa geri döndüğünde beslenme verilerini yenile
    if (result == true || mounted) {
      _nutritionBloc.add(const RefreshNutrition());
    }
  }

  Future<void> _navigateToStepsPage(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BlocProvider(
          create: (context) => sl<StepsBloc>()..add(const LoadTodaySteps()),
          child: const StepsTrackingPage(),
        ),
      ),
    );

    // Sayfa geri döndüğünde adım verilerini yenile
    if (result == true || mounted) {
      _stepsBloc.add(const RefreshSteps());
    }
  }

  Future<void> _navigateToWeightPage(BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MultiBlocProvider(
          providers: [
            BlocProvider(
              create: (context) =>
                  sl<WeightBloc>()..add(const LoadWeightHistory(limit: 30)),
            ),
            BlocProvider(
              create: (context) => sl<ProfileBloc>()..add(const LoadProfile()),
            ),
          ],
          child: const WeightTrackingPage(),
        ),
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
    required String subtitle,
    required Color color,
    VoidCallback? onTap,
  }) {
    return Card(
      elevation: 0,
      color: color.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(height: 12),
              Text(
                value,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey[200]!,
          width: 1,
        ),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 22),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Colors.grey[400],
        ),
      ),
    );
  }
}
