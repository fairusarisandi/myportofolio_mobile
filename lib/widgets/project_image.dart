import 'package:material_ui/material_ui.dart';

class ProjectImage extends StatelessWidget {
  const ProjectImage({super.key, required this.url, required this.fit});

  final String url;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    return Image.network(
      url,
      fit: fit,
      errorBuilder: (context, error, stackTrace) => ColoredBox(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        child: const Center(
          child: Icon(
            Icons.broken_image_outlined,
            semanticLabel: 'Gambar proyek gagal dimuat',
          ),
        ),
      ),
    );
  }
}
