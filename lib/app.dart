import 'package:flutter/material.dart';

import 'screens/home_screen.dart';
import 'screens/tasks_screen.dart';

class MyAssistantApp extends StatelessWidget {
  const MyAssistantApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Assistant',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const _RootShell(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class _RootShell extends StatefulWidget {
  const _RootShell();
  @override
  State<_RootShell> createState() => _RootShellState();
}

class _RootShellState extends State<_RootShell> {
  int _index = 0;
  final _pages = const [HomeScreen(), TasksScreen()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.assistant), label: 'Assistant'),
          NavigationDestination(icon: Icon(Icons.checklist), label: 'Tasks'),
        ],
      ),
    );
  }
}
