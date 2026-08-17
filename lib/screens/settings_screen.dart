import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import '../providers/settings_controller.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late TextEditingController _nameCtrl;
  late TextEditingController _phoneCtrl;

  @override
  void initState() {
    super.initState();
    final s = context.read<SettingsController>();
    _nameCtrl = TextEditingController(text: s.profileName);
    _phoneCtrl = TextEditingController(text: s.profilePhone);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsController>(
      builder: (context, settings, _) {
        return Scaffold(
          appBar: AppBar(title: const Text('Settings')),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Profile',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _nameCtrl,
                    decoration: const InputDecoration(labelText: 'Name'),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _phoneCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Phone number',
                    ),
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () {
                      settings.setProfile(
                        _nameCtrl.text.trim(),
                        _phoneCtrl.text.trim(),
                      );
                    },
                    child: const Text('Save profile'),
                  ),

                  const SizedBox(height: 24),
                  Text(
                    'Theme',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  RadioListTile<ThemeMode>(
                    value: ThemeMode.system,
                    groupValue: settings.themeMode,
                    title: const Text('System'),
                    onChanged: (m) {
                      if (m != null) settings.setThemeMode(m);
                    },
                  ),
                  RadioListTile<ThemeMode>(
                    value: ThemeMode.light,
                    groupValue: settings.themeMode,
                    title: const Text('Light'),
                    onChanged: (m) {
                      if (m != null) settings.setThemeMode(m);
                    },
                  ),
                  RadioListTile<ThemeMode>(
                    value: ThemeMode.dark,
                    groupValue: settings.themeMode,
                    title: const Text('Dark'),
                    onChanged: (m) {
                      if (m != null) settings.setThemeMode(m);
                    },
                  ),

                  const SizedBox(height: 24),
                  Text(
                    'Background',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: List.generate(3, (i) {
                      final selected = settings.backgroundVariant == i;
                      return ChoiceChip(
                        label: Text('Theme ${i + 1}'),
                        selected: selected,
                        onSelected: (sel) {
                          if (sel) settings.setBackgroundVariant(i);
                        },
                      );
                    }),
                  ),

                  const SizedBox(height: 24),
                  SwitchListTile(
                    value: settings.splash3D,
                    onChanged: (v) {
                      settings.setSplash3D(v);
                    },
                    title: const Text('3D Splash animation'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
