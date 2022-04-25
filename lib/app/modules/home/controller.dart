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
  final tasks = <Task>[].obs;

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
    super.onClose();
  }

  void changeChipIndex(int value) {
    chipIndex.value = value;
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
}
