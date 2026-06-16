import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
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
}

class _CommentsSheet extends StatelessWidget {
  const _CommentsSheet({required this.banner});

  final ChurchBanner banner;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Comentários', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            // TODO(backend): listar/criar comentários via API.
            Text(
              banner.commentCount == 0
                  ? 'Seja o primeiro a comentar.'
                  : '${banner.commentCount} comentário(s) — em breve.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            TextField(
              enabled: false,
              decoration: InputDecoration(
                hintText: 'Escreva um comentário...',
                suffixIcon: const Icon(Icons.send),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
