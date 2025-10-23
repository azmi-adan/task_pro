// lib/screens/task_detail_screen.dart - FIXED VERSION
import 'package:flutter/material.dart';
import '../services/task_service.dart';
import '../screens/home_screen.dart';

class TaskDetailScreen extends StatefulWidget {
  final Task? task;
  final int userId;
  final Function onTaskUpdated;

  const TaskDetailScreen({
    super.key,
    required this.task,
    required this.userId,
    required this.onTaskUpdated,
  });

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  Priority _selectedPriority = Priority.medium;
  bool _isEditing = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.task != null) {
      _titleController.text = widget.task!.title;
      _descriptionController.text = widget.task!.description;
      _selectedDate = widget.task!.dueDate;
      _selectedPriority = widget.task!.priority;
    } else {
      _isEditing = true;
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  // SAFE ID PARSING - FIXED
  dynamic _parseTaskId(dynamic taskId) {
    print('🔧 Parsing task ID: $taskId (type: ${taskId.runtimeType})');
    if (taskId is int) return taskId;
    if (taskId is String) {
      final parsed = int.tryParse(taskId);
      return parsed ?? taskId; // Return original if parsing fails
    }
    return taskId;
  }

  Future<void> _saveTask() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      final taskData = {
        'userId': widget.userId, // Already an int
        'title': _titleController.text,
        'description': _descriptionController.text,
        'dueDate': _selectedDate.toIso8601String(),
        'priority': _priorityToString(_selectedPriority),
        'isCompleted': widget.task?.isCompleted ?? false,
      };

      Map<String, dynamic> result;
      if (widget.task == null) {
        // Create new task
        result = await TaskService.createTask(taskData);
      } else {
        // Update existing task - USE SAFE PARSING
        final safeId = _parseTaskId(widget.task!.id);
        print('🔄 Updating task with ID: $safeId (type: ${safeId.runtimeType})');
        result = await TaskService.updateTask(safeId, taskData);
      }

      setState(() => _isLoading = false);

      if (result['success'] == true) {
        widget.onTaskUpdated();
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Failed to save task'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _deleteTask() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Task'),
          content: const Text('Are you sure you want to delete this task?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context); // Close dialog
                setState(() => _isLoading = true);

                // USE SAFE PARSING
                final safeId = _parseTaskId(widget.task!.id);
                print('🗑️ Deleting task with ID: $safeId (type: ${safeId.runtimeType})');
                final result = await TaskService.deleteTask(safeId);
                
                setState(() => _isLoading = false);

                if (result['success'] == true) {
                  widget.onTaskUpdated();
                  Navigator.pop(context); // Go back to home
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Task deleted successfully')),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(result['message'] ?? 'Failed to delete task'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _toggleCompletion() async {
    setState(() => _isLoading = true);

    // USE SAFE PARSING
    final safeId = _parseTaskId(widget.task!.id);
    print('🔄 Toggling task with ID: $safeId (type: ${safeId.runtimeType})');
    final result = await TaskService.toggleTaskCompletion(
      safeId, 
      !widget.task!.isCompleted,
    );

    setState(() => _isLoading = false);

    if (result['success'] == true) {
      widget.onTaskUpdated();
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Failed to update task'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String _priorityToString(Priority priority) {
    switch (priority) {
      case Priority.high: return 'high';
      case Priority.medium: return 'medium';
      case Priority.low: return 'low';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isNewTask = widget.task == null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isNewTask ? 'Add New Task' : 'Task Details'),
        actions: [
          if (!isNewTask && !_isEditing)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => setState(() => _isEditing = true),
            ),
          if (_isEditing || isNewTask)
            IconButton(
              icon: _isLoading 
                  ? const CircularProgressIndicator()
                  : const Icon(Icons.save),
              onPressed: _isLoading ? null : _saveTask,
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (!_isEditing && !isNewTask) ...[
                      // View Mode
                      _buildDetailSection(),
                      const SizedBox(height: 24),
                      _buildActionButtons(),
                    ] else ...[
                      // Edit Mode
                      _buildEditForm(),
                    ],
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildDetailSection() {
    final task = widget.task!;
    final priorityColor = _getPriorityColor(task.priority);
    final isDueSoon = task.dueDate.difference(DateTime.now()).inDays <= 1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Priority Badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: priorityColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: priorityColor),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _getPriorityIcon(task.priority),
                size: 16,
                color: priorityColor,
              ),
              const SizedBox(width: 4),
              Text(
                _getPriorityText(task.priority),
                style: TextStyle(
                  color: priorityColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Title
        Text(
          task.title,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        // Description
        Text(
          'Description',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          task.description,
          style: const TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 24),
        // Due Date
        Row(
          children: [
            Icon(
              Icons.calendar_today,
              color: Colors.grey.shade600,
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Due Date',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 14,
                  ),
                ),
                Text(
                  _formatDate(task.dueDate),
                  style: TextStyle(
                    fontSize: 16,
                    color: isDueSoon ? Colors.red : Colors.black,
                    fontWeight: isDueSoon ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Status
        Row(
          children: [
            Icon(
              task.isCompleted ? Icons.check_circle : Icons.pending_actions,
              color: task.isCompleted ? Colors.green : Colors.orange,
            ),
            const SizedBox(width: 8),
            Text(
              task.isCompleted ? 'Completed' : 'Pending',
              style: TextStyle(
                color: task.isCompleted ? Colors.green : Colors.orange,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _isLoading ? null : _toggleCompletion,
            icon: Icon(
              widget.task!.isCompleted ? Icons.refresh : Icons.check_circle,
            ),
            label: Text(
              widget.task!.isCompleted ? 'Mark as Pending' : 'Mark as Completed',
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: widget.task!.isCompleted ? Colors.orange : Colors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _isLoading ? null : _deleteTask,
            icon: const Icon(Icons.delete, color: Colors.red),
            label: const Text(
              'Delete Task',
              style: TextStyle(color: Colors.red),
            ),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              side: const BorderSide(color: Colors.red),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEditForm() {
    return Column(
      children: [
        TextFormField(
          controller: _titleController,
          decoration: const InputDecoration(
            labelText: 'Task Title',
            border: OutlineInputBorder(),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter a task title';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _descriptionController,
          decoration: const InputDecoration(
            labelText: 'Description',
            border: OutlineInputBorder(),
            alignLabelWithHint: true,
          ),
          maxLines: 4,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter a task description';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        // Due Date Picker
        InkWell(
          onTap: () => _selectDate(context),
          child: InputDecorator(
            decoration: const InputDecoration(
              labelText: 'Due Date',
              border: OutlineInputBorder(),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(_formatDate(_selectedDate)),
                const Icon(Icons.calendar_today),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Priority Selector
        InputDecorator(
          decoration: const InputDecoration(
            labelText: 'Priority',
            border: OutlineInputBorder(),
          ),
          child: DropdownButton<Priority>(
            value: _selectedPriority,
            isExpanded: true,
            underline: const SizedBox(),
            onChanged: (Priority? newValue) {
              setState(() {
                _selectedPriority = newValue!;
              });
            },
            items: Priority.values.map((Priority priority) {
              return DropdownMenuItem<Priority>(
                value: priority,
                child: Row(
                  children: [
                    Icon(
                      _getPriorityIcon(priority),
                      color: _getPriorityColor(priority),
                    ),
                    const SizedBox(width: 8),
                    Text(_getPriorityText(priority)),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _saveTask,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: _isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text(
                    'Save Task',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
          ),
        ),
        if (!_isEditing && widget.task != null) ...[
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () => setState(() => _isEditing = false),
              child: const Text('Cancel'),
            ),
          ),
        ],
      ],
    );
  }

  Color _getPriorityColor(Priority priority) {
    switch (priority) {
      case Priority.high:
        return Colors.red;
      case Priority.medium:
        return Colors.orange;
      case Priority.low:
        return Colors.green;
    }
  }

  IconData _getPriorityIcon(Priority priority) {
    switch (priority) {
      case Priority.high:
        return Icons.flag;
      case Priority.medium:
        return Icons.outlined_flag;
      case Priority.low:
        return Icons.flag_outlined;
    }
  }

  String _getPriorityText(Priority priority) {
    switch (priority) {
      case Priority.high:
        return 'High Priority';
      case Priority.medium:
        return 'Medium Priority';
      case Priority.low:
        return 'Low Priority';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}