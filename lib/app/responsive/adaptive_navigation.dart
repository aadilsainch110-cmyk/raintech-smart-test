import 'package:flutter/material.dart';
import 'responsive_utils.dart';

class AdaptiveNavigation extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onDestinationSelected;
  final List<NavigationDestination> destinations;
  final Color? backgroundColor;
  final Color? selectedItemColor;
  final Color? unselectedItemColor;

  const AdaptiveNavigation({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.destinations,
    this.backgroundColor,
    this.selectedItemColor,
    this.unselectedItemColor,
  });

  @override
  Widget build(BuildContext context) {
    // Desktop-only: always use NavigationRail
    return _buildNavigationRail(context);
  }

  Widget _buildNavigationRail(BuildContext context) {
    return NavigationRail(
      selectedIndex: selectedIndex,
      onDestinationSelected: onDestinationSelected,
      backgroundColor: backgroundColor,
      elevation: 8,
      leading: Padding(
        padding: const EdgeInsets.all(16),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Theme.of(context).colorScheme.primary,
                Theme.of(context).colorScheme.secondary,
              ],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.school, color: Colors.white, size: 32),
        ),
      ),
      destinations: destinations
          .map(
            (dest) => NavigationRailDestination(
              icon: dest.icon,
              selectedIcon: dest.selectedIcon,
              label: Text(dest.label),
            ),
          )
          .toList(),
      labelType: NavigationRailLabelType.all,
    );
  }
}

class AdaptiveScaffold extends StatelessWidget {
  final PreferredSizeWidget? appBar;
  final Widget body;
  final Widget? floatingActionButton;
  final Widget? bottomNavigationBar;
  final Widget? drawer;
  final Widget? endDrawer;
  final Color? backgroundColor;
  final bool extendBody;
  final bool extendBodyBehindAppBar;

  const AdaptiveScaffold({
    super.key,
    this.appBar,
    required this.body,
    this.floatingActionButton,
    this.bottomNavigationBar,
    this.drawer,
    this.endDrawer,
    this.backgroundColor,
    this.extendBody = false,
    this.extendBodyBehindAppBar = false,
  });

  @override
  Widget build(BuildContext context) {
    // Desktop-only: always use desktop scaffold
    return _buildDesktopScaffold(context);
  }

  Widget _buildDesktopScaffold(BuildContext context) {
    return Scaffold(
      appBar: appBar,
      body: Row(
        children: [
          if (drawer != null) SizedBox(width: 280, child: drawer),
          Expanded(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 1400),
              child: body,
            ),
          ),
        ],
      ),
      floatingActionButton: floatingActionButton,
      endDrawer: endDrawer,
      backgroundColor: backgroundColor,
      extendBody: extendBody,
      extendBodyBehindAppBar: extendBodyBehindAppBar,
    );
  }
}

class AdaptiveDrawer extends StatelessWidget {
  final Widget? header;
  final List<Widget> children;
  final double? width;

  const AdaptiveDrawer({
    super.key,
    this.header,
    required this.children,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    // Desktop-only: use fixed drawer width
    final drawerWidth = width ?? 280;

    return SizedBox(
      width: drawerWidth,
      child: Drawer(
        child: Column(
          children: [
            // ignore: use_null_aware_elements
            if (header != null) header!,
            Expanded(
              child: ListView(padding: EdgeInsets.zero, children: children),
            ),
          ],
        ),
      ),
    );
  }
}

class AdaptiveAppBar extends StatelessWidget {
  final String title;
  final List<Widget>? actions;
  final bool automaticallyImplyLeading;
  final Widget? leading;
  final VoidCallback? onBackPressed;

  const AdaptiveAppBar({
    super.key,
    required this.title,
    this.actions,
    this.automaticallyImplyLeading = true,
    this.leading,
    this.onBackPressed,
  });

  @override
  Widget build(BuildContext context) {
    // Desktop-only: always use desktop app bar style
    return AppBar(
      title: Text(
        title,
        style: TextStyle(
          fontSize: ResponsiveUtils.responsiveFontSize(context, 20),
        ),
      ),
      actions: actions,
      automaticallyImplyLeading: automaticallyImplyLeading,
      leading: leading,
      centerTitle: false,
    );
  }
}
