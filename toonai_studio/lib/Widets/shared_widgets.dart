import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// A chip-style selector used across Character Creator, Scene Editor, etc.
class OptionChips extends StatelessWidget {
  final List<String> options;
  final String selected;
  final ValueChanged<String> onSelected;

  const OptionChips({
    super.key,
    required this.options,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: options.map((o) {
        final isSelected = o == selected;
        return ChoiceChip(
          label: Text(o),
          selected: isSelected,
          onSelected: (_) => onSelected(o),
          labelStyle: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: FontWeight.w600,
          ),
          selectedColor: AppColors.brand,
          backgroundColor: AppColors.light,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide.none,
          ),
        );
      }).toList(),
    );
  }
}

/// Section label used inside forms/editors.
class SectionLabel extends StatelessWidget {
  final String text;
  const SectionLabel(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 18, bottom: 8),
      child: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
      ),
    );
  }
}

/// A rounded gradient banner used for tagline / promo areas.
class BrandBanner extends StatelessWidget {
  final String title;
  final String subtitle;
  const BrandBanner({super.key, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.brand, AppColors.brand2],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          Text(subtitle,
              style: const TextStyle(color: Colors.white, fontSize: 13, height: 1.3)),
        ],
      ),
    );
  }
}

/// Simple placeholder "character avatar" built from emoji + color, standing
/// in for the real rendered cartoon character art.
class CharacterAvatar extends StatelessWidget {
  final String label;
  final double size;
  const CharacterAvatar({super.key, required this.label, this.size = 56});

  Color _colorFor(String s) {
    final colors = [
      AppColors.brand, AppColors.brand2, const Color(0xFF2ECC71),
      const Color(0xFF3498DB), const Color(0xFFE67E22),
    ];
    return colors[s.hashCode % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: size / 2,
      backgroundColor: _colorFor(label).withOpacity(0.15),
      child: Text(
        label.isNotEmpty ? label[0].toUpperCase() : '?',
        style: TextStyle(
          color: _colorFor(label),
          fontWeight: FontWeight.w800,
          fontSize: size * 0.4,
        ),
      ),
    );
  }
}

class PrimaryCTA extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final IconData? icon;
  const PrimaryCTA({super.key, required this.label, required this.onPressed, this.icon});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: icon != null ? Icon(icon) : const SizedBox.shrink(),
        label: Text(label),
      ),
    );
  }
}
