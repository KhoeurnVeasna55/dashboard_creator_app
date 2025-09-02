import 'package:dashboard_admin/screen/category_screen/main_category.dart';
import 'package:dashboard_admin/screen/home_ds.dart';
import 'package:dashboard_admin/screen/products-screen/main_product_screen.dart';
import 'package:flutter/material.dart';
import 'package:sidebarx/sidebarx.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class MainPage extends StatelessWidget {
  MainPage({super.key});
  final _controller = SidebarXController(selectedIndex: 0, extended: true);
  final _key = GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Builder(
        builder: (context) {
          final isSmallScreen = MediaQuery.of(context).size.width < 600;
          return Scaffold(
            key: _key,
            appBar: isSmallScreen
                ? AppBar(
                    backgroundColor: canvasColor,
                    title: Text(getTitleByIndex(_controller.selectedIndex)),
                    leading: IconButton(
                      onPressed: () {
                        // if (!Platform.isAndroid && !Platform.isIOS) {
                        //   _controller.setExtended(true);
                        // }
                        _key.currentState?.openDrawer();
                      },
                      icon: const Icon(Icons.menu),
                    ),
                  )
                : null,
            drawer: ExampleSidebarX(controller: _controller),
            body: Row(
              children: [
                if (!isSmallScreen) ExampleSidebarX(controller: _controller),
                Expanded(
                  child: AnimatedBuilder(
                    animation: _controller,
                    builder: (context, _) {
                      switch (_controller.selectedIndex) {
                        case 0:
                          return HomeDsPage(controller: _controller);
                        case 1:
                          return MainProductScreen();
                        case 2:
                          return MainCategory();
                        default:
                          return Center(child: Text('Page not found'));
                      }
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class ExampleSidebarX extends StatelessWidget {
  const ExampleSidebarX({super.key, required SidebarXController controller})
    : _controller = controller;

  final SidebarXController _controller;

  @override
  Widget build(BuildContext context) {
    return SidebarX(
      controller: _controller,
      theme: SidebarXTheme(
        // padding: EdgeInsets.symmetric(horizontal: 15),
        width: 90,
        margin: EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: canvasColor,
          borderRadius: BorderRadius.circular(25),
        ),
        hoverColor: scaffoldBackgroundColor,
        textStyle: Theme.of(context).textTheme.titleSmall,
        selectedTextStyle: Theme.of(context).textTheme.titleSmall!.copyWith(
          color: Color(0xFF273C6E),
          fontSize: 16,
        ),
        hoverTextStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
        itemMargin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        itemPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        itemTextPadding: const EdgeInsets.only(left: 30),
        selectedItemTextPadding: const EdgeInsets.only(left: 30),
        selectedItemPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        selectedItemMargin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        selectedIconTheme: IconThemeData(color: Color(0xFF273C6E), size: 20),
        // itemPadding: EdgeInsets.symmetric(horizontal: 10),
        itemDecoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: canvasColor),
        ),
        selectedItemDecoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: actionColor.withValues(alpha: 0.37)),
          color: accentCanvasColor,
          boxShadow: [
            BoxShadow(
              color: Color.fromARGB(255, 40, 39, 94).withValues(alpha: 0.28),
              blurRadius: 30,
            ),
          ],
        ),
        iconTheme: IconThemeData(
          color: Colors.white.withValues(alpha: 0.7),
          size: 20,
        ),
      ),
      extendedTheme: const SidebarXTheme(
        width: 200,
        decoration: BoxDecoration(color: canvasColor),
      ),
      footerDivider: divider,
      headerBuilder: (context, extended) {
        return SizedBox(
          height: 100,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: CircleAvatar(
              minRadius: 60,
              backgroundImage: AssetImage('assets/logo/Logo.jpg'),
            ),
          ),
        );
      },
      items: [
        SidebarXItem(
          icon: LucideIcons.layoutDashboard,
          label: 'Dashboard',
          onTap: () {
            debugPrint('Dashboard');
          },
        ),
        const SidebarXItem(icon: LucideIcons.shoppingBag100, label: 'Products'),
        const SidebarXItem(icon: LucideIcons.creditCard, label: 'Category'),
        SidebarXItem(
          icon: LucideIcons.heart,
          label: 'Favorites',
          selectable: false,
          onTap: () => _showDisabledAlert(context),
        ),
        // ignore: deprecated_member_use
        const SidebarXItem(iconWidget: FlutterLogo(size: 20), label: 'Flutter'),
      ],
    );
  }

  void _showDisabledAlert(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Item disabled for selecting',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
      ),
    );
  }
}

// ignore: unused_element
class _ScreensExample extends StatelessWidget {
  const _ScreensExample({required this.controller});

  final SidebarXController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final pageTitle = getTitleByIndex(controller.selectedIndex);
        switch (controller.selectedIndex) {
          case 0:
            return ListView.builder(
              padding: const EdgeInsets.only(top: 10),
              itemBuilder: (context, index) => Container(
                height: 100,
                width: double.infinity,
                margin: EdgeInsets.only(bottom: 10, right: 10, left: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Theme.of(context).canvasColor,
                  boxShadow: const [BoxShadow()],
                ),
              ),
            );
          default:
            return Text(pageTitle, style: theme.textTheme.headlineSmall);
        }
      },
    );
  }
}

String getTitleByIndex(int index) {
  switch (index) {
    case 0:
      return 'Dashboard';
    case 1:
      return 'Products';
    case 2:
      return 'Category';
    case 3:
      return 'Favorites';
    case 4:
      return 'Custom iconWidget';
    default:
      return 'Not found page';
  }
}

const primaryColor = Color(0xFF685BFF);
const canvasColor = Color(0xFF171A3B);
const scaffoldBackgroundColor = Color(0xFF464667);
const accentCanvasColor = Color(0xFFFFCF00);
const white = Colors.white;
final actionColor = const Color(0xFFFFCF00).withValues(alpha: 0.6);
final divider = Divider(color: white.withValues(alpha: 0.3), height: 1);
