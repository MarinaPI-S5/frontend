import 'package:flutter/material.dart';

class CustomBottomNav extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  const CustomBottomNav({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: NavigationBarTheme(
            data: NavigationBarThemeData(
              iconTheme: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return const IconThemeData(color: Colors.white);
                }
                return const IconThemeData(color: Colors.grey);
              }),
              labelTextStyle: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  );
                }
                return const TextStyle(color: Colors.grey, fontSize: 10);
              }),
              indicatorColor: Colors.blueAccent.withValues(alpha: 0.3),
            ),
            child: NavigationBar(
              backgroundColor: Colors.black,
              selectedIndex: selectedIndex,
              onDestinationSelected: onDestinationSelected,
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.home_outlined),
                  label: 'Início',
                ),
                NavigationDestination(
                  icon: Icon(Icons.person_outlined),
                  label: 'Clientes',
                ),
                NavigationDestination(
                  icon: Icon(Icons.sailing_outlined),
                  label: 'Embarcações',
                ),
                NavigationDestination(
                  icon: Icon(Icons.settings_outlined),
                  label: 'Configurações',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
