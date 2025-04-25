import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/todo_bloc.dart';
import '../bloc/todo_event.dart';
import '../bloc/todo_state.dart';
import '../models/todo.dart';
import '../theme/theme_provider.dart';
import '../widgets/todo_item.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: TweenAnimationBuilder<double>(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOutCubic,
          tween: Tween<double>(begin: 0, end: 1),
          builder: (context, value, child) => Transform.translate(
            offset: Offset(0, 8 * (1 - value)),
            child: Opacity(
              opacity: value,
              child: child,
            ),
          ),
          child: const Text(
            'My Tasks',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeOutCubic,
              tween: Tween<double>(begin: 0, end: 1),
              builder: (context, value, child) => Transform.translate(
                offset: Offset(-8 * (1 - value), 0),
                child: Opacity(
                  opacity: value,
                  child: child,
                ),
              ),
              child: IconButton(
                icon: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: (Widget child, Animation<double> animation) {
                    return RotationTransition(
                      turns: animation,
                      child: ScaleTransition(
                        scale: Tween<double>(
                          begin: 0.5,
                          end: 1.0,
                        ).animate(CurvedAnimation(
                          parent: animation,
                          curve: Curves.easeOutBack,
                        )),
                        child: FadeTransition(
                          opacity: animation,
                          child: child,
                        ),
                      ),
                    );
                  },
                  child: Icon(
                    context.watch<ThemeCubit>().state == ThemeMode.light
                        ? Icons.dark_mode
                        : Icons.light_mode,
                    key: ValueKey(context.watch<ThemeCubit>().state),
                  ),
                ),
                tooltip: 'Toggle theme',
                onPressed: () => context.read<ThemeCubit>().toggleTheme(),
              ),
            ),
          ),
        ],
      ),
      body: BlocBuilder<TodoBloc, TodoState>(
        builder: (context, state) {
          if (state is TodoLoading) {
            return Center(
              child: TweenAnimationBuilder<double>(
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeOutCubic,
                tween: Tween<double>(begin: 0, end: 1),
                builder: (context, value, child) => Transform.scale(
                  scale: 0.8 + (0.2 * value),
                  child: Opacity(
                    opacity: value,
                    child: child,
                  ),
                ),
                child: const CircularProgressIndicator(),
              ),
            );
          } else if (state is TodoLoaded) {
            return AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              switchInCurve: Curves.easeOutBack,
              switchOutCurve: Curves.easeInBack,
              transitionBuilder: (Widget child, Animation<double> animation) {
                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 0.1),
                      end: Offset.zero,
                    ).animate(animation),
                    child: child,
                  ),
                );
              },
              child: state.todos.isEmpty
                  ? Center(
                      key: const ValueKey('empty'),
                      child: TweenAnimationBuilder<double>(
                        duration: const Duration(milliseconds: 600),
                        curve: Curves.easeOutCubic,
                        tween: Tween<double>(begin: 0, end: 1),
                        builder: (context, value, child) => Transform.scale(
                          scale: 0.8 + (0.2 * value),
                          child: Opacity(
                            opacity: value,
                            child: child,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.task_outlined,
                              size: 100,
                              color: theme.colorScheme.primary.withOpacity(0.2),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No tasks yet!',
                              style: TextStyle(
                                fontSize: 24,
                                color: theme.colorScheme.onBackground,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Tap + to add a new task',
                              style: TextStyle(
                                fontSize: 16,
                                color: theme.colorScheme.onBackground.withOpacity(0.7),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : CustomScrollView(
                      key: const ValueKey('list'),
                      physics: const BouncingScrollPhysics(),
                      slivers: [
                        SliverPadding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          sliver: SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                final todo = state.todos[index];
                                return TweenAnimationBuilder<double>(
                                  key: ValueKey(todo.id),
                                  duration: Duration(milliseconds: 400 + (index * 100)),
                                  curve: Curves.easeOutCubic,
                                  tween: Tween<double>(begin: 0, end: 1),
                                  builder: (context, value, child) => Transform.translate(
                                    offset: Offset(0, 32 * (1 - value)),
                                    child: Opacity(
                                      opacity: value,
                                      child: child,
                                    ),
                                  ),
                                  child: TodoItem(
                                    todo: todo,
                                    index: index,
                                  ),
                                );
                              },
                              childCount: state.todos.length,
                            ),
                          ),
                        ),
                      ],
                    ),
            );
          } else if (state is TodoError) {
            return Center(
              child: TweenAnimationBuilder<double>(
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeOutCubic,
                tween: Tween<double>(begin: 0, end: 1),
                builder: (context, value, child) => Transform.scale(
                  scale: 0.8 + (0.2 * value),
                  child: Opacity(
                    opacity: value,
                    child: child,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 60,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Error: ${state.message}',
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }
          return const SizedBox();
        },
      ),
      floatingActionButton: TweenAnimationBuilder<double>(
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeOutBack,
        tween: Tween<double>(begin: 0, end: 1),
        builder: (context, value, child) => Transform.scale(
          scale: value,
          child: Transform.translate(
            offset: Offset(0, 32 * (1 - value)),
            child: child,
          ),
        ),
        child: FloatingActionButton.extended(
          onPressed: () => _showAddTodoDialog(context),
          label: const Text('Add Task'),
          icon: const Icon(Icons.add),
        ),
      ),
    );
  }

  void _showAddTodoDialog(BuildContext context) {
    final textController = TextEditingController();
    final theme = Theme.of(context);
    bool isComposing = false;

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      barrierColor: theme.colorScheme.scrim.withOpacity(0.5),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) {
        return Container(); // Placeholder, will be replaced
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutBack,
          reverseCurve: Curves.easeInBack,
        );

        return ScaleTransition(
          scale: Tween<double>(begin: 0.8, end: 1.0).animate(curvedAnimation),
          child: FadeTransition(
            opacity: animation,
            child: StatefulBuilder(
              builder: (context, setState) => Dialog(
                backgroundColor: theme.colorScheme.surface,
                surfaceTintColor: theme.colorScheme.surfaceTint,
                insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: 400,
                    minHeight: 200,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          TweenAnimationBuilder<double>(
                            duration: const Duration(milliseconds: 400),
                            curve: Curves.easeOutCubic,
                            tween: Tween<double>(begin: 0, end: 1),
                            builder: (context, value, child) => Transform.scale(
                              scale: 0.8 + (0.2 * value),
                              child: Opacity(
                                opacity: value,
                                child: child,
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.primaryContainer,
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: theme.colorScheme.shadow.withOpacity(0.1),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Icon(
                                    Icons.add_task,
                                    color: theme.colorScheme.onPrimaryContainer,
                                    size: 32,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Add New Task',
                                        style: TextStyle(
                                          fontSize: 28,
                                          fontWeight: FontWeight.bold,
                                          color: theme.colorScheme.onSurface,
                                          letterSpacing: -0.5,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Create a new task to stay organized',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: theme.colorScheme.onSurfaceVariant,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                      
                          const SizedBox(height: 32),
                          TweenAnimationBuilder<double>(
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.easeOutCubic,
                            tween: Tween<double>(begin: 0, end: 1),
                            builder: (context, value, child) => Transform.translate(
                              offset: Offset(0, 16 * (1 - value)),
                              child: Opacity(
                                opacity: value,
                                child: child,
                              ),
                            ),
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: isComposing 
                                      ? theme.colorScheme.primary 
                                      : theme.colorScheme.outline.withOpacity(0.5),
                                  width: isComposing ? 2 : 1,
                                ),
                                color: theme.colorScheme.surfaceVariant.withOpacity(0.1),
                                boxShadow: [
                                  BoxShadow(
                                    color: isComposing
                                        ? theme.colorScheme.primary.withOpacity(0.1)
                                        : theme.colorScheme.shadow.withOpacity(0.05),
                                    blurRadius: isComposing ? 8 : 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Stack(
                                children: [
                                  AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20),
                                      gradient: LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: isComposing
                                            ? [
                                                theme.colorScheme.primary.withOpacity(0.05),
                                                theme.colorScheme.primary.withOpacity(0.02),
                                              ]
                                            : [
                                                theme.colorScheme.surfaceVariant.withOpacity(0.1),
                                                theme.colorScheme.surfaceVariant.withOpacity(0.05),
                                              ],
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                                          child: Row(
                                            children: [
                                              Container(
                                                padding: const EdgeInsets.all(8),
                                                decoration: BoxDecoration(
                                                  color: isComposing
                                                      ? theme.colorScheme.primary.withOpacity(0.1)
                                                      : theme.colorScheme.surfaceVariant.withOpacity(0.3),
                                                  borderRadius: BorderRadius.circular(12),
                                                ),
                                                child: AnimatedSwitcher(
                                                  duration: const Duration(milliseconds: 200),
                                                  transitionBuilder: (child, animation) => ScaleTransition(
                                                    scale: animation,
                                                    child: FadeTransition(
                                                      opacity: animation,
                                                      child: child,
                                                    ),
                                                  ),
                                                  child: Icon(
                                                    isComposing ? Icons.edit : Icons.edit_outlined,
                                                    key: ValueKey(isComposing),
                                                    color: isComposing 
                                                        ? theme.colorScheme.primary 
                                                        : theme.colorScheme.outline,
                                                    size: 20,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 12),
                                              Text(
                                                'Task Details',
                                                style: TextStyle(
                                                  color: isComposing
                                                      ? theme.colorScheme.primary
                                                      : theme.colorScheme.onSurfaceVariant,
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                                          child: TextField(
                                            controller: textController,
                                            decoration: InputDecoration(
                                              hintText: 'What needs to be done?',
                                              hintStyle: TextStyle(
                                                color: theme.colorScheme.onSurfaceVariant.withOpacity(0.7),
                                                fontSize: 16,
                                                height: 1.5,
                                              ),
                                              border: InputBorder.none,
                                              contentPadding: EdgeInsets.zero,
                                              isDense: true,
                                            ),
                                            autofocus: true,
                                            textCapitalization: TextCapitalization.sentences,
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: theme.colorScheme.onSurface,
                                              height: 1.5,
                                            ),
                                            minLines: 3,
                                            maxLines: 5,
                                            onChanged: (value) {
                                              setState(() {
                                                isComposing = value.isNotEmpty;
                                              });
                                            },
                                            onSubmitted: (value) {
                                              if (value.isNotEmpty) {
                                                context.read<TodoBloc>().add(AddTodo(value));
                                                Navigator.pop(context);
                                              }
                                            },
                                          ),
                                        ),
                                        if (isComposing) ...[
                                          AnimatedContainer(
                                            duration: const Duration(milliseconds: 200),
                                            height: 1,
                                            margin: const EdgeInsets.symmetric(horizontal: 16),
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                colors: [
                                                  theme.colorScheme.primary.withOpacity(0.1),
                                                  theme.colorScheme.primary.withOpacity(0.05),
                                                ],
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(16),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(
                                                  Icons.straighten,
                                                  size: 16,
                                                  color: theme.colorScheme.onSurfaceVariant.withOpacity(0.7),
                                                ),
                                                const SizedBox(width: 8),
                                                Text(
                                                  '${textController.text.length} characters',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: theme.colorScheme.onSurfaceVariant.withOpacity(0.7),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                  Positioned(
                                    right: 16,
                                    top: 16,
                                    child: AnimatedOpacity(
                                      duration: const Duration(milliseconds: 200),
                                      opacity: isComposing ? 1.0 : 0.0,
                                      child: AnimatedContainer(
                                        duration: const Duration(milliseconds: 200),
                                        decoration: BoxDecoration(
                                          color: theme.colorScheme.primary.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        child: Text(
                                          'Editing',
                                          style: TextStyle(
                                            color: theme.colorScheme.primary,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              TweenAnimationBuilder<double>(
                                duration: const Duration(milliseconds: 400),
                                curve: Curves.easeOutCubic,
                                tween: Tween<double>(begin: 0, end: 1),
                                builder: (context, value, child) => Transform.scale(
                                  scale: value,
                                  child: Opacity(
                                    opacity: value,
                                    child: child,
                                  ),
                                ),
                                child: Icon(
                                  Icons.info_outline,
                                  size: 16,
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: TweenAnimationBuilder<double>(
                                  duration: const Duration(milliseconds: 400),
                                  curve: Curves.easeOutCubic,
                                  tween: Tween<double>(begin: 0, end: 1),
                                  builder: (context, value, child) => Opacity(
                                    opacity: value,
                                    child: Transform.translate(
                                      offset: Offset(8 * (1 - value), 0),
                                      child: child,
                                    ),
                                  ),
                                  child: Text(
                                    'Add a clear and specific task title',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 32),
                          TweenAnimationBuilder<double>(
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.easeOutCubic,
                            tween: Tween<double>(begin: 0, end: 1),
                            builder: (context, value, child) => Transform.translate(
                              offset: Offset(0, 16 * (1 - value)),
                              child: Opacity(
                                opacity: value,
                                child: child,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                TextButton.icon(
                                  onPressed: () => Navigator.pop(context),
                                  icon: Icon(
                                    Icons.close,
                                    size: 20,
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                  label: Text(
                                    'CANCEL',
                                    style: TextStyle(
                                      color: theme.colorScheme.onSurfaceVariant,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  style: TextButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 16,
                                    ),
                                  ),
                                ),
                                AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 200),
                                  transitionBuilder: (child, animation) => ScaleTransition(
                                    scale: animation,
                                    child: FadeTransition(
                                      opacity: animation,
                                      child: child,
                                    ),
                                  ),
                                  child: FilledButton.icon(
                                    key: ValueKey(isComposing),
                                    onPressed: isComposing
                                        ? () {
                                            context.read<TodoBloc>().add(AddTodo(textController.text));
                                            Navigator.pop(context);
                                          }
                                        : null,
                                    icon: const Icon(Icons.add),
                                    label: const Text(
                                      'ADD TASK',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    style: FilledButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 24,
                                        vertical: 16,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                    ),
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
          ),
        );
      },
    );
  }
} 