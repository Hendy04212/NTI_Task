import 'dart:io';
import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
class Task {
  String? createdAt;
  String? discription;
  int? id;
  String? imagePath;
  String? title;

  Task({this.createdAt, this.discription, this.id, this.imagePath, this.title});

  Task.fromJson(Map<String, dynamic> json) {
    createdAt = json['created_at'];
    discription = json['description'];
    id = json['id'];
    imagePath = json['image_path'];
    title = json['title'];
  }

  Map<String, dynamic> toJson() {
    return {
      'created_at': createdAt,
      'description': discription,
      'id': id,
      'image_path': imagePath,
      'title': title
    };
  }
}
class Menu {
  static void displayAuthMenu() {
    print('1. login');
    print('2. register');
    print('3. exit');
  }

  static void displayTasksMenu() {
    print('1. get tasks');
    print('2. add task');
    print('3. update task');
    print('4. delete task');
    print('5. exit');
    print('6. change password');
  }

  static T userInput<T>(T? Function(String input) validator) {
    while (true) {
      String input = stdin.readLineSync(encoding: utf8) ?? "";
      T? result = validator(input);
      if (result != null) {
        return result;
      }
    }
  }

  static String? validateNonEmpty(String input) {
    String v = input.trim();
    if (v.isNotEmpty) {
      return v;
    }
    return null;
  }

  static int? validatePositiveInt(String input) {
    int? v = int.tryParse(input);
    if (v != null && v > 0) {
      return v;
    }
    return null;
  }
}
class ApiClient {
  final Dio dio;

  ApiClient._internal(this.dio);

  factory ApiClient() {
    final d = Dio(BaseOptions(
      baseUrl: 'https://ntitodo-production-779a.up.railway.app/api/',
    ));
    return ApiClient._internal(d);
  }
}

class AuthService {
  final ApiClient api;

  AuthService(this.api);

  Future<Either<String, Map<String, dynamic>>> login() async {
    print("Enter username:");
    String username = Menu.userInput(Menu.validateNonEmpty);
    print("Enter password:");
    String password = Menu.userInput(Menu.validateNonEmpty);

    try {
      var loginResponse = await api.dio.post(
        'login',
        data: FormData.fromMap({
          'username': username,
          'password': password
        }),
      );
      var successResponse = loginResponse.data as Map<String, dynamic>;
      return Right(successResponse);
    } catch (e) {
      if (e is DioException) {
        var errorResponse = e.response?.data as Map<String, dynamic>?;
        return Left(errorResponse?['message'] ?? 'Unknown error');
      } else {
        return Left('An Error occurred.\nTry again later');
      }
    }
  }

  Future<Either<String, String>> register() async {
    print("Enter username:");
    String username = Menu.userInput(Menu.validateNonEmpty);
    print("Enter password:");
    String password = Menu.userInput(Menu.validateNonEmpty);

    try {
      var registerResponse = await api.dio.post(
        'register',
        data: FormData.fromMap({
          'username': username,
          'password': password
        }),
      );
      var successResponse = registerResponse.data as Map<String, dynamic>;
      return Right(successResponse['message'] ?? 'Registration successful');
    } catch (e) {
      if (e is DioException) {
        var errorResponse = e.response?.data as Map<String, dynamic>?;
        return Left(errorResponse?['message'] ?? 'Unknown error');
      } else {
        return Left('An Error occurred.\nTry again later');
      }
    }
  }

  Future<Either<String, String>> changePassword(String accessToken) async {
    print("Enter current password:");
    String currentPassword = Menu.userInput(Menu.validateNonEmpty);

    print("Enter new password:");
    String newPassword = Menu.userInput(Menu.validateNonEmpty);

    print("Confirm new password:");
    String confirmPassword = Menu.userInput(Menu.validateNonEmpty);

    if (newPassword != confirmPassword) {
      return Left("New password and confirmation do not match");
    }

    try {
      var response = await api.dio.post(
        'change_password',
        data: FormData.fromMap({
          'current_password': currentPassword,
          'new_password': newPassword,
          'new_password_confirm': confirmPassword
        }),
        options: Options(
          headers: {
            'Authorization': 'Bearer $accessToken'
          },
        ),
      );
      if (response.statusCode == 204) {
        return Right("Password changed successfully");
      }
      if (response.data is String) {
        return Right(response.data);
      }
      if (response.data is Map<String, dynamic>) {
        var map = response.data as Map<String, dynamic>;
        return Right(map['message'] ?? "Password changed successfully");
      }

      return Right("Password changed successfully");
    } catch (e) {
      if (e is DioException) {
        var err = e.response?.data;

        if (err is String) {
          return Left(err);
        }

        if (err is Map<String, dynamic>) {
          return Left(err['message'] ?? "Unknown error");
        }

        return Left("Unknown error");
      } else {
        return Left("An Error occurred.\nTry again later");
      }
    }
  }
}

class TaskService {
  final ApiClient api;

  TaskService(this.api);

  Future<Either<String, List<Task>>> getTasks(String accessToken) async {
    try {
      var response = await api.dio.get(
        'my_tasks',
        options: Options(
          headers: {
            'Authorization': 'Bearer $accessToken'
          },
        ),
      );
      var tasksResponse = response.data as Map<String, dynamic>;
      List<Task> tasks = [];
      for (var taskJson in tasksResponse['tasks']) {
        tasks.add(Task.fromJson(taskJson));
      }
      return Right(tasks);
    } catch (e) {
      if (e is DioException) {
        var errorResponse = e.response?.data as Map<String, dynamic>?;
        return Left(errorResponse?['message'] ?? 'Unknown error');
      } else {
        return Left('An Error occurred.\nTry again later');
      }
    }
  }

  Future<Either<String, String>> addTask(String accessToken) async {
    print('Enter title:');
    String newTitle = Menu.userInput(Menu.validateNonEmpty);
    print('Enter description:');
    String newDescription = Menu.userInput(Menu.validateNonEmpty);

    try {
      var addResponse = await api.dio.post(
        'new_task',
        data: FormData.fromMap({
          'title': newTitle,
          'description': newDescription,
        }),
        options: Options(
          headers: {
            'Authorization': 'Bearer $accessToken'
          },
        ),
      );
      var response = addResponse.data as Map<String, dynamic>;
      return Right(response['message'] ?? 'Task created successfully');
    } catch (e) {
      if (e is DioException) {
        var errorResponse = e.response?.data as Map<String, dynamic>?;
        return Left(errorResponse?['message'] ?? 'Unknown error');
      } else {
        return Left('An Error occurred.\nTry again later');
      }
    }
  }

  Future<Either<String, Map<String, dynamic>>> updateTask(String accessToken) async {
    print('Enter task ID to update:');
    int taskId = Menu.userInput(Menu.validatePositiveInt);
    print('Enter new title:');
    String newTitle = Menu.userInput(Menu.validateNonEmpty);
    print('Enter new description:');
    String newDescription = Menu.userInput(Menu.validateNonEmpty);

    try {
      var updateResponse = await api.dio.put(
        'tasks/$taskId',
        data: FormData.fromMap({
          'title': newTitle,
          'description': newDescription
        }),
        options: Options(
          headers: {
            'Authorization': 'Bearer $accessToken'
          },
        ),
      );
      return Right(updateResponse.data as Map<String, dynamic>);
    } catch (e) {
      if (e is DioException) {
        var errorResponse = e.response?.data as Map<String, dynamic>?;
        return Left(errorResponse?['message'] ?? 'Unknown error');
      } else {
        return Left('An Error occurred.\nTry again later');
      }
    }
  }

  Future<Either<String, String>> deleteTask(String accessToken) async {
    print('Enter task ID to delete:');
    int taskId = Menu.userInput(Menu.validatePositiveInt);

    try {
      var res = await api.dio.delete(
        'tasks/$taskId',
        options: Options(
          headers: {
            'Authorization': 'Bearer $accessToken'
          },
        ),
      );
      if (res.statusCode == 204) {
        return Right('Task deleted successfully');
      }
      var map = res.data as Map<String, dynamic>?;
      return Right(map?['message'] ?? 'Task deleted successfully');
    } catch (e) {
      if (e is DioException) {
        var errorResponse = e.response?.data as Map<String, dynamic>?;
        return Left(errorResponse?['message'] ?? 'Unknown error');
      } else {
        return Left('An Error occurred.\nTry again later');
      }
    }
  }
}
class App {
  final AuthService authService;
  final TaskService taskService;

  App({
    required this.authService,
    required this.taskService,
  });

  Future<Map<String, dynamic>> auth() async {
    Map<String, dynamic> userData = {};
    while (true) {
      Menu.displayAuthMenu();
      int authChoice = Menu.userInput((String input) {
        int? choice = int.tryParse(input);
        if (choice != null) {
          if (choice >= 1 && choice <= 3) {
            return choice;
          }
        }
        return null;
      });

      if (authChoice == 1) {
        var result = await authService.login();
        bool loggedInFlag = false;
        result.fold(
          (String errorMsg) {
            print("Login Failed: $errorMsg");
          },
          (Map<String, dynamic> userResponse) {
            loggedInFlag = true;
            userData = userResponse;
          },
        );
        if (loggedInFlag == true) {
          print("Login successful");
          break;
        }
      } else if (authChoice == 2) {
        var result = await authService.register();
        result.fold(
          (String errorMsg) {
            print("Registration Failed: $errorMsg");
          },
          (String successMsg) {
            print(successMsg);
          },
        );
      } else if (authChoice == 3) {
        print("See you later!");
        exit(0);
      }
    }
    return userData;
  }

  Future<void> run() async {
    stdout.encoding = utf8;

    Map<String, dynamic> userData = await auth();
    print(userData.toString());

    while (true) {
      Menu.displayTasksMenu();
      int mainChoice = Menu.userInput((String input) {
        int? choice = int.tryParse(input);
        if (choice != null) {
          if (choice >= 1 && choice <= 6) {
            return choice;
          }
        }
        return null;
      });

      if (mainChoice == 1) {
        var tasksResponse = await taskService.getTasks(userData['access_token']);
        tasksResponse.fold((String errorMsg) {
          print("Failed to fetch tasks: $errorMsg");
        }, (List<Task> tasks) {
          if (tasks.isEmpty) {
            print('No tasks yet.');
          } else {
            for (var task in tasks) {
             print("-------------------------");
print("Task ID     : ${task.id}");
print("Title       : ${task.title}");
print("Description : ${task.discription}");
print("Image Path  : ${task.imagePath ?? '(none)'}");
print("Created At  : ${task.createdAt}");
print("-------------------------");
            }
          }
        });
      } else if (mainChoice == 2) {
        var addTaskResponse = await taskService.addTask(userData['access_token']);
        addTaskResponse.fold((String errorMsg) {
          print("Failed to add task: $errorMsg");
        }, (String successMsg) {
          print(successMsg);
        });
      } else if (mainChoice == 3) {
        var updateTaskResponse = await taskService.updateTask(userData['access_token']);
        updateTaskResponse.fold((String errorMsg) {
          print("Failed to update task: $errorMsg");
        }, (Map<String, dynamic> updatedTask) {
          print(updatedTask.toString());
        });
      } else if (mainChoice == 4) {
        var deleteResp = await taskService.deleteTask(userData['access_token']);
        deleteResp.fold(
          (err) => print('Failed to delete task: $err'),
          (msg) => print(msg),
        );
      } else if (mainChoice == 5) {
        print("See you later!");
        exit(0);
      } else if (mainChoice == 6) {
        final result = await authService.changePassword(userData['access_token']);
        result.fold(
          (err) => print("Password Change Failed: $err"),
          (msg) => print(msg),
        );
      } else {
        print("Invalid choice, try again.");
      }
    }
  }
}
void main() async {
  final api = ApiClient();
  final authService = AuthService(api);
  final taskService = TaskService(api);

  final app = App(authService: authService, taskService: taskService);
  await app.run();
}