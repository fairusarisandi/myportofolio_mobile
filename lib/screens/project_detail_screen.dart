import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/models/project.dart';
import 'package:myportofolio_mobile/widgets/project_image.dart';

class ProjectDetailScreen extends StatelessWidget {
  const ProjectDetailScreen({super.key, required this.project});

  final Project project;

  @override
  Widget build(BuildContext context) {
    final imageUrl = project.projectImageUrl.trim();
    return Scaffold(
      appBar: AppBar(title: Text(project.title)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (imageUrl.isNotEmpty) ...[
            AspectRatio(
              aspectRatio: 16 / 9,
              child: ProjectImage(url: imageUrl, fit: BoxFit.contain),
            ),
            const SizedBox(height: 16),
          ],
          Text(project.description),
          if (project.techStack.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(project.techStack),
          ],
          if (project.projectUrl.isNotEmpty) ...[
            const SizedBox(height: 16),
            SelectableText(project.projectUrl),
          ],
        ],
      ),
    );
  }
}
