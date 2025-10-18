// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'task_list_screen.dart';
import 'task_detail_screen.dart';

class Task {
  final String id;
  final String title;
  final String description;
  final DateTime dueDate;
  final Priority priority;
  final bool isCompleted;

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.dueDate,
    required this.priority,
    this.isCompleted = false,
  });

  Task copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? dueDate,
    Priority? priority,
    bool? isCompleted,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      priority: priority ?? this.priority,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}

enum Priority { high, medium, low }

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final List<Task> _tasks = [
    Task(
      id: '1',
      title: 'Web Design Assignment',
      description: 'Complete the responsive design project',
      dueDate: DateTime.now().add(const Duration(days: 2)),
      priority: Priority.high,
    ),
    Task(
      id: '2',
      title: 'Team Meeting',
      description: 'Weekly team sync meeting',
      dueDate: DateTime.now().add(const Duration(hours: 5)),
      priority: Priority.medium,
    ),
    Task(
      id: '3',
      title: 'Buy Groceries',
      description: 'Milk, Eggs, Bread, Fruits',
      dueDate: DateTime.now().add(const Duration(days: 1)),
      priority: Priority.low,
    ),
    Task(
      id: '4',
      title: 'Flutter Project Submission',
      description: 'Submit the TaskPro app project',
      dueDate: DateTime.now().add(const Duration(days: 7)),
      priority: Priority.high,
      isCompleted: true,
    ),
  ];

  List<Task> get _pendingTasks =>
      _tasks.where((task) => !task.isCompleted).toList();

  List<Task> get _completedTasks =>
      _tasks.where((task) => task.isCompleted).toList();

  List<Task> get _highPriorityTasks => _tasks
      .where((task) => task.priority == Priority.high && !task.isCompleted)
      .toList();

  List<Task> get _mediumPriorityTasks => _tasks
      .where((task) => task.priority == Priority.medium && !task.isCompleted)
      .toList();

  List<Task> get _lowPriorityTasks => _tasks
      .where((task) => task.priority == Priority.low && !task.isCompleted)
      .toList();

  void _onTaskToggle(Task task) {
    setState(() {
      final index = _tasks.indexWhere((t) => t.id == task.id);
      if (index != -1) {
        _tasks[index] = task.copyWith(isCompleted: !task.isCompleted);
      }
    });
  }

  void _onTaskTap(Task task) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TaskDetailScreen(
          task: task,
          onTaskUpdated: (updatedTask) {
            setState(() {
              final index = _tasks.indexWhere((t) => t.id == updatedTask.id);
              if (index != -1) {
                _tasks[index] = updatedTask;
              }
            });
          },
        ),
      ),
    );
  }

  void _addNewTask() async {
    final newTask = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TaskDetailScreen(
          task: null,
          onTaskUpdated: (task) => task,
        ),
      ),
    );

    if (newTask != null && newTask is Task) {
      setState(() {
        _tasks.add(newTask);
      });
    }
  }

  Widget _buildTaskCard(Task task) {
    final isDueSoon = task.dueDate.difference(DateTime.now()).inDays <= 1;
    final priorityColor = _getPriorityColor(task.priority);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
      child: ListTile(
        leading: Checkbox(
          value: task.isCompleted,
          onChanged: (value) => _onTaskToggle(task),
        ),
        title: Text(
          task.title,
          style: TextStyle(
            decoration: task.isCompleted ? TextDecoration.lineThrough : null,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              task.description,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 12,
                  color: Colors.grey.shade600,
                ),
                const SizedBox(width: 4),
                Text(
                  'Due: ${_formatDate(task.dueDate)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDueSoon ? Colors.red : Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: priorityColor,
            shape: BoxShape.circle,
          ),
        ),
        onTap: () => _onTaskTap(task),
      ),
    );
  }

  Widget _buildPrioritySection(String title, List<Task> tasks, Color color) {
    if (tasks.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '$title (${tasks.length})',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ),
        ...tasks.map((task) => _buildTaskCard(task)).toList(),
        const SizedBox(height: 8),
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

  Widget _buildStatsCard(String title, int count, Color color) {
    return Expanded(
      child: Card(
        color: color.withOpacity(0.1),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Text(
                count.toString(),
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: TextStyle(
                  color: color,
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TaskPro'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Search functionality
            },
          ),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          // All Tasks Tab
          Column(
            children: [
              // Stats Section
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    _buildStatsCard('Pending', _pendingTasks.length, Colors.orange),
                    const SizedBox(width: 12),
                    _buildStatsCard('Completed', _completedTasks.length, Colors.green),
                    const SizedBox(width: 12),
                    _buildStatsCard('High Priority', _highPriorityTasks.length, Colors.red),
                  ],
                ),
              ),
              // Tasks List
              Expanded(
                child: ListView.builder(
                  itemCount: _tasks.length,
                  itemBuilder: (context, index) {
                    return _buildTaskCard(_tasks[index]);
                  },
                ),
              ),
            ],
          ),
          // Completed Tasks Tab
          _completedTasks.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_circle_outline, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'No completed tasks yet',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: _completedTasks.length,
                  itemBuilder: (context, index) {
                    return _buildTaskCard(_completedTasks[index]);
                  },
                ),
          // All Priorities Tab
          Column(
            children: [
              // Stats Section for Priorities
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    _buildStatsCard('High', _highPriorityTasks.length, Colors.red),
                    const SizedBox(width: 12),
                    _buildStatsCard('Medium', _mediumPriorityTasks.length, Colors.orange),
                    const SizedBox(width: 12),
                    _buildStatsCard('Low', _lowPriorityTasks.length, Colors.green),
                  ],
                ),
              ),
              // Priority Sections
              Expanded(
                child: ListView(
                  children: [
                    _buildPrioritySection('High Priority', _highPriorityTasks, Colors.red),
                    _buildPrioritySection('Medium Priority', _mediumPriorityTasks, Colors.orange),
                    _buildPrioritySection('Low Priority', _lowPriorityTasks, Colors.green),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addNewTask,
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'All Tasks',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.check_circle),
            label: 'Completed',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.filter_list),
            label: 'Priorities',
          ),
        ],
      ),
    );
  }
}