import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/church_banner.dart';
import '../bloc/banners_cubit.dart';

/// RF-008c: criação de publicação (post) por Mídia/Pastor.
///
/// TODO(backend): enviar para POST /api/banners/ com upload de mídia.
class CreatePostPage extends StatefulWidget {
  const CreatePostPage({super.key});

  @override
  State<CreatePostPage> createState() => _CreatePostPageState();
}

class _CreatePostPageState extends State<CreatePostPage> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  BannerKind _kind = BannerKind.event;
  BannerMediaType _mediaType = BannerMediaType.photo;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nova publicação')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Título'),
              autofocus: true,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Descrição'),
              maxLines: 4,
            ),
            const SizedBox(height: 16),
            Text('Tipo', style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 8),
            SegmentedButton<BannerKind>(
              segments: const [
                ButtonSegment(value: BannerKind.event, label: Text('Evento'), icon: Icon(Icons.event)),
                ButtonSegment(value: BannerKind.service, label: Text('Culto'), icon: Icon(Icons.church)),
                ButtonSegment(value: BannerKind.word, label: Text('Palavra'), icon: Icon(Icons.menu_book)),
              ],
              selected: {_kind},
              onSelectionChanged: (selection) => setState(() => _kind = selection.first),
            ),
            const SizedBox(height: 16),
            Text('Mídia', style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 8),
            SegmentedButton<BannerMediaType>(
              segments: const [
                ButtonSegment(value: BannerMediaType.photo, label: Text('Foto'), icon: Icon(Icons.image)),
                ButtonSegment(value: BannerMediaType.video, label: Text('Vídeo'), icon: Icon(Icons.videocam)),
              ],
              selected: {_mediaType},
              onSelectionChanged: (selection) => setState(() => _mediaType = selection.first),
            ),
            const SizedBox(height: 8),
            // TODO(backend): selecionar arquivo de mídia (image_picker) e enviar no upload.
            Text(
              'A seleção de arquivo de mídia será habilitada quando o upload estiver disponível.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => _publish(context),
                child: const Text('Publicar'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _publish(BuildContext context) {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Informe um título para a publicação.')),
      );
      return;
    }

    context.read<BannersCubit>().createPost(
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          kind: _kind,
          mediaType: _mediaType,
        );
    Navigator.of(context).pop();
  }
}
