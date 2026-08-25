import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/shared_widgets.dart';

class PhotoToCartoonScreen extends StatefulWidget {
  const PhotoToCartoonScreen({super.key});

  @override
  State<PhotoToCartoonScreen> createState() => _PhotoToCartoonScreenState();
}

class _PhotoToCartoonScreenState extends State<PhotoToCartoonScreen> {
  bool consentGiven = false;
  bool photoPicked = false;
  bool generating = false;
  bool generated = false;
  String style = 'Classic Cartoon';
  String? uploadedImageUrl;
  String? error;

  // TODO(platform): the mock bytes below stand in for a real picked photo.
  // Wire up `image_picker` here, e.g.:
  //   final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
  //   final bytes = await picked!.readAsBytes();
  List<int>? _pickedPhotoBytes;
  String _pickedPhotoName = 'photo.jpg';

  final styles = const ['Classic Cartoon', 'Anime', '3D Toon', 'Sketch'];

  Future<void> _generate() async {
    final state = context.read<AppState>();
    setState(() { generating = true; error = null; });
    try {
      // 1) Upload the consented photo to the backend, which returns a
      //    public URL D-ID can render from.
      final imageUrl = await state.ai.uploadPhoto(
        _pickedPhotoBytes ?? [],
        _pickedPhotoName,
      );
      uploadedImageUrl = imageUrl;
      if (!mounted) return;
      setState(() {
        generating = false;
        generated = true;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        generating = false;
        error = 'Could not generate your cartoon character right now: $e';
      });
    }
  }

  void _pickPhoto() {
    // TODO(platform): replace with a real image_picker call; for now this
    // marks a photo as "picked" so the flow can be exercised end-to-end
    // once you wire in real bytes above.
    setState(() {
      photoPicked = true;
      _pickedPhotoBytes = [];
    });
  }

  void _saveCharacter() {
    final character = ToonCharacter(
      name: 'My Photo Character',
      characterType: 'Other Fictional',
      generatedPortraitUrl: uploadedImageUrl,
    );
    context.read<AppState>().addCharacter(character);
    Navigator.of(context).pop(character);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Photo to Cartoon')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.warning.withOpacity(0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.info_outline_rounded, color: Color(0xFF8A6D00)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Upload only your own photo, or a photo you have clear permission to use. '
                    'Do not upload photos of other people without their consent, and never upload '
                    'a photo of a minor other than your own child with parental consent.',
                    style: TextStyle(fontSize: 12.5, color: Color(0xFF8A6D00), height: 1.4),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          CheckboxListTile(
            value: consentGiven,
            onChanged: (v) => setState(() => consentGiven = v ?? false),
            controlAffinity: ListTileControlAffinity.leading,
            contentPadding: EdgeInsets.zero,
            title: const Text(
              'I confirm I have the right to use this photo.',
              style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600),
            ),
          ),
          const SectionLabel('Photo'),
          GestureDetector(
            onTap: consentGiven ? _pickPhoto : null,
            child: Container(
              height: 180,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.light,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                    color: consentGiven ? AppColors.brand.withOpacity(0.4) : Colors.black12),
              ),
              child: photoPicked
                  ? const Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.image_rounded, size: 44, color: AppColors.brand),
                        SizedBox(height: 8),
                        Text('photo_selected.jpg', style: TextStyle(fontWeight: FontWeight.w600)),
                      ],
                    )
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.add_a_photo_outlined,
                            size: 40, color: consentGiven ? AppColors.brand : Colors.black26),
                        const SizedBox(height: 8),
                        Text(
                          consentGiven ? 'Tap to upload from camera or gallery' : 'Accept the notice above first',
                          style: TextStyle(
                              color: consentGiven ? Colors.black54 : Colors.black26, fontSize: 12.5),
                        ),
                      ],
                    ),
            ),
          ),
          const SectionLabel('Cartoon Style'),
          OptionChips(options: styles, selected: style, onSelected: (v) => setState(() => style = v)),
          const Padding(
            padding: EdgeInsets.only(top: 6),
            child: Text(
              'Note: this build animates your real photo directly (talking + lip-sync via D-ID). '
              'Full cartoon-style stylization is a separate pipeline — see backend README §7.',
              style: TextStyle(fontSize: 11, color: Colors.black38),
            ),
          ),
          const SizedBox(height: 24),
          if (!generated)
            PrimaryCTA(
              label: generating ? 'Generating cartoon...' : 'Generate Cartoon Character',
              icon: Icons.auto_awesome_rounded,
              onPressed: (photoPicked && !generating) ? _generate : () {},
            ),
          if (generating) ...[
            const SizedBox(height: 16),
            const Center(child: CircularProgressIndicator(color: AppColors.brand)),
          ],
          if (error != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.red.withOpacity(0.08), borderRadius: BorderRadius.circular(12)),
              child: Text(error!, style: const TextStyle(color: Colors.red, fontSize: 12)),
            ),
          ],
          if (generated) ...[
            const SizedBox(height: 8),
            Center(
              child: Column(
                children: [
                  const CharacterAvatar(label: 'My Photo Character', size: 110),
                  const SizedBox(height: 10),
                  const Text('Your cartoon character is ready!',
                      style: TextStyle(fontWeight: FontWeight.w700)),
                ],
              ),
            ),
            const SizedBox(height: 20),
            PrimaryCTA(
              label: 'Save & Continue to Customize',
              icon: Icons.check_circle_outline_rounded,
              onPressed: _saveCharacter,
            ),
          ],
        ],
      ),
    );
  }
}
