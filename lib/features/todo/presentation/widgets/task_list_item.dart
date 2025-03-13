import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/models/task_model.dart';

class TaskListItem extends StatelessWidget {
  final Task task;
  final VoidCallback onTap;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  const TaskListItem({
    Key? key,
    required this.task,
    required this.onTap,
    required this.onToggle,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(task.id),
      background: Container(
        decoration: BoxDecoration(
          color: Colors.red.shade400,
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: const Icon(
          Icons.delete_outline,
          color: Colors.white,
          size: 28,
        ),
      ),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDelete(),
      child: Card(
        elevation: 3,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: [
                _getPriorityColor().withOpacity(0.05),
                Colors.white,
              ],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
              child: Row(
                children: [
                  // Checkbox with custom design
                  Transform.scale(
                    scale: 1.2,
                    child: Checkbox(
                      value: task.isCompleted,
                      onChanged: (_) => onToggle(),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                      activeColor: Colors.green,
                      checkColor: Colors.white,
                      side: BorderSide(
                        color: _getPriorityColor(),
                        width: 2,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Task details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                task.title,
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                  decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                                  color: task.isCompleted ? Colors.grey : Colors.black87,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            _buildPriorityBadge(),
                          ],
                        ),
                        if (task.description.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Text(
                            task.description,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 14,
                            ),
                          ),
                        ],
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: _getDateBackgroundColor(),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    _getDateIcon(),
                                    size: 14,
                                    color: _getDateTextColor(),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    _formatDateTime(task.dueDate),
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: _getDateTextColor(),
                                      fontWeight: _isOverdue() ? FontWeight.bold : FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Spacer(),
                            _buildTimeIndicator(),
                          ],
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
    );
  }

  Widget _buildPriorityBadge() {
    Color color = _getPriorityColor();
    String label;
    IconData icon;

    switch (task.priority) {
      case 1:
        label = 'Low';
        icon = Icons.arrow_downward;
        break;
      case 2:
        label = 'Med';
        icon = Icons.remove;
        break;
      case 3:
        label = 'High';
        icon = Icons.arrow_upward;
        break;
      default:
        label = 'None';
        icon = Icons.remove;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 12,
            color: color,
          ),
          const SizedBox(width: 2),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeIndicator() {
    if (task.isCompleted) {
      return Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.green.withOpacity(0.2),
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.check,
          color: Colors.green,
          size: 16,
        ),
      );
    }

    final now = DateTime.now();
    final difference = task.dueDate.difference(now);
    
    // Overdue
    if (difference.isNegative) {
      return Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.2),
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.warning,
          color: Colors.red,
          size: 16,
        ),
      );
    }

    if (difference.inDays == 0) {
      if (difference.inHours < 1) {
        return Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.orange.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Text(
            '${difference.inMinutes}m',
            style: const TextStyle(
              color: Colors.orange,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      }
      
      return Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.orange.withOpacity(0.2),
          shape: BoxShape.circle,
        ),
        child: Text(
          '${difference.inHours}h',
          style: const TextStyle(
            color: Colors.orange,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }
    
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.2),
        shape: BoxShape.circle,
      ),
      child: Text(
        '${difference.inDays}d',
        style: TextStyle(
          color: Colors.blue[700],
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Color _getPriorityColor() {
    switch (task.priority) {
      case 1:
        return Colors.green;
      case 2:
        return Colors.orange;
      case 3:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _formatDateTime(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final dateToCheck = DateTime(date.year, date.month, date.day);
    
    if (dateToCheck == today) {
      return 'Today, ${DateFormat('h:mm a').format(date)}';
    } else if (dateToCheck == tomorrow) {
      return 'Tomorrow, ${DateFormat('h:mm a').format(date)}';
    } else {
      return DateFormat('MMM d, h:mm a').format(date);
    }
  }

  bool _isOverdue() {
    return !task.isCompleted && task.dueDate.isBefore(DateTime.now());
  }
  
  Color _getDateBackgroundColor() {
    if (task.isCompleted) {
      return Colors.grey.withOpacity(0.2);
    }
    
    if (_isOverdue()) {
      return Colors.red.withOpacity(0.2);
    }
    
    final now = DateTime.now();
    final difference = task.dueDate.difference(now);
    
    if (difference.inDays == 0) {
      return Colors.orange.withOpacity(0.2);
    }
    
    return Colors.blue.withOpacity(0.2);
  }
  
  Color _getDateTextColor() {
    if (task.isCompleted) {
      return Colors.grey;
    }
    
    if (_isOverdue()) {
      return Colors.red;
    }
    
    final now = DateTime.now();
    final difference = task.dueDate.difference(now);
    
    if (difference.inDays == 0) {
      return Colors.orange;
    }
    
    return Colors.blue;
  }
  
  IconData _getDateIcon() {
    if (task.isCompleted) {
      return Icons.event_available;
    }
    
    if (_isOverdue()) {
      return Icons.event_busy;
    }
    
    final now = DateTime.now();
    final difference = task.dueDate.difference(now);
    
    if (difference.inDays == 0) {
      return Icons.access_time;
    }
    
    return Icons.event;
  }
}