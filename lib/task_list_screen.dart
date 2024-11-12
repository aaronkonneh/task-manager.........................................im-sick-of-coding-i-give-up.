// task_list_screen.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_screen.dart';
import 'task.dart';

class TaskListScreen extends StatefulWidget {
  @override
  _TaskListScreenState createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _taskController = TextEditingController();

  // Method to add a task to Firestore
  void _addTask(String taskName) async {
    if (taskName.isNotEmpty) {
      await _firestore.collection('tasks').add({
        'name': taskName,
        'isComplete': false,
      });
      _taskController.clear();
    }
  }

  // Method to toggle task completion status
  void _toggleComplete(String taskId, bool isComplete) {
    _firestore
        .collection('tasks')
        .doc(taskId)
        .update({'isComplete': !isComplete});
  }

  // Method to delete a task from Firestore
  void _deleteTask(String taskId) {
    _firestore.collection('tasks').doc(taskId).delete();
  }

  // Sign-Out
  Future<void> _signOut() async {
    await _auth.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    User? user = _auth.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text('Task Manager'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: _signOut,
          ),
        ],
      ),
      body: user == null
          ? Center(child: CircularProgressIndicator())
          : _buildTaskManagerUI(),
    );
  }

  Widget _buildTaskManagerUI() {
    return Column(
      children: [
        _buildAddTaskField(),
        Expanded(child: _buildTaskList()),
      ],
    );
  }

  Widget _buildAddTaskField() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _taskController,
              decoration: InputDecoration(labelText: 'Enter task name'),
            ),
          ),
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () => _addTask(_taskController.text),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskList() {
    return StreamBuilder(
      stream: _firestore.collection('tasks').snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error loading tasks.'));
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text('No tasks available.'));
        }

        final tasks = snapshot.data!.docs.map((doc) {
          return Task.fromMap(doc.data() as Map<String, dynamic>, doc.id);
        }).toList();

        return ListView.builder(
          itemCount: tasks.length,
          itemBuilder: (context, index) {
            final task = tasks[index];
            return ListTile(
              leading: Checkbox(
                value: task.isComplete,
                onChanged: (_) => _toggleComplete(task.id, task.isComplete),
              ),
              title: Text(task.name),
              trailing: IconButton(
                icon: Icon(Icons.delete),
                onPressed: () => _deleteTask(task.id),
              ),
            );
          },
        );
      },
    );
  }
}
