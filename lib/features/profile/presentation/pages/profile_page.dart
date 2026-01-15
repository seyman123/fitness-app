import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/profile.dart';
import '../../../auth/domain/entities/user.dart';
import '../bloc/profile_bloc.dart';
import '../bloc/profile_event.dart';
import '../bloc/profile_state.dart';

/// Profile page - View or edit user profile
class ProfilePage extends StatefulWidget {
  final User? user;

  const ProfilePage({super.key, this.user});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _isEditing = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profilim'),
        actions: !_isEditing
            ? [
                IconButton(
                  icon: const Icon(Icons.edit),
                  tooltip: 'Profili Düzenle',
                  onPressed: () => setState(() => _isEditing = true),
                ),
              ]
            : null,
      ),
      body: BlocConsumer<ProfileBloc, ProfileState>(
        listener: (context, state) {
          if (state is ProfileOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
              ),
            );
            // Profili yeniden yükle ve düzenleme modundan çık
            context.read<ProfileBloc>().add(const LoadProfile());
            setState(() => _isEditing = false);
          }

          if (state is ProfileError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is ProfileLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ProfileLoaded && !_isEditing) {
            // Profil varsa ve düzenleme modunda değilsek göster
            return _buildProfileView(state.profile);
          }

          // Profil yoksa veya düzenleme modundaysak form göster
          final profile = state is ProfileLoaded ? state.profile : null;
          return _ProfileForm(
            existingProfile: profile,
            onCancel: profile != null
                ? () => setState(() => _isEditing = false)
                : null,
          );
        },
      ),
    );
  }

  Widget _buildProfileView(Profile profile) {
    final userName = widget.user?.name ?? widget.user?.email ?? 'Kullanıcı';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Profil Header - Kompakt
          Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: Theme.of(context).primaryColor,
                child: Icon(
                  profile.gender == 'male' ? Icons.male : Icons.female,
                  size: 30,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userName,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${profile.age} Yaş • ${profile.gender == 'male' ? 'Erkek' : 'Kadın'}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Fiziksel Bilgiler - Grid Layout
          Row(
            children: [
              Icon(Icons.monitor_heart_outlined, size: 20, color: Colors.grey[700]),
              const SizedBox(width: 8),
              Text(
                'Fiziksel Bilgiler',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildCompactCard(
                  icon: Icons.height,
                  label: 'Boy',
                  value: '${profile.height.toStringAsFixed(0)}',
                  unit: 'cm',
                  color: Colors.blue,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildCompactCard(
                  icon: Icons.monitor_weight,
                  label: 'Kilo',
                  value: '${profile.weight.toStringAsFixed(1)}',
                  unit: 'kg',
                  color: Colors.green,
                ),
              ),
              if (profile.goalWeight != null) ...[
                const SizedBox(width: 10),
                Expanded(
                  child: _buildCompactCard(
                    icon: Icons.flag,
                    label: 'Hedef',
                    value: '${profile.goalWeight!.toStringAsFixed(1)}',
                    unit: 'kg',
                    color: Colors.orange,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 20),

          // Hesaplanan Değerler
          if (profile.bmi != null) ...[
            Row(
              children: [
                Icon(Icons.favorite_outline, size: 20, color: Colors.grey[700]),
                const SizedBox(width: 8),
                Text(
                  'Sağlık Metrikleri',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildInfoCard(
              icon: Icons.analytics,
              label: 'BMI',
              value: profile.bmi!.toStringAsFixed(1),
              subtitle: profile.bmiCategory,
              color: Colors.purple,
            ),
            if (profile.dailyCalories != null) ...[
              const SizedBox(height: 8),
              _buildInfoCard(
                icon: Icons.local_fire_department,
                label: 'Günlük Kalori',
                value: '${profile.dailyCalories} kcal',
                color: Colors.deepOrange,
              ),
            ],
            const SizedBox(height: 24),
          ],

          // Aktivite Seviyesi
          Row(
            children: [
              Icon(Icons.directions_run, size: 20, color: Colors.grey[700]),
              const SizedBox(width: 8),
              Text(
                'Aktivite Seviyesi',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.teal.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.teal.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.teal.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.directions_run, color: Colors.teal, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Aktivite',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        profile.activityLevelDescription,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Düzenle Butonu
          ElevatedButton.icon(
            onPressed: () => setState(() => _isEditing = true),
            icon: const Icon(Icons.edit, size: 20),
            label: const Text('Profili Düzenle'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactCard({
    required IconData icon,
    required String label,
    required String value,
    required String unit,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
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
          Text(
            unit,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String label,
    required String value,
    String? subtitle,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                if (subtitle != null)
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[600],
                    ),
                  ),
              ],
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

// Profil Form Widget (Ayrı widget olarak)
class _ProfileForm extends StatefulWidget {
  final Profile? existingProfile;
  final VoidCallback? onCancel;

  const _ProfileForm({
    this.existingProfile,
    this.onCancel,
  });

  @override
  State<_ProfileForm> createState() => _ProfileFormState();
}

class _ProfileFormState extends State<_ProfileForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _ageController;
  late final TextEditingController _heightController;
  late final TextEditingController _weightController;
  late final TextEditingController _goalWeightController;

  String _gender = 'male';
  double _activityLevel = 1.375;
  String _goalType = 'MAINTAIN';

  @override
  void initState() {
    super.initState();
    _ageController = TextEditingController(
      text: widget.existingProfile?.age.toString() ?? '',
    );
    _heightController = TextEditingController(
      text: widget.existingProfile?.height.toString() ?? '',
    );
    _weightController = TextEditingController(
      text: widget.existingProfile?.weight.toString() ?? '',
    );
    _goalWeightController = TextEditingController(
      text: widget.existingProfile?.goalWeight?.toString() ?? '',
    );

    if (widget.existingProfile != null) {
      _gender = widget.existingProfile!.gender;
      _activityLevel = widget.existingProfile!.activityLevel;
      _goalType = widget.existingProfile!.goalType ?? 'MAINTAIN';
    }
  }

  @override
  void dispose() {
    _ageController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _goalWeightController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final age = int.parse(_ageController.text);
    final height = double.parse(_heightController.text);
    final weight = double.parse(_weightController.text);
    final goalWeight = _goalWeightController.text.isNotEmpty
        ? double.parse(_goalWeightController.text)
        : null;

    if (widget.existingProfile != null) {
      // Güncelle
      context.read<ProfileBloc>().add(UpdateProfile(
            age: age,
            gender: _gender,
            height: height,
            weight: weight,
            activityLevel: _activityLevel,
            goalWeight: goalWeight,
            goalType: _goalType,
          ));
    } else {
      // Oluştur
      context.read<ProfileBloc>().add(CreateProfile(
            age: age,
            gender: _gender,
            height: height,
            weight: weight,
            activityLevel: _activityLevel,
            goalWeight: goalWeight,
            goalType: _goalType,
          ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Başlık
            Row(
              children: [
                Icon(Icons.edit, size: 20, color: Colors.grey[700]),
                const SizedBox(width: 8),
                Text(
                  widget.existingProfile != null
                      ? 'Profili Düzenle'
                      : 'Profil Oluştur',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Yaş
            TextFormField(
              controller: _ageController,
              keyboardType: TextInputType.number,
              style: const TextStyle(fontSize: 15),
              decoration: InputDecoration(
                labelText: 'Yaş',
                hintText: '25',
                hintStyle: TextStyle(color: Colors.grey[400]),
                prefixIcon: const Icon(Icons.calendar_today, size: 20),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: Theme.of(context).primaryColor,
                    width: 2,
                  ),
                ),
                filled: true,
                fillColor: Colors.grey[50],
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) return 'Zorunlu';
                final age = int.tryParse(value);
                if (age == null || age < 10 || age > 120) {
                  return 'Geçersiz yaş';
                }
                return null;
              },
            ),
            const SizedBox(height: 14),

            // Cinsiyet - Modern Card Style
            Row(
              children: [
                Expanded(
                  child: _buildGenderCard('male', 'Erkek', Icons.male),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildGenderCard('female', 'Kadın', Icons.female),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Boy
            TextFormField(
              controller: _heightController,
              keyboardType: TextInputType.number,
              style: const TextStyle(fontSize: 15),
              decoration: InputDecoration(
                labelText: 'Boy',
                hintText: '175 cm',
                hintStyle: TextStyle(color: Colors.grey[400]),
                prefixIcon: const Icon(Icons.height, size: 20),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: Theme.of(context).primaryColor,
                    width: 2,
                  ),
                ),
                filled: true,
                fillColor: Colors.grey[50],
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) return 'Zorunlu';
                final height = double.tryParse(value);
                if (height == null || height < 100 || height > 250) {
                  return 'Geçersiz boy';
                }
                return null;
              },
            ),
            const SizedBox(height: 14),

            // Kilo
            TextFormField(
              controller: _weightController,
              keyboardType: TextInputType.number,
              style: const TextStyle(fontSize: 15),
              decoration: InputDecoration(
                labelText: 'Kilo',
                hintText: '75 kg',
                hintStyle: TextStyle(color: Colors.grey[400]),
                prefixIcon: const Icon(Icons.monitor_weight, size: 20),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: Theme.of(context).primaryColor,
                    width: 2,
                  ),
                ),
                filled: true,
                fillColor: Colors.grey[50],
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) return 'Zorunlu';
                final weight = double.tryParse(value);
                if (weight == null || weight < 30 || weight > 300) {
                  return 'Geçersiz kilo';
                }
                return null;
              },
            ),
            const SizedBox(height: 14),

            // Hedef Kilo
            TextFormField(
              controller: _goalWeightController,
              keyboardType: TextInputType.number,
              style: const TextStyle(fontSize: 15),
              decoration: InputDecoration(
                labelText: 'Hedef Kilo (Opsiyonel)',
                hintText: '70 kg',
                hintStyle: TextStyle(color: Colors.grey[400]),
                prefixIcon: const Icon(Icons.flag, size: 20),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: Theme.of(context).primaryColor,
                    width: 2,
                  ),
                ),
                filled: true,
                fillColor: Colors.grey[50],
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Hedef Türü - Section Header
            Row(
              children: [
                Icon(Icons.flag_outlined, size: 20, color: Colors.grey[700]),
                const SizedBox(width: 8),
                Text(
                  'Fitness Hedefi',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Hedef Türleri - Modern Cards
            ...[
              ('LOSE_WEIGHT', 'Kilo Ver', 'Sağlıklı kilo kaybı', Icons.trending_down),
              ('GAIN_WEIGHT', 'Kilo Al', 'Kilo almak istiyorum', Icons.trending_up),
              ('BUILD_MUSCLE', 'Kas Yap', 'Kas kütlesi artır', Icons.fitness_center),
              ('MAINTAIN', 'Koru', 'Mevcut kilonu koru', Icons.balance),
              ('GET_FIT', 'Formda Kal', 'Genel fitness ve sağlık', Icons.local_fire_department),
            ].map((e) => _buildGoalTypeCard(e.$1, e.$2, e.$3, e.$4)),
            const SizedBox(height: 20),

            // Aktivite Seviyesi - Section Header
            Row(
              children: [
                Icon(Icons.directions_run, size: 20, color: Colors.grey[700]),
                const SizedBox(width: 8),
                Text(
                  'Aktivite Seviyesi',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Aktivite Seviyeleri - Modern Cards
            ...[
              (1.2, 'Hareketsiz', 'Masabaşı iş, az hareket'),
              (1.375, 'Az Aktif', 'Haftada 1-3 gün egzersiz'),
              (1.55, 'Orta', 'Haftada 3-5 gün egzersiz'),
              (1.725, 'Çok Aktif', 'Haftada 6-7 gün egzersiz'),
              (1.9, 'Ekstra Aktif', 'Günde 2x egzersiz/fiziksel iş'),
            ].map((e) => _buildActivityCard(e.$1, e.$2, e.$3)),
            const SizedBox(height: 24),

            // Butonlar
            Row(
              children: [
                if (widget.onCancel != null) ...[
                  Expanded(
                    child: OutlinedButton(
                      onPressed: widget.onCancel,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        side: BorderSide(color: Colors.grey[400]!),
                      ),
                      child: const Text(
                        'İptal',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: ElevatedButton(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      widget.existingProfile != null ? 'Güncelle' : 'Kaydet',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGenderCard(String value, String label, IconData icon) {
    final isSelected = _gender == value;
    final color = isSelected ? Theme.of(context).primaryColor : Colors.grey[400]!;

    return InkWell(
      onTap: () => setState(() => _gender = value),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).primaryColor.withOpacity(0.1)
              : Colors.grey[50],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? Theme.of(context).primaryColor
                : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 32,
              color: color,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: isSelected ? color : Colors.grey[700],
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalTypeCard(String value, String title, String description, IconData icon) {
    final isSelected = _goalType == value;
    final color = isSelected ? Theme.of(context).primaryColor : Colors.grey[400]!;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: () => setState(() => _goalType = value),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isSelected
                ? Theme.of(context).primaryColor.withOpacity(0.1)
                : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected
                  ? Theme.of(context).primaryColor
                  : Colors.grey[300]!,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Theme.of(context).primaryColor.withOpacity(0.2)
                      : Colors.grey[100],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 20,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? color : Colors.grey[800],
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                Icon(
                  Icons.check_circle,
                  color: color,
                  size: 24,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActivityCard(double value, String title, String description) {
    final isSelected = _activityLevel == value;
    final color = isSelected ? Theme.of(context).primaryColor : Colors.grey[400]!;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: () => setState(() => _activityLevel = value),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isSelected
                ? Theme.of(context).primaryColor.withOpacity(0.1)
                : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected
                  ? Theme.of(context).primaryColor
                  : Colors.grey[300]!,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Theme.of(context).primaryColor.withOpacity(0.2)
                      : Colors.grey[100],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  isSelected ? Icons.check_circle : Icons.circle_outlined,
                  color: color,
                  size: 20,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? color : Colors.grey[800],
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      description,
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
        ),
      ),
    );
  }
}
