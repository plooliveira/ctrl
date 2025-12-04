import 'package:example_playground/data/repositories/todo_repository.dart';
import 'package:ctrl/ctrl.dart';

enum TodosFilter { all, active, completed }

class TodosController with Ctrl {
  late final TodoRepository _repository;

  TodosController(TodoRepository repo) : _repository = repo;

  late final allTodos = _repository.todos.live;

  late final _currentFilter = mutable(TodosFilter.all);
  Observable<TodosFilter> get currentFilter => _currentFilter;

  late final filteredTodos = scope.join([_currentFilter, allTodos], () {
    final filter = _currentFilter.value;
    final list = allTodos.value;

    switch (filter) {
      case TodosFilter.all:
        return list;
      case TodosFilter.active:
        return list.where((t) => !t.completed).toList();
      case TodosFilter.completed:
        return list.where((t) => t.completed).toList();
    }
  });

  late final activeCount = allTodos.transform(
    (todos) => todos.value.where((t) => !t.completed).length,
  );

  late final completedCount = allTodos.transform(
    (todos) => todos.value.where((t) => t.completed).length,
  );

  void toggleTodo(int id) => _repository.toggle(id);

  void deleteTodo(int id) => _repository.delete(id);

  void setFilter(TodosFilter filter) => _currentFilter.value = filter;

  void clearCompleted() => _repository.deleteCompleted();

  @override
  void dispose() {
    _repository.dispose();
    super.dispose();
  }
}
