import 'package:equatable/equatable.dart';
import '../models/todo.dart';

abstract class TodoState extends Equatable {
  const TodoState();

  @override
  List<Object> get props => [];
}

class TodoInitial extends TodoState {}

class TodoLoading extends TodoState {}

class TodoLoaded extends TodoState {
  final List<Todo> todos;

  const TodoLoaded({this.todos = const []});

  @override
  List<Object> get props => [todos];

  TodoLoaded copyWith({List<Todo>? todos}) {
    return TodoLoaded(todos: todos ?? this.todos);
  }
}

class TodoError extends TodoState {
  final String message;

  const TodoError(this.message);

  @override
  List<Object> get props => [message];
} 