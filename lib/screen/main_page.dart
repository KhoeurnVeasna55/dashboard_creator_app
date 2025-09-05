// main_page.dart
import 'package:dashboard_admin/core/routes/router_utils.dart';
import 'package:dashboard_admin/screen/category_screen/main_category.dart';
import 'package:dashboard_admin/screen/home_ds.dart';
import 'package:dashboard_admin/screen/products-screen/main_product_screen.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:sidebarx/sidebarx.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

// theme bits you had
const primaryColor = Color(0xFF685BFF);
const canvasColor = Color(0xFF171A3B);
const scaffoldBackgroundColor = Color(0xFF464667);
const accentCanvasColor = Color(0xFFFFCF00);
const white = Colors.white;
final actionColor = const Color(0xFFFFCF00).withOpacity(0.6);
final divider = const Divider(color: Colors.white54, height: 1);

class MainPage extends StatefulWidget {
  const MainPage({super.key});
  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  late final SidebarXController _controller;
  final _key = GlobalKey<ScaffoldState>();
  final _router = WebPathRouter();

  bool _applyingPath = false;

  String _normalize(String p) => _router.normalize(p);

  int _indexForPath(String path) {
    final p = _normalize(path);
    if (p.startsWith('/products')) return 1;
    if (p == '/categories' || p.startsWith('/categories/')) return 2;
    return 0;
  }

  String _pathForIndex(int i) {
    switch (i) {
      case 0:
        return '/dashboard';
      case 1:
        return '/products';
      case 2:
        return '/categories';
      default:
        return '/dashboard';
    }
  }

  void _applyPathToTab() {
    if (!kIsWeb) return;
    final idx = _indexForPath(_router.read());
    if (_controller.selectedIndex != idx) {
      _applyingPath = true;
      _controller.selectIndex(idx);
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => _applyingPath = false,
      );
    }
  }

  @override
  void initState() {
    super.initState();

    final initialIndex = _indexForPath(_router.read());
    _controller = SidebarXController(
      selectedIndex: initialIndex,
      extended: true,
    );

    // normalize only if root
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final p = _router.read();
      if (p == '/' || p.isEmpty) {
        _router.write(_pathForIndex(_controller.selectedIndex), replace: true);
      }
    });

    _router.addListeners(() {
      if (_router.isWriting) return;
      _applyPathToTab();
    });

    _controller.addListener(() {
      if (!kIsWeb) return;
      if (_applyingPath || _router.isWriting) return;

      final current = _router.read();
      if (_controller.selectedIndex == 2) return;

      final desired = _pathForIndex(_controller.selectedIndex);
      if (_normalize(current) != _normalize(desired)) {
        WidgetsBinding.instance.addPostFrameCallback(
          (_) => _router.write(desired),
        );
      }
    });
  }

  @override
  void dispose() {
    _router.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 600;

    return SelectionContainer.disabled(
      child: Scaffold(
        key: _key,
        appBar: isSmallScreen
            ? AppBar(
                backgroundColor: canvasColor,
                title: Text(getTitleByIndex(_controller.selectedIndex)),
                leading: IconButton(
                  onPressed: () => _key.currentState?.openDrawer(),
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
                      return const MainCategory();
                    default:
                      return const Center(child: Text('Page not found'));
                  }
                },
              ),
            ),
          ],
        ),
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
        width: 90,
        margin: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: canvasColor,
          borderRadius: BorderRadius.circular(25),
        ),
        hoverColor: scaffoldBackgroundColor,
        textStyle: Theme.of(context).textTheme.titleSmall,
        selectedTextStyle: Theme.of(context).textTheme.titleSmall!.copyWith(
          color: const Color(0xFF273C6E),
          fontSize: 16,
        ),
        hoverTextStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
        itemMargin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        itemPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        itemTextPadding: const EdgeInsets.only(left: 30),
        selectedItemTextPadding: const EdgeInsets.only(left: 30),
        selectedItemPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 12,
        ),
        selectedItemMargin: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 5,
        ),
        selectedIconTheme: const IconThemeData(
          color: Color(0xFF273C6E),
          size: 20,
        ),
        itemDecoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: canvasColor),
        ),
        selectedItemDecoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: actionColor),
          color: accentCanvasColor,
          boxShadow: const [
            BoxShadow(color: Color.fromARGB(255, 40, 39, 94), blurRadius: 30),
          ],
        ),
        iconTheme: IconThemeData(
          color: Colors.white.withOpacity(0.7),
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
              backgroundImage: const AssetImage('assets/logo/Logo.jpg'),
            ),
          ),
        );
      },
      items: [
        SidebarXItem(
          icon: LucideIcons.layoutDashboard,
          label: 'Dashboard',
          onTap: () => Future.microtask(() => _controller.selectIndex(0)),
        ),
        SidebarXItem(
          icon: LucideIcons.shoppingBag,
          label: 'Products',
          onTap: () => Future.microtask(() => _controller.selectIndex(1)),
        ),
        SidebarXItem(
          icon: LucideIcons.creditCard,
          label: 'Category',
          onTap: () => Future.microtask(() => _controller.selectIndex(2)),
        ),
      ],
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
      return 'Categories';
    default:
      return 'Not found page';
  }
}
