import 'package:ctrl/ctrl.dart';
import '../../../data/repositories/todo_repository.dart';

class AddTodoController with Ctrl {
  late final TodoRepository _repository;

  AddTodoController(TodoRepository repository) : _repository = repository;

  void addTodo(String title) {
    if (title.trim().isEmpty) return;
    _repository.add(title.trim());
  }

  @override
  void dispose() {
    _repository.dispose();
    super.dispose();
  }
}
