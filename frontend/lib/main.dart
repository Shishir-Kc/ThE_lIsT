import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'widgets/ai_panel.dart';
import 'widgets/todo_panel.dart';
import 'widgets/stats_panel.dart';
import 'widgets/resizable_layout.dart';
import 'services/task_service.dart';
import 'package:window_manager/window_manager.dart';
import 'dart:async';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();

  WindowOptions windowOptions = const WindowOptions(
    size: Size(1200, 800),
    minimumSize: Size(1200, 800),
    center: true,
    backgroundColor: Colors.transparent,
    skipTaskbar: false,
    titleBarStyle: TitleBarStyle.normal,
  );
  
  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });

  runApp(const DashboardApp());
}

class DashboardApp extends StatelessWidget {
  const DashboardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Modern Dashboard',
      theme: AppTheme.darkTheme,
      home: const DashboardPage(),
    );
  }
}

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}



class _DashboardPageState extends State<DashboardPage> {
  final TaskService _taskService = TaskService();
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _taskService.fetchTasks();
    _timer = Timer.periodic(const Duration(seconds: 20), (timer) {
      _taskService.fetchTasks();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ResizableLayout(
          initialFlex: const [3, 4, 3],
          children: [
            // Left Panel: AI Chat
             const AiPanel(),
            
            // Middle Panel: Todo List
             TodoPanel(taskService: _taskService),

            // Right Panel: Stats
             StatsPanel(taskService: _taskService),
          ],
        ),
      ),
    );
  }
}
