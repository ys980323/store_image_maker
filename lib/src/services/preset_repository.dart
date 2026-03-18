import 'package:shared_preferences/shared_preferences.dart';

import '../models/store_image_models.dart';

class PresetRepository {
  static const _key = 'presets';

  Future<List<Preset>> loadAll() async {
    final prefs = await SharedPreferences.getInstance();
    final entries = prefs.getStringList(_key) ?? [];
    return entries.map(Preset.decode).toList();
  }

  Future<void> saveAll(List<Preset> presets) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _key,
      presets.map((p) => p.encode()).toList(),
    );
  }

  Future<void> add(Preset preset) async {
    final presets = await loadAll();
    presets.add(preset);
    await saveAll(presets);
  }

  Future<void> deleteAt(int index) async {
    final presets = await loadAll();
    if (index >= 0 && index < presets.length) {
      presets.removeAt(index);
      await saveAll(presets);
    }
  }
}
