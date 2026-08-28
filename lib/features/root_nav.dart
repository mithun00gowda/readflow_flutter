import 'package:flutter/material.dart';
import 'package:readflow/core/theme/app_theme.dart';
import 'package:readflow/features/add_book/add_book_screen.dart';
import 'package:readflow/features/bookshelf/book_shelf_screen.dart';
import 'package:readflow/features/home/home.dart';
import 'package:readflow/features/settings/reminder_screen.dart';
import 'package:readflow/features/stats/stats_screen.dart';

class RootNav extends StatefulWidget {
  const RootNav({super.key});

  @override
  State<RootNav> createState() => _RootNavState();
}

class _RootNavState extends State<RootNav> {
  int _currentindex = 0;

  static const _screen = [Home(), BookShelfScreen(),StatsScreen(), ReminderScreen()];

  void _onTabTapped(int index) => setState(() => _currentindex = index);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentindex, children: _screen),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: SizedBox(
        width: 64,
        height: 64,
        child: FloatingActionButton(
          onPressed: () {
            Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const AddBookScreen()));
          },
          heroTag: 'root_nav_add_book_fab',
          shape: const CircleBorder(),
          backgroundColor: AppColors.primary,
          elevation: 4,
          child: const Icon(Icons.add, size: 32, color: Colors.white),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        color: AppColors.surface,
        elevation: 8,
        height: 64,
        padding: EdgeInsets.zero,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _NavIcons(
              icon: Icons.home_outlined,
              selectedIcon: Icons.home,
              isSelected: _currentindex == 0,
              onTap: () => _onTabTapped(0),
            ),
            _NavIcons(
              icon: Icons.menu_book_outlined,
              selectedIcon: Icons.menu_book,
              isSelected: _currentindex == 1,
              onTap: () => _onTabTapped(1),
            ),
            SizedBox(width: 40,),
            _NavIcons(
              icon: Icons.bar_chart_outlined,
              selectedIcon: Icons.bar_chart,
              isSelected: _currentindex == 2,
              onTap: () => _onTabTapped(2),
            ),
            _NavIcons(
              icon: Icons.settings_outlined,
              selectedIcon: Icons.settings,
              isSelected: _currentindex == 3,
              onTap: () => _onTabTapped(3),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavIcons extends StatelessWidget {
  final IconData icon;
  final IconData selectedIcon;
  final bool isSelected;
  final VoidCallback onTap;
  const _NavIcons({
    super.key,
    required this.icon,
    required this.selectedIcon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Icon(
          isSelected ? selectedIcon : icon,
          color: isSelected ? AppColors.primary : AppColors.textSecondary,
          size: 26,
        ),
      ),
    );
  }
}

// NavigationBar(
// selectedIndex: _currentindex,
// onDestinationSelected: (index) => setState(() => _currentindex = index),
// backgroundColor: AppColors.surface,
// elevation: 3,
// destinations: [
// NavigationDestination(
// icon: Icon(Icons.home_outlined),
// selectedIcon: Icon(Icons.home),
// label: 'Home',
// ),
// NavigationDestination(
// icon: Icon(Icons.menu_book_outlined),
// selectedIcon: Icon(Icons.menu_book),
// label: 'Bookshelf',
// ),
// NavigationDestination(
// icon: Icon(Icons.settings_outlined),
// selectedIcon: Icon(Icons.settings),
// label: 'Settings',
// ),
// ],
// )
