import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/todo_bloc.dart';
import '../bloc/todo_event.dart';
import '../models/todo.dart';

class TodoItem extends StatefulWidget {
  final Todo todo;
  final int index;

  const TodoItem({
    Key? key,
    required this.todo,
    required this.index,
  }) : super(key: key);

  @override
  State<TodoItem> createState() => _TodoItemState();
}

class _TodoItemState extends State<TodoItem> with TickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _fadeAnimation;
  late final AnimationController _completionController;
  late final Animation<double> _strikeThrough;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _completionController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutQuart,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );

    _strikeThrough = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _completionController,
      curve: Curves.easeInOut,
    ));

    Future.delayed(Duration(milliseconds: 100 * widget.index), () {
      _controller.forward();
    });

    if (widget.todo.isCompleted) {
      _completionController.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(TodoItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.todo.isCompleted != oldWidget.todo.isCompleted) {
      if (widget.todo.isCompleted) {
        _completionController.forward();
      } else {
        _completionController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _completionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final completedColor = Colors.green.shade500;

    return ScaleTransition(
      scale: _scaleAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Dismissible(
          key: Key(widget.todo.id),
          background: Container(
            decoration: BoxDecoration(
              color: Colors.red.shade400,
              borderRadius: BorderRadius.circular(16),
            ),
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            padding: const EdgeInsets.only(right: 16.0),
            alignment: Alignment.centerRight,
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Icon(Icons.delete, color: Colors.white),
                SizedBox(width: 8),
                Text(
                  'Delete',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          direction: DismissDirection.endToStart,
          confirmDismiss: (direction) async {
            return await showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text('Delete Task'),
                  content: const Text('Are you sure you want to delete this task?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('CANCEL'),
                    ),
                    TextButton(
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.red,
                      ),
                      onPressed: () => Navigator.of(context).pop(true),
                      child: const Text('DELETE'),
                    ),
                  ],
                );
              },
            );
          },
          onDismissed: (direction) {
            final todoBloc = context.read<TodoBloc>();
            final deletedTodo = widget.todo;
            
            todoBloc.add(DeleteTodo(widget.todo));
            
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Task deleted'),
                action: SnackBarAction(
                  label: 'UNDO',
                  onPressed: () {
                    todoBloc.add(AddTodo(deletedTodo.title));
                  },
                ),
              ),
            );
          },
          child: Card(
            elevation: widget.todo.isCompleted ? 1 : 2,
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: InkWell(
              onTap: () => _showEditDialog(context),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    _buildCheckbox(theme),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Stack(
                        children: [
                          Text(
                            widget.todo.title,
                            style: TextStyle(
                              fontSize: 16,
                              color: widget.todo.isCompleted 
                                  ? completedColor.withOpacity(0.7)
                                  : theme.colorScheme.onSurface,
                            ),
                          ),
                          AnimatedBuilder(
                            animation: _strikeThrough,
                            builder: (context, child) {
                              return CustomPaint(
                                painter: StrikeThroughPainter(
                                  progress: _strikeThrough.value,
                                  color: completedColor.withOpacity(0.7),
                                ),
                                child: Text(
                                  widget.todo.title,
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Color.lerp(
                                      theme.colorScheme.onSurface,
                                      completedColor.withOpacity(0.7),
                                      _strikeThrough.value,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () => _confirmDelete(context),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCheckbox(ThemeData theme) {
    final completedColor = Colors.green.shade500;
    
    return GestureDetector(
      onTap: () => context.read<TodoBloc>().add(ToggleTodo(widget.todo)),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: widget.todo.isCompleted 
                ? completedColor
                : theme.colorScheme.outline,
            width: 2,
          ),
          color: widget.todo.isCompleted 
              ? completedColor
              : Colors.transparent,
          boxShadow: widget.todo.isCompleted
              ? [
                  BoxShadow(
                    color: completedColor.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: AnimatedScale(
            scale: widget.todo.isCompleted ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            child: Icon(
              Icons.check,
              size: 16,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final delete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Task'),
          content: const Text('Are you sure you want to delete this task?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('CANCEL'),
            ),
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('DELETE'),
            ),
          ],
        );
      },
    );
    
    if (delete == true && context.mounted) {
      final todoBloc = context.read<TodoBloc>();
      final deletedTodo = widget.todo;
      
      todoBloc.add(DeleteTodo(widget.todo));
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Task deleted'),
            action: SnackBarAction(
              label: 'UNDO',
              onPressed: () {
                todoBloc.add(AddTodo(deletedTodo.title));
              },
            ),
          ),
        );
      }
    }
  }

  void _showEditDialog(BuildContext context) {
    final textController = TextEditingController(text: widget.todo.title);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Todo'),
        content: TextField(
          controller: textController,
          decoration: const InputDecoration(
            labelText: 'Title',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL'),
          ),
          FilledButton(
            onPressed: () {
              if (textController.text.isNotEmpty) {
                final updatedTodo = widget.todo.copyWith(
                  title: textController.text,
                );
                context.read<TodoBloc>().add(UpdateTodo(updatedTodo));
                Navigator.pop(context);
              }
            },
            child: const Text('SAVE'),
          ),
        ],
      ),
    );
  }
}

class StrikeThroughPainter extends CustomPainter {
  final double progress;
  final Color color;

  StrikeThroughPainter({
    required this.progress,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final path = Path()
      ..moveTo(0, size.height / 2)
      ..lineTo(size.width * progress, size.height / 2);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(StrikeThroughPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
} 