import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/responsive.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/my_page_screen.dart';
import 'features/favorites/presentation/favorites_screen.dart';
import 'features/recipe_search/presentation/recipe_search_screen.dart';
import 'features/settings/presentation/locale_provider.dart';

class MyRecipeApp extends ConsumerWidget {
  const MyRecipeApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localeOverride = ref.watch(localeOverrideProvider);
    return MaterialApp(
      title: '나의 레시피',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      locale: localeOverride,
      supportedLocales: supportedAppLocales,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: const HomeShell(),
    );
  }
}

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  static const _screens = [
    RecipeSearchScreen(),
    FavoritesScreen(),
    MyPageScreen(),
  ];

  static const _icons = [
    Icons.search,
    Icons.favorite_border,
    Icons.person_outline,
  ];
  static const _labels = ['검색', '즐겨찾기', '마이페이지'];

  @override
  Widget build(BuildContext context) {
    final body = IndexedStack(index: _index, children: _screens);

    // 태블릿 가로모드처럼 화면이 넓을 땐 하단 탭 대신 옆에 붙는 NavigationRail을 사용.
    if (isWideLayout(context)) {
      return Scaffold(
        body: Row(
          children: [
            NavigationRail(
              selectedIndex: _index,
              onDestinationSelected: (i) => setState(() => _index = i),
              labelType: NavigationRailLabelType.all,
              destinations: [
                for (var i = 0; i < _icons.length; i++)
                  NavigationRailDestination(
                    icon: Icon(_icons[i]),
                    label: Text(_labels[i]),
                  ),
              ],
            ),
            const VerticalDivider(width: 1),
            Expanded(child: body),
          ],
        ),
      );
    }

    return Scaffold(
      body: body,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: [
          for (var i = 0; i < _icons.length; i++)
            NavigationDestination(icon: Icon(_icons[i]), label: _labels[i]),
        ],
      ),
    );
  }
}
