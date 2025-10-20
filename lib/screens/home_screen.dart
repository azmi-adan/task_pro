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

  // Search related variables
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  List<Task> _searchResults = [];

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

  // Search functionality
  void _performSearch(String query) {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
      _searchResults = _tasks.where((task) {
        final titleMatch = task.title.toLowerCase().contains(query.toLowerCase());
        final descriptionMatch = task.description.toLowerCase().contains(query.toLowerCase());
        final priorityMatch = _getPriorityText(task.priority).toLowerCase().contains(query.toLowerCase());
        
        return titleMatch || descriptionMatch || priorityMatch;
      }).toList();
    });
  }

  void _clearSearch() {
    setState(() {
      _searchController.clear();
      _searchResults = [];
      _isSearching = false;
    });
  }

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
    final daysUntilDue = task.dueDate.difference(DateTime.now()).inDays;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            left: BorderSide(
              color: priorityColor,
              width: 4,
            ),
          ),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: task.isCompleted 
                  ? Colors.green.withOpacity(0.1)
                  : Colors.grey.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Checkbox(
              value: task.isCompleted,
              onChanged: (value) => _onTaskToggle(task),
              shape: const CircleBorder(),
              fillColor: MaterialStateProperty.resolveWith<Color>((states) {
                if (states.contains(MaterialState.selected)) {
                  return Colors.green;
                }
                return Colors.transparent;
              }),
            ),
          ),
          title: Text(
            task.title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              decoration: task.isCompleted ? TextDecoration.lineThrough : null,
              color: task.isCompleted ? Colors.grey : Colors.black87,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text(
                task.description,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: _getPriorityColor(task.priority).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      _getPriorityText(task.priority).split(' ')[0],
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: _getPriorityColor(task.priority),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.calendar_today,
                    size: 12,
                    color: isDueSoon ? Colors.red : Colors.grey.shade600,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    daysUntilDue == 0 
                        ? 'Today' 
                        : daysUntilDue == 1 
                            ? 'Tomorrow' 
                            : '$daysUntilDue days left',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: isDueSoon ? Colors.red : Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ],
          ),
          trailing: task.isCompleted
              ? Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check, size: 12, color: Colors.green),
                      const SizedBox(width: 4),
                      Text(
                        'Done',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                )
              : null,
          onTap: () => _onTaskTap(task),
        ),
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
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.05),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color.withOpacity(0.2)),
          ),
          child: Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  tasks.length.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
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
        return const Color(0xFFFF4757);
      case Priority.medium:
        return const Color(0xFFFFA502);
      case Priority.low:
        return const Color(0xFF2ED573);
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

  Widget _buildStatsCard(String title, int count, Color color, IconData icon) {
    return Expanded(
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color.withOpacity(0.1),
                color.withOpacity(0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, size: 20, color: color),
                ),
                const SizedBox(height: 12),
                Text(
                  count.toString(),
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(String message, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 48, color: Colors.grey.shade400),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    if (_searchResults.isEmpty && _searchController.text.isNotEmpty) {
      return _buildEmptyState('No tasks found for "${_searchController.text}"', Icons.search_off);
    }

    return ListView.builder(
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        return _buildTaskCard(_searchResults[index]);
      },
    );
  }

  Widget _buildNormalContent() {
    switch (_currentIndex) {
      case 0: // All Tasks Tab
        return Column(
          children: [
            // Stats Section
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  _buildStatsCard('Pending', _pendingTasks.length, 
                      const Color(0xFFFFA502), Icons.pending_actions),
                  const SizedBox(width: 12),
                  _buildStatsCard('Completed', _completedTasks.length, 
                      const Color(0xFF2ED573), Icons.check_circle),
                  const SizedBox(width: 12),
                  _buildStatsCard('High Priority', _highPriorityTasks.length, 
                      const Color(0xFFFF4757), Icons.flag),
                ],
              ),
            ),
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Text(
                    'All Tasks (${_tasks.length})',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${_pendingTasks.length} pending',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            // Tasks List
            Expanded(
              child: _tasks.isEmpty
                  ? _buildEmptyState('No tasks yet', Icons.task_alt)
                  : ListView.builder(
                      itemCount: _tasks.length,
                      itemBuilder: (context, index) {
                        return _buildTaskCard(_tasks[index]);
                      },
                    ),
            ),
          ],
        );
      
      case 1: // Completed Tasks Tab
        return _completedTasks.isEmpty
            ? _buildEmptyState('No completed tasks yet', Icons.check_circle_outline)
            : Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Text(
                          'Completed Tasks (${_completedTasks.length})',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _completedTasks.length,
                      itemBuilder: (context, index) {
                        return _buildTaskCard(_completedTasks[index]);
                      },
                    ),
                  ),
                ],
              );
      
      case 2: // Priorities Tab
        return Column(
          children: [
            // Stats Section for Priorities
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  _buildStatsCard('High', _highPriorityTasks.length, 
                      const Color(0xFFFF4757), Icons.flag),
                  const SizedBox(width: 12),
                  _buildStatsCard('Medium', _mediumPriorityTasks.length, 
                      const Color(0xFFFFA502), Icons.outlined_flag),
                  const SizedBox(width: 12),
                  _buildStatsCard('Low', _lowPriorityTasks.length, 
                      const Color(0xFF2ED573), Icons.flag_outlined),
                ],
              ),
            ),
            // Priority Sections
            Expanded(
              child: _pendingTasks.isEmpty
                  ? _buildEmptyState('No pending tasks', Icons.flag)
                  : ListView(
                      children: [
                        _buildPrioritySection('High Priority', _highPriorityTasks, const Color(0xFFFF4757)),
                        _buildPrioritySection('Medium Priority', _mediumPriorityTasks, const Color(0xFFFFA502)),
                        _buildPrioritySection('Low Priority', _lowPriorityTasks, const Color(0xFF2ED573)),
                      ],
                    ),
            ),
          ],
        );
      
      default:
        return const SizedBox();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Search tasks...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Colors.grey.shade600),
                ),
                style: const TextStyle(fontSize: 16),
                onChanged: _performSearch,
              )
            : const Text(
                'TaskPro',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 20,
                ),
              ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        centerTitle: false,
        actions: [
          if (_isSearching)
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: _clearSearch,
            )
          else
            IconButton(
              icon: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.search, size: 20),
              ),
              onPressed: () {
                setState(() {
                  _isSearching = true;
                });
              },
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: _isSearching ? _buildSearchResults() : _buildNormalContent(),
      floatingActionButton: _isSearching ? null : FloatingActionButton(
        onPressed: _addNewTask,
        backgroundColor: const Color(0xFF2D5AFF),
        foregroundColor: Colors.white,
        elevation: 4,
        child: const Icon(Icons.add, size: 24),
      ),
      bottomNavigationBar: _isSearching ? null : Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          ),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) => setState(() => _currentIndex = index),
            backgroundColor: Colors.white,
            selectedItemColor: const Color(0xFF2D5AFF),
            unselectedItemColor: Colors.grey.shade600,
            selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
            type: BottomNavigationBarType.fixed,
            elevation: 0,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.dashboard),
                label: 'Overview',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.check_circle),
                label: 'Completed',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.filter_alt),
                label: 'Priorities',
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}