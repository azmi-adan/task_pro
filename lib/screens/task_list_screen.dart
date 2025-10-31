import 'package:flutter/material.dart';
import 'package:learning_app/screens/home_screen.dart';
import 'task_detail_screen.dart';

class TaskListScreen extends StatefulWidget {
  final List<Task> tasks;
  final String title;
  final Map<String, dynamic> user;
  final Function onTaskUpdated;

  const TaskListScreen({
    super.key,
    required this.tasks,
    required this.title,
    required this.user,
    required this.onTaskUpdated,
  });

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  List<Task> get _filteredTasks {
    List<Task> filtered = widget.tasks;

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((task) {
        return task.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            task.description.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }

    // Apply priority filter
    if (_selectedPriority != null) {
      filtered = filtered
          .where((task) => task.priority == _selectedPriority)
          .toList();
    }

    return filtered;
  }

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  Priority? _selectedPriority;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.home),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search and Filter Section
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search tasks...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _searchQuery = '';
                              });
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                ),
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildPriorityFilter('All', null),
                      const SizedBox(width: 8),
                      _buildPriorityFilter('High', Priority.high),
                      const SizedBox(width: 8),
                      _buildPriorityFilter('Medium', Priority.medium),
                      const SizedBox(width: 8),
                      _buildPriorityFilter('Low', Priority.low),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Tasks List
          Expanded(
            child: _filteredTasks.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.task_outlined, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'No tasks found',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: _filteredTasks.length,
                    itemBuilder: (context, index) {
                      final task = _filteredTasks[index];
                      return _buildTaskCard(task);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriorityFilter(String label, Priority? priority) {
    final isSelected = _selectedPriority == priority;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedPriority = selected ? priority : null;
        });
      },
      backgroundColor: isSelected ? Colors.blue : Colors.grey.shade200,
      labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black),
    );
  }

  Widget _buildTaskCard(Task task) {
    final isDueSoon = task.dueDate.difference(DateTime.now()).inDays <= 1;
    final priorityColor = _getPriorityColor(task.priority);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: priorityColor.withValues(alpha: 0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(
            _getPriorityIcon(task.priority),
            color: priorityColor,
            size: 20,
          ),
        ),
        title: Text(
          task.title,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            decoration: task.isCompleted ? TextDecoration.lineThrough : null,
            color: task.isCompleted ? Colors.grey : Colors.black,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              task.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                decoration: task.isCompleted
                    ? TextDecoration.lineThrough
                    : null,
                color: task.isCompleted ? Colors.grey : Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 12,
                  color: isDueSoon ? Colors.red : Colors.grey.shade600,
                ),
                const SizedBox(width: 4),
                Text(
                  'Due: ${_formatDate(task.dueDate)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDueSoon ? Colors.red : Colors.grey.shade600,
                    fontWeight: isDueSoon ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: task.isCompleted
            ? const Icon(Icons.check_circle, color: Colors.green)
            : const Icon(Icons.radio_button_unchecked, color: Colors.grey),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TaskDetailScreen(
                task: task,
                userId: widget.user['id'],
                onTaskUpdated: widget.onTaskUpdated,
              ),
            ),
          );
        },
      ),
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

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
