import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import '../bloc/nutrition_bloc.dart';
import '../bloc/nutrition_event.dart';
import '../bloc/nutrition_state.dart';
import '../../domain/entities/nutrition_log.dart';

class NutritionTrackingPage extends StatefulWidget {
  const NutritionTrackingPage({super.key});

  @override
  State<NutritionTrackingPage> createState() => _NutritionTrackingPageState();
}

class _NutritionTrackingPageState extends State<NutritionTrackingPage> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        context.read<NutritionBloc>().add(const LoadTodayNutrition());
      } catch (e) {
        if (kDebugMode) {
          debugPrint('[Nutrition] Failed to auto-load today nutrition: $e');
        }
      }
    });
  }

  Map<String, List<NutritionLog>> _groupByMealType(List<NutritionLog> logs) {
    final grouped = <String, List<NutritionLog>>{
      'breakfast': <NutritionLog>[],
      'lunch': <NutritionLog>[],
      'dinner': <NutritionLog>[],
      'snack': <NutritionLog>[],
    };

    for (final log in logs) {
      final key = log.mealType;
      if (grouped.containsKey(key)) {
        grouped[key]!.add(log);
      }
    }
    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, true);
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Beslenme Takibi'),
        ),
        body: BlocConsumer<NutritionBloc, NutritionState>(
          listener: (context, state) {
            if (state is NutritionOperationSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.green,
                  duration: const Duration(seconds: 2),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              );
            } else if (state is NutritionError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              );
            }
          },
          builder: (context, state) {
            if (state is NutritionLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is NutritionError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 64, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(state.message),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        context.read<NutritionBloc>().add(const LoadTodayNutrition());
                      },
                      child: const Text('Tekrar Dene'),
                    ),
                  ],
                ),
              );
            }

            final List<NutritionLog> logs = state is NutritionLoaded ? state.logs : const <NutritionLog>[];
            final totals = state is NutritionLoaded ? state.totals : {'calories': 0.0, 'protein': 0.0, 'carbs': 0.0, 'fat': 0.0};
            final byMealType = state is NutritionLoaded
              ? (state.byMealType ?? (logs.isNotEmpty ? _groupByMealType(logs) : null))
              : null;

            const dailyCalorieGoal = 2000.0; // Default goal

            return RefreshIndicator(
              onRefresh: () async {
                context.read<NutritionBloc>().add(const RefreshNutrition());
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Calories Progress Card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.orange.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.local_fire_department, size: 20, color: Colors.grey[700]),
                                const SizedBox(width: 8),
                                Text(
                                  'Günlük Kalori',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey[800],
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              '${totals['calories']?.toStringAsFixed(0)} / ${dailyCalorieGoal.toStringAsFixed(0)} kcal',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.orange,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: LinearProgressIndicator(
                            value: (totals['calories'] ?? 0) / dailyCalorieGoal,
                            minHeight: 16,
                            backgroundColor: Colors.white,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              (totals['calories'] ?? 0) >= dailyCalorieGoal ? Colors.green : Colors.orange,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          '${(((totals['calories'] ?? 0) / dailyCalorieGoal) * 100).toStringAsFixed(0)}% tamamlandı${(totals['calories'] ?? 0) >= dailyCalorieGoal ? " 🎉" : ""}',
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Macros Summary
                  Row(
                    children: [
                      Expanded(
                        child: _buildMacroCard(
                          'Protein',
                          totals['protein']?.toStringAsFixed(1) ?? '0',
                          'g',
                          Colors.red,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildMacroCard(
                          'Karbonhidrat',
                          totals['carbs']?.toStringAsFixed(1) ?? '0',
                          'g',
                          Colors.amber,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildMacroCard(
                          'Yağ',
                          totals['fat']?.toStringAsFixed(1) ?? '0',
                          'g',
                          Colors.purple,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Quick Add Button
                  OutlinedButton.icon(
                    onPressed: () => _showAddFoodDialog(context),
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text(
                      'Yemek Ekle',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      side: BorderSide(color: Colors.grey[300]!),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Meals by Type
                  if (byMealType != null) ...[
                    _buildMealSection(context, 'Kahvaltı', 'breakfast', byMealType['breakfast'] ?? []),
                    _buildMealSection(context, 'Öğle Yemeği', 'lunch', byMealType['lunch'] ?? []),
                    _buildMealSection(context, 'Akşam Yemeği', 'dinner', byMealType['dinner'] ?? []),
                    _buildMealSection(context, 'Atıştırmalık', 'snack', byMealType['snack'] ?? []),
                  ] else if (logs.isEmpty) ...[
                    Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.restaurant_outlined,
                            size: 48,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Henüz beslenme kaydı yok',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    ),
  );
}

  Widget _buildMacroCard(String label, String value, String unit, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey[200]!,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              label == 'Protein' ? Icons.egg_outlined :
              label == 'Karbonhidrat' ? Icons.grain : Icons.water_drop_outlined,
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              Text(
                unit,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMealSection(BuildContext context, String title, String mealType, List logs) {
    if (logs.isEmpty) return const SizedBox.shrink();

    final totalCalories = logs.fold<double>(0, (sum, log) => sum + log.calories);

    IconData mealIcon;
    switch (mealType) {
      case 'breakfast':
        mealIcon = Icons.free_breakfast;
        break;
      case 'lunch':
        mealIcon = Icons.lunch_dining;
        break;
      case 'dinner':
        mealIcon = Icons.dinner_dining;
        break;
      case 'snack':
        mealIcon = Icons.cookie_outlined;
        break;
      default:
        mealIcon = Icons.restaurant;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(mealIcon, size: 20, color: Colors.grey[700]),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
              ],
            ),
            Text(
              '${totalCalories.toStringAsFixed(0)} kcal',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ...logs.map((log) => _buildFoodCard(context, log)),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildFoodCard(BuildContext context, log) {
    final timeFormat = DateFormat('HH:mm');

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey[200]!,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.restaurant,
              color: Colors.orange,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  log.foodName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${log.calories.toStringAsFixed(0)} kcal',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[700],
                  ),
                ),
                if (log.protein != null || log.carbs != null || log.fat != null)
                  Text(
                    'P: ${log.protein?.toStringAsFixed(0) ?? '-'}g • K: ${log.carbs?.toStringAsFixed(0) ?? '-'}g • Y: ${log.fat?.toStringAsFixed(0) ?? '-'}g',
                    style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                  ),
                const SizedBox(height: 2),
                Text(
                  timeFormat.format(log.date),
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
            onPressed: () {
              _showDeleteConfirmation(context, log.id);
            },
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  void _showAddFoodDialog(BuildContext pageContext) {
    final foodController = TextEditingController();
    final caloriesController = TextEditingController();
    final proteinController = TextEditingController();
    final carbsController = TextEditingController();
    final fatController = TextEditingController();
    String selectedMealType = 'breakfast';

    showDialog(
      context: pageContext,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogBuilderContext, setState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Yemek Ekle',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Öğün Seçin',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildMealTypeChip(
                      dialogBuilderContext,
                      'breakfast',
                      'Kahvaltı',
                      Icons.free_breakfast,
                      selectedMealType,
                      (value) => setState(() => selectedMealType = value),
                    ),
                    const SizedBox(width: 8),
                    _buildMealTypeChip(
                      dialogBuilderContext,
                      'lunch',
                      'Öğle',
                      Icons.lunch_dining,
                      selectedMealType,
                      (value) => setState(() => selectedMealType = value),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildMealTypeChip(
                      dialogBuilderContext,
                      'dinner',
                      'Akşam',
                      Icons.dinner_dining,
                      selectedMealType,
                      (value) => setState(() => selectedMealType = value),
                    ),
                    const SizedBox(width: 8),
                    _buildMealTypeChip(
                      dialogBuilderContext,
                      'snack',
                      'Atıştırmalık',
                      Icons.cookie_outlined,
                      selectedMealType,
                      (value) => setState(() => selectedMealType = value),
                    ),
                  ],
                ),
              const SizedBox(height: 12),
              TextField(
                controller: foodController,
                style: const TextStyle(fontSize: 15),
                decoration: InputDecoration(
                  labelText: 'Yemek Adı',
                  hintText: 'Örn: Tavuk Göğsü',
                  hintStyle: TextStyle(color: Colors.grey[400]),
                  prefixIcon: const Icon(Icons.restaurant_outlined, size: 20),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Theme.of(dialogBuilderContext).primaryColor,
                      width: 2,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: caloriesController,
                keyboardType: TextInputType.number,
                style: const TextStyle(fontSize: 15),
                decoration: InputDecoration(
                  labelText: 'Kalori (kcal)',
                  hintText: 'Örn: 250',
                  hintStyle: TextStyle(color: Colors.grey[400]),
                  prefixIcon: const Icon(Icons.local_fire_department, size: 20),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Theme.of(dialogBuilderContext).primaryColor,
                      width: 2,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: proteinController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(fontSize: 15),
                      decoration: InputDecoration(
                        labelText: 'Protein (g)',
                        hintStyle: TextStyle(color: Colors.grey[400]),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                              color: Theme.of(dialogBuilderContext).primaryColor,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: carbsController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(fontSize: 15),
                      decoration: InputDecoration(
                        labelText: 'Karb. (g)',
                        hintStyle: TextStyle(color: Colors.grey[400]),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                              color: Theme.of(dialogBuilderContext).primaryColor,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: fatController,
                keyboardType: TextInputType.number,
                style: const TextStyle(fontSize: 15),
                decoration: InputDecoration(
                  labelText: 'Yağ (g)',
                  hintStyle: TextStyle(color: Colors.grey[400]),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Theme.of(dialogBuilderContext).primaryColor,
                      width: 2,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              final foodName = foodController.text.trim();
              final caloriesText = caloriesController.text.trim();

              // Yemek adı kontrolü
              if (foodName.isEmpty) {
                ScaffoldMessenger.of(pageContext).showSnackBar(
                  SnackBar(
                    content: const Text('Lütfen yemek adı girin'),
                    backgroundColor: Colors.red,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                );
                return;
              }

              // Kalori kontrolü
              if (caloriesText.isEmpty) {
                ScaffoldMessenger.of(pageContext).showSnackBar(
                  SnackBar(
                    content: const Text('Lütfen kalori değeri girin'),
                    backgroundColor: Colors.red,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                );
                return;
              }

              final calories = double.tryParse(caloriesText);
              if (calories == null || calories < 1) {
                ScaffoldMessenger.of(pageContext).showSnackBar(
                  SnackBar(
                    content: const Text('Lütfen geçerli bir kalori değeri girin (0\'dan büyük)'),
                    backgroundColor: Colors.red,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                );
                return;
              }

              final protein = double.tryParse(proteinController.text.trim());
              final carbs = double.tryParse(carbsController.text.trim());
              final fat = double.tryParse(fatController.text.trim());

              if (kDebugMode) {
                debugPrint('[Nutrition] Add button pressed: mealType=$selectedMealType foodName=$foodName calories=$calories');
              }

              Navigator.pop(dialogContext);

              try {
                pageContext.read<NutritionBloc>().add(
                      AddNutritionLog(
                        mealType: selectedMealType,
                        foodName: foodName,
                        calories: calories,
                        protein: protein,
                        carbs: carbs,
                        fat: fat,
                      ),
                    );
              } catch (e) {
                if (kDebugMode) {
                  debugPrint('[Nutrition] Failed to dispatch AddNutritionLog: $e');
                }
                ScaffoldMessenger.of(pageContext).showSnackBar(
                  SnackBar(
                    content: Text('Yemek ekleme başlatılamadı: $e'),
                    backgroundColor: Colors.red,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Ekle'),
          ),
        ],
      ),
    ),
  );
}

Widget _buildMealTypeChip(
  BuildContext context,
  String value,
  String label,
  IconData icon,
  String selectedValue,
  Function(String) onSelect,
) {
  final isSelected = selectedValue == value;
  final primaryColor = Theme.of(context).primaryColor;

  return Expanded(
    child: InkWell(
      onTap: () => onSelect(value),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? primaryColor.withOpacity(0.1) : Colors.grey[50],
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? primaryColor : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected ? primaryColor : Colors.grey[600],
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected ? primaryColor : Colors.grey[700],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    ),
  );
}

  void _showDeleteConfirmation(BuildContext context, String id) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          'Kaydı Sil',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'Bu beslenme kaydını silmek istediğinize emin misiniz?',
          style: TextStyle(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<NutritionBloc>().add(DeleteNutritionLog(id));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Sil'),
          ),
        ],
      ),
    );
  }
}
