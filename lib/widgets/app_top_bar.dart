import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

import 'package:animikan/utils/platform.dart';

class AppTopBar extends StatelessWidget {
  const AppTopBar({super.key, required this.title, this.onBack, this.trailing});

  static const double height = 38.0;

  static const double _windowButtonsWidth = height * 3;

  final String title;

  final VoidCallback? onBack;

  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final bool desktop = isDesktop();
    final row = Row(
      children: [
        if (onBack != null)
          SizedBox(
            width: height,
            child: IconButton(
              icon: const Icon(Icons.arrow_back_rounded, size: 18),
              onPressed: onBack,
              padding: EdgeInsets.zero,
              splashRadius: 14,
              color: colors.onSurface.withValues(alpha: 0.7),
            ),
          ),
        SizedBox(width: onBack == null ? 16.0 : 4.0),
        Expanded(
          child: Text(
            title,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 13,
              color: colors.onSurface.withValues(alpha: 0.7),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        if (trailing != null && !desktop)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: trailing!,
          ),
      ],
    );

    if (!desktop) return SizedBox(height: height, child: row);

    final double reserve = trailing == null
        ? 0.0
        : _windowButtonsWidth + height;
    return SizedBox(
      height: height,
      child: Stack(
        children: [
          Positioned.fill(
            child: DragToMoveArea(
              child: Padding(
                padding: EdgeInsets.only(right: reserve),
                child: row,
              ),
            ),
          ),
          if (trailing != null)
            Positioned(
              top: 0,
              bottom: 0,
              right: _windowButtonsWidth,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: trailing!,
                ),
              ),
            ),
          const Positioned(top: 0, right: 0, child: WindowButtons()),
        ],
      ),
    );
  }
}

class WindowButtons extends StatefulWidget {
  const WindowButtons({super.key});

  @override
  State<WindowButtons> createState() => _WindowButtonsState();
}

class _WindowButtonsState extends State<WindowButtons> with WindowListener {
  bool _maximized = false;

  @override
  void initState() {
    super.initState();
    windowManager.addListener(this);
    windowManager.isMaximized().then((value) {
      if (mounted) setState(() => _maximized = value);
    });
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    super.dispose();
  }

  @override
  void onWindowMaximize() => setState(() => _maximized = true);

  @override
  void onWindowUnmaximize() => setState(() => _maximized = false);

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    const size = 14.0;
    final color = colors.onSurface;
    final hover = colors.onSurface.withValues(alpha: 0.1);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _TitleBarButton(
          icon: Icons.horizontal_rule_rounded,
          size: size,
          color: color,
          hoverColor: hover,
          onPressed: windowManager.minimize,
        ),
        _TitleBarButton(
          icon: _maximized
              ? Icons.filter_none_rounded
              : Icons.crop_square_rounded,
          size: size + 2,
          color: color,
          hoverColor: hover,
          onPressed: _maximized
              ? windowManager.unmaximize
              : windowManager.maximize,
        ),
        _TitleBarButton(
          icon: Icons.close_rounded,
          size: size + 2,
          color: color,
          hoverColor: const Color(0xFFC42B1C),
          onPressed: windowManager.close,
        ),
      ],
    );
  }
}

class _TitleBarButton extends StatefulWidget {
  const _TitleBarButton({
    required this.icon,
    required this.size,
    required this.color,
    required this.hoverColor,
    required this.onPressed,
  });

  final IconData icon;
  final double size;
  final Color color;
  final Color hoverColor;
  final VoidCallback onPressed;

  @override
  State<_TitleBarButton> createState() => _TitleBarButtonState();
}

class _TitleBarButtonState extends State<_TitleBarButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) => MouseRegion(
    onEnter: (_) => setState(() => _hovered = true),
    onExit: (_) => setState(() => _hovered = false),
    child: Container(
      width: AppTopBar.height,
      height: AppTopBar.height,
      color: _hovered ? widget.hoverColor : Colors.transparent,
      child: InkWell(
        onTap: widget.onPressed,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        child: Center(
          child: Icon(widget.icon, size: widget.size, color: widget.color),
        ),
      ),
    ),
  );
}
