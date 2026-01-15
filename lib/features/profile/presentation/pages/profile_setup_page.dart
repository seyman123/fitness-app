import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection_container.dart';
import '../../../auth/domain/entities/user.dart';
import '../../../tracking/presentation/pages/dashboard_page.dart';
import '../bloc/profile_bloc.dart';
import '../bloc/profile_event.dart';
import '../bloc/profile_state.dart';

class ProfileSetupPage extends StatefulWidget {
  final User? user;
  
  const ProfileSetupPage({super.key, this.user});

  @override
  State<ProfileSetupPage> createState() => _ProfileSetupPageState();
}

class _ProfileSetupPageState extends State<ProfileSetupPage> {
  final _formKey = GlobalKey<FormState>();

  final _ageController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();

  String _gender = 'male';

  @override
  void dispose() {
    _ageController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  void _onContinue() {
    if (!_formKey.currentState!.validate()) return;

    final age = int.parse(_ageController.text);
    final height = double.parse(_heightController.text);
    final weight = double.parse(_weightController.text);

    // Profil bilgilerini kaydet
    context.read<ProfileBloc>().add(CreateProfile(
      age: age,
      gender: _gender,
      height: height,
      weight: weight,
      activityLevel: 1.375, // Varsayılan aktivite seviyesi
      goalWeight: null,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<ProfileBloc>(),
      child: BlocListener<ProfileBloc, ProfileState>(
        listener: (context, state) {
          if (state is ProfileLoaded) {
            // Profil başarıyla oluşturuldu, dashboard'a geç
            final user = widget.user ?? User(
              id: 'guest-${DateTime.now().millisecondsSinceEpoch}',
              email: 'guest@fitness.app',
              name: 'Misafir Kullanıcı',
              createdAt: DateTime.now(),
            );
            
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (_) => DashboardPage(user: user),
              ),
            );
          } else if (state is ProfileError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Profil Bilgileri'),
          ),
          body: BlocBuilder<ProfileBloc, ProfileState>(
            builder: (context, state) {
              final isLoading = state is ProfileLoading;
              
              return Padding(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Başlamak için temel bilgilerini gir',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          value: _gender,
                          items: const [
                            DropdownMenuItem(value: 'male', child: Text('Erkek')),
                            DropdownMenuItem(value: 'female', child: Text('Kadın')),
                          ],
                          decoration: const InputDecoration(labelText: 'Cinsiyet'),
                          onChanged: (value) {
                            if (value == null) return;
                            setState(() => _gender = value);
                          },
                        ),
                        TextFormField(
                          controller: _ageController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: 'Yaş'),
                          validator: (value) {
                            if (value == null || value.isEmpty) return 'Zorunlu alan';
                            final age = int.tryParse(value);
                            if (age == null || age <= 0) return 'Geçerli bir yaş gir';
                            return null;
                          },
                        ),
                        TextFormField(
                          controller: _heightController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: 'Boy (cm)'),
                          validator: (value) {
                            if (value == null || value.isEmpty) return 'Zorunlu alan';
                            final h = double.tryParse(value);
                            if (h == null || h <= 0) return 'Geçerli bir boy gir';
                            return null;
                          },
                        ),
                        TextFormField(
                          controller: _weightController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: 'Kilo (kg)'),
                          validator: (value) {
                            if (value == null || value.isEmpty) return 'Zorunlu alan';
                            final w = double.tryParse(value);
                            if (w == null || w <= 0) return 'Geçerli bir kilo gir';
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton(
                            onPressed: isLoading ? null : _onContinue,
                            child: isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    ),
                                  )
                                : const Text('Devam'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
