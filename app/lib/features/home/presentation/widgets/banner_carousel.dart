import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/di/injector.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../data/banners_api_service.dart';
import '../../domain/entities/banner_comment.dart';
import '../../domain/entities/church_banner.dart';
import '../bloc/banners_cubit.dart';

/// Carrossel de posts (estilo Instagram/Stories) para banners de eventos,
/// cultos e palavras (RF-005), com curtir e comentar.
class BannerCarousel extends StatefulWidget {
  const BannerCarousel({super.key});

  @override
  State<BannerCarousel> createState() => _BannerCarouselState();
}

class _BannerCarouselState extends State<BannerCarousel> {
  final _pageController = PageController(viewportFraction: 0.92);
  int _page = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BannersCubit, List<ChurchBanner>>(
      builder: (context, banners) {
        if (banners.isEmpty) return const SizedBox.shrink();

        return Column(
          children: [
            SizedBox(
              height: 360,
              child: PageView.builder(
                controller: _pageController,
                itemCount: banners.length,
                onPageChanged: (index) => setState(() => _page = index),
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: _BannerPostCard(banner: banners[index]),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            _PageIndicator(count: banners.length, currentPage: _page),
          ],
        );
      },
    );
  }
}

class _PageIndicator extends StatelessWidget {
  const _PageIndicator({required this.count, required this.currentPage});

  final int count;
  final int currentPage;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (index) {
        final isActive = index == currentPage;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: isActive ? 10 : 7,
          height: isActive ? 10 : 7,
          decoration: BoxDecoration(
            color: isActive ? AppColors.navy : AppColors.navy.withValues(alpha: 0.25),
            shape: BoxShape.circle,
          ),
        );
      }),
    );
  }
}

class _BannerPostCard extends StatelessWidget {
  const _BannerPostCard({required this.banner});

  final ChurchBanner banner;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _PostHeader(banner: banner),
          Expanded(child: _PostMedia(banner: banner)),
          _PostActions(banner: banner),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(banner.title, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 4),
                Text(
                  banner.description,
                  style: Theme.of(context).textTheme.bodyMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PostHeader extends StatelessWidget {
  const _PostHeader({required this.banner});

  final ChurchBanner banner;

  @override
  Widget build(BuildContext context) {
    final (icon, label) = switch (banner.kind) {
      BannerKind.event => (Icons.event, 'Evento'),
      BannerKind.service => (Icons.church, 'Culto'),
      BannerKind.word => (Icons.menu_book, 'Palavra'),
    };

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: AppColors.navy,
            child: Icon(icon, size: 16, color: AppColors.white),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: Theme.of(context).textTheme.labelLarge),
                Text(
                  DateFormat("d 'de' MMMM, HH:mm", 'pt_BR').format(banner.startsAt),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PostMedia extends StatelessWidget {
  const _PostMedia({required this.banner});

  final ChurchBanner banner;

  @override
  Widget build(BuildContext context) {
    // TODO(backend): renderizar banner.mediaUrl com cached_network_image
    // (foto) ou um player de vídeo quando mediaType == video.
    return Container(
      width: double.infinity,
      color: AppColors.navyLight.withValues(alpha: 0.15),
      child: Center(
        child: banner.mediaType == BannerMediaType.video
            ? const Icon(Icons.play_circle_fill, size: 56, color: AppColors.navy)
            : const Icon(Icons.image, size: 56, color: AppColors.navy),
      ),
    );
  }
}

class _PostActions extends StatelessWidget {
  const _PostActions({required this.banner});

  final ChurchBanner banner;

  @override
  Widget build(BuildContext context) {
    final canEdit = context.watch<AuthBloc>().state.role.canPublishContent;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          IconButton(
            icon: Icon(
              banner.likedByMe ? Icons.favorite : Icons.favorite_border,
              color: banner.likedByMe ? AppColors.error : AppColors.textPrimary,
            ),
            onPressed: () => context.read<BannersCubit>().toggleLike(banner.id),
          ),
          Text('${banner.likeCount}'),
          const SizedBox(width: 16),
          IconButton(
            icon: const Icon(Icons.mode_comment_outlined),
            onPressed: () => _showComments(context, banner),
          ),
          Text('${banner.commentCount}'),
          if (canEdit) ...[
            const Spacer(),
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert),
              onSelected: (value) {
                if (value == 'edit') _showEditDialog(context, banner);
                if (value == 'delete') _confirmDelete(context, banner);
              },
              itemBuilder: (_) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(children: [
                    Icon(Icons.edit_outlined),
                    SizedBox(width: 8),
                    Text('Editar'),
                  ]),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(children: [
                    Icon(Icons.delete_outline, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Excluir', style: TextStyle(color: Colors.red)),
                  ]),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  void _showComments(BuildContext context, ChurchBanner banner) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => _CommentsSheet(banner: banner),
    );
  }

  void _showEditDialog(BuildContext context, ChurchBanner banner) {
    final cubit = context.read<BannersCubit>();
    final messenger = ScaffoldMessenger.of(context);
    final titleCtrl = TextEditingController(text: banner.title);
    final descCtrl = TextEditingController(text: banner.description);

    showDialog<void>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Editar publicação'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleCtrl,
              decoration: const InputDecoration(labelText: 'Título'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: descCtrl,
              decoration: const InputDecoration(labelText: 'Descrição'),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.of(dialogCtx).pop();
              final ok = await cubit.updatePost(
                id: banner.id,
                title: titleCtrl.text.trim(),
                description: descCtrl.text.trim(),
              );
              messenger.showSnackBar(SnackBar(
                content: Text(ok ? 'Publicação atualizada.' : 'Erro ao atualizar.'),
                backgroundColor: ok ? Colors.green.shade700 : Colors.red.shade700,
              ));
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, ChurchBanner banner) {
    final cubit = context.read<BannersCubit>();
    final messenger = ScaffoldMessenger.of(context);

    showDialog<void>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Excluir publicação'),
        content: Text('Deseja excluir "${banner.title}"? Esta ação não pode ser desfeita.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red.shade700),
            onPressed: () async {
              Navigator.of(dialogCtx).pop();
              final ok = await cubit.deletePost(banner.id);
              messenger.showSnackBar(SnackBar(
                content: Text(ok ? 'Publicação excluída.' : 'Erro ao excluir.'),
                backgroundColor: ok ? Colors.green.shade700 : Colors.red.shade700,
              ));
            },
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }
}

class _CommentsSheet extends StatefulWidget {
  const _CommentsSheet({required this.banner});

  final ChurchBanner banner;

  @override
  State<_CommentsSheet> createState() => _CommentsSheetState();
}

class _CommentsSheetState extends State<_CommentsSheet> {
  final _controller = TextEditingController();
  final _api = injector<BannersApiService>();

  List<BannerComment>? _comments;
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    _loadComments();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadComments() async {
    try {
      final comments = await _api.fetchComments(widget.banner.id);
      if (mounted) setState(() => _comments = comments);
    } catch (_) {
      if (mounted) setState(() => _comments = []);
    }
  }

  Future<void> _submit() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _sending) return;
    setState(() => _sending = true);
    try {
      final comment = await _api.postComment(widget.banner.id, text);
      if (mounted) {
        setState(() {
          _comments = [comment, ...?_comments];
          _sending = false;
        });
        _controller.clear();
        if (mounted) {
          context.read<BannersCubit>().incrementCommentCount(widget.banner.id);
        }
      }
    } catch (_) {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Comentários', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            if (_comments == null)
              const Center(child: CircularProgressIndicator())
            else if (_comments!.isEmpty)
              Text('Seja o primeiro a comentar.', style: Theme.of(context).textTheme.bodyMedium)
            else
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 300),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _comments!.length,
                  itemBuilder: (context, index) {
                    final comment = _comments![index];
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: CircleAvatar(
                        backgroundColor: AppColors.navy,
                        child: Text(
                          comment.authorName.isNotEmpty ? comment.authorName[0].toUpperCase() : '?',
                          style: const TextStyle(color: AppColors.white),
                        ),
                      ),
                      title: Text(comment.authorName),
                      subtitle: Text(comment.text),
                    );
                  },
                ),
              ),
            const SizedBox(height: 16),
            TextField(
              controller: _controller,
              enabled: !_sending,
              decoration: InputDecoration(
                hintText: 'Escreva um comentário...',
                suffixIcon: IconButton(
                  icon: _sending
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.send),
                  onPressed: _sending ? null : _submit,
                ),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onSubmitted: (_) => _submit(),
            ),
          ],
        ),
      ),
    );
  }
}
