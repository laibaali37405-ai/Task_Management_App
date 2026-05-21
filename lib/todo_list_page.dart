import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

import 'add_task_page.dart';
import 'task_status_page.dart';

class TodoListPage extends StatelessWidget {
  const TodoListPage({super.key});

  // STATUS UPDATE FUNCTION
  void _updateTaskStatus(String docId, String newStatus) {
    FirebaseFirestore.instance.collection('tasks').doc(docId).update({
      'status': newStatus,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SizedBox.expand(
            child: Image.asset("assets/images/assets2.png", fit: BoxFit.cover),
          ),

          SafeArea(
            child: Column(
              children: [
                _buildAppBar(context),

                Expanded(
                  child: StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection('tasks')
                        .where(
                          'uid',
                          isEqualTo: FirebaseAuth.instance.currentUser?.uid,
                        )
                        .where('status', isEqualTo: 'To-do')
                        .snapshots(),

                    builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      var docs = snapshot.data!.docs;

                      if (docs.isEmpty) {
                        return const Center(
                          child: Text(
                            "No tasks added yet!",
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                        );
                      }

                      return ListView.builder(
                        padding: const EdgeInsets.all(20),

                        itemCount: docs.length,

                        itemBuilder: (context, index) {
                          return _buildTaskTile(context, docs[index]);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.deepPurple,

        child: const Icon(Icons.add, color: Colors.white, size: 30),

        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const add_task_page()),
        ),
      ),
    );
  }

  Widget _buildTaskTile(BuildContext context, QueryDocumentSnapshot task) {
    DateTime date = (task['dueDate'] as Timestamp).toDate();

    String formattedDate = DateFormat('dd MMM').format(date);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),

      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),

      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),

        borderRadius: BorderRadius.circular(20),

        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
        ],
      ),

      child: Row(
        children: [
          // TO IN PROGRESS
          IconButton(
            icon: const Icon(
              Icons.radio_button_off,
              color: Colors.orangeAccent,
            ),

            tooltip: "Move to Progress",

            onPressed: () {
              _updateTaskStatus(task.id, 'In Progress');

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Task moved to In Progress")),
              );
            },
          ),

          // TASK INFO
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Text(
                  task['title'],

                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                Text(
                  "Due: $formattedDate",

                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),

          // DIRECT COMPLETE
          IconButton(
            icon: const Icon(Icons.check_circle_outline, color: Colors.green),

            tooltip: "Mark as Completed",

            onPressed: () {
              _updateTaskStatus(task.id, 'Complete');

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Task marked as Completed")),
              );
            },
          ),

          // DELETE
          IconButton(
            icon: const Icon(
              Icons.delete_outline,
              color: Colors.redAccent,
              size: 20,
            ),

            onPressed: () {
              FirebaseFirestore.instance
                  .collection('tasks')
                  .doc(task.id)
                  .delete();

              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text("Task deleted")));
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),

      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,

        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios_new,
                  color: Colors.deepPurple,
                ),

                onPressed: () => Navigator.pop(context),
              ),

              const Text(
                "To-Do List",

                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ],
          ),

          // GO TO PROGRESS PAGE
          IconButton(
            icon: const Icon(Icons.history, color: Colors.deepPurple),

            onPressed: () {
              Navigator.push(
                context,

                MaterialPageRoute(
                  builder: (context) =>
                      const TaskStatusPage(statusTitle: "In Progress"),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
