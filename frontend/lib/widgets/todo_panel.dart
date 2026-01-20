import 'package:flutter/material.dart';
import '../services/task_service.dart';
import 'package:intl/intl.dart';

class TodoPanel extends StatelessWidget {
  final TaskService taskService;
  const TodoPanel({super.key, required this.taskService});

  void _showAddTaskDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AddTaskDialog(taskService: taskService),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  "Manage your to-do list",
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w300,
                        fontFamily: 'Caveat',
                        fontSize: 24,
                      ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: () => _showAddTaskDialog(context),
                icon: const Icon(Icons.add_circle_outline, size: 28),
                color: Theme.of(context).colorScheme.primary,
              ),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: AnimatedBuilder(
              animation: taskService,
              builder: (context, child) {
                final tasks = taskService.tasks;
                final activeTasks = tasks.where((t) => !t.isCompleted).toList()
                  ..sort((a, b) => b.priority.compareTo(a.priority));
                final completedTasks = tasks.where((t) => t.isCompleted).toList();
                
                if (tasks.isEmpty) {
                  return Center(
                    child: Text(
                      "No tasks yet",
                      style: TextStyle(color: Colors.white.withOpacity(0.3)),
                    ),
                  );
                }

                return LayoutBuilder(
                  builder: (context, constraints) {
                    return ScrollConfiguration(
                      behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
                      child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Active Tasks Section (Drop Target for Un-completing)
                          DragTarget<Task>(
                            onWillAccept: (data) => data != null && data.isCompleted,
                            onAccept: (task) => taskService.setTaskCompletion(task.id, false),
                            builder: (context, candidateData, rejectedData) {
                               return Container(
                                 width: double.infinity,
                                 color: Colors.transparent,
                                 child: Column(
                                 crossAxisAlignment: CrossAxisAlignment.start,
                                 children: [
                                   if (activeTasks.isNotEmpty) ...[
                                    Text(
                                      "Active Tasks",
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.5),
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    ...activeTasks.map((task) => DragTarget<Task>(
                                      onWillAccept: (data) => data != null && !data.isCompleted && data.id != task.id,
                                      onAccept: (data) => taskService.reorderActiveTask(data.id, task.id),
                                      builder: (context, candidate, rejected) {
                                        return Draggable<Task>(
                                          data: task,
                                          feedback: Material(
                                            borderRadius: BorderRadius.circular(30),
                                            elevation: 0,
                                            color: Colors.transparent,
                                            child: SizedBox(
                                              width: constraints.maxWidth,
                                              child: TaskItem(task: task, onToggle: () {}),
                                            ),
                                          ),
                                          childWhenDragging: Opacity(
                                            opacity: 0.3,
                                            child: MouseRegion(
                                              cursor: SystemMouseCursors.grab,
                                              child: TaskItem(
                                                key: ValueKey(task.id),
                                                task: task,
                                                onToggle: () => taskService.toggleTaskCompletion(task.id),
                                              ),
                                            ),
                                          ),
                                          child: MouseRegion(
                                            cursor: SystemMouseCursors.grab,
                                            child: TaskItem(
                                              key: ValueKey(task.id),
                                              task: task,
                                              onToggle: () => taskService.toggleTaskCompletion(task.id),
                                              onDelete: () => taskService.deleteTask(task.id),
                                            ),
                                          ),
                                        );
                                      }
                                    )),
                                  ] else 
                                    Container(
                                      height: 50, 
                                      alignment: Alignment.centerLeft,
                                      child: Text("No active tasks", style: TextStyle(color: Colors.white.withOpacity(0.1))),
                                    ),
                                 ],
                               ),
                               );
                            },
                          ),

                          const SizedBox(height: 16),
                          Divider(color: Colors.white.withOpacity(0.1), thickness: 1),
                          const SizedBox(height: 16),

                          // Completed Tasks Section (Drop Target for Completing)
                          DragTarget<Task>(
                            onWillAccept: (data) => data != null && !data.isCompleted,
                            onAccept: (task) => taskService.setTaskCompletion(task.id, true),
                            builder: (context, candidateData, rejectedData) {
                              return Container(
                                constraints: const BoxConstraints(minHeight: 100), 
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: Colors.transparent,
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                       padding: const EdgeInsets.only(bottom: 12.0),
                                       child: Text(
                                        "Completed",
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(0.5),
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'Caveat',
                                          letterSpacing: 1.0,
                                        ),
                                      ),
                                     ),
                                    if (completedTasks.isEmpty)
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          "Drop tasks here to complete",
                                          style: TextStyle(color: Colors.white.withOpacity(0.1), fontStyle: FontStyle.italic),
                                        ),
                                      ),
                                    ...completedTasks.map((task) => Draggable<Task>(
                                      data: task,
                                      feedback: Material(
                                        borderRadius: BorderRadius.circular(30),
                                        elevation: 0,
                                        color: Colors.transparent,
                                        child: SizedBox(
                                          width: constraints.maxWidth,
                                          child: Opacity(opacity: 0.6, child: TaskItem(task: task, onToggle: () {})),
                                        ),
                                      ),
                                      childWhenDragging: Opacity(
                                        opacity: 0.3,
                                        child: MouseRegion(
                                            cursor: SystemMouseCursors.grab,
                                            child: TaskItem(task: task, onToggle: () => taskService.toggleTaskCompletion(task.id))
                                        ),
                                      ),
                                      child: MouseRegion(
                                          cursor: SystemMouseCursors.grab,
                                          child: Opacity(
                                            opacity: 0.6,
                                            child: TaskItem(
                                              key: ValueKey(task.id),
                                              task: task,
                                              onToggle: () => taskService.toggleTaskCompletion(task.id),
                                              onDelete: () => taskService.deleteTask(task.id),
                                            ),
                                          ),
                                      ),
                                    )),
                                    const SizedBox(height: 500),
                                  ],
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                      ),
                    );
                  }
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class AddTaskDialog extends StatefulWidget {
  final TaskService taskService;
  const AddTaskDialog({super.key, required this.taskService});

  @override
  State<AddTaskDialog> createState() => _AddTaskDialogState();
}

class _AddTaskDialogState extends State<AddTaskDialog> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 1));
  double _priority = 5;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF1E1E1E),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Add New Task",
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 24),
              
              // Task Name
              _buildLabel("Task Name"),
              const SizedBox(height: 8),
              TextField(
                controller: _titleController,
                decoration: _buildInputDecoration("Enter task title..."),
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 16),

              // Description
              _buildLabel("Task Description"),
              const SizedBox(height: 8),
              TextField(
                controller: _descController,
                decoration: _buildInputDecoration("Enter details..."),
                maxLines: 3,
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 16),

              // Dates Row
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel("Start Date"),
                        const SizedBox(height: 8),
                        _buildDatePicker(context, _startDate, (date) => setState(() => _startDate = date)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel("End Date"),
                        const SizedBox(height: 8),
                        _buildDatePicker(context, _endDate, (date) => setState(() => _endDate = date)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Priority
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildLabel("Priority Label"),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      "Level ${_priority.toInt()}",
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              Slider(
                value: _priority,
                min: 1,
                max: 10,
                divisions: 9,
                label: _priority.toInt().toString(),
                onChanged: (val) => setState(() => _priority = val),
              ),
              
              const SizedBox(height: 24),

              // Actions
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text("Cancel", style: TextStyle(color: Colors.white.withOpacity(0.5))),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    child: const Text("Add Task", style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submit() {
    if (_titleController.text.trim().isEmpty) return;

    widget.taskService.addTask(
      title: _titleController.text.trim(),
      description: _descController.text.trim(),
      startDate: _startDate,
      endDate: _endDate,
      priority: _priority.toInt(),
    );
    Navigator.pop(context);
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        color: Colors.white.withOpacity(0.7),
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  InputDecoration _buildInputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
      filled: true,
      fillColor: Colors.white.withOpacity(0.05),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );
  }

  Widget _buildDatePicker(BuildContext context, DateTime date, Function(DateTime) onPick) {
    return GestureDetector(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: date,
          firstDate: DateTime(2020),
          lastDate: DateTime(2030),
          builder: (context, child) {
            return Theme(
              data: ThemeData.dark().copyWith(
                colorScheme: ColorScheme.dark(
                  primary: Theme.of(context).colorScheme.primary,
                  onPrimary: Colors.black,
                  surface: const Color(0xFF1E1E1E),
                  onSurface: Colors.white,
                ),
                dialogBackgroundColor: const Color(0xFF1E1E1E),
              ),
              child: child!,
            );
          },
        );
        if (picked != null) onPick(picked);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today, size: 16, color: Colors.white.withOpacity(0.5)),
            const SizedBox(width: 8),
            Text(
              DateFormat('MMM dd, yyyy').format(date),
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}

class TaskItem extends StatefulWidget {
  final Task task;
  final VoidCallback onToggle;
  final VoidCallback? onDelete; // Added callback

  const TaskItem({
    super.key, 
    required this.task, 
    required this.onToggle,
    this.onDelete,
  });

  @override
  State<TaskItem> createState() => _TaskItemState();
}

class _TaskItemState extends State<TaskItem> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      child: Stack(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: widget.task.isCompleted 
                    ? Theme.of(context).colorScheme.primary.withOpacity(0.5) 
                    : Colors.white.withOpacity(0.1),
              ),
              color: widget.task.isCompleted 
                  ? Theme.of(context).colorScheme.primary.withOpacity(0.05) 
                  : Colors.transparent,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.task.title,
                        style: TextStyle(
                          fontSize: 14,
                          decoration: widget.task.isCompleted ? TextDecoration.lineThrough : null,
                          color: widget.task.isCompleted ? Colors.white.withOpacity(0.5) : Colors.white,
                        ),
                      ),
                      if (widget.task.description.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Text(
                            widget.task.description,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white.withOpacity(0.3),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                
                // Priority Indicator (Small dot)
                if (!widget.task.isCompleted)
                   Container(
                    margin: const EdgeInsets.only(right: 8),
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _getPriorityColor(widget.task.priority),
                    ),
                   ),
              ],
            ),
          ),
          
          // Sliding Delete Button
          Positioned(
            right: 0,
            top: 0,
            bottom: 12, // Match margin of container
            child: ClipRRect(
              borderRadius: const BorderRadius.horizontal(right: Radius.circular(30)),
              child: AnimatedSlide(
                offset: _isHovering ? Offset.zero : const Offset(1.0, 0.0),
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                child: Container(
                  width: 60,
                  height: double.infinity,
                  decoration: BoxDecoration(
                     color: Colors.red.withOpacity(0.8),
                     borderRadius: const BorderRadius.horizontal(right: Radius.circular(30)),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.white),
                    onPressed: widget.onDelete,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getPriorityColor(int priority) {
    if (priority >= 8) return Colors.redAccent;
    if (priority >= 5) return Colors.orangeAccent;
    return Colors.greenAccent;
  }
}
