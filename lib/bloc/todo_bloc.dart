import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import '../models/todo.dart';
import 'todo_event.dart';
import 'todo_state.dart';

class TodoBloc extends Bloc<TodoEvent, TodoState> {
  final Box<Todo> todoBox;

  TodoBloc({required this.todoBox}) : super(TodoInitial()) {
    on<LoadTodos>(_onLoadTodos);
    on<AddTodo>(_onAddTodo);
    on<UpdateTodo>(_onUpdateTodo);
    on<DeleteTodo>(_onDeleteTodo);
    on<ToggleTodo>(_onToggleTodo);
  }

  void _onLoadTodos(LoadTodos event, Emitter<TodoState> emit) {
    emit(TodoLoading());
    try {
      final todos = todoBox.values.toList();
      emit(TodoLoaded(todos: todos));
    } catch (e) {
      emit(TodoError(e.toString()));
    }
  }

  void _onAddTodo(AddTodo event, Emitter<TodoState> emit) async {
    final state = this.state;
    if (state is TodoLoaded) {
      try {
        final todo = Todo(title: event.title);
        await todoBox.put(todo.id, todo);
        emit(TodoLoaded(todos: todoBox.values.toList()));
      } catch (e) {
        emit(TodoError(e.toString()));
      }
    }
  }

  void _onUpdateTodo(UpdateTodo event, Emitter<TodoState> emit) async {
    final state = this.state;
    if (state is TodoLoaded) {
      try {
        await todoBox.put(event.todo.id, event.todo);
        emit(TodoLoaded(todos: todoBox.values.toList()));
      } catch (e) {
        emit(TodoError(e.toString()));
      }
    }
  }

  void _onDeleteTodo(DeleteTodo event, Emitter<TodoState> emit) async {
    final state = this.state;
    if (state is TodoLoaded) {
      try {
        await todoBox.delete(event.todo.id);
        emit(TodoLoaded(todos: todoBox.values.toList()));
      } catch (e) {
        emit(TodoError(e.toString()));
      }
    }
  }

  void _onToggleTodo(ToggleTodo event, Emitter<TodoState> emit) async {
    final state = this.state;
    if (state is TodoLoaded) {
      try {
        final updatedTodo = event.todo.copyWith(
          isCompleted: !event.todo.isCompleted,
        );
        await todoBox.put(event.todo.id, updatedTodo);
        emit(TodoLoaded(todos: todoBox.values.toList()));
      } catch (e) {
        emit(TodoError(e.toString()));
      }
    }
  }
} 