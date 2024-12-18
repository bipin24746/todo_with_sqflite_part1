import 'package:flutter/material.dart';
import 'package:todo_with_sqflite/models/task.dart';
import 'package:todo_with_sqflite/services/database_services.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  final DatabaseService _databaseService = DatabaseService.instance;
  String? task = null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: addTaskButton(),
      body: tasksList(),
    );
  }

  Widget addTaskButton() {
    return FloatingActionButton(
      onPressed: () {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text("Add Task"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  onChanged: (value) {
                    task = value;
                  },
                ),
                MaterialButton(
                  onPressed: () async {
                    if (task == null || task!.isEmpty) return;
                    await _databaseService.addTask(task!);
                    setState(() {}); // Refresh UI
                    task = null; // Clear input
                    Navigator.pop(context);
                  },
                  child: const Text("Done"),
                ),
              ],
            ),
          ),
        );
      },
      child: const Icon(Icons.add),
    );
  }

  Widget tasksList() {
    return FutureBuilder<List<Task>>(
      future: _databaseService.getTasks(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done &&
            snapshot.hasData &&
            snapshot.data!.isNotEmpty) {
          final tasks = snapshot.data!;
          return ListView.builder(
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              final task = tasks[index];
              return ListTile(
                title: Text(task.content),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed: () => editTask(task),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () async {
                        await _databaseService.deleteTask(task.id);
                        setState(() {}); // Refresh UI
                      },
                    ),
                  ],
                ),
              );
            },
          );
        }
        return const Center(child: Text("No tasks available"));
      },
    );
  }

  void editTask(Task task) {
    String? updatedTaskContent = task.content;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Edit Task"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: TextEditingController(text: task.content),
              onChanged: (value) {
                updatedTaskContent = value;
              },
            ),
            MaterialButton(
              onPressed: () async {
                if (updatedTaskContent == null || updatedTaskContent!.isEmpty)
                  return;
                await _databaseService.updateTask(task.id, updatedTaskContent!);
                setState(() {}); // Refresh UI
                Navigator.pop(context);
              },
              child: const Text("Update"),
            ),
          ],
        ),
      ),
    );
  }
}
