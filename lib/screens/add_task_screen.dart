import 'package:flutter/material.dart';
import '../models/task_item.dart';
import '../database/database_helper.dart';

class AddTaskScreen extends StatefulWidget {
  const AddTaskScreen({super.key});

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _priority = 'Low';
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _animationController.dispose();
    super.dispose();
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

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'New Task',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header Icon
                AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _animationController.value,
                      child: Opacity(
                        opacity: _animationController.value,
                        child: child,
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          theme.colorScheme.primary,
                          theme.colorScheme.secondary,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: theme.colorScheme.primary.withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.add_task_rounded,
                      size: 40,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Title Field
                AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    final animation = Tween<double>(begin: 0.0, end: 1.0).animate(
                      CurvedAnimation(
                        parent: _animationController,
                        curve: const Interval(0.2, 0.6, curve: Curves.easeOut),
                      ),
                    );
                    return Transform.translate(
                      offset: Offset(0, 30 * (1 - animation.value)),
                      child: Opacity(opacity: animation.value, child: child),
                    );
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Task Title',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _titleController,
                        style: const TextStyle(fontSize: 16),
                        decoration: const InputDecoration(
                          hintText: 'Enter task title',
                          prefixIcon: Icon(Icons.title_rounded),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a title';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Priority Selector
                AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    final animation = Tween<double>(begin: 0.0, end: 1.0).animate(
                      CurvedAnimation(
                        parent: _animationController,
                        curve: const Interval(0.3, 0.7, curve: Curves.easeOut),
                      ),
                    );
                    return Transform.translate(
                      offset: Offset(0, 30 * (1 - animation.value)),
                      child: Opacity(opacity: animation.value, child: child),
                    );
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Priority',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: ['Low', 'Medium', 'High'].map((priority) {
                          final isSelected = _priority == priority;
                          return Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(12),
                                onTap: () {
                                  setState(() {
                                    _priority = priority;
                                  });
                                },
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? _getPriorityColor(priority).withOpacity(0.15)
                                        : theme.colorScheme.surfaceContainerHighest,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: isSelected
                                          ? _getPriorityColor(priority)
                                          : Colors.transparent,
                                      width: 2,
                                    ),
                                  ),
                                  child: Column(
                                    children: [
                                      Icon(
                                        _getPriorityIcon(priority),
                                        color: isSelected
                                            ? _getPriorityColor(priority)
                                            : theme.colorScheme.onSurface.withOpacity(0.5),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        priority,
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: isSelected
                                              ? _getPriorityColor(priority)
                                              : theme.colorScheme.onSurface.withOpacity(0.7),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Description Field
                AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    final animation = Tween<double>(begin: 0.0, end: 1.0).animate(
                      CurvedAnimation(
                        parent: _animationController,
                        curve: const Interval(0.4, 0.8, curve: Curves.easeOut),
                      ),
                    );
                    return Transform.translate(
                      offset: Offset(0, 30 * (1 - animation.value)),
                      child: Opacity(opacity: animation.value, child: child),
                    );
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Description',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _descriptionController,
                        style: const TextStyle(fontSize: 16),
                        maxLines: 5,
                        decoration: const InputDecoration(
                          hintText: 'Enter task description',
                          alignLabelWithHint: true,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a description';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Submit Button
                AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    final animation = Tween<double>(begin: 0.0, end: 1.0).animate(
                      CurvedAnimation(
                        parent: _animationController,
                        curve: const Interval(0.5, 1.0, curve: Curves.easeOut),
                      ),
                    );
                    return Transform.scale(
                      scale: 0.8 + (0.2 * animation.value),
                      child: Opacity(opacity: animation.value, child: child),
                    );
                  },
                  child: ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        try {
                          final task = TaskItem(
                            title: _titleController.text,
                            priority: _priority,
                            description: _descriptionController.text,
                          );
                          await DatabaseHelper().insertTask(task);
                          if (context.mounted) {
                            Navigator.pop(context);
                          }
                        } catch (e) {
                          // Show error dialog
                          if (context.mounted) {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Error'),
                                content: Text('Failed to create task: $e'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('OK'),
                                  ),
                                ],
                              ),
                            );
                          }
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Create Task',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}