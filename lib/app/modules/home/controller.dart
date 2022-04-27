import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:getx_todo_list/app/data/models/task.dart';
import 'package:getx_todo_list/app/data/services/storage/repository.dart';

class HomeController extends GetxController {
  TaskRepository taskRepository;
  HomeController({required this.taskRepository});
  final formKey = GlobalKey<FormState>();
  final editCtrl = TextEditingController();
  final chipIndex = 0.obs;
  final deleting = false.obs;
  final tasks = <Task>[].obs;
  final task = Rx<Task?>(null);
  final doingTodos = <dynamic>[].obs;
  final doneTodos = <dynamic>[].obs;

  @override
  void onInit() {
    super.onInit();
    // tasksをclearし、List<Task>をaddAllしている
    tasks.assignAll(taskRepository.readTasks());
    // 第1引数の変数が変更されるたびに第2引数の関数が実行されます。変数はobservable(obs付きで宣言)でなければならず、valueはつけません。
    ever(tasks, (_) => taskRepository.writeTasks(tasks));
  }

  @override
  void onClose() {
    editCtrl.dispose();
    super.onClose();
  }

  void changeChipIndex(int value) {
    chipIndex.value = value;
  }

  void changeDeleting(bool value) {
    deleting.value = value;
  }

  void changeTask(Task? select) {
    task.value = select;
  }

  void changeTodos(List<dynamic> select) {
    doingTodos.clear();
    doneTodos.clear();
    for (int i = 0; i < select.length; i++) {
      var todo = select[i];
      var status = todo['done'];
      if (status == true) {
        doneTodos.add(todo);
      } else {
        doingTodos.add(todo);
      }
    }
  }

  bool addTask(Task task) {
    // TaskクラスはEquatableクラスを継承している
    // propsメソッドにプロパティ（title, icon, color）を設定する
    // これらのプロパティが全て同じである場合、containsがtrueになる
    if (tasks.contains(task)) {
      return false;
    }
    tasks.add(task);
    return true;
  }

  void deleteTask(Task task) {
    tasks.remove(task);
  }

  updateTask(Task task, String title) {
    var todos = task.todos ?? [];
    if (containTodo(todos, title)) {
      return false;
    }
    // TODOリストに新たなTODOを追加
    var todo = {'title': title, 'done': false};
    todos.add(todo);
    // 新たなタスクを設定し、そのタスクが入っている要素を上書きする
    var newTask = task.copyWith(todos: todos);
    int oldIdx = tasks.indexOf(task);
    tasks[oldIdx] = newTask;
    // カスタムタイプのRxを使用してUIを参照する場合に、[value]を直接更新してStreamに追加すると便利です。
    // final person = Person(name: 'John', last: 'Doe', age: 18).obs;
    // person.value.name = 'Roi';
    // person.refresh();
    // print(person);
    tasks.refresh();
    return true;
  }

  bool containTodo(List todos, String title) {
    return todos.any((element) => element['title'] == title);
  }

  bool addTodo(String title) {
    var todo = {'title': title, 'done': false};
    if (doingTodos
        .any((element) => mapEquals<String, dynamic>(todo, element))) {
      return false;
    }
    var doneTodo = {'title': title, 'done': true};
    if (doneTodos
        .any((element) => mapEquals<String, dynamic>(doneTodo, element))) {
      return false;
    }
    doingTodos.add(todo);
    return true;
  }

  void updateTodos() {
    var newTodos = <Map<String, dynamic>>[];
    newTodos.addAll([
      ...doingTodos,
      ...doneTodos,
    ]);
    var newTask = task.value!.copyWith(todos: newTodos);
    int oldIdx = tasks.indexOf(task.value);
    tasks[oldIdx] = newTask;
    tasks.refresh();
  }

  void doneTodo(String title) {
    var doingTodo = {'title': title, 'done': false};
    int index = doingTodos.indexWhere(
        (element) => mapEquals<String, dynamic>(doingTodo, element));
    doingTodos.removeAt(index);
    var doneTodo = {'title': title, 'done': true};
    doneTodos.add(doneTodo);
    doingTodos.refresh();
    doneTodos.refresh();
  }

  void deleteDoneTodo(dynamic doneTodo) {
    int index = doneTodos
        .indexWhere((element) => mapEquals<String, dynamic>(doneTodo, element));
    doneTodos.removeAt(index);
    // class User {
    //   String name, last;
    //   int age;
    //   User({this.name, this.last, this.age});

    //   @override
    //   String toString() => '$name $last, $age years old';
    // }

    // final user = User(name: 'John', last: 'Doe', age: 33).obs;

    // `user` 自体はリアクティブですが、その中のプロパティはリアクティブではありません。
    // そのため、このようにプロパティの値を変更してもWidgetは更新されません。
    // user.value.name = 'Roi';
    // `Rx` には自ら変更を検知する手段がないからです。
    // そのため、カスタムクラスの場合はこのようにWidgetに変更を知らせる必要があります。
    // user.refresh();

    // もしくは `update()` メソッドを使用してください。
    // user.update((value){
    //   value.name='Roi';
    // });
    doneTodos.refresh();
  }

  bool isTodosEmpty(Task task) {
    return task.todos == null || task.todos!.isEmpty;
  }

  int getDoneTodo(Task task) {
    var res = 0;
    for (int i = 0; i < task.todos!.length; i++) {
      if (task.todos![i]['done'] == true) {
        res += 1;
      }
    }
    return res;
  }
}
