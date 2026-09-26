import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import 'package:animikan/router.dart';
import 'package:animikan/services/auth.dart';

const _placeholderAsset = 'assets/images/avatar_placeholder.svg';

class UserAvatar extends StatelessWidget {
  const UserAvatar({super.key, required this.user, this.size = 40});

  final AuthUser? user;

  final double size;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final url = user?.avatar.url ?? '';

    return Container(
      width: size,
      height: size,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: colors.surfaceContainerHighest,
      ),
      child: url.isEmpty
          ? _placeholder(colors)
          : CachedNetworkImage(
              imageUrl: url,
              fit: BoxFit.cover,
              errorWidget: (_, _, _) => _placeholder(colors),
              placeholder: (_, _) => _placeholder(colors),
            ),
    );
  }

  Widget _placeholder(ColorScheme colors) => Padding(
    padding: EdgeInsets.all(size * 0.2),
    child: SvgPicture.asset(
      _placeholderAsset,
      colorFilter: ColorFilter.mode(colors.onSurfaceVariant, BlendMode.srcIn),
    ),
  );
}

class UserAvatarButton extends StatelessWidget {
  const UserAvatarButton({super.key, this.size = 40});

  final double size;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AuthState>(
      valueListenable: BangumiAuth.instance,
      builder: (context, state, _) => InkWell(
        customBorder: const CircleBorder(),
        onTap: () => context.push(AppRoute.account),
        child: UserAvatar(user: state.user, size: size),
      ),
    );
  }
}
