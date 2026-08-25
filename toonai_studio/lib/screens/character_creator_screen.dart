import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/catalog.dart';
import '../models/models.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/shared_widgets.dart';

class CharacterCreatorScreen extends StatefulWidget {
  final ToonCharacter? editing;
  const CharacterCreatorScreen({super.key, this.editing});

  @override
  State<CharacterCreatorScreen> createState() => _CharacterCreatorScreenState();
}

class _CharacterCreatorScreenState extends State<CharacterCreatorScreen> {
  late TextEditingController _nameCtrl;
  late String type, hair, outfit, face, skin, body;
  late List<String> accessories;

  @override
  void initState() {
    super.initState();
    final e = widget.editing;
    _nameCtrl = TextEditingController(text: e?.name ?? '');
    type = e?.characterType ?? Catalog.characterTypes.first;
    hair = e?.hairstyle ?? Catalog.hairstyles.first;
    outfit = e?.outfit ?? Catalog.outfits.first;
    face = e?.faceShape ?? Catalog.faceShapes.first;
    skin = e?.skinTone ?? Catalog.skinTones.first;
    body = e?.bodyType ?? Catalog.bodyTypes.first;
    accessories = List.from(e?.accessories ?? []);
  }

  void _save() {
    final name = _nameCtrl.text.trim().isEmpty ? type : _nameCtrl.text.trim();
    final character = ToonCharacter(
      id: widget.editing?.id,
      name: name,
      characterType: type,
      hairstyle: hair,
      outfit: outfit,
      faceShape: face,
      skinTone: skin,
      bodyType: body,
      accessories: accessories,
    );
    if (widget.editing == null) {
      context.read<AppState>().addCharacter(character);
    } else {
      // Replace in place.
      final lib = context.read<AppState>().characterLibrary;
      final idx = lib.indexWhere((c) => c.id == widget.editing!.id);
      if (idx != -1) lib[idx] = character;
    }
    Navigator.of(context).pop(character);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Character')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
        children: [
          Center(
            child: Column(
              children: [
                CharacterAvatar(label: _nameCtrl.text.isEmpty ? type : _nameCtrl.text, size: 96),
                const SizedBox(height: 8),
                const Text('Preview updates as you customize',
                    style: TextStyle(fontSize: 12, color: Colors.black45)),
              ],
            ),
          ),
          const SectionLabel('Character Name'),
          TextField(
            controller: _nameCtrl,
            decoration: const InputDecoration(hintText: 'e.g. Papa, Kavya, Hero...'),
            onChanged: (_) => setState(() {}),
          ),
          const SectionLabel('Character Type'),
          OptionChips(options: Catalog.characterTypes, selected: type,
              onSelected: (v) => setState(() => type = v)),
          const SectionLabel('Hairstyle'),
          OptionChips(options: Catalog.hairstyles, selected: hair,
              onSelected: (v) => setState(() => hair = v)),
          const SectionLabel('Clothes / Outfit'),
          OptionChips(options: Catalog.outfits, selected: outfit,
              onSelected: (v) => setState(() => outfit = v)),
          const SectionLabel('Face Shape'),
          OptionChips(options: Catalog.faceShapes, selected: face,
              onSelected: (v) => setState(() => face = v)),
          const SectionLabel('Skin Tone'),
          OptionChips(options: Catalog.skinTones, selected: skin,
              onSelected: (v) => setState(() => skin = v)),
          const SectionLabel('Body Type'),
          OptionChips(options: Catalog.bodyTypes, selected: body,
              onSelected: (v) => setState(() => body = v)),
          const SectionLabel('Accessories (optional, multi-select)'),
          Wrap(
            spacing: 8, runSpacing: 8,
            children: Catalog.accessories.map((a) {
              final selected = accessories.contains(a);
              return FilterChip(
                label: Text(a),
                selected: selected,
                onSelected: (v) => setState(
                    () => v ? accessories.add(a) : accessories.remove(a)),
                selectedColor: AppColors.brand2,
                labelStyle: TextStyle(
                    color: selected ? Colors.white : Colors.black87,
                    fontWeight: FontWeight.w600),
              );
            }).toList(),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: PrimaryCTA(
            label: 'Save Character', icon: Icons.check_circle_outline_rounded, onPressed: _save,
          ),
        ),
      ),
    );
  }
}
