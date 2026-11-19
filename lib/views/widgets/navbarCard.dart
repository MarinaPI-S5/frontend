import 'package:flutter/material.dart';

class CustomBottomNav extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final bool isLoggedIn;

  const CustomBottomNav({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
    this.isLoggedIn = true,
  });

  @override
  Widget build(BuildContext context) {
    final destinations = <NavigationDestination>[
      const NavigationDestination(
        icon: Icon(Icons.home_outlined),
        label: 'Início',
      ),
      if (!isLoggedIn)
        const NavigationDestination(
          icon: Icon(Icons.person_outlined),
          label: 'Clientes',
        ),
      const NavigationDestination(
        icon: Icon(Icons.sailing_outlined),
        label: 'Embarcações',
      ),
      const NavigationDestination(
        icon: Icon(Icons.view_agenda_rounded),
        label: 'Agendamento',
      ),
    ];

    final safeIndex = selectedIndex.clamp(0, destinations.length - 1);

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
              selectedIndex: safeIndex,
              onDestinationSelected: onDestinationSelected,
              destinations: destinations,
            ),
          ),
        ),
      ),
    );
  }
}
