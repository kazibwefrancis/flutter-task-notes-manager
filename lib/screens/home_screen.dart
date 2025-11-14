import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/theme_manager.dart';
import '../models/task_item.dart';
import '../database/database_helper.dart';
import 'add_task_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  List<TaskItem> _tasks = [];
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _loadTasks();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadTasks() async {
    final tasks = await DatabaseHelper().getTasks();
    print('Loaded ${tasks.length} tasks from database');
    setState(() {
      _tasks = tasks;
    });
    _animationController.forward(from: 0);
  }

  Future<void> _toggleTaskCompletion(TaskItem task) async {
    final updatedTask = TaskItem(
      id: task.id,
      title: task.title,
      priority: task.priority,
      description: task.description,
      isCompleted: !task.isCompleted,
    );
    await DatabaseHelper().updateTask(updatedTask);
    _loadTasks();
  }

  Future<void> _deleteTask(int id) async {
    await DatabaseHelper().deleteTask(id);
    _loadTasks();
  }

  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return Colors.red.shade400;
      case 'medium':
        return Colors.orange.shade400;
      case 'low':
        return Colors.green.shade400;
      default:
        return Colors.grey.shade400;
    }
  }

  IconData _getPriorityIcon(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return Icons.flag;
      case 'medium':
        return Icons.flag_outlined;
      case 'low':
        return Icons.outlined_flag;
      default:
        return Icons.flag;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeManager = Provider.of<ThemeManager>(context);
    final completedTasks = _tasks.where((t) => t.isCompleted).length;
    final totalTasks = _tasks.length;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          'Tasks',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 28),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: IconButton(
              icon: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (child, animation) {
                  return RotationTransition(
                    turns: animation,
                    child: child,
                  );
                },
                child: Icon(
                  themeManager.isDarkMode 
                      ? Icons.light_mode_rounded 
                      : Icons.dark_mode_rounded,
                  key: ValueKey(themeManager.isDarkMode),
                ),
              ),
              onPressed: () async {
                print('Toggling theme');
                await themeManager.toggleTheme();
                print('Theme toggled to: ${themeManager.isDarkMode}');
              },
              tooltip: 'Toggle theme',
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Stats Card
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      theme.colorScheme.primary,
                      theme.colorScheme.secondary,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: theme.colorScheme.primary.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Progress',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '$completedTasks / $totalTasks',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Tasks completed',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.emoji_events_rounded,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Tasks List
            Expanded(
              child: _tasks.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.task_alt_rounded,
                            size: 80,
                            color: theme.colorScheme.primary.withOpacity(0.3),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No tasks yet',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: theme.colorScheme.onSurface.withOpacity(0.6),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Tap + to add your first task',
                            style: TextStyle(
                              fontSize: 14,
                              color: theme.colorScheme.onSurface.withOpacity(0.4),
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: _tasks.length,
                      itemBuilder: (context, index) {
                        final task = _tasks[index];
                        return AnimatedBuilder(
                          animation: _animationController,
                          builder: (context, child) {
                            final animation = Tween<double>(
                              begin: 0.0,
                              end: 1.0,
                            ).animate(
                              CurvedAnimation(
                                parent: _animationController,
                                curve: Interval(
                                  (index / _tasks.length) * 0.5,
                                  ((index + 1) / _tasks.length) * 0.5 + 0.5,
                                  curve: Curves.easeOut,
                                ),
                              ),
                            );

                            return Transform.translate(
                              offset: Offset(0, 50 * (1 - animation.value)),
                              child: Opacity(
                                opacity: animation.value,
                                child: child,
                              ),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 12.0),
                            child: Dismissible(
                              key: Key(task.id.toString()),
                              background: Container(
                                margin: const EdgeInsets.symmetric(vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.red.shade400,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.only(right: 20),
                                child: const Icon(
                                  Icons.delete_rounded,
                                  color: Colors.white,
                                  size: 28,
                                ),
                              ),
                              direction: DismissDirection.endToStart,
                              onDismissed: (direction) {
                                _deleteTask(task.id!);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: const Text('Task deleted'),
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                );
                              },
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(16),
                                  onTap: () => _toggleTaskCompletion(task),
                                  child: Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: theme.cardTheme.color,
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: theme.colorScheme.surfaceContainerHighest,
                                        width: 1,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        // Checkbox
                                        Container(
                                          width: 28,
                                          height: 28,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: task.isCompleted
                                                  ? theme.colorScheme.primary
                                                  : theme.colorScheme.onSurface.withOpacity(0.3),
                                              width: 2,
                                            ),
                                            color: task.isCompleted
                                                ? theme.colorScheme.primary
                                                : Colors.transparent,
                                          ),
                                          child: task.isCompleted
                                              ? const Icon(
                                                  Icons.check_rounded,
                                                  color: Colors.white,
                                                  size: 18,
                                                )
                                              : null,
                                        ),
                                        const SizedBox(width: 16),
                                        
                                        // Content
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                task.title,
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600,
                                                  decoration: task.isCompleted
                                                      ? TextDecoration.lineThrough
                                                      : null,
                                                  color: task.isCompleted
                                                      ? theme.colorScheme.onSurface.withOpacity(0.5)
                                                      : theme.colorScheme.onSurface,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                task.description,
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                                                  decoration: task.isCompleted
                                                      ? TextDecoration.lineThrough
                                                      : null,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        
                                        // Priority badge
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 6,
                                          ),
                                          decoration: BoxDecoration(
                                            color: _getPriorityColor(task.priority).withOpacity(0.15),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                _getPriorityIcon(task.priority),
                                                size: 14,
                                                color: _getPriorityColor(task.priority),
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                task.priority,
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w600,
                                                  color: _getPriorityColor(task.priority),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddTaskScreen()),
          );
          _loadTasks();
        },
        icon: const Icon(Icons.add_rounded),
        label: const Text('New Task'),
      ),
    );
  }
}