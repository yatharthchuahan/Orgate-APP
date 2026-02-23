import 'package:flutter/material.dart';

class OrangtreAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final PreferredSizeWidget? bottom;
  final VoidCallback? onMenuPressed;
  final VoidCallback? onProfilePressed;
  final bool showMenuIcon;
  final bool showProfileIcon;
  final double height;

  const OrangtreAppBar({
    Key? key,
    this.title = 'Orangtre',
    this.actions,
    this.bottom,
    this.onMenuPressed,
    this.onProfilePressed,
    this.showMenuIcon = true,
    this.showProfileIcon = true,
    this.height = 85.0,
  }) : super(key: key);

  @override
  Size get preferredSize =>
      Size.fromHeight(height + (bottom?.preferredSize.height ?? 0));

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF2C3E50),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: AppBar(
        leading: showMenuIcon
            ? IconButton(
                icon: const Icon(Icons.menu),
                iconSize: 28,
                onPressed:
                    onMenuPressed ??
                    () {
                      Scaffold.of(context).openDrawer();
                    },
              )
            : null,
        title: Text(
          title,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        toolbarHeight: height,
        actions: [
          if (showProfileIcon)
            IconButton(
              icon: const Icon(Icons.account_circle),
              iconSize: 32,
              onPressed:
                  onProfilePressed ??
                  () {
                    Navigator.pushNamed(context, '/profile');
                  },
            ),
          if (actions != null) ...actions!,
        ],
        bottom: bottom,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(30),
            bottomRight: Radius.circular(30),
          ),
        ),
      ),
    );
  }
}

class MainScaffold extends StatelessWidget {
  final String title;
  final Widget body;
  final Widget? floatingActionButton;
  final Widget? drawer;
  final List<Widget>? actions;
  final PreferredSizeWidget? bottom;
  final Color? backgroundColor;
  final VoidCallback? onMenuPressed;
  final VoidCallback? onProfilePressed;
  final bool showMenuIcon;
  final bool showProfileIcon;
  final double appBarHeight;

  const MainScaffold({
    Key? key,
    required this.body,
    this.title = 'Orangtre',
    this.floatingActionButton,
    this.drawer,
    this.actions,
    this.bottom,
    this.backgroundColor,
    this.onMenuPressed,
    this.onProfilePressed,
    this.showMenuIcon = true,
    this.showProfileIcon = true,
    this.appBarHeight = 80.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: OrangtreAppBar(
        title: title,
        actions: actions,
        bottom: bottom,
        onMenuPressed: onMenuPressed,
        onProfilePressed: onProfilePressed,
        showMenuIcon: showMenuIcon,
        showProfileIcon: showProfileIcon,
        height: appBarHeight,
      ),
      drawer: drawer,
      backgroundColor: backgroundColor,
      body: body,
      floatingActionButton: floatingActionButton,
    );
  }
}
