import 'package:get/get.dart';
import 'package:getx_todo_list/app/data/models/task.dart';
import 'package:getx_todo_list/app/data/services/storage/repository.dart';

class HomeController extends GetxController {
  TaskRepository taskRepository;
  HomeController({required this.taskRepository});

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
}
